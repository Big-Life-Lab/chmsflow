# Waist-to-height ratio (WHR)

This function calculates the Waist-to-Height Ratio (WHR) by dividing the
waist circumference by the height of the respondent.

## Usage

``` r
calculate_WHR(HWM_11CM, HWM_14CX)
```

## Arguments

- HWM_11CM:

  A numeric value representing the height of the respondent in
  centimeters.

- HWM_14CX:

  A numeric value representing the waist circumference of the respondent
  in centimeters.

## Value

A numeric value representing the WHR:

- If both `HWM_11CM` and `HWM_14CX` are provided, the function returns
  the WHR (waist circumference divided by height).

- If either `HWM_11CM` or `HWM_14CX` is missing, the function returns a
  tagged NA (`NA(b)`) indicating an invalid input or non-response.

## Examples

``` r

# Example 1: Calculate WHR for a respondent with height = 170 cm and waist circumference = 85 cm.
calculate_WHR(HWM_11CM = 170, HWM_14CX = 85)
#> [1] 0.5
# Output: 0.5 (85/170)

# Example 2: Calculate WHR for a respondent with missing height.
calculate_WHR(HWM_11CM = NA, HWM_14CX = 85)
#> [1] NA
# Output: NA(b)
```
