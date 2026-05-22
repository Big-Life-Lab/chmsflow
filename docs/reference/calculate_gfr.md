# Estimated glomerular filtration rate (GFR)

This function calculates the estimated glomerular filtration rate (GFR)
according to Finlay's formula, where serum creatine is in mg/dL. The
calculation takes into account the respondent's ethnicity, sex, and age.

## Usage

``` r
calculate_gfr(lab_bcre, pgdcgt, clc_sex, clc_age)
```

## Arguments

- lab_bcre:

  [numeric](https://rdrr.io/r/base/numeric.html) Blood creatine
  (umol/L). It should be a numeric between 14 and 785.

- pgdcgt:

  [integer](https://rdrr.io/r/base/integer.html) Ethnicity (13
  categories). It should be an integer between 1 and 13.

- clc_sex:

  [integer](https://rdrr.io/r/base/integer.html) Sex (Male = 1, Female =
  2). It should be an integer of either 1 or 2.

- clc_age:

  [numeric](https://rdrr.io/r/base/numeric.html) Age (years). It should
  be a numeric between 3 and 79.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The calculated GFR. If
inputs are invalid or out of bounds, the function returns a tagged NA.

## Details

This function implements the Modification of Diet in Renal Disease
(MDRD) equation to estimate glomerular filtration rate, a key indicator
of kidney function.

         **Clinical Significance:**
         GFR estimates are essential for:
         - Chronic kidney disease (CKD) classification
         - Medication dosing adjustments
         - Cardiovascular risk assessment

         **Formula Application:**
         Base: GFR = 175 x (creatinine^-1.154) x (age^-0.203)
         Adjustments:
         - Female: x 0.742
         - Black ethnicity: x 1.210

         **Unit Conversion:**
         Serum creatinine converted from umol/L to mg/dL (/ 88.4)

         **Missing Data Codes:**
         - `lab_bcre`: `9996` (Not applicable), `9997-9999` (Missing)
         - `pgdcgt`: `96` (Not applicable), `97-99` (Missing)
         - `clc_sex`: `6` (Not applicable), `7-9` (Missing)
         - `clc_age`: `96` (Not applicable), `97-99` (Missing)

## See also

[`categorize_ckd()`](https://big-life-lab.github.io/chmsflow/reference/categorize_ckd.md)
for CKD classification based on GFR values

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Calculate gfr for a 45-year-old white female with serum creatine of 80 umol/L.
calculate_gfr(lab_bcre = 80, pgdcgt = 1, clc_sex = 2, clc_age = 45)
#> [1] 67.27905
# Output: 67.27905

# Example 2: Respondent has non-response values for all inputs.
result <- calculate_gfr(lab_bcre = 9998, pgdcgt = 98, clc_sex = 8, clc_age = 98)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_gfr(
  lab_bcre = c(80, 70, 90), pgdcgt = c(1, 2, 1),
  clc_sex = c(2, 2, 1), clc_age = c(45, 35, 50)
)
#> [1] 67.27905 99.94114 77.47422
# Returns: c(67.27905, 99.94114, 70.38001)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(gfr = calculate_gfr(lab_bcre, pgdcgt, clc_sex, clc_age))
```
