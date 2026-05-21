# Adjusted diastolic blood pressure

This function adjusts diastolic blood pressure based on the respondent's
diastolic average blood pressure across six measurements. The adjustment
is made using specific correction factors. The adjusted diastolic blood
pressure is returned as a numeric value.

## Usage

``` r
adjust_DBP(BPMDPBPD)
```

## Arguments

- BPMDPBPD:

  A numeric representing the respondent's diastolic average blood
  pressure (in mmHg) across six measurements.

## Value

The adjusted diastolic blood pressure as a numeric value.

## Details

The function calculates the adjusted diastolic blood pressure (DBP_adj)
based on the value of BPMDPBPD. If BPMDPBPD is greater than or equal to
0 and less than 996, the adjustment is made using the formula: DBP_adj =
15.6 + (0.83 \* BPMDPBPD). Otherwise, if BPMDPBPD is a non-response
value (BPMDPBPD \>= 996), the adjusted diastolic blood pressure is set
to NA(b), indicating that the measurement is not available. The adjusted
diastolic blood pressure is returned as the final output.

## Examples

``` r

# Example: Adjust for a respondent with average diastolic blood pressure of 80 mmHg.
adjust_DBP(BPMDPBPD = 80)
#> [1] 82
# Output: 82
```
