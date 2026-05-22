# Cardiovascular disease (CVD) personal history

This function determines a respondent's cardiovascular disease (CVD)
personal history based on the presence or absence of specific conditions
related to heart disease, heart attack, and stroke.

## Usage

``` r
derive_cvd_personal_history(ccc_61, ccc_63, ccc_81)
```

## Arguments

- ccc_61:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the respondent's personal history of heart disease. 1 for "Yes" if the
  person has heart disease, 2 for "No" if the person does not have heart
  disease.

- ccc_63:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the respondent's personal history of heart attack. 1 for "Yes" if the
  person had a heart attack, 2 for "No" if the person did not have a
  heart attack.

- ccc_81:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the respondent's personal history of stroke. 1 for "Yes" if the person
  had a stroke, 2 for "No" if the person did not have a stroke.

## Value

[integer](https://rdrr.io/r/base/integer.html) The CVD personal
history: - 1: "Yes" if the person had heart disease, heart attack, or
stroke. - 2: "No" if the person had neither of the conditions. -
`haven::tagged_na("a")`: Not applicable - `haven::tagged_na("b")`:
Missing

## Details

This function synthesizes self-reported data on major cardiovascular
events (heart disease, heart attack, stroke) into a single binary
indicator.

         **Missing Data Codes:**
         - For all input variables:
           - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`derive_cvd_family_history()`](https://big-life-lab.github.io/chmsflow/reference/derive_cvd_family_history.md)

## Examples

``` r
# Scalar usage: Single respondent
# Determine CVD personal history for a person with heart disease (ccc_61 = 1).
derive_cvd_personal_history(ccc_61 = 1, ccc_63 = 2, ccc_81 = 2)
#> [1] 1
# Output: 1

# Example: Respondent has non-response values for all inputs.
result <- derive_cvd_personal_history(ccc_61 = 8, ccc_63 = 8, ccc_81 = 8)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
derive_cvd_personal_history(ccc_61 = c(1, 2, 2), ccc_63 = c(2, 1, 2), ccc_81 = c(2, 2, 1))
#> [1] 1 1 1
# Returns: c(1, 1, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(cvd_personal_history = derive_cvd_personal_history(ccc_61, ccc_63, ccc_81))
```
