# Adjusted total household income

This function calculates the adjusted total household income based on
the respondent's income amount and actual household size, taking into
account the weighted household size.

## Usage

``` r
calculate_hhld_income(THI_01, DHHDHSZ)
```

## Arguments

- THI_01:

  A numeric representing the respondent's household income amount in
  dollars.

- DHHDHSZ:

  An integer representing the respondent's actual household size in
  persons.

## Value

The calculated adjusted total household income as a numeric value. If
any of the input parameters (THI_01, DHHDHSZ) are non-response values
(THI_01 \>= 996, DHHDHSZ \>= 996), the adjusted household income will be
NA(b) (Not Available).

## Details

The function first calculates the weighted household size (hh_size_wt)
based on the respondent's actual household size (DHHDHSZ). It uses a
loop to iterate from 1 to DHHDHSZ and assigns weights to each household
member based on their count. If the household size (i) is 1, the weight
is 1; if i is 2, the weight is 0.4; if i is greater than or equal to 3,
the weight is 0.3. The weighted household size is then used to adjust
the respondent's total household income (THI_01) by dividing it by
hh_size_wt. The adjusted household income (adj_hh_inc) is returned as
the final output.

## Examples

``` r

# Example 1: Respondent with $50,000 income and a household size of 3.
calculate_hhld_income(THI_01 = 50000, DHHDHSZ = 3)
#> [1] 29411.76
# Output: 29411.76

# Example 2: Respondent with $75000 income and a household size of 2.
calculate_hhld_income(THI_01 = 75000, DHHDHSZ = 2)
#> [1] 53571.43
# Output: 53571.43

# Example 3: Respondent with $90000 income and a household size of 1.
calculate_hhld_income(THI_01 = 90000, DHHDHSZ = 1)
#> [1] 90000
# Output: 90000
```
