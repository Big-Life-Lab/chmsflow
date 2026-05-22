# AGENTS.md

This file provides guidance to AI coding agents (Claude, Codex, GitHub
Copilot, and similar) working in this repository.

## What this package does

`chmsflow` is an R package that harmonizes Canadian Health Measures
Survey (CHMS) variables across Cycles 1–6 (2007–2019). Variable names,
codings, and survey methodology drift between cycles; this package
produces analysis-ready, consistent variables.

It depends on the broader **recodeflow** ecosystem (sibling:
`cchsflow`). Most recoding behaviour is **data-driven** — defined in
CSVs, not code — and consumed at runtime by
[`recodeflow::rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).

## Common commands

This is a standard R package using **renv** for dependencies and
**testthat** for tests.

``` r

# Setup after clone
renv::restore()
devtools::install()

# Iterate
devtools::load_all()                 # load without installing
devtools::document()                 # regenerate man/ + NAMESPACE from roxygen
devtools::test()                     # run all tests
testthat::test_file("tests/testthat/test-alcohol.R")  # single test file
devtools::check()                    # full R CMD check (CI parity)

# Lint / style (matches CI)
lintr::lint_package()
styler::style_pkg()

# Rebuild bundled .rda data after editing CSVs in inst/extdata or data-raw/
source("data-raw/prep-dummy-data.R")

# Vignettes (built with Quarto, not knitr)
quarto::quarto_render("vignettes/get_started.qmd")

# pkgdown site (output to docs/)
pkgdown::build_site()
```

R floor is **R \>= 4.0** (DESCRIPTION). `.Rprofile` warns if below.

## Architecture

The package has two co-equal “sources of truth” that need to stay in
sync:

### 1. Metadata CSVs — `inst/extdata/`

- **`variables.csv`** — one row per harmonized variable. Key columns:
  `variable`, `databaseStart` (which cycles it applies to),
  `variableStart` (how to find it in each cycle).
- **`variable-details.csv`** — one row per recode rule. Specifies how
  raw values map to harmonized values (per cycle), including category
  labels and tagged-NA missing codes.

These are read by
`recodeflow::rec_with_table(data, "variable_name", variable_details = variable_details)`.
They are also bundled as lazy-loaded datasets (`data(variables)`,
`data(variable_details)`) via `data-raw/prep-dummy-data.R`.

**`variableStart` format conventions** (recodeflow standard, documented
in `inst/metadata/`): - `[varname]` — same name across all cycles -
`cycle1::var1, [var2]` — mixed: `cycle1` uses `var1`, all other cycles
default to `var2` (the bracketed value is the **default**) -
`database::varname` — explicit per-cycle name when it varies -
`DerivedVar::[var1, var2]` — variable is computed from others by an R
function (named in `recEnd` as `Func::function_name`)

**Range notation in `recStart`/`recEnd`**: `[7,9]` (inclusive),
`[18.5,25)` (half-open), `else` (catch-all).

CHMS-specific quirk: **Cycle 1 (2007-2009) often uses different variable
names** than Cycles 2-6 (e.g., `amsdmva1` vs `ammdmva1`), which is why
mixed format exists.

### 2. Derived-variable functions — `R/`

When `variable-details.csv` references `Func::name`, that R function
lives in `R/` and is exported via NAMESPACE. Files are organized by
health domain:

`alcohol.R`, `blood-pressure.R`, `cholesterol-and-obesity.R`,
`diabetes.R`, `diet.R`, `exercise.R`, `family-history.R`, `income.R`,
`kidney.R`, `smoking.R`, plus `data.R` for dataset documentation.

Medication code is split across three files because of its scale and the
per-cycle ATC handling:

- `medications-predicates.R` — `is_atc_class()` helper and the eight
  scalar ATC predicates
  ([`is_ace_inhibitor()`](https://big-life-lab.github.io/chmsflow/reference/is_ace_inhibitor.md),
  [`is_beta_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_beta_blocker.md),
  [`is_calcium_channel_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_calcium_channel_blocker.md),
  [`is_diuretic()`](https://big-life-lab.github.io/chmsflow/reference/is_diuretic.md),
  [`is_diabetes_med()`](https://big-life-lab.github.io/chmsflow/reference/is_diabetes_med.md),
  [`is_nsaid()`](https://big-life-lab.github.io/chmsflow/reference/is_nsaid.md),
  [`is_any_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_any_antihtn_med.md),
  [`is_other_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_other_antihtn_med.md))
- `medications-cycles1to2.R` — `is_atc_class_cycles1to2()` helper and
  the eight cycles 1–2 wrapper functions; each wrapper preserves its
  80-argument signature because that signature is load-bearing for the
  `DerivedVar::` metadata contract in `variable-details.csv`
- `medications-recode.R` — the four DB wrappers
  ([`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md),
  [`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md),
  [`aggregate_meds_by_person()`](https://big-life-lab.github.io/chmsflow/reference/aggregate_meds_by_person.md),
  [`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md))
  plus shared internal helpers

