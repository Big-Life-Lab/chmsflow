# Categorical adjusted household income

This function categorizes individuals' adjusted household income based
on specified income ranges.

## Usage

``` r
categorize_income(adj_hh_inc)
```

## Arguments

- adj_hh_inc:

  Numeric value representing the adjusted household income.

## Value

A categorical value indicating the income category:

- 1: Below or equal to \$21,500

- 2: Above \$21,500 and up to \$35,000

- 3: Above \$35,000 and up to \$50,000

- 4: Above \$50,000 and up to \$70,000

- 5: Above \$70,000

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Categorize a household income of $25,000
categorize_income(25000)
#> [1] 2
# Output: 2

# Example 2: Categorize a household income of $45,000
categorize_income(45000)
#> [1] 3
# Output: 3
```
