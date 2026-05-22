# Lowest income quintile indicator

This function checks if an individual's income category corresponds to
the lowest income quintile.

## Usage

``` r
is_lowest_income_quintile(income_quintile)
```

## Arguments

- income_quintile:

  [integer](https://rdrr.io/r/base/integer.html) A categorical vector
  indicating the income category as defined by the
  categorize_income_quintile function.

## Value

[integer](https://rdrr.io/r/base/integer.html) Whether the individual is
in the lowest income quintile:

- 1: In the lowest income quntile

- 2: Not in the lowest income quntile

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function identifies individuals in the lowest income quintile, a
common indicator for socioeconomic disadvantage.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `income_quintile`.

## See also

[`categorize_income_quintile()`](https://big-life-lab.github.io/chmsflow/reference/categorize_income_quintile.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Check if an income category of 3 is in the lowest quintile
is_lowest_income_quintile(3)
#> [1] 2
# Output: 2

# Example 2: Check if an income category of 1 is in the lowest quintile
is_lowest_income_quintile(1)
#> [1] 1
# Output: 1

# Multiple respondents
is_lowest_income_quintile(c(3, 1, 5))
#> [1] 2 1 2
# Returns: c(2, 1, 2)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(in_lowest_quintile = is_lowest_income_quintile(income_category))
```
