# Smoking pack-years

This function calculates an individual's smoking pack-years based on
various CHMS smoking variables. Pack years is a measure used by
researchers to quantify lifetime exposure to cigarette use.

## Usage

``` r
calculate_pack_years(
  smkdsty,
  clc_age,
  smk_54,
  smk_52,
  smk_31,
  smk_41,
  smk_53,
  smk_42,
  smk_21,
  smk_11
)
```

## Arguments

- smkdsty:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the smoking status of the respondent.

- clc_age:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's age.

- smk_54:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's age when they stopped smoking daily.

- smk_52:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's age when they first started smoking daily.

- smk_31:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the number of cigarettes smoked per day for daily smokers.

- smk_41:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the number of cigarettes smoked per day for occasional smokers.

- smk_53:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the number of cigarettes smoked per day for former daily smokers.

- smk_42:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the number of days in past month the respondent smoked at least 1
  cigarette (for occasional smokers).

- smk_21:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's age when they first started smoking occasionally.

- smk_11:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  whether the respondent has smoked at least 100 cigarettes in their
  lifetime.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
the pack years for the respondent's smoking history. If inputs are
invalid or out of bounds, the function returns a tagged NA.

## Details

Pack-years is a standardized measure of lifetime cigarette exposure used
in epidemiological research and clinical practice. The calculation
varies by smoking pattern:

         **Smoking Patterns:**
         - Daily smokers: Consistent daily consumption over time period
         - Occasional smokers: Variable consumption adjusted for frequency
         - Former smokers: Historical consumption during smoking periods

         **Minimum Values:**
         The function applies minimum pack-year values (0.0137 or 0.007) to prevent
         underestimation of health risks for light smokers.

         **Missing Data Codes:**
         - `smkdsty`: `96` (Not applicable), `97-99` (Missing)
         - `clc_age`: `96` (Not applicable), `97-99` (Missing)
         - Other variables: Handled within the formula logic.

## See also

https://big-life-lab.github.io/cchsflow/reference/calculate_pack_years.html

## Examples

``` r
# Scalar usage: Single respondent
# A former occasional smoker who smoked at least 100 cigarettes in their lifetime.
calculate_pack_years(
  smkdsty = 5, clc_age = 50, smk_54 = 40, smk_52 = 18, smk_31 = NA,
  smk_41 = 15, smk_53 = NA, smk_42 = 3, smk_21 = 25, smk_11 = 1
)
#> [1] 0.0137
# Output: 0.0137

# Example: Respondent has non-response values for all inputs.
result <- calculate_pack_years(
  smkdsty = 98, clc_age = 998, smk_54 = 98, smk_52 = 98, smk_31 = 98,
  smk_41 = 98, smk_53 = 98, smk_42 = 98, smk_21 = 98, smk_11 = 8
)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_pack_years(
  smkdsty = c(1, 5, 6),
  clc_age = c(40, 50, 60),
  smk_52 = c(20, 18, NA),
  smk_31 = c(30, NA, NA),
  smk_54 = c(NA, 40, NA),
  smk_41 = c(NA, 15, NA),
  smk_53 = c(NA, NA, NA),
  smk_42 = c(NA, 3, NA),
  smk_21 = c(NA, 25, NA),
  smk_11 = c(NA, 1, NA)
)
#> [1] 30.0000  0.0137  0.0000
# Returns: c(30, 0.0137, 0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(pack_years = calculate_pack_years(smkdsty, clc_age, smk_54, smk_52,
#     smk_31, smk_41, smk_53, smk_42, smk_21, smk_11))
```
