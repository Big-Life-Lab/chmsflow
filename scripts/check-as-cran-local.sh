#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${CHMSFLOW_CHECK_DIR:-"$ROOT/.tmp/check"}"
R_BIN="${R_BIN:-R}"
RSCRIPT_BIN="${RSCRIPT_BIN:-Rscript}"

mkdir -p "$OUT_DIR"

# Avoid renv autoload hangs in non-interactive package tooling. We still expose
# the normal library paths explicitly so R CMD check can see Suggests packages.
export RENV_CONFIG_AUTOLOADER_ENABLED="${RENV_CONFIG_AUTOLOADER_ENABLED:-false}"
R_LIBS_DETECTED="$("$RSCRIPT_BIN" --vanilla -e 'cat(paste(.libPaths(), collapse = .Platform$path.sep))')"
export R_LIBS="${R_LIBS:-$R_LIBS_DETECTED}"

if [[ "${1:-}" == "--doctor" ]]; then
  echo "R: $("$R_BIN" --version | head -n 1)"
  echo "R_LIBS: $R_LIBS"
  echo "RENV_CONFIG_AUTOLOADER_ENABLED: $RENV_CONFIG_AUTOLOADER_ENABLED"
  "$RSCRIPT_BIN" --vanilla -e 'pkgs <- c("DT", "kableExtra", "knitr", "processx", "quarto", "testthat"); for (pkg in pkgs) cat(pkg, ": ", requireNamespace(pkg, quietly = TRUE), "\n", sep = "")'
  if command -v quarto >/dev/null 2>&1; then
    echo "quarto CLI: $(quarto --version)"
  else
    echo "quarto CLI: not found on PATH"
  fi
  exit 0
fi

BUILD_LOG="$OUT_DIR/build.log"
CHECK_LOG="$OUT_DIR/check.log"
RUN_LOG="$OUT_DIR/run.log"

{
  echo "=== local as-cran run: $(date) ==="
  echo "root: $ROOT"
  echo "out: $OUT_DIR"
  echo "R: $("$R_BIN" --version | head -n 1)"
  echo "R_LIBS: $R_LIBS"
  echo "RENV_CONFIG_AUTOLOADER_ENABLED: $RENV_CONFIG_AUTOLOADER_ENABLED"
} > "$RUN_LOG"

rm -rf "$OUT_DIR"/*.Rcheck "$OUT_DIR"/chmsflow_*.tar.gz

echo "Building source package..."
(
  cd "$OUT_DIR"
  "$R_BIN" CMD build "$ROOT"
) > "$BUILD_LOG" 2>&1

TARBALL="$(ls -t "$OUT_DIR"/chmsflow_*.tar.gz | head -n 1)"
echo "tarball: $TARBALL" >> "$RUN_LOG"

echo "Checking source package --as-cran..."
set +e
(
  cd "$OUT_DIR"
  "$R_BIN" CMD check --as-cran "$(basename "$TARBALL")"
) > "$CHECK_LOG" 2>&1
STATUS=$?
set -e

echo "exit_code: $STATUS" >> "$RUN_LOG"

CHECK_DIR="$(find "$OUT_DIR" -maxdepth 1 -type d -name '*.Rcheck' | head -n 1)"
if [[ -n "$CHECK_DIR" && -f "$CHECK_DIR/00check.log" ]]; then
  grep -E '^Status:|ERROR|WARNING|NOTE' "$CHECK_DIR/00check.log" | tail -n 20 || true
else
  tail -n 40 "$CHECK_LOG" || true
fi

echo "Logs:"
echo "  $BUILD_LOG"
echo "  $CHECK_LOG"
echo "  $RUN_LOG"

exit "$STATUS"
