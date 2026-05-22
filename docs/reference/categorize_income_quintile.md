# Categorical adjusted household income

This function categorizes individuals' adjusted household income based
on specified income ranges.

## Usage

``` r
categorize_income_quintile(adj_hh_income)
```

## Arguments

- adj_hh_income:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the adjusted household income.

## Value

[integer](https://rdrr.io/r/base/integer.html) The income category:

- 1: Below or equal to \$21,500

- 2: Above \$21,500 and up to \$35,000

- 3: Above \$35,000 and up to \$50,000

- 4: Above \$50,000 and up to \$70,000

- 5: Above \$70,000

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function segments adjusted household income into quintiles,
providing a standardized measure of socioeconomic status.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `adj_hh_income`.

## See also

[`calculate_household_income()`](https://big-life-lab.github.io/chmsflow/reference/calculate_household_income.md),
[`is_lowest_income_quintile()`](https://big-life-lab.github.io/chmsflow/reference/is_lowest_income_quintile.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Categorize a household income of $25,000
categorize_income_quintile(25000)
#> [1] 2
# Output: 2

# Example 2: Categorize a household income of $45,000
categorize_income_quintile(45000)
#> [1] 3
# Output: 3

# Multiple respondents
categorize_income_quintile(c(25000, 45000, 80000))
#> [1] 2 3 5
# Returns: c(2, 3, 5)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(income_category = categorize_income_quintile(adj_hh_income))
```
