# Using chmsflow at an RDC

## Overview

Statistics Canada Research Data Centres (RDCs) provide access to CHMS
master files in a controlled environment with no internet access. This
means you cannot install packages from CRAN or GitHub inside the RDC.
This vignette explains how to set up chmsflow at an RDC and how to
organize your workflow between the RDC and your regular development
environment.

## Workflow

Working with chmsflow at an RDC follows a three-step model:

1.  **Develop outside the RDC** – Write and test your R scripts using
    chmsflow’s bundled dummy data on your own computer. The dummy data
    mirrors the structure of the real CHMS data, so your code will run
    the same way inside the RDC.
2.  **Have the RDC analyst set up the environment** – The RDC analyst
    places the R packages, CHMS data files, and your R scripts into the
    RDC environment (typically on your P drive).
3.  **Run inside the RDC** – Go into the RDC and run your tested scripts
    against the real CHMS master file data.

This separation means you can iterate on your analysis code without
using RDC time, and only go in when the code is ready to run on real
data.

## Setup inside the RDC

### 1. Set the library path

Since there is no internet access at the RDC, all R package dependencies
(chmsflow, recodeflow, dplyr, haven, purrr, etc.) must be pre-installed
in a folder on your P drive. The RDC analyst can do this for you. Then
point R to that folder:

``` r

.libPaths("<path_to_your_P_drive_package_folder>")
```

Note that `renv` does not work at the RDC because
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
requires internet access to download packages.

### 2. Load packages

``` r

library(chmsflow)
library(recodeflow)
library(dplyr)
```

### 3. Load additional scripts and worksheets

If you have custom functions or modified metadata files, load them with
[`source()`](https://rdrr.io/r/base/source.html) and
[`read.csv()`](https://rdrr.io/r/utils/read.table.html):

``` r

source("my_custom_functions.R")
my_variable_details <- read.csv("my_variable_details.csv")
```

### 4. Load CHMS data

Load CHMS data files and name the objects to match chmsflow’s naming
conventions. This is important because
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
uses the object name to match the `databaseStart` column in
`variable-details.csv`.

- Name main cycle data as `cycle1` through `cycle6`
- Name medication data as `cycle1_meds` through `cycle6_meds`

``` r

# Cycles 1-6: Stata format
cycle1 <- haven::read_stata("cycle1.dta")
cycle2 <- haven::read_stata("cycle2.dta")
cycle3 <- haven::read_stata("cycle3.dta")
cycle4 <- haven::read_stata("cycle4.dta")
cycle5 <- haven::read_stata("cycle5.dta")
cycle6 <- haven::read_stata("cycle6.dta")

# Medication data: Stata for cycles 3-6, SAS for cycles 1-2
cycle1_meds <- haven::read_sas("cycle1_meds.sas7bdat")
cycle2_meds <- haven::read_sas("cycle2_meds.sas7bdat")
cycle3_meds <- haven::read_stata("cycle3_meds.dta")
cycle4_meds <- haven::read_stata("cycle4_meds.dta")
cycle5_meds <- haven::read_stata("cycle5_meds.dta")
cycle6_meds <- haven::read_stata("cycle6_meds.dta")
```

Some cycles use uppercase column names. Lowercase them so
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
can match the variable names in `variable-details.csv`:

``` r

names(cycle1) <- tolower(names(cycle1))
names(cycle4) <- tolower(names(cycle4))
names(cycle6) <- tolower(names(cycle6))

names(cycle1_meds) <- tolower(names(cycle1_meds))
names(cycle4_meds) <- tolower(names(cycle4_meds))
names(cycle6_meds) <- tolower(names(cycle6_meds))
```

### 5. Run your analysis

From here, the workflow is identical to what you tested with dummy data.
See [Analysis
walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md)
for a complete example, or [Recoding
medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)
for the medication recoding pipeline.

## Tips

- **Test thoroughly outside the RDC.** RDC time is limited. Use
  chmsflow’s dummy data to verify your code runs end-to-end before going
  in.
- **Bring all dependencies.** Check what chmsflow imports by running
  `tools::package_dependencies("chmsflow", recursive = TRUE)` outside
  the RDC, and make sure all of those packages are on your P drive.
- **Keep medication data separate.** Do not merge medication files into
  the main cycle files before loading. chmsflow expects them as separate
  objects for
  [`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)
  and
  [`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md).

## Next steps

- **Run a complete analysis** – Follow the [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md)
  to estimate hypertension prevalence across cycles 3–6 using dummy
  data, then bring the same code into the RDC.
- **Recode medications** – If your analysis needs medication variables,
  see [Recoding
  medications](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)
  for the full pipeline.
- **Understand the methodology** – For background on why harmonization
  is non-trivial, see
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).
