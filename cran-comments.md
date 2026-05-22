## Test environments

- Local macOS (Apple Silicon), R 4.4.2
- GitHub Actions:
  - macOS-latest, R-release
  - windows-latest, R-release
  - ubuntu-latest, R-devel
  - ubuntu-latest, R-release
  - ubuntu-latest, R-oldrel-1
- win-builder (R-devel, 2026-05-19 r90065 ucrt): 0 errors | 0 warnings | 1 NOTE
  (CRAN incoming feasibility — "New submission" plus two flagged words
  that are not misspelled: see below)

## R CMD check results

0 errors | 0 warnings | 0 notes on the GitHub Actions matrix
(Status: OK on macOS-latest, windows-latest, and ubuntu-latest for
R-devel / R-release / R-oldrel-1).

CRAN's incoming-feasibility check produces a single NOTE (confirmed via
win-builder R-devel):

* **New submission.** This is the first CRAN release of chmsflow.

* **Possibly misspelled words in DESCRIPTION.** CRAN's spell-checker
  flags "CHMS" (the Canadian Health Measures Survey acronym used
  throughout the package) and "Ludecke" (the surname of the author
  cited for the sjmisc package). Both are intentional and correct.

## Downstream dependencies

This is a new submission; there are no reverse dependencies.

The package's strong dependencies are dplyr, haven, purrr, and recodeflow.
All four are on CRAN.
