# Categorical diet indicator

This function categorizes individuals' diet quality based on their total
fruit and vegetable consumption.

## Usage

``` r
categorize_diet_quality(fv_daily)
```

## Arguments

- fv_daily:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the average times per day fruits and vegetables were
  consumed in a year.

## Value

[integer](https://rdrr.io/r/base/integer.html) A categorical indicating
the diet quality:

- 1: Good diet (fv_daily \>= 5)

- 2: Poor diet (fv_daily \< 5)

- `haven::tagged_na("a")`: Valid skip

- `haven::tagged_na("b")`: Missing

## Details

This function categorizes diet quality based on the widely recognized
"5-a-day" recommendation for fruit and vegetable intake.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `fv_daily`.

## See also

[`calculate_fv_daily_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/calculate_fv_daily_cycles1to2.md),
[`calculate_fv_daily_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/calculate_fv_daily_cycles3to6.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Categorize a fv_daily value of 3 as poor diet
categorize_diet_quality(3)
#> [1] 2
# Output: 2

# Example 2: Categorize a fv_daily value of 7 as good diet
categorize_diet_quality(7)
#> [1] 1
# Output: 1

# Multiple respondents
categorize_diet_quality(c(3, 7, 5))
#> [1] 2 1 1
# Returns: c(2, 1, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(diet_quality = categorize_diet_quality(total_fv))
```
