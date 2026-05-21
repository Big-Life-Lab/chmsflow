# Categorical non-HDL cholesterol level

This function categorizes individuals' non-HDL cholesterol levels based
on a threshold value.

## Usage

``` r
categorize_nonHDL(nonHDL)
```

## Arguments

- nonHDL:

  Numeric value representing an individual's non-HDL cholesterol level.

## Value

A categorical value indicating the non-HDL cholesterol category:

- 1: High non-HDL cholesterol (nonHDL \>= 4.3)

- 2: Normal non-HDL cholesterol (nonHDL \< 4.3)

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Categorize a nonHDL value of 5.0 as high non-HDL cholesterol
categorize_nonHDL(5.0)
#> [1] 1
# Output: 1

# Example 2: Categorize a nonHDL value of 3.8 as normal non-HDL cholesterol
categorize_nonHDL(3.8)
#> [1] 2
# Output: 2
```
