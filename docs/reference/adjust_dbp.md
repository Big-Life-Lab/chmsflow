# Adjusted diastolic blood pressure

This function adjusts diastolic blood pressure based on the respondent's
diastolic average blood pressure across six measurements. The adjustment
is made using specific correction factors. The adjusted diastolic blood
pressure is returned as a numeric value.

## Usage

``` r
adjust_dbp(bpmdpbpd)
```

## Arguments

- bpmdpbpd:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's diastolic average blood pressure (in mmHg) across six
  measurements.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The adjusted diastolic
blood pressure as a numeric.

## Details

Blood pressure measurements in survey settings may require adjustment to
account for measurement conditions and equipment differences. This
function applies a standardized adjustment using the formula:
dbp_adj_mmhg = 15.6 + (0.83 \* bpmdpbpd).

         **Missing Data Codes:**
         - `996`: Valid skip (e.g., measurement not taken). Handled as `haven::tagged_na("a")`.
         - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`adjust_sbp()`](https://big-life-lab.github.io/chmsflow/reference/adjust_sbp.md)
for systolic blood pressure adjustment,
[`derive_hypertension()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension.md)
for hypertension classification

## Examples

``` r
# Scalar usage: Single respondent
# Example: Adjust for a respondent with average diastolic blood pressure of 80 mmHg.
adjust_dbp(bpmdpbpd = 80)
#> [1] 82
# Output: 82

# Example: Adjust for a respondent with a non-response diastolic blood pressure of 996.
result <- adjust_dbp(bpmdpbpd = 996)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#> [1] "NA"

# Multiple respondents
adjust_dbp(bpmdpbpd = c(80, 90, 100))
#> [1] 82.0 90.3 98.6
# Returns: c(82, 90.3, 98.6)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(dbp_adj_mmhg = adjust_dbp(bpmdpbpd))
```
