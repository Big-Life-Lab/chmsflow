# Low risk drinking score - former/never categories

Computes a categorical alcohol consumption score based on Canada's
Low-Risk Alcohol Drinking Guidelines (Step 1), while distinguishing
between never, former, light, moderate, and heavy drinkers. The function
uses information about weekly consumption, past-year use, lifetime
drinking, and history of heavy drinking.

## Usage

``` r
derive_alcohol_risk_detailed(clc_sex, alc_11, alcdwky, alc_17, alc_18)
```

## Arguments

- clc_sex:

  [integer](https://rdrr.io/r/base/integer.html) Respondent's sex (1 =
  male, 2 = female).

- alc_11:

  [integer](https://rdrr.io/r/base/integer.html) Whether the respondent
  drank alcohol in the past year (1 = Yes, 2 = No).

- alcdwky:

  [integer](https://rdrr.io/r/base/integer.html) Number of standard
  drinks consumed in a typical week (0-84).

- alc_17:

  [integer](https://rdrr.io/r/base/integer.html) Whether the respondent
  ever drank alcohol in their lifetime (1 = Yes, 2 = No).

- alc_18:

  [integer](https://rdrr.io/r/base/integer.html) Whether the respondent
  regularly drank more than 12 drinks per week (1 = Yes, 2 = No).

## Value

[integer](https://rdrr.io/r/base/integer.html) Score: 1 = Never drank, 2
= Low-risk (former or light) drinker, 3 = Moderate drinker (1–2 points),
4 = Heavy drinker (3–4 points). If inputs are invalid or out of bounds,
the function returns a tagged NA.

## Details

Step 1: Assign points based on weekly alcohol consumption.

- If the respondent drank in the past year (alc_11 == 1):

  - 0 to 10 drinks/week: 0 points

  - 11 to 15 drinks/week: 0 points for males, 1 point for females

  - 16 to 20 drinks/week: 1 point for males, 3 points for females

  - More than 20 drinks/week: 3 points for males, 5 points for females

- If they did not drink in the past year (alc_11 == 2): 0 points

Step 2: Determine the final categorical score.

- If the point score from Step 1 is 0, the final category is determined
  based on lifetime and past-year drinking habits:

  - A score of 1 (Never drinker) is assigned if the respondent either
    never drank alcohol in their lifetime or is a former drinker who did
    not regularly consume more than 12 drinks a week.

  - A score of 2 (Low-risk drinker) is assigned if the respondent drank
    in the past year (but still scored 0 points) or is a former drinker
    with a history of regularly consuming more than 12 drinks a week.

- If the point score from Step 1 is 1 or 2, the respondent is classified
  as a Moderate drinker (Score = 3).

- If the point score from Step 1 is 3 or more, the respondent is
  classified as a Heavy drinker (Score = 4). If inputs are invalid or
  out of bounds, the function returns a tagged NA.

## Note

This function uses only Step 1 of the guidelines, as Step 2 information
is unavailable in CHMS.

## References

Canada's Low-Risk Alcohol Drinking Guidelines, Health Canada

## See also

[`derive_alcohol_risk()`](https://big-life-lab.github.io/chmsflow/reference/derive_alcohol_risk.md)
for basic risk scoring without drinking history

## Examples

``` r
# Scalar usage: Single respondent
# Example: Male, drinks 3 drinks/week, drank in past year, no history of heavy drinking
derive_alcohol_risk_detailed(
  clc_sex = 1, alc_11 = 1, alcdwky = 3,
  alc_17 = 1, alc_18 = 2
)
#> [1] 2
# Expected output: 2

# Missing data examples showing tagged NA patterns
result <- derive_alcohol_risk_detailed(
  clc_sex = 1, alc_11 = 6, alcdwky = 5,
  alc_17 = 1, alc_18 = 2
)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#> [1] "NA"

result <- derive_alcohol_risk_detailed(
  clc_sex = 1, alc_11 = 7, alcdwky = 5,
  alc_17 = 1, alc_18 = 2
)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

result <- derive_alcohol_risk_detailed(
  clc_sex = 1, alc_11 = 1, alcdwky = NA,
  alc_17 = 1, alc_18 = 2
)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
derive_alcohol_risk_detailed(
  clc_sex = c(1, 2, 1), alc_11 = c(1, 1, 2),
  alcdwky = c(3, 12, NA), alc_17 = c(1, 1, 1), alc_18 = c(2, 2, 1)
)
#> [1] 2 3 2
# Returns: c(2, 3, 2)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(
#     alc_detailed_risk_score = derive_alcohol_risk_detailed(
#       clc_sex, alc_11, alcdwky, alc_17, alc_18
#     )
#   )
```
