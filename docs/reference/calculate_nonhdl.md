# Non-HDL cholesterol level

This function calculates a respondent's non-HDL cholesterol level by
subtracting their HDL cholesterol level from their total cholesterol
level. It first checks whether the input values `lab_chol` (total
cholesterol) and `lab_hdl` (HDL cholesterol) are within valid ranges.

## Usage

``` r
calculate_nonhdl(lab_chol, lab_hdl)
```

## Arguments

- lab_chol:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  a respondent's total cholesterol level in mmol/L.

- lab_hdl:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  a respondent's HDL cholesterol level in mmol/L.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The calculated non-HDL
cholesterol level (in mmol/L). If inputs are invalid or out of bounds,
the function returns a tagged NA.

## Details

The function calculates the non-HDL cholesterol level by subtracting the
HDL cholesterol level from the total cholesterol level.

         **Missing Data Codes:**
         - `lab_chol`:
           - `99.96`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `99.97-99.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
         - `lab_hdl`:
           - `9.96`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `9.97-9.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`categorize_nonhdl()`](https://big-life-lab.github.io/chmsflow/reference/categorize_nonhdl.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example: Respondent has total cholesterol of 5.0 mmol/L and HDL cholesterol of 1.5 mmol/L.
calculate_nonhdl(lab_chol = 5.0, lab_hdl = 1.5)
#> [1] 3.5
# Output: 3.5

# Example: Respondent has non-response values for cholesterol.
result <- calculate_nonhdl(lab_chol = 99.98, lab_hdl = 1.5)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_nonhdl(lab_chol = c(5.0, 6.0, 7.0), lab_hdl = c(1.5, 1.0, 2.0))
#> [1] 3.5 5.0 5.0
# Returns: c(3.5, 5.0, 5.0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(non_hdl = calculate_nonhdl(lab_chol, lab_hdl))
```
