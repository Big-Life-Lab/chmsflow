# Diabetes derived variable

This function evaluates diabetes status based on three factors:
`diab_m`, `CCC_51`, and `diab_drug2`.

## Usage

``` r
determine_inclusive_diabetes(diab_m, CCC_51, diab_drug2)
```

## Arguments

- diab_m:

  An integer indicating whether the respondent has diabetes based on
  HbA1c level. 1 for "Yes", 2 for "No".

- CCC_51:

  An integer indicating whether the respondent self-reported diabetes. 1
  for "Yes", 2 for "No".

- diab_drug2:

  An integer indicating whether the respondent is on diabetes
  medication. 1 for "Yes", 0 for "No".

## Value

An integer indicating the inclusive diabetes status: - 1 ("Yes") if any
of `diab_m`, `CCC_51`, or `diab_drug2` is 1. - 2 ("No") if all of
`diab_m`, `CCC_51`, and `diab_drug2` are 2. - `haven::tagged_na("b")` if
all three parameters are `NA`. - If two parameters are `NA`, the third
non-`NA` parameter determines the result. - If one parameter is `NA`,
the function checks the remaining two for a decision.

## Examples

``` r

# Example: Determine the inclusive diabetes status for a respondent with diabetes based on HbA1c.
determine_inclusive_diabetes(diab_m = 1, CCC_51 = 2, diab_drug2 = 2)
#> [1] 1
# Output: 1 (Inclusive diabetes status is "Yes").

# Example: Determine the inclusive diabetes status for a respondent no diabetes all around.
determine_inclusive_diabetes(diab_m = 2, CCC_51 = 2, diab_drug2 = 2)
#> [1] NA
# Output: 2 (Inclusive diabetes status is "No").

# Example: Determine inclusive diabetes status when only one parameter is NA.
determine_inclusive_diabetes(diab_m = 2, CCC_51 = NA, diab_drug2 = 1)
#> [1] 1
# Output: 1 (Based on `diab_drug2`, inclusive diabetes status is "Yes").
```
