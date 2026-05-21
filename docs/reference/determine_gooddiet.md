# Categorical diet indicator

This function categorizes individuals' diet quality based on their total
fruit and vegetable consumption.

## Usage

``` r
determine_gooddiet(totalFV)
```

## Arguments

- totalFV:

  Numeric value representing the average times per day fruits and
  vegetables were consumed in a year.

## Value

A categorical value indicating the diet quality:

- 1: Good diet (totalFV \>= 5)

- 2: Poor diet (totalFV \< 5)

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Categorize a totalFV value of 3 as poor diet
determine_gooddiet(3)
#> [1] 2
# Output: 2

# Example 2: Categorize a totalFV value of 7 as good diet
determine_gooddiet(7)
#> [1] 1
# Output: 1
```