Conventions in these functions: - Vectorised — accept scalars or vectors
of equal length - Return `haven::tagged_na("a")` for “not applicable” /
`tagged_na("b")` for “missing”; StatsCan codes 6/7/8/9 map to specific
tagged NAs - Use `logger::log_*` for diagnostics rather than
[`message()`](https://rdrr.io/r/base/message.html)/[`warning()`](https://rdrr.io/r/base/warning.html) -
Documented with roxygen2 (markdown enabled — see
`Roxygen: list(markdown = TRUE)` in DESCRIPTION)

### 3. Bundled dummy data — `data/*.rda`

`cycle1`–`cycle6` and `cycle1_meds`–`cycle6_meds` are **synthetic** (not
real CHMS data). Generated by `data-raw/prep-dummy-data.R`. Used for
examples, tests, and vignettes. Real CHMS data is only available inside
StatsCan Research Data Centres.

### 4. Schema documentation — `inst/metadata/`

YAML files documenting recodeflow conventions and CHMS-specific
observations. **Not loaded at runtime** — these are reference/validation
specs anticipating a future migration to the recodeflow package
architecture. See `inst/metadata/README.md` for the distinction between
universal recodeflow conventions and CHMS-specific patterns.

### 5. Vignettes — `vignettes/*.qmd`

Built with **Quarto** (`VignetteBuilder: quarto`), not knitr/Rmd. The
`_quarto.yml` at repo root sets `freeze: auto` so unchanged vignettes
don’t rebuild. `_freeze/` caches outputs and is checked in.

The vignette set follows the [Divio documentation
system](https://docs.divio.com/documentation-system/):

- Tutorial: `analysis_walkthrough.qmd` (end-to-end hypertension
  prevalence example)
- How-to: `recoding_medications.qmd`, `using_chmsflow_at_an_rdc.qmd`,
  `how_to_add_variables.qmd`
- Explanation: `methodology.qmd`, `derived_variables.qmd`,
  `tagged_na_usage.qmd`
- Reference: `variables_and_variable_details.qmd`
- Orientation: `get_started.qmd`

## Adding or modifying a harmonized variable

1.  Add/edit row(s) in `inst/extdata/variables.csv` and
    `inst/extdata/variable-details.csv`.
2.  If it’s a derived variable, add the `Func::name` function in the
    appropriate `R/<domain>.R` file with `@export` and roxygen docs.
3.  Re-run `data-raw/prep-dummy-data.R` to refresh `data/variables.rda`
    and `data/variable_details.rda`.
4.  Run `devtools::document()` to regenerate `man/`.
5.  Add a `tests/testthat/test-<domain>.R` test (one per domain file
    already exists).
6.  If user-visible, add a bullet to `NEWS.md`.

## CI

GitHub Actions (`.github/workflows/`): - `R-CMD-check.yaml` — full check
on macOS / Windows / Ubuntu (devel, release, oldrel-1) - `lint.yaml` —
lintr (config in `.lintr` — line length, object naming, cyclocomp limit
100, etc. relaxed) - `style.yaml` — styler (auto-commits style fixes
back to the branch) - `test-coverage.yaml` — covr - `pkgdown.yaml` —
site deploy to `docs/`

## CSV editing safety

**Never use sed/awk/perl on `inst/extdata/*.csv`** — use R
(`read.csv`/`write.csv` or `readr`). The `variableStart` and `recStart`
columns contain commas inside quoted strings; bash text tools will
corrupt them.

## Repo conventions

- Commits should be reviewed before being made; commit messages are
  plain text and do not include AI attribution.
