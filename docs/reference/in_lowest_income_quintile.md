# Lowest income quintile indicator

This function checks if an individual's income category corresponds to
the lowest income quintile.

## Usage

``` r
in_lowest_income_quintile(incq)
```

## Arguments

- incq:

  Categorical value indicating the income category as defined by the
  categorize_income function.

## Value

A categorical value indicating whether the individual is in the lowest
income quintile:

- 1: In the lowest income quntile

- 2: Not in the lowest income quntile

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Check if an income category of 3 (between $35,000-50,000) is in the lowest quintile
in_lowest_income_quintile(3)
#> [1] 2
# Output: 2

# Example 2: Check if an income category of 1 (below or equal to $21,500) is in the lowest quintile
in_lowest_income_quintile(1)
#> [1] 1
# Output: 1
```
