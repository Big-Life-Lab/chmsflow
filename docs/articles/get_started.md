# Get started

``` r

library(chmsflow)
```

## 1. Introduction

chmsflow harmonizes variables from the Canadian Health Measures Survey
(CHMS) across cycles 1–6 and derives health indicators used in health
research. It works with the
[recodeflow](https://big-life-lab.github.io/recodeflow/) package to
transform raw CHMS variables into analysis-ready versions using recoding
rules defined in CSV metadata files.

### What chmsflow provides

The package includes two metadata CSV files (`variables.csv` and
`variable-details.csv`) that define how raw CHMS variables are recoded,
and 42 functions that derive new health indicators. The table below
summarizes the available variables, organized by `section` and `subject`
as defined in `variables.csv`:

| Section | Subject | Examples |
|----|----|----|
| Sociodemographics | Age, sex, ethnicity | `clc_age`, `clc_sex`, `pgdcgt` |
| Socioeconomic | Income, education, occupation, marital status | `adj_hh_income`, `income_quintile`, `edudr04` |
| Health status | Blood pressure, hypertension | `sbp_adj_mmhg`, `htn_status`, `htn_control_status` |
| Health status | Chronic disease (diabetes, CKD, CVD) | `diab_status`, `ckd_status`, `cvd_status` |
| Health status | Medication (8 drug classes from ATC codes) | `ace_med`, `any_htn_med`, `diab_med` |
| Health status | Weight, height, cholesterol | `nonhdl_mmoll`, `waist_height_ratio`, `hwmdbmi` |
| Health status | Family history | `cvd_premature_famhist_status`, `fam_bp` |
| Health behaviour | Alcohol, diet | `alc_risk_score`, `fv_daily_times`, `healthy_diet_indicator` |
| Health behaviour | Exercise | `exercise_min_week`, `enough_exercise_indicator` |
| Health behaviour | Smoking | `pack_years`, `smoke` |

For the full variable list, see [Variable schema
reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).

### Typical workflow

1.  **Merge cycle components** - At the RDC, combine household, clinic,
    and lab data into one object per cycle (e.g., `cycle4`). Keep
    medication data separate as `cyclex_meds`.
2.  **Recode medications first** - If your analysis needs medication
    variables, always recode them before other variables. See [Recoding
    medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md).
3.  **Recode other variables** - Use
    [`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
    from recodeflow to transform source variables and derive new ones.

## 2. Installation

``` r

# Install release version from CRAN
install.packages("chmsflow")

# Install the most recent version from GitHub
devtools::install_github("Big-Life-Lab/chmsflow")
```

## 3. Quick start

Use
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
from recodeflow to transform CHMS variables. The cycle data object must
be named `cyclex` for recoding to work properly.

``` r

library(recodeflow)

# Recode a source variable (age)
cycle4_ages <- rec_with_table(
  cycle4, "clc_age",
  variable_details = variable_details, log = TRUE
)
```

    Using the passed data variable name as database_name

    The variable clc_age was recoded into clc_age for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1     copy    [3, 80]           50
    2    NA::a        996            0
    3    NA::b [997, 999]            0
    4     <NA>       else            0

``` r

head(cycle4_ages)
```

      clc_age
    1      73
    2      33
    3      22
    4      47
    5      74
    6      22

## 4. Variable types

chmsflow handles three types of variables, each recoded differently.

### 4.1 Source variables (direct mapping)

Source variables are mapped directly from raw CHMS columns. Variable
names may differ across cycles, but chmsflow harmonizes them to a single
name.

``` r

# Recode sex (same variable name across all cycles)
cycle4_sexes <- rec_with_table(
  cycle4, "clc_sex",
  variable_details = variable_details, log = TRUE
)
```

    Using the passed data variable name as database_name

    The variable clc_sex was recoded into clc_sex for the database cycle4 the following recodes were made: 

      value_to   From rows_recoded
    1        1      1           27
    2        2      2           23
    3    NA::a      6            0
    4    NA::b [7, 9]            0
    5    NA(b)   else            0

``` r

head(cycle4_sexes)
```

      clc_sex
    1       2
    2       2
    3       2
    4       2
    5       2
    6       2

### 4.2 Transformed variables (continuous to categorical)

Some variables convert continuous measurements into categories using
thresholds defined in `variable-details.csv`.

``` r

# Recode age into 4 groups
cycle4_categorical_ages <- rec_with_table(
  cycle4, "agegroup4",
  variable_details = variable_details, log = TRUE
)
```

    Using the passed data variable name as database_name

    The variable clc_age was recoded into agegroup4 for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1        1   [20, 39]           12
    2        2   [40, 59]           23
    3        3   [60, 69]            6
    4        4   [70, 79]            9
    5    NA::a        996            0
    6    NA::b [997, 999]            0
    7    NA(b)       else            0

``` r

head(cycle4_categorical_ages)
```

      agegroup4
    1         4
    2         1
    3         1
    4         2
    5         4
    6         1

### 4.3 Derived variables (computed by functions)

Derived variables are computed by R functions referenced as `Func::`
entries in `variable-details.csv`. These require their input variables
to be present in the data. See [Derived
variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.md)
for details.

``` r

# Derive adjusted systolic blood pressure
# bpmdpbps (raw SBP) must be in the data for sbp_adj_mmhg to be computed
cycle4_adjusted_SBPs <- rec_with_table(
  cycle4, c("bpmdpbps", "sbp_adj_mmhg"),
  variable_details = variable_details, log = TRUE
)
```

    Using the passed data variable name as database_name

    The variable bpmdpbps was recoded into bpmdpbps for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1     copy  [73, 216]           50
    2    NA::a        996            0
    3    NA::b [997, 999]            0
    4     <NA>       else            0

``` r

head(cycle4_adjusted_SBPs)
```

      bpmdpbps sbp_adj_mmhg
    1      207       203.91
    2      101       105.33
    3       92        96.96
    4      196       193.68
    5      152       152.76
    6       79        84.87

## 5. Next steps

- **Full walkthrough** – End-to-end hypertension prevalence analysis in
  [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md).
- **Medication recoding** – Required before deriving hypertension or
  diabetes status. See [Recoding
  medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md).
- **Understanding the metadata** – Learn about the CSV schema in
  [Variable schema
  reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).
- **Derived variables** – How `Func::` and `DerivedVar::` entries work
  in [Derived
  variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.md).
- **Adding variables** – Extend chmsflow with your own variables in [How
  to add
  variables](https://big-life-lab.github.io/chmsflow/articles/how_to_add_variables.md).
- **Missing data** – How
  [`haven::tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html)
  handles CHMS missing codes in [Missing data
  (tagged_na)](https://big-life-lab.github.io/chmsflow/articles/tagged_na_usage.md).
- **Methodology** – Why harmonization is non-trivial and how chmsflow
  works in
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).
- **RDC setup** – Using chmsflow at a Research Data Centre in [Using
  chmsflow at an
  RDC](https://big-life-lab.github.io/chmsflow/articles/using_chmsflow_at_an_rdc.md).
