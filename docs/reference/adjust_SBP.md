# Adjusted systolic blood pressure

This function adjusts systolic blood pressure based on the respondent's
systolic average blood pressure across six measurements. The adjustment
is made using specific correction factors. The adjusted systolic blood
pressure is returned as a numeric value.

## Usage

``` r
adjust_SBP(BPMDPBPS)
```

## Arguments

- BPMDPBPS:

  A numeric representing the respondent's systolic average blood
  pressure (in mmHg) across six measurements.

## Value

The adjusted systolic blood pressure as a numeric value.

## Details

The function calculates the adjusted systolic blood pressure (SBP_adj)
based on the value of BPMDPBPS. If BPMDPBPS is greater than or equal to
0 and less than 996, the adjustment is made using the formula: SBP_adj =
11.4 + (0.93 \* BPMDPBPS). Otherwise, if BPMDPBPS is a non-response
value (BPMDPBPS \>= 996), the adjusted systolic blood pressure is set to
NA(b), indicating that the measurement is not available. The adjusted
systolic blood pressure is returned as the final output.

## Examples

``` r

# Example: Adjust for a respondent with average systolic blood pressure of 120 mmHg.
adjust_SBP(BPMDPBPS = 120)
#> [1] 123
# Output: 123
```
