## Test environments

- Local macOS (Apple Silicon), R 4.4.2
- GitHub Actions:
  - macOS-latest, R-release
  - windows-latest, R-release
  - ubuntu-latest, R-devel
  - ubuntu-latest, R-release
  - ubuntu-latest, R-oldrel-1
- win-builder (R-devel): _TO BE FILLED IN AT STAGE 7 SUBMISSION TIME_
- R-hub (linux-devel): _TO BE FILLED IN AT STAGE 7 SUBMISSION TIME_

## R CMD check results

0 errors | 0 warnings | 0 notes on the GitHub Actions matrix
(Status: OK on macOS-latest, windows-latest, and ubuntu-latest for
R-devel / R-release / R-oldrel-1).

CRAN's incoming-feasibility check is expected to add a single NOTE:

* **New submission.** This is the first CRAN release of chmsflow.

## Downstream dependencies

This is a new submission; there are no reverse dependencies.

The package's strong dependencies are dplyr, haven, purrr, and recodeflow.
All four are on CRAN.
