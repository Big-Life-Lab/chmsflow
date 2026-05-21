# Hypertension derived variable with adjusted blood pressures

This function determines the hypertension status of a respondent based
on their adjusted systolic and diastolic blood pressure measurements and
medication usage.

## Usage

``` r
determine_adjusted_hypertension(
  SBP_adj,
  DBP_adj,
  ANYMED2,
  CCC_32 = 2,
  CARDIOV = 2,
  DIABX = 2,
  CKD = 2
)
```

## Arguments

- SBP_adj:

  An integer representing the adjusted systolic blood pressure
  measurement of the respondent.

- DBP_adj:

  An integer representing the adjusted diastolic blood pressure
  measurement of the respondent.

- ANYMED2:

  An integer indicating whether the respondent is on medication for
  hypertension.

  - 1: Yes

  - 0: No

- CCC_32:

  An optional integer indicating whether the respondent is actually on
  medication for hypertension.

  - 1: Yes

  - 2: No (default)

- CARDIOV:

  An optional integer indicating the presence of cardiovascular disease,
  affecting medication status.

  - 1: Yes

  - 2: No (default)

- DIABX:

  An optional integer indicating the presence of diabetes, affecting
  blood pressure thresholds.

  - 1: Yes

  - 2: No (default)

- CKD:

  An optional integer indicating the presence of chronic kidney disease,
  affecting blood pressure thresholds.

  - 1: Yes

  - 2: No (default)

## Value

An integer representing the hypertension status:

- 1: High blood pressure (adjusted BP ≥ 140/90 mmHg (or ≥ 130/80 mmHg if
  diabetes or CKD) or on hypertension medication)

- 2: Normal blood pressure (adjusted BP \< 140/90 mmHg (or \< 130/80
  mmHg if diabetes or CKD) and not on hypertension medication)

- NA(b): Invalid input or non-response

## Examples

``` r

# Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
determine_adjusted_hypertension(SBP_adj = 150, DBP_adj = 95, ANYMED2 = 1)
#> [1] 1
# Output: 1 (High blood pressure due to adjusted SBP, adjusted DBP, and medication usage).

# Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and not on medication.
determine_adjusted_hypertension(SBP_adj = 120, DBP_adj = 80, ANYMED2 = 2)
#> [1] 1
# Output: 2 (Normal blood pressure as adjusted BP is below 140/90 mmHg and not on medication).
```
