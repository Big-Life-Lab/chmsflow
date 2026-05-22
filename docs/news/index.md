# Changelog

## chmsflow 0.1.0

### Basic features

- Added variables.csv that contains list of CHMS variables in chmsflow.
- Added variable-details.csv that maps variables across CHMS cycles 1-6
- Added Vignettes to describe the process of using rec_with_table()
  (part of recodeflow) to combine the data

### Medication features

- [`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)
  and
  [`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md)
  recode medication data and merge medication columns into the main
  cycle data frame in one call. Both share the same call signature, so
  the workflow is identical regardless of cycle:

  ``` r

  cycle1 <- recode_meds_cycles1to2(cycle1, cycle1_meds, c("any_htn_med", "diab_med"))
  cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
  ```

- [`aggregate_meds_by_person()`](https://big-life-lab.github.io/chmsflow/reference/aggregate_meds_by_person.md)
  collapses long-format medication data to one row per respondent,
  preserving `tagged_na("a")` (valid skip) and `tagged_na("b")`
  (missing) distinctions across the aggregation.

- [`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
  recodes derived variables (e.g. `htn_status`, `diab_status`) whose
  inputs include pre-computed medication variables, automatically
  excluding meds-database rows from `variable_details` so medication
  columns are passed through rather than re-derived from raw ATC/MHR
  columns.

- 16 ATC-classification functions
  ([`is_ace_inhibitor()`](https://big-life-lab.github.io/chmsflow/reference/is_ace_inhibitor.md),
  [`is_beta_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_beta_blocker.md),
  [`is_calcium_channel_blocker()`](https://big-life-lab.github.io/chmsflow/reference/is_calcium_channel_blocker.md),
  [`is_diuretic()`](https://big-life-lab.github.io/chmsflow/reference/is_diuretic.md),
  [`is_diabetes_med()`](https://big-life-lab.github.io/chmsflow/reference/is_diabetes_med.md),
  [`is_nsaid()`](https://big-life-lab.github.io/chmsflow/reference/is_nsaid.md),
  [`is_any_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_any_antihtn_med.md),
  [`is_other_antihtn_med()`](https://big-life-lab.github.io/chmsflow/reference/is_other_antihtn_med.md),
  plus their `is_*_cycles1to2()` variants) are exported for custom
  workflows.

- New vignette `recoding_medications.qmd` documents the
  medication-recoding workflow for both cycle groupings, with a section
  on calling the underlying `is_*` classifiers directly.

### Breaking changes (medications)

- The `any_htn_med2` argument of
  [`derive_hypertension()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension.md),
  [`derive_hypertension_adj()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension_adj.md),
  [`derive_hypertension_control()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension_control.md),
  and
  [`derive_hypertension_control_adj()`](https://big-life-lab.github.io/chmsflow/reference/derive_hypertension_control_adj.md)
  has been renamed to `any_htn_med`. The `diab_med2` argument of
  [`derive_diabetes_status()`](https://big-life-lab.github.io/chmsflow/reference/derive_diabetes_status.md)
  has been renamed to `diab_med`. Calls that pass the old argument by
  name will fail with an “unused argument” error.
- The self-referential `any_htn_med2` and `diab_med2` entries in
  `inst/extdata/variable-details.csv` have been removed. New
  `any_htn_med` and `diab_med` entries cover all six cycles via three
  database tiers: `DerivedVar` rows for cycles 1-2 (`atc_*`/`mhr_*`
  columns), `DerivedVar` rows for cycles 3-6 (`meucatc`, `npi_25b`), and
  `copy` passthrough rows for the main cycle databases once medications
  have been merged in.
