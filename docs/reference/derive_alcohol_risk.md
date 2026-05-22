# Low risk drinking score

This function calculates a low drink score (step 1 only) for a
respondent using Canada's Low-Risk Alcohol Drinking Guideline. The score
is based solely on the number of standard drinks consumed per week and
the respondent's sex. (Step 2, which would add additional points based
on other drinking habits, is not included.).

## Usage

``` r
derive_alcohol_risk(clc_sex, alc_11, alcdwky)
```

## Arguments

- clc_sex:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  the respondent's sex (1 for male, 2 for female).

- alc_11:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  whether the respondent drank alcohol in the past year (1 for "Yes", 2
  for "No").

- alcdwky:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the number of standard drinks consumed by the respondent in a week.

## Value

[integer](https://rdrr.io/r/base/integer.html) The low drink score,
with:

- 1 for "Low risk" (0 points),

- 2 for "Marginal risk" (1-2 points),

- 3 for "Medium risk" (3-4 points), and

- 4 for "High risk" (5-9 points). If inputs are invalid or out of
  bounds, the function returns a tagged NA.

## Details

The scoring is determined by first allocating points (referred to as
`step1`) based on the weekly alcohol consumption and the respondent's
sex:

- If the respondent drank in the past year (alc_11 == 1):

  - For alcdwky \<= 10, assign 0 points.

  - For alcdwky \> 10 and \<= 15: assign 0 points for males (clc_sex
    == 1) and 1 point for females (clc_sex == 2).

  - For alcdwky \> 15 and \<= 20: assign 1 point for males and 3 points
    for females.

  - For alcdwky \> 20: assign 3 points.

- For respondents who did not drink in the past year (alc_11 == 2), 0
  points are assigned.

These `step1` points are then mapped to the final categorical score as
follows:

- 0 points -\> score of 1 ("Low risk"),

- 1-2 points -\> score of 2 ("Marginal risk"),

- 3-4 points -\> score of 3 ("Medium risk"),

- 5-9 points -\> score of 4 ("High risk").

This function implements Canada's Low-Risk Alcohol Drinking Guidelines
(Step 1 only) to assess alcohol consumption risk. The scoring system
considers both the quantity of alcohol consumed and biological sex
differences in alcohol metabolism.

**Risk Categories:**

- Low risk (0 points): Safe consumption levels

- Marginal risk (1-2 points): Slightly elevated risk

- Medium risk (3-4 points): Moderate health concerns

- High risk (5-9 points): Significant health risks

**Sex-Based Differences:** Women generally have lower tolerance
thresholds due to physiological differences in alcohol metabolism,
reflected in the sex-specific point allocations.

**Non-response Handling:** Invalid inputs or survey non-response values
result in tagged NA ("b").

## Note

This function implements only Step 1 of the guidelines. Step 2
(additional drinking pattern assessments) is not included due to data
limitations in the survey.

## References

Canada's Low-Risk Alcohol Drinking Guidelines, Health Canada

## See also

[`derive_alcohol_risk_detailed()`](https://big-life-lab.github.io/chmsflow/reference/derive_alcohol_risk_detailed.md)
for extended categorization including former/never drinkers

## Examples

``` r
# Scalar usage: Single respondent
# Example: A male respondent who drank in the past year and consumes 3 standard drinks per week.
derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = 3)
#> [1] 1
# Expected output: 1 (Low risk)

# Missing data examples showing tagged NA patterns
result <- derive_alcohol_risk(clc_sex = 1, alc_11 = 6, alcdwky = 5)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#> [1] "NA"

result <- derive_alcohol_risk(clc_sex = 1, alc_11 = 7, alcdwky = 5)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

result <- derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = NA)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
derive_alcohol_risk(clc_sex = c(1, 2, 1), alc_11 = c(1, 1, 2), alcdwky = c(3, 12, NA))
#> [1] 1 2 1
# Returns: c(1, 2, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(alc_risk_score = derive_alcohol_risk(clc_sex, alc_11, alcdwky))
```
