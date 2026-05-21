# Non-HDL cholesterol level

This function calculates a respondent's non-HDL cholesterol level by
subtracting their HDL cholesterol level from their total cholesterol
level. It first checks whether the input values `LAB_CHOL` (total
cholesterol) and `LAB_HDL` (HDL cholesterol) are both less than certain
thresholds (99.6 mmol/L and 9.96 mmol/L, respectively). If both
conditions are met, it calculates the non-HDL cholesterol level;
otherwise, it sets the non-HDL value to NA to indicate that the
calculation is not applicable.

## Usage

``` r
calculate_nonHDL(LAB_CHOL, LAB_HDL)
```

## Arguments

- LAB_CHOL:

  A numeric representing a respondent's total cholesterol level in
  mmol/L.

- LAB_HDL:

  A numeric representing a respondent's HDL cholesterol level in mmol/L.

## Value

A numeric representing the calculated non-HDL cholesterol level (in
mmol.L) if both `LAB_CHOL` and `LAB_HDL` are below the specified
thresholds; otherwise, it returns NA(b) to indicate that the calculation
is not applicable.

## Details

The function calculates the non-HDL cholesterol level by subtracting the
HDL cholesterol level from the total cholesterol level. It first checks
if both `LAB_CHOL` and `LAB_HDL` are less than the specified thresholds
(99.6 mmol/L and 9.96 mmol/L, respectively). If both conditions are met
and neither input is missing, the non-HDL cholesterol level is
calculated. If either of the conditions is not met or if either input is
missing (NA), the function returns NA(b) to indicate that the
calculation is not applicable.

## Examples

``` r

# Example: Respondent has total cholesterol of 50 mmol/L and HDL cholesterol of 5 mmol/L.
calculate_nonHDL(LAB_CHOL = 50, LAB_HDL = 5)
#> [1] 45
# Output: 45 (non-HDL cholesterol = total cholesterol - HDL cholesterol = 50 - 5 = 45)
```
