# Adjusted total household income

This function calculates the adjusted total household income based on
the respondent's income amount and actual household size, taking into
account the weighted household size.

## Usage

``` r
calculate_household_income(thi_01, dhhdhsz)
```

## Arguments

- thi_01:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the respondent's household income amount in dollars.

- dhhdhsz:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the respondent's actual household size in persons.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The calculated adjusted
total household income as a numeric. If inputs are invalid or out of
bounds, the function returns a tagged NA.

## Details

This function applies equivalence scales to adjust household income for
household size, allowing for meaningful income comparisons across
different household compositions.

         **Equivalence Scale Logic:**
         - First adult: Weight = 1.0 (full weight)
         - Second adult: Weight = 0.4 (economies of scale)
         - Additional members: Weight = 0.3 each (further economies)

         **Missing Data Codes:**
         - `thi_01`:
           - `99999996`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `99999997-99999999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
         - `dhhdhsz`:
           - `96`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `97-99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`categorize_income_quintile()`](https://big-life-lab.github.io/chmsflow/reference/categorize_income_quintile.md)
for income classification,
[`is_lowest_income_quintile()`](https://big-life-lab.github.io/chmsflow/reference/is_lowest_income_quintile.md)
for poverty indicators

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Respondent with $50,000 income and a household size of 3.
calculate_household_income(thi_01 = 50000, dhhdhsz = 3)
#> [1] 29411.76
# Output: 29411.76

# Example 2: Respondent has non-response values for all inputs.
result <- calculate_household_income(thi_01 = 99999998, dhhdhsz = 98)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_household_income(thi_01 = c(50000, 75000, 90000), dhhdhsz = c(3, 2, 1))
#> [1] 29411.76 53571.43 90000.00
# Returns: c(29411.76, 53571.43, 90000)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(adj_hh_income = calculate_household_income(thi_01, dhhdhsz))
```
