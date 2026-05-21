# Chronic kidney disease (CKD) derived variable

This function categorizes individuals' glomerular filtration rate (GFR)
into stages of Chronic Kidney Disease (CKD).

## Usage

``` r
categorize_GFR_to_CKD(GFR)
```

## Arguments

- GFR:

  Numeric value representing the glomerular filtration rate.

## Value

A categorical value indicating the CKD stage:

- 1: GFR of 60 or below (indicating CKD)

- 2: GFR above 60 (not indicating CKD)

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Categorize a GFR of 45
categorize_GFR_to_CKD(45)
#> [1] 1
# Output: 1

# Example 2: Categorize a GFR of 75
categorize_GFR_to_CKD(75)
#> [1] 2
# Output: 2
```
