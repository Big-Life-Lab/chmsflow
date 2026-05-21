# Low risk drinking score

This function calculates a low drink score (step 1 only) for a
respondent using Canada's Low-Risk Alcohol Drinking Guideline. The score
is based solely on the number of standard drinks consumed per week and
the respondent's sex. (Step 2, which would add additional points based
on other drinking habits, is not included.)

## Usage

``` r
low_drink_score_fun(CLC_SEX, ALC_11, ALCDWKY)
```

## Arguments

- CLC_SEX:

  An integer indicating the respondent's sex (1 for male, 2 for female).

- ALC_11:

  An integer indicating whether the respondent drank alcohol in the past
  year (1 for "Yes", 2 for "No").

- ALCDWKY:

  An integer representing the number of standard drinks consumed by the
  respondent in a week.

## Value

An integer representing the low drink score, with:

- 1 for "Low risk" (0 points),

- 2 for "Marginal risk" (1–2 points),

- 3 for "Medium risk" (3–4 points), and

- 4 for "High risk" (5–9 points). If inputs are invalid or out of
  bounds, the function returns a tagged NA.

## Details

The scoring is determined by first allocating points (referred to as
`step1`) based on the weekly alcohol consumption and the respondent's
sex:

- If the respondent drank in the past year (ALC_11 == 1):

  - For ALCDWKY ≤ 10, assign 0 points.

  - For ALCDWKY \> 10 and ≤ 15: assign 0 points for males (CLC_SEX == 1)
    and 1 point for females (CLC_SEX == 2).

  - For ALCDWKY \> 15 and ≤ 20: assign 1 point for males and 3 points
    for females.

  - For ALCDWKY \> 20: assign 3 points.

- For respondents who did not drink in the past year (ALC_11 == 2), 0
  points are assigned.

These `step1` points are then mapped to the final categorical score as
follows:

- 0 points → score of 1 ("Low risk"),

- 1–2 points → score of 2 ("Marginal risk"),

- 3–4 points → score of 3 ("Medium risk"),

- 5–9 points → score of 4 ("High risk").

## Note

This function does not include the additional points from step 2 of the
guideline.

## Examples

``` r
# Example: A male respondent who drank in the past year and consumes 3 standard drinks per week.
low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 3)
#> [1] 1
# Expected output: 1 (Low risk)
```
