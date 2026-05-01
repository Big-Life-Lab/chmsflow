# chmsflow 0.1.0 (Medication Fixes)

## Breaking changes

- The `any_htn_med2` argument of `derive_hypertension()`, `derive_hypertension_adj()`, `derive_hypertension_control()`, and `derive_hypertension_control_adj()` has been renamed to `any_htn_med`. The `diab_med2` argument of `derive_diabetes_status()` has been renamed to `diab_med`. Calls that pass the old argument by name will fail with an "unused argument" error.
- The self-referential `any_htn_med2` and `diab_med2` entries in `inst/extdata/variable-details.csv` have been removed. New `any_htn_med` and `diab_med` entries cover all six cycles via three database tiers: `DerivedVar` rows for cycles 1-2 (`atc_*`/`mhr_*` columns), `DerivedVar` rows for cycles 3-6 (`meucatc`, `npi_25b`), and `copy` passthrough rows for the main cycle databases once medications have been merged in.

## New features

- `recode_meds_cycles1to2()` and `recode_meds_cycles3to6()` recode medication data and merge medication columns into the main cycle data frame in one call. Both share the same call signature, so the workflow is identical regardless of cycle:

    ```r
    cycle1 <- recode_meds_cycles1to2(cycle1, cycle1_meds, c("any_htn_med", "diab_med"))
    cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
    ```

- `aggregate_meds_by_person()` collapses long-format medication data to one row per respondent, preserving `tagged_na("a")` (valid skip) and `tagged_na("b")` (missing) distinctions across the aggregation.
- `recode_after_meds()` recodes derived variables (e.g. `htn_status`, `diab_status`) whose inputs include pre-computed medication variables, automatically excluding meds-database rows from `variable_details` so medication columns are passed through rather than re-derived from raw ATC/MHR columns.
- 16 ATC-classification functions (`is_ace_inhibitor()`, `is_beta_blocker()`, `is_calcium_channel_blocker()`, `is_diuretic()`, `is_diabetes_med()`, `is_nsaid()`, `is_any_antihtn_med()`, `is_other_antihtn_med()`, plus their `is_*_cycles1to2()` variants) are exported for custom workflows.

## Documentation

- New vignette `recoding_medications.qmd` documents the medication-recoding workflow for both cycle groupings, with a section on calling the underlying `is_*` classifiers directly.

# chmsflow 0.1.0 (First Steps)

## Features

- Added variables.csv that contains list of CHMS variables in chmsflow.
- Added variable-details.csv that maps variables across CHMS cycles 1-6
- Added Vignettes to describe the process of using rec_with_table() (part of recodeflow) to combine the data
