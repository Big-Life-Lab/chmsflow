# Analysis walkthrough: hypertension prevalence

``` r

library(chmsflow)
library(recodeflow)
library(dplyr)
```

## Overview

This tutorial walks through a complete analysis using chmsflow:
estimating hypertension prevalence for CHMS cycle 3. The same workflow
applies to cycles 4–6 – just swap the cycle number.

The steps are:

1.  Load cycle data and medication data
2.  Recode medications and merge into cycle data
3.  Derive hypertension status and its input variables
4.  Inspect results
5.  Combine cycles into one dataset

## 1. Load data

chmsflow includes bundled dummy data for all six CHMS cycles. Each cycle
has a main dataset (`cycle3`, `cycle4`, etc.) and a medication dataset
(`cycle3_meds`, `cycle4_meds`, etc.).

``` r

# Bundled dummy data is loaded automatically with library(chmsflow)
dim(cycle3)
```

    [1] 50 81

``` r

dim(cycle3_meds)
```

    [1] 4000    3

At an RDC, you would load real CHMS data from Stata or SAS files
instead. See [Using chmsflow at an
RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md)
for setup instructions.

## 2. Recode medications

Medication recoding must happen before deriving hypertension status,
because the hypertension derivation uses `any_htn_med` as an input. For
full details on medication recoding, see [Recoding
medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md).

[`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md)
classifies each medication row by drug class, aggregates to one row per
respondent, and merges the result into the main cycle data.

``` r

cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
```

After this step, `any_htn_med` and `diab_med` are columns in the cycle
dataset.

``` r

select(cycle3, clinicid, any_htn_med, diab_med) |> head()
```

      clinicid any_htn_med diab_med
    1        1           1        1
    2        2           1        1
    3        3           1        1
    4        4           1        1
    5        5           1        1
    6        6           1        1

## 3. Derive hypertension status

Use
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
instead of
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
for variables that depend on medication status. It automatically
excludes medication-specific rows from `variable_details` so the
pre-computed medication columns are passed through rather than
re-derived.

Hypertension derivation requires a chain of intermediate variables:
blood pressure measurements, comorbidities (diabetes, CVD, CKD), and
their inputs. List all of them so
[`recode_after_meds()`](https://big-life-lab.github.io/chmsflow/reference/recode_after_meds.md)
can derive them in order.

``` r

htn_variables <- c(
  # Blood pressure (raw + adjusted)
  "bpmdpbps", "bpmdpbpd", "sbp_adj_mmhg", "dbp_adj_mmhg",
  # Medication inputs (merged in step 2)
  "any_htn_med", "ccc_32",
  # Diabetes chain (input to hypertension functions)
  "lab_hba1", "diab_a1c", "ccc_51", "diab_med", "diab_status",
  # CVD chain
  "ccc_61", "ccc_63", "ccc_81", "cvd_status",
  # CKD chain
  "lab_bcre", "pgdcgt", "clc_sex", "clc_age", "gfr_ml_min", "ckd_status",
  # Hypertension outcomes
  "htn_status", "htn_adj_status", "htn_control_status", "htn_control_adj_status"
)

cycle3_htn <- recode_after_meds(cycle3, htn_variables)
```

    NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to other"

## 4. Inspect results

The result contains the derived hypertension variables alongside
`clinicid`. Values are:

- `1` – high blood pressure
- `2` – normal blood pressure
- `tagged_na("a")` – not applicable
- `tagged_na("b")` – missing

``` r

cycle3_htn |>
  select(clinicid, htn_status, htn_adj_status) |>
  head(10)
```

       clinicid htn_status htn_adj_status
    1         1          1              1
    2         2          1              1
    3         3          1              1
    4         4          1              1
    5         5          1              1
    6         6          1              1
    7         7          1              1
    8         8          1              1
    9         9          1              1
    10       10          1              1

To see the distribution and prevalence:

``` r

table(cycle3_htn$htn_status, useNA = "always")
```


       1 <NA>
      50    0 

``` r

cycle3_htn |>
  filter(!is.na(htn_status)) |>
  summarise(
    n = n(),
    n_htn = sum(htn_status == 1),
    prevalence = mean(htn_status == 1)
  )
```

       n n_htn prevalence
    1 50    50          1

For more on how chmsflow handles missing data codes, see [Missing data
(tagged_na)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md).

## 5. Combine cycles

To analyse multiple cycles, repeat steps 2–3 for each cycle, add a cycle
identifier, and bind them together.

``` r

# Repeat for cycles 4-6
cycle4 <- recode_meds_cycles3to6(cycle4, cycle4_meds, c("any_htn_med", "diab_med"))
cycle5 <- recode_meds_cycles3to6(cycle5, cycle5_meds, c("any_htn_med", "diab_med"))
cycle6 <- recode_meds_cycles3to6(cycle6, cycle6_meds, c("any_htn_med", "diab_med"))

cycle4_htn <- recode_after_meds(cycle4, htn_variables)
cycle5_htn <- recode_after_meds(cycle5, htn_variables)
cycle6_htn <- recode_after_meds(cycle6, htn_variables)

# Add cycle identifiers and combine
cycle3_htn$cycle <- 3
cycle4_htn$cycle <- 4
cycle5_htn$cycle <- 5
cycle6_htn$cycle <- 6

combined <- bind_rows(cycle3_htn, cycle4_htn, cycle5_htn, cycle6_htn)

# Hypertension prevalence by cycle
combined |>
  filter(!is.na(htn_status)) |>
  group_by(cycle) |>
  summarise(
    n = n(),
    n_htn = sum(htn_status == 1),
    prevalence = mean(htn_status == 1)
  )
```

## Next steps

- **Add more drug classes** – This walkthrough used `any_htn_med` and
  `diab_med`, but chmsflow supports 8 drug classes. See [Recoding
  medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)
  for the full list and how to use individual classification functions.
- **Include cycles 1–2** – Cycles 1–2 use a different medication format
  but the same downstream workflow. See [Recoding
  medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)
  for the cycles 1–2 pipeline.
- **Understand the recoding rules** – To inspect or customize how
  variables are harmonized, see [Variable schema
  reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).
- **Handle missing data carefully** – The `tagged_na("a")` and
  `tagged_na("b")` values in results carry different meanings. See
  [Missing data
  (tagged_na)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md).
- **Work at an RDC** – To run this analysis on real CHMS data, see
  [Using chmsflow at an
  RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md).
- **Understand the methodology** – For why harmonization is non-trivial
  and how chmsflow works under the hood, see
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).
