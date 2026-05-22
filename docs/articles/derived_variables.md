# Derived variables

``` r

library(chmsflow)
```

## Introduction

There are two types of derived variables in the CHMS surveys. Both are
supported in chmsflow.

- **Variable mapping** – mapping two or more variables into a single
  variable.
- **Computed variables** – variables derived using mathematical
  equations or clinical logic.

chmsflow computes derived variables using functions referenced in
`variable-details.csv`. The `recEnd` column uses the prefix `Func::` to
name the R function, and the `variableStart` column uses the prefix
`DerivedVar::` to list the input variables.

For example, GFR (`gfr_ml_min`) has:

- `recEnd`: `Func::calculate_gfr`
- `variableStart`: `DerivedVar::[lab_bcre, pgdcgt, clc_sex, clc_age]`

This tells
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
to call
[`calculate_gfr()`](https://big-life-lab.github.io/chmsflow/reference/calculate_gfr.md)
with the four input variables.

## How to use derived variables

Since derived variables depend on their input variables, you must list
both the derived variable and its inputs when calling
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html):

``` r

cycle2_gfr <- recodeflow::rec_with_table(
  cycle2,
  variables = c("lab_bcre", "pgdcgt", "clc_sex", "clc_age", "gfr_ml_min"),
  variable_details = variable_details,
  log = TRUE
)
```

For variables that depend on medication status (e.g., hypertension,
diabetes), use
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
instead of
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).
See [Recoding
medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)
and [Analysis
walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md)
for the full workflow.

## Creating a derived variable

To add a new derived variable to chmsflow, you need to create a
harmonized set of input variables and an R function that computes the
derived value. See [How to add
variables](https://big-life-lab.github.io/chmsflow/articles/how_to_add_variables.md)
for step-by-step instructions.

For details on the metadata schema, see [Variable schema
reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).

## Next steps

- **See derived variables in a full analysis** – The [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md)
  demonstrates deriving hypertension status from CHMS cycle 3 data.
- **Handle missing data** – Learn how `tagged_na()` codes propagate
  through derived variable functions in [Missing data
  (tagged_na)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md).
- **Understand the methodology** – For the design rationale behind the
  rules-as-data approach, see
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).
