# Estimated glomerular filtration rate (GFR)

This function calculates the estimated glomerular filtration rate (GFR)
according to Finlay's formula, where serum creatine is in mg/dL. The
calculation takes into account the respondent's ethnicity, sex, and age.

## Usage

``` r
calculate_GFR(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE)
```

## Arguments

- LAB_BCRE:

  Blood creatine (µmol/L). It should be a numeric value between 14 and
  785.

- PGDCGT:

  Ethnicity (13 categories). It should be an integer value between 1 and
  13.

- CLC_SEX:

  Sex (Male = 1, Female = 2). It should be an integer value of either 1
  or 2.

- CLC_AGE:

  Age (years). It should be a numeric value between 3 and 79.

## Value

The calculated GFR as a numeric value. If any of the input parameters
(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE) are non-response values (LAB_BCRE
\>= 996, PGDCGT \>= 96, CLC_SEX \>= 6, CLC_AGE \>= 996) or out of
bounds, the GFR will be NA(b).

## Details

The function uses the serum creatine level (LAB_BCRE) in µmol/L to
calculate the estimated GFR. First, it checks if any of the input
parameters are non-response values. If any non-response values are
found, the GFR will be set to NA, and the function will return
immediately. Otherwise, it proceeds with the calculation by converting
the serum creatine to mg/dL (serumcreat = LAB_BCRE / 88.4). Based on the
respondent's ethnicity (PGDCGT), sex (CLC_SEX), and age (CLC_AGE), the
appropriate formula is applied to calculate the GFR. The formula used
for each combination of ethnicity and sex is as follows:

         - Female and Black (PGDCGT == 2, CLC_SEX == 2): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
                                                        (0.742) * (1.210)
         - Female and not Black (PGDCGT != 2, CLC_SEX == 2): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
                                                            (0.742)
         - Male and Black (PGDCGT == 2, CLC_SEX == 1): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
                                                      (1.210)
         - Male and not Black (PGDCGT != 2, CLC_SEX == 1): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203))

## Examples

``` r

# Example 1: Calculate GFR for a 45-year-old white female with serum creatine of 80 µmol/L.
calculate_GFR(LAB_BCRE = 80, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 45)
#> [1] 67.27905
# Output: GFR = 67.27905

# Example 2: Calculate GFR for a 35-year-old black female with serum creatine of 70 µmol/L.
calculate_GFR(LAB_BCRE = 70, PGDCGT = 2, CLC_SEX = 2, CLC_AGE = 35)
#> [1] 99.94114
# Output: GFR = 99.94114
```
