# chmsflow

`chmsflow` harmonizes variables from the Canadian Health Measures Survey
(CHMS) across cycles 1–6 (2007–2019), producing consistent,
analysis-ready datasets.

``` r

library(chmsflow)

# Harmonize ethnicity from cycle 3 in one call
cycle3_ethnicity <- recodeflow::rec_with_table(
  cycle3, "pgdcgt",
  variable_details = variable_details
)
```

## Installation

``` r

# Install from CRAN
install.packages("chmsflow")

# Install from GitHub
devtools::install_github("Big-Life-Lab/chmsflow")
```

For use at a Research Data Centre (RDC), see
[`vignette("using_chmsflow_at_an_rdc")`](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md).

## Documentation

- **Tutorial** – [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md):
  end-to-end hypertension prevalence using cycles 3–6
- **How-to guides** – [Recoding
  medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md),
  [Using chmsflow at an
  RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md),
  [Adding
  variables](https://big-life-lab.github.io/chmsflow/articles/how_to_add_variables.md)
- **Explanation** –
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md),
  [Missing data (tagged
  NA)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md),
  [Derived
  variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.md)
- **Reference** – [Variable
  schema](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md),
  [Function
  reference](https://big-life-lab.github.io/chmsflow/reference/index.md)

## Contributing

Contributions are welcome – see the [contributing
guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md).

## Statistics Canada attribution

The dummy data included in this package is for illustrative purposes
only and does not contain any real data from Statistics Canada.

This package is adapted from Statistics Canada, Canadian Health Measures
Survey Cycles 1–6 (2007 to 2019), accessed June 2023. This does not
constitute an endorsement by Statistics Canada of this product.
