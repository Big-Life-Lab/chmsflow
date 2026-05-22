# Waist-to-height ratio (WHtR)

This function calculates the Waist-to-Height Ratio (WHtR) by dividing
the waist circumference by the height of the respondent.

## Usage

``` r
calculate_waist_height_ratio(hwm_11cm, hwm_14cx)
```

## Arguments

- hwm_11cm:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the height of the respondent in centimeters.

- hwm_14cx:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the waist circumference of the respondent in centimeters.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The WHtR. If inputs are
invalid or out of bounds, the function returns a tagged NA.

## Details

This function calculates the Waist-to-Height Ratio (WHtR), an indicator
of central obesity.

         **Missing Data Codes:**
         - `hwm_11cm`:
           - `999.96`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `999.97-999.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
         - `hwm_14cx`:
           - `999.6`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `999.7-999.9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Calculate WHtR for a respondent with height = 170 cm and waist circumference = 85 cm.
calculate_waist_height_ratio(hwm_11cm = 170, hwm_14cx = 85)
#> [1] 0.5
# Output: 0.5 (85/170)

# Example 2: Calculate WHtR for a respondent with missing height.
result <- calculate_waist_height_ratio(hwm_11cm = 999.98, hwm_14cx = 85)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_waist_height_ratio(hwm_11cm = c(170, 180, 160), hwm_14cx = c(85, 90, 80))
#> [1] 0.5 0.5 0.5
# Returns: c(0.5, 0.5, 0.5)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(whtr = calculate_waist_height_ratio(hwm_11cm, hwm_14cx))
```
