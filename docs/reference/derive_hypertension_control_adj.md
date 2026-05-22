# Controlled hypertension derived variable with adjusted blood pressures

This function determines the controlled hypertension status of a
respondent based on their adjusted systolic and diastolic blood pressure
measurements and medication usage.

## Usage

``` r
derive_hypertension_control_adj(
  sbp_adj_mmhg,
  dbp_adj_mmhg,
  any_htn_med,
  ccc_32 = 2,
  cvd_status = 2,
  diab_status = 2,
  ckd_status = 2
)
```

## Arguments

- sbp_adj_mmhg:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the adjusted systolic blood pressure measurement of the respondent.

- dbp_adj_mmhg:

  [integer](https://rdrr.io/r/base/integer.html) An integer representing
  the adjusted diastolic blood pressure measurement of the respondent.

- any_htn_med:

  [integer](https://rdrr.io/r/base/integer.html) An integer indicating
  whether the respondent is on medication for hypertension.

  - 1: Yes

  - 0: No

- ccc_32:

  [integer](https://rdrr.io/r/base/integer.html) An optional integer
  indicating whether the respondent is actually on medication for
  hypertension.

  - 1: Yes

  - 2: No (default)

- cvd_status:

  [integer](https://rdrr.io/r/base/integer.html) An optional integer
  indicating the presence of cardiovascular disease, affecting
  medication status.

  - 1: Yes

  - 2: No (default)

- diab_status:

  [integer](https://rdrr.io/r/base/integer.html) An optional integer
  indicating the presence of diabetes, affecting blood pressure
  thresholds.

  - 1: Yes

  - 2: No (default)

- ckd_status:

  [integer](https://rdrr.io/r/base/integer.html) An optional integer
  indicating the presence of chronic kidney disease, affecting blood
  pressure thresholds.

  - 1: Yes

  - 2: No (default)

## Value

[integer](https://rdrr.io/r/base/integer.html) The hypertension status:

- 1: Hypertension controlled (BP \< 140/90 mmHg (or \< 130/80 mmHg if
  diabetes or CKD) when on hypertension medication)

- 2: Hypertension not controlled (BP \>= 140/90 mmHg (or \>= 130/80 mmHg
  if diabetes or CKD) when on hypertension medication)

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function assesses whether a respondent's hypertension is controlled
using adjusted BP values:

         **Control Thresholds:**
         - General population: < 140/90 mmHg
         - Diabetes or CKD patients: < 130/80 mmHg

         **Logic:**
         - Only applies to respondents taking hypertension medication.
         - If adjusted BP is below the threshold, hypertension is "controlled" (1).
         - If adjusted BP is at or above the threshold, it is "not controlled" (2).

         **Missing Data Codes:**
         - `sbp_adj_mmhg`, `dbp_adj_mmhg`:
           - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
         - `any_htn_med`:
           - Tagged NA "a": Valid skip.
           - Tagged NA "b": Don't know, refusal, or not stated.
         - `ccc_32`, `cvd_status`, `diab_status`, `ckd_status`:
           - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`derive_hypertension_control()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension_control.md)
for controlled status with unadjusted BP

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
derive_hypertension_control_adj(sbp_adj_mmhg = 150, dbp_adj_mmhg = 95, any_htn_med = 1)
#> [1] 2
# Output: 2 (Hypertension not controlled due to high adjusted SBP and DBP despite medication usage).

# Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and on medication.
derive_hypertension_control_adj(sbp_adj_mmhg = 120, dbp_adj_mmhg = 80, any_htn_med = 1)
#> [1] 1
# Output: 1 (Hypertension controlled as adjusted BP is below 140/90 mmHg and on medication).

# Example 3: Respondent has non-response BP values of 996 for both systolic and diastolic.
result <- derive_hypertension_control_adj(sbp_adj_mmhg = 996, dbp_adj_mmhg = 996, any_htn_med = 0)
result # Shows: NA
#> [1] 2
haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#> [1] FALSE
format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#> [1] "2"

# Multiple respondents
derive_hypertension_control_adj(
  sbp_adj_mmhg = c(150, 120, 135), dbp_adj_mmhg = c(95, 80, 85),
  any_htn_med = c(1, 1, 1), diab_status = c(2, 2, 1)
)
#> [1] 2 1 2
# Returns: c(2, 1, 2)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(controlled_htn_adj = derive_hypertension_control_adj(sbp_adj_mmhg,
#     dbp_adj_mmhg, any_htn_med))
```
