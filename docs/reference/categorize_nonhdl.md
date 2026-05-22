# Categorical non-HDL cholesterol level

This function categorizes individuals' non-HDL cholesterol levels based
on a threshold value.

## Usage

``` r
categorize_nonhdl(nonhdl)
```

## Arguments

- nonhdl:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  an individual's non-HDL cholesterol level.

## Value

[integer](https://rdrr.io/r/base/integer.html) A categorical indicating
the non-HDL cholesterol category:

- 1: High non-HDL cholesterol (nonhdl \>= 4.3)

- 2: Normal non-HDL cholesterol (nonhdl \< 4.3)

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function categorizes non-HDL cholesterol levels into 'High' or
'Normal' based on a 4.3 mmol/L threshold.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `nonhdl`.

## See also

[`calculate_nonhdl()`](https://big-life-lab.github.io/chmsflow/reference/calculate_nonhdl.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Categorize a nonhdl value of 5.0 as high non-HDL cholesterol
categorize_nonhdl(5.0)
#> [1] 1
# Output: 1

# Example 2: Categorize a nonhdl value of 3.8 as normal non-HDL cholesterol
categorize_nonhdl(3.8)
#> [1] 2
# Output: 2

# Multiple respondents
categorize_nonhdl(c(5.0, 3.8, 4.3))
#> [1] 1 2 1
# Returns: c(1, 2, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(non_hdl_category = categorize_nonhdl(non_hdl))
```
