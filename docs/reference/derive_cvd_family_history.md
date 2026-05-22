# Cardiovascular Disease (CVD) family history

This function evaluates a respondent's family history of cardiovascular
disease (CVD), based on data about diagnoses of heart disease and stroke
in immediate family members and the ages at which these diagnoses
occurred. It identifies premature CVD if any diagnosis occurred before
age 60.

## Usage

``` r
derive_cvd_family_history(fmh_11, fmh_12, fmh_13, fmh_14)
```

## Arguments

- fmh_11:

  [integer](https://rdrr.io/r/base/integer.html) An integer: Indicates
  whether an immediate family member was diagnosed with heart disease. -
  1 for "Yes" - 2 for "No".

- fmh_12:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric: Represents
  the youngest age at diagnosis of heart disease in an immediate family
  member.

- fmh_13:

  [integer](https://rdrr.io/r/base/integer.html) An integer: Indicates
  whether an immediate family member was diagnosed with stroke. - 1 for
  "Yes" - 2 for "No".

- fmh_14:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric: Represents
  the youngest age at diagnosis of stroke in an immediate family member.

## Value

[integer](https://rdrr.io/r/base/integer.html) The CVD family history:

- 1: "Yes" – Family history of premature CVD exists (diagnosis before
  age 60).

- 2: "No" – No family history of premature CVD.

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function assesses family history of premature cardiovascular
disease (CVD), a significant risk factor for personal CVD development.

         **Missing Data Codes:**
         - `fmh_11`, `fmh_13`:
           - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
         - `fmh_12`, `fmh_14`:
           - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`derive_cvd_personal_history()`](https://big-life-lab.github.io/chmsflow/reference/derive_cvd_personal_history.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Premature CVD due to heart disease diagnosis at age 50
derive_cvd_family_history(fmh_11 = 1, fmh_12 = 50, fmh_13 = 2, fmh_14 = NA)
#> [1] 1
# Output: 1

# Example 2: Respondent has non-response values for all inputs.
result <- derive_cvd_family_history(fmh_11 = 8, fmh_12 = 998, fmh_13 = 8, fmh_14 = 998)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
derive_cvd_family_history(
  fmh_11 = c(1, 2, 1), fmh_12 = c(50, NA, 70),
  fmh_13 = c(2, 1, 2), fmh_14 = c(NA, 55, NA)
)
#> [1] 1 1 2
# Returns: c(1, 1, 2)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(cvd_family_history = derive_cvd_family_history(fmh_11, fmh_12, fmh_13, fmh_14))
```
