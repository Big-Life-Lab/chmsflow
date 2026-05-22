# Recoding CHMS medication variables

``` r

library(chmsflow)
library(recodeflow)
library(dplyr)
```

## 1. Introduction

chmsflow provides 16 functions that classify medications from ATC codes
recorded in CHMS clinic data. Each function checks whether a respondent
is taking a specific drug class and returns `1` (yes) or `0` (no), with
[`haven::tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html)
codes for missing or not-applicable responses.

### Available medication variables

| Variable | Drug class | ATC prefix | Cycles 3–6 function | Cycles 1–2 function |
|----|----|----|----|----|
| `ace_med` | ACE inhibitors | C09 | [`is_ace_inhibitor()`](https://big-life-lab.github.io/chmsflow/reference/is_ace_inhibitor.md) | [`is_ace_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_ace_med_cycles1to2.md) |
| `bb_med` | Beta blockers | C07 | [`is_beta_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_beta_blocker.md) | [`is_bb_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_bb_med_cycles1to2.md) |
| `ccb_med` | Calcium channel blockers | C08 | [`is_calcium_channel_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_calcium_channel_blocker.md) | [`is_ccb_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_ccb_med_cycles1to2.md) |
| `diur_med` | Diuretics | C03 | [`is_diuretic()`](https://big-life-lab.github.io/chmsflow/reference/is_diuretic.md) | [`is_diur_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_diur_med_cycles1to2.md) |
| `misc_htn_med` | Other antihypertensives | mixed | [`is_other_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_other_antihtn_med.md) | [`is_misc_htn_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_misc_htn_med_cycles1to2.md) |
| `any_htn_med` | Any antihypertensive | combined | [`is_any_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_any_antihtn_med.md) | [`is_any_htn_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_any_htn_med_cycles1to2.md) |
| `nsaid_med` | NSAIDs | M01A | [`is_nsaid()`](https://big-life-lab.github.io/chmsflow/reference/is_nsaid.md) | [`is_nsaid_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_nsaid_med_cycles1to2.md) |
| `diab_med` | Diabetes medications | A10 | [`is_diabetes_med()`](https://big-life-lab.github.io/chmsflow/reference/is_diabetes_med.md) | [`is_diab_med_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/is_diab_med_cycles1to2.md) |

### Cycle differences

Medication data is structured differently across CHMS cycles:

- **Cycles 1–2** store medications in a flat format with up to 80
  individual columns (`atc_101a` to `atc_235a` for ATC codes, `mhr_101b`
  to `mhr_235b` for time last taken). The cycles 1–2 wrapper functions
  accept all of these columns as parameters.
- **Cycles 3–6** store medications in a multi-row format with two
  variables per row: `meucatc` (ATC code) and `npi_25b` (time last
  taken). Each respondent may have multiple rows. After recoding,
  results must be aggregated by `clinicid`.

## 2. When to use medication recoding

If your analysis requires medication variables, ***always perform
medication recoding first***, before recoding any other variables. Two
downstream health outcome variables depend on medication status:

- **Hypertension** – `any_htn_med` must be merged into the main cycle
  dataset before deriving hypertension outcomes.
- **Diabetes** – `diab_med` must be merged before deriving diabetes
  outcomes.

## 3. Workflow

The workflow is the same for all cycles: recode medication variables and
merge into the main cycle dataset using
[`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)
or
[`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md),
then derive health outcomes using
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md).
Use
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
instead of
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
– it automatically excludes medication-specific rows from
`variable_details` so pre-computed medication columns are passed through
rather than re-derived.

### 3.1 Cycles 1–2

Cycles 1–2 medication data uses uppercase column names (`CLINICID`,
`ATC_101A`, etc.).
[`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)
normalizes these internally.

**Step 1** – Recode medication variables and merge with main cycle data.
Requires: `cycle1`, `cycle1_meds`.

``` r

cycle1 <- recode_meds_cycles1to2(cycle1, cycle1_meds, c("any_htn_med", "diab_med"))
```

**Step 2** – Derive diabetes status. Requires: `cycle1` from Step 1.

``` r

cycle1_diab_data <- recode_after_meds(
  cycle1,
  c("lab_hba1", "diab_a1c", "diab_med", "ccc_51", "diab_status")
)
head(select(cycle1_diab_data, clinicid, diab_status))
```

      clinicid diab_status
    1        1           1
    2        2           2
    3        3        <NA>
    4        4           1
    5        5           1
    6        6           2

**Step 3** – Derive hypertension status. Requires: `cycle1` from Step 1.

``` r

cycle1_htn_data <- recode_after_meds(
  cycle1,
  c(
    # Blood pressure (raw + adjusted)
    "bpmdpbps", "bpmdpbpd", "sbp_adj_mmhg", "dbp_adj_mmhg",
    # Medication inputs (merged in Step 1)
    "any_htn_med", "ccc_32",
    # Diabetes chain (input to htn functions)
    "lab_hba1", "diab_a1c", "ccc_51", "diab_med", "diab_status",
    # CVD chain
    "ccc_61", "ccc_63", "ccc_81", "cvd_status",
    # CKD chain
    "lab_bcre", "pgdcgt", "clc_sex", "clc_age", "gfr_ml_min", "ckd_status",
    # Hypertension outcomes
    "htn_status", "htn_adj_status", "htn_control_status", "htn_control_adj_status"
  )
)
```

    NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to other"

``` r

head(select(cycle1_htn_data, clinicid, htn_status, htn_adj_status))
```

      clinicid htn_status htn_adj_status
    1        1          1              1
    2        2          1              1
    3        3          1              1
    4        4          1              1
    5        5          1              1
    6        6          1              1

### 3.2 Cycles 3–6

**Step 1** – Recode medication variables and merge with main cycle data.
Requires: `cycle3`, `cycle3_meds`.

``` r

cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
```

**Step 2** – Derive diabetes status. Requires: `cycle3` from Step 1.

``` r

cycle3_diab_data <- recode_after_meds(
  cycle3,
  c("lab_hba1", "diab_a1c", "diab_med", "ccc_51", "diab_status")
)
head(select(cycle3_diab_data, clinicid, diab_status))
```

      clinicid diab_status
    1        1           1
    2        2           1
    3        3           1
    4        4           1
    5        5           1
    6        6           1

**Step 3** – Derive hypertension status. Requires: `cycle3` from Step 1.

`cvd_status`, `diab_status`, and `ckd_status` are intermediate inputs to
the hypertension functions. Their full input chains must also be listed
so
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
can derive them.

``` r

cycle3_htn_data <- recode_after_meds(
  cycle3,
  c(
    # Blood pressure (raw + adjusted)
    "bpmdpbps", "bpmdpbpd", "sbp_adj_mmhg", "dbp_adj_mmhg",
    # Medication inputs (merged in Step 1)
    "any_htn_med", "ccc_32",
    # Diabetes chain (input to htn functions)
    "lab_hba1", "diab_a1c", "ccc_51", "diab_med", "diab_status",
    # CVD chain
    "ccc_61", "ccc_63", "ccc_81", "cvd_status",
    # CKD chain
    "lab_bcre", "pgdcgt", "clc_sex", "clc_age", "gfr_ml_min", "ckd_status",
    # Hypertension outcomes
    "htn_status", "htn_adj_status", "htn_control_status", "htn_control_adj_status"
  )
)
```

    NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to other"

``` r

head(select(cycle3_htn_data, clinicid, htn_status, htn_adj_status))
```

      clinicid htn_status htn_adj_status
    1        1          1              1
    2        2          1              1
    3        3          1              1
    4        4          1              1
    5        5          1              1
    6        6          1              1

## 4. Advanced: using individual classification functions

The `is_*` functions underlie the wrapper functions and are available
directly for custom workflows – for example, deriving a single drug
class without the full pipeline, or integrating classification logic
into your own aggregation steps.

Each function accepts an ATC code and a time-last-taken value and
returns `1`, `0`, or a `tagged_na()` code:

``` r

# Single medication classification
is_beta_blocker("C07AA05", 1) # returns 1
```

    [1] 1

``` r

is_ace_inhibitor("C09AA02", 1) # returns 1
```

    [1] 1

``` r

is_diabetes_med("A10BA02", 1) # returns 1
```

    [1] 1

### Cycle format differences

**Cycles 1–2** – one row per respondent with up to 80 `atc_*/mhr_*`
column pairs. The `is_*_med_cycles1to2()` variants accept named
arguments for each slot:

``` r

# Classification using cycles 1--2 wide-format columns
is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 1) # returns 1
```

    [1] 1

``` r

is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 6) # returns 0 (not taken recently)
```

    [1] 0

**Cycles 3–6** – one row per medication per respondent with two columns:
`meucatc` (ATC code) and `npi_25b` (time last taken). Classify per row,
then aggregate across rows per respondent:

``` r

cycle3_meds |>
  mutate(ace_med = is_ace_inhibitor(meucatc, npi_25b)) |>
  aggregate_meds_by_person(variables = "ace_med")
```

    # A tibble: 50 × 2
       clinicid ace_med
          <int>   <dbl>
     1        1       1
     2        2       1
     3        3       1
     4        4       1
     5        5       1
     6        6       1
     7        7       1
     8        8       1
     9        9       1
    10       10       1
    # ℹ 40 more rows

> **Warning**
>
> Avoid using `as.numeric(as.character(.x))` to aggregate medication
> columns. That pattern strips `tagged_na("a")` (valid skip) and
> `tagged_na("b")` (missing/refused) distinctions, collapsing them into
> plain `NA`. Use
> [`aggregate_meds_by_person()`](https://big-life-lab.github.io/chmsflow/reference/aggregate_meds_by_person.md)
> instead – it preserves tagged-NA semantics across the aggregation.

## Next steps

- **Full analysis example** – See how medication recoding fits into an
  end-to-end workflow in [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md).
- **Understand missing data** – Learn how `tagged_na("a")` and
  `tagged_na("b")` are preserved through the medication pipeline in
  [Missing data
  (tagged_na)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md).
- **Inspect the metadata** – See how medication variables are defined in
  `variable-details.csv` in [Variable schema
  reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).
- **Work at an RDC** – For loading real CHMS medication data at a
  Research Data Centre, see [Using chmsflow at an
  RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md).
