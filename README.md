# chmsflow <img src="man/figures/logo.svg" alt="chmsflow logo" align="right" width="180"/>

<!-- badges: start -->

[![Lifecycle: development](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable-1) [![](https://img.shields.io/cran/v/chmsflow?color=green)](https://CRAN.R-project.org/package=chmsflow) ![](https://img.shields.io/github/v/release/big-life-lab/chmsflow?color=green&label=GitHub) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![](https://cranlogs.r-pkg.org/badges/chmsflow)](https://cran.r-project.org/package=chmsflow) [![R-CMD-check](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Big-Life-Lab/chmsflow/actions/workflows/R-CMD-check.yaml)

<!-- badges: end -->

`chmsflow` harmonizes variables from the Canadian Health Measures Survey (CHMS) across cycles 1--6 (2007--2019), producing consistent, analysis-ready datasets.

```r
library(chmsflow)

# Harmonize ethnicity from cycle 3 in one call
cycle3_ethnicity <- recodeflow::rec_with_table(
  cycle3, "pgdcgt",
  variable_details = variable_details
)
```

## Installation

```r
# Install from CRAN
install.packages("chmsflow")

# Install from GitHub
devtools::install_github("Big-Life-Lab/chmsflow")
```

For use at a Research Data Centre (RDC), see `vignette("using_chmsflow_at_an_rdc")`.

## Documentation

- **Tutorial** -- [Analysis walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.html): end-to-end hypertension prevalence using cycles 3--6
- **How-to guides** -- [Recoding medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.html), [Using chmsflow at an RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.html), [Adding variables](https://big-life-lab.github.io/chmsflow/articles/how_to_add_variables.html)
- **Explanation** -- [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.html), [Missing data (tagged NA)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.html), [Derived variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.html)
- **Reference** -- [Variable schema](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.html), [Function reference](https://big-life-lab.github.io/chmsflow/reference/index.html)

## Contributing

Contributions are welcome -- see the [contributing guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md).

## Statistics Canada attribution

The dummy data included in this package is for illustrative purposes only and does not contain any real data from Statistics Canada.

This package is adapted from Statistics Canada, Canadian Health Measures Survey Cycles 1--6 (2007 to 2019), accessed June 2023. This does not constitute an endorsement by Statistics Canada of this product.
