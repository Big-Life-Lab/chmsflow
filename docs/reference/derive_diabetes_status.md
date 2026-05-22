# Diabetes derived variable

This function evaluates diabetes status using a comprehensive approach
that combines laboratory measurements, self-reported diagnosis, and
medication usage to create an inclusive diabetes classification.

## Usage

``` r
derive_diabetes_status(diab_a1c, ccc_51, diab_med)
```

## Arguments

- diab_a1c:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  whether the respondent has diabetes based on HbA1c level. 1 for "Yes",
  2 for "No".

- ccc_51:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  whether the respondent self-reported diabetes. 1 for "Yes", 2 for
  "No".

- diab_med:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  whether the respondent is on diabetes medication. 1 for "Yes", 0 for
  "No".

## Value

[integer](https://rdrr.io/r/base/integer.html) The inclusive diabetes
status: - 1 ("Yes") if any of `diab_a1c`, `ccc_51`, or `diab_med`
is 1. - 2 ("No") if all of `diab_a1c`, `ccc_51`, and `diab_med` are 2 or
0. - `haven::tagged_na("a")`: Not applicable - `haven::tagged_na("b")`:
Missing

## Details

This function classifies diabetes status based that considers:

         **Data Sources:**
         - Laboratory: HbA1c levels indicating diabetes (diab_a1c)
         - Self-report: Participant-reported diabetes diagnosis (ccc_51)
         - Medication: Current diabetes medication usage (diab_med)

         **Classification Logic:**
         - ANY positive indicator results in diabetes classification
         - ALL negative indicators required for "no diabetes" classification
         - Sophisticated missing data handling preserves available information

         **Missing Data Codes:**
         - `diab_a1c`, `diab_med`:
           - Tagged NA "a": Valid skip.
           - Tagged NA "b": Don't know, refusal, or not stated.
         - `ccc_51`:
           - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

Related health condition functions:
[`derive_hypertension()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension.md),
[`calculate_gfr()`](https://big-life-lab.github.io/chmsflow/reference/calculate_gfr.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example: Determine the inclusive diabetes status for a respondent with diabetes based on HbA1c.
derive_diabetes_status(diab_a1c = 1, ccc_51 = 2, diab_med = 0)
#> [1] 1
# Output: 1 (Inclusive diabetes status is "Yes").

# Example: Determine the inclusive diabetes status for a respondent no diabetes all around.
derive_diabetes_status(diab_a1c = 2, ccc_51 = 2, diab_med = 0)
#> [1] 2
# Output: 2 (Inclusive diabetes status is "No").

# Example: Determine inclusive diabetes status when only one parameter is NA.
derive_diabetes_status(diab_a1c = 2, ccc_51 = NA, diab_med = 1)
#> [1] 1
# Output: 1 (Based on `diab_med`, inclusive diabetes status is "Yes").

# Example: Respondent has non-response values for all inputs.
result <- derive_diabetes_status(haven::tagged_na("b"), 8, haven::tagged_na("b"))
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
derive_diabetes_status(diab_a1c = c(1, 2, 2), ccc_51 = c(2, 1, 2), diab_med = c(0, 0, 1))
#> [1] 1 1 1
# Returns: c(1, 1, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(diabetes_status = derive_diabetes_status(diab_a1c, ccc_51, diab_med))
```
