# Adjusted systolic blood pressure

This function adjusts systolic blood pressure based on the respondent's
systolic average blood pressure across six measurements. The adjustment
is made using specific correction factors. The adjusted systolic blood
pressure is returned as a numeric value.

## Usage

``` r
adjust_sbp(bpmdpbps)
```

## Arguments

- bpmdpbps:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's systolic average blood pressure (in mmHg) across six
  measurements.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The adjusted systolic
blood pressure as a numeric.

## Details

Blood pressure measurements in survey settings may require adjustment to
account for measurement conditions and equipment differences. This
function applies a standardized adjustment using the formula:
sbp_adj_mmhg = 11.4 + (0.93 \* bpmdpbps).

         **Missing Data Codes:**
         - `996`: Valid skip (e.g., measurement not taken). Handled as `haven::tagged_na("a")`.
         - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`adjust_dbp()`](https://big-life-lab.github.io/chmsflow/reference/adjust_dbp.md)
for diastolic blood pressure adjustment,
[`derive_hypertension()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension.md)
for hypertension classification

## Examples

``` r
# Scalar usage: Single respondent
# Example: Adjust for a respondent with average systolic blood pressure of 120 mmHg.
adjust_sbp(bpmdpbps = 120)
#> [1] 123
# Output: 123

# Example: Adjust for a respondent with a non-response systolic blood pressure of 996.
result <- adjust_sbp(bpmdpbps = 996)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#> [1] "NA"

# Multiple respondents
adjust_sbp(bpmdpbps = c(120, 130, 140))
#> [1] 123.0 132.3 141.6
# Returns: c(123, 132.3, 141.6)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(sbp_adj_mmhg = adjust_sbp(bpmdpbps))
```
