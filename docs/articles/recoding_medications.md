# Recoding CHMS medication variables

## 1. Load packages

``` r

# Install release version from CRAN
install.packages("chmsflow")

# Install the most recent version from GitHub
devtools::install_github("Big-Life-Lab/chmsflow")
```

``` r

library(chmsflow)
```

## 2. Recode medication variables for individual cycles

Medication data object always has to be called “cyclex_meds” in order
for recoding to work properly, with rest of the data being separated and
called “cyclex” as stated in recoding-variables.qmd.

Note that row headers for medication data of cycles 1, 4, and 6 must be
put to lower case prior to recoding.

``` r

# Load recodeflow and dplyr
library(recodeflow)
library(dplyr)
```


    Attaching package: 'dplyr'

    The following objects are masked from 'package:stats':

        filter, lag

    The following objects are masked from 'package:base':

        intersect, setdiff, setequal, union

``` r

# Recoding basic variables from cycles 1 and 3
cycle2_medication_data <- rec_with_table(cycle2_meds, c("clinicid", "atc_101a", "mhr_101b"), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

``` r

head(cycle2_medication_data)
```

      atc_101a clinicid mhr_101b
    1  C07AA05        1        2
    2  C09AA06        2        3
    3  C08CA01        3        1
    4  A10BC02        4        3

``` r

cycle3_medication_data <- rec_with_table(cycle3_meds, c("clinicid", "meucatc", "npi_25b"), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

``` r

head(cycle3_medication_data)
```

      clinicid meucatc npi_25b
    1        1 C07AA05       2
    2        1 C09AA06       3
    3        1 C08CA01       1
    4        1 A10BC02       3
    5        1 C07AA05       2
    6        1 C09AA06       3

``` r

# Recoding derived variable acemed for cycle2. Select vars by role used to avoid writing all med variables in one line
cycle2_ace_medication_data <- rec_with_table(cycle2_meds, c("clinicid", "acemed", recodeflow:::select_vars_by_role("Drugs", variables)), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    INFO [2026-05-21 21:09:28] Adding variable 'ACEmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ACEmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ACEmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ACEmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:28] Adding variable 'diabetes_drug' to the data frame.

``` r

head(select(cycle2_ace_medication_data, clinicid, acemed))
```

      clinicid acemed
    1        1      1
    2        2      1
    3        3      1
    4        4      0

``` r

# Recoding derived variable acemed for cycle3. Much simpler function used here.
cycle3_ace_medication_data <- rec_with_table(cycle3_meds, c("clinicid", "meucatc", "npi_25b", "acemed"), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

``` r

head(cycle3_ace_medication_data)
```

      clinicid meucatc npi_25b acemed
    1        1 C07AA05       2      0
    2        1 C09AA06       3      1
    3        1 C08CA01       1      0
    4        1 A10BC02       3      0
    5        1 C07AA05       2      0
    6        1 C09AA06       3      1

## 3. Merge recoded medication data from different cycles

``` r

# Aggregating recoded cycle3 data by clinicid
cycle3_ace_medication_data <- cycle3_ace_medication_data %>%
  group_by(clinicid) %>%
  summarize(
    meucatc = paste(unique(meucatc), collapse = ", "), # Concatenate unique values of meucatc
    npi_25b = paste(unique(npi_25b), collapse = ", "), # Concatenate unique values of npi_25b
    acemed = max(as.numeric(as.character(acemed))) # Find maximum of acemed
  )
head(cycle3_ace_medication_data)
```

    # A tibble: 4 × 4
      clinicid meucatc                            npi_25b acemed
         <dbl> <chr>                              <chr>    <dbl>
    1        1 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    2        2 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    3        3 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    4        4 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1

``` r

# De-factorizing acemed variable in recoded cycle2 data
cycle2_ace_medication_data$acemed <- as.numeric(as.character(cycle2_ace_medication_data$acemed))

# Merging recoded cycle2 and cycle3 data, and ensuring one acemed column in the end
cycles2and3_ace_medication_data <- merge(cycle2_ace_medication_data, cycle3_ace_medication_data, by = "clinicid")

cycles2and3_ace_medication_data <- cycles2and3_ace_medication_data %>%
  mutate(acemed = pmax(acemed.x, acemed.y)) %>%
  select(-c(acemed.x, acemed.y))
head(cycles2and3_ace_medication_data)
```

      clinicid atc_101a atc_102a atc_103a atc_104a atc_105a atc_106a atc_107a
    1        1  C07AA05  A01AB05  C02CC07  C03CA01  C09AA04  C09AA04  C09AA04
    2        2  C09AA06  C09AA02  C08CA06  C03CA01  C07AB02  C07AB02  C07AB02
    3        3  C08CA01  C07AB02  C07AB07  C09AA04  C08CA02  C08CA02  C08CA02
    4        4  A10BC02  C03AA03  C07AB03  C08CA02  A10BD05  A10BD05  A10BD05
      atc_108a atc_109a atc_110a atc_111a atc_112a atc_113a atc_114a atc_115a
    1  C09AA04  C09AA04  C09AA04  C09AA04  C09AA04  C09AA04  C09AA04  C09AA04
    2  C07AB02  C07AB02  C07AB02  C07AB02  C07AB02  C07AB02  C07AB02  C07AB02
    3  C08CA02  C08CA02  C08CA02  C08CA02  C08CA02  C08CA02  C08CA02  C08CA02
    4  A10BD05  A10BD05  A10BD05  A10BD05  A10BD05  A10BD05  A10BD05  A10BD05
      atc_131a atc_132a atc_133a atc_134a atc_135a atc_201a atc_202a atc_203a
    1  C07AA05  C03BA08  C03BC02  C02KX01  A01AB05  C03BA08  C07AA05  C03BA08
    2  C09AA06  C07AA07  C08CA01  C02AA05  C09AA02  C07AA07  C09AA06  C07AA07
    3  C08CA01  C07AA12  C07AA05  C07AG02  C07AB02  C07AA12  C08CA01  C07AA12
    4  A10BC02  M01AG02  C07AA06  C07AA06  C03AA03  M01AG02  A10BC02  M01AG02
      atc_204a atc_205a atc_206a atc_207a atc_208a atc_209a atc_210a atc_211a
    1  C03BC02  C02KX01  A01AB05  C02CC07  C03CA01  C09AA04  C09AA04  C09AA04
    2  C08CA01  C02AA05  C09AA02  C08CA06  C03CA01  C07AB02  C07AB02  C07AB02
    3  C07AA05  C07AG02  C07AB02  C07AB07  C09AA04  C08CA02  C08CA02  C08CA02
    4  C07AA06  C07AA06  C03AA03  C07AB03  C08CA02  A10BD05  A10BD05  A10BD05
      atc_212a atc_213a atc_214a atc_215a atc_231a atc_232a atc_233a atc_234a
    1  C09AA04  C09AA04  C09AA04  C09AA04  C02CC07  C03CA01  C09AA04  C09AA04
    2  C07AB02  C07AB02  C07AB02  C07AB02  C08CA06  C03CA01  C07AB02  C07AB02
    3  C08CA02  C08CA02  C08CA02  C08CA02  C07AB07  C09AA04  C08CA02  C08CA02
    4  A10BD05  A10BD05  A10BD05  A10BD05  C07AB03  C08CA02  A10BD05  A10BD05
      atc_235a mhr_101b mhr_102b mhr_103b mhr_104b mhr_105b mhr_106b mhr_107b
    1  C09AA04        2        1        3        1        3        3        3
    2  C07AB02        3        4        2        2        2        2        2
    3  C08CA02        1        3        1        4        1        1        1
    4  A10BD05        3        2        4        3        4        4        4
      mhr_108b mhr_109b mhr_110b mhr_111b mhr_112b mhr_113b mhr_114b mhr_115b
    1        3        3        3        3        3        3        3        3
    2        2        2        2        2        2        2        2        2
    3        1        1        1        1        1        1        1        1
    4        4        4        4        4        4        4        4        4
      mhr_131b mhr_132b mhr_133b mhr_134b mhr_135b mhr_201b mhr_202b mhr_203b
    1        2        3        3        1        1        3        2        3
    2        3        2        1        2        4        2        3        2
    3        1        2        5        3        3        2        1        2
    4        3        3        1        4        2        3        3        3
      mhr_204b mhr_205b mhr_206b mhr_207b mhr_208b mhr_209b mhr_210b mhr_211b
    1        3        1        1        3        1        3        3        3
    2        1        2        4        2        2        2        2        2
    3        5        3        3        1        4        1        1        1
    4        1        4        2        4        3        4        4        4
      mhr_212b mhr_213b mhr_214b mhr_215b mhr_231b mhr_232b mhr_233b mhr_234b
    1        3        3        3        3        3        1        3        3
    2        2        2        2        2        2        2        2        2
    3        1        1        1        1        1        4        1        1
    4        4        4        4        4        4        3        4        4
      mhr_235b anymed diab_drug                            meucatc npi_25b acemed
    1        3      1         0 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    2        2      1         0 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    3        1      1         0 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1
    4        4      1         1 C07AA05, C09AA06, C08CA01, A10BC02 2, 3, 1      1

## 4. Example: Determine hypertension status by recoding medications

If you need medication variables in your analysis (especially to derive
other variables), always recode them before recoding other variables.

``` r

# Cycles 1-2
# Recode medication variables first - anymed for hypertension and diab_drug for diabetes which is involved in determining hypertension status
cycle2_htn_medication_data <- rec_with_table(cycle2_meds, c("clinicid", recodeflow:::select_vars_by_role("Drugs", variables)), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    INFO [2026-05-21 21:09:29] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'ANYmed' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'diabetes_drug' to the data frame.
    INFO [2026-05-21 21:09:29] Adding variable 'diabetes_drug' to the data frame.

``` r

# Create dummy medication variable by duplicating recoded medication variable
cycle2_htn_medication_data$anymed2 <- as.numeric(as.character(cycle2_htn_medication_data$anymed))
cycle2_htn_medication_data$diab_drug2 <- as.numeric(as.character(cycle2_htn_medication_data$diab_drug))
cycle2_htn_medication_data <- select(cycle2_htn_medication_data, clinicid, anymed2, diab_drug2)

# Merge medication data with rest of data
cycle2 <- merge(cycle2, cycle2_htn_medication_data, by = "clinicid")

# Recode hypertension (and diabetes) status using recoded, dummy medication variables
cycle2_htn_data <- rec_with_table(cycle2, c(recodeflow:::select_vars_by_role("Test", variables)), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to "other", as per OCAP.

``` r

head(cycle2_htn_data)
```

      anymed2 bpmdpbpd bpmdpbps ccc_32 ccc_51 ccc_61 ccc_63 ccc_81 clc_age clc_sex
    1       1       95      140      2      1      2      2      1      20       1
    2       1       85      130      1      2      2      2      2      30       2
    3       1       75      120      1      2      2      2      2      40       1
    4       1       65      110      1      2      2      2      1      50       2
      diab_drug2 diab_m lab_bcre lab_hba1 pgdcgt cardiov      gfr ckd dbp_adj diabx
    1          0      1       20     0.07      1       1 529.3541   2   94.45     1
    2          0      2       30     0.06      1       2 226.5658   2   86.15     2
    3          0      2       40     0.05      1       2 206.6563   2   77.85     2
    4          1  NA(b)       50       NA      2       1 137.0664   2   69.55     1
      sbp_adj highbp14090_adj
    1   141.6               1
    2   132.3               1
    3   123.0               1
    4   113.7               1

``` r

# Cycles 3-6
# Recode medication variables first - - anymed for hypertension and diab_drug for diabetes which is involved in determining hypertension status
cycle3_htn_medication_data <- rec_with_table(cycle3_meds, c("clinicid", "meucatc", "npi_25b", "anymed", "diab_drug"), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

``` r

# Aggregating recoded cycle3 data by clinicid
cycle3_htn_medication_data <- cycle3_htn_medication_data %>%
  group_by(clinicid) %>%
  summarize(
    meucatc = paste(unique(meucatc), collapse = ", "), # Concatenate unique values of meucatc
    npi_25b = paste(unique(npi_25b), collapse = ", "), # Concatenate unique values of npi_25b
    anymed = max(as.numeric(as.character(anymed))), # Find maximum of anymed
    diab_drug = max(as.numeric(as.character(diab_drug))) # Find maximum of diab_drug
  )

# Create dummy medication variable by duplicating recoded medication variable
cycle3_htn_medication_data$anymed2 <- as.numeric(as.character(cycle3_htn_medication_data$anymed))
cycle3_htn_medication_data$diab_drug2 <- as.numeric(as.character(cycle3_htn_medication_data$diab_drug))
cycle3_htn_medication_data <- select(cycle3_htn_medication_data, clinicid, anymed2, diab_drug2)

# Merge medication data with original data
# Call overall data "cyclex" in order to recode other variables afterwards
cycle3 <- merge(cycle3, cycle3_htn_medication_data, by = "clinicid")

# Recode hypertension (and diabetes) status using recoded, dummy medication variables
cycle3_htn_data <- rec_with_table(cycle3, c(recodeflow:::select_vars_by_role("Test", variables)), variable_details = variable_details)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    NOTE for pgdcgt: Respondents who respond as indigenous to previous question are identified as 'not applicable' in this question. Recode to "other", as per OCAP.

``` r

head(cycle3_htn_data)
```

      anymed2 bpmdpbpd bpmdpbps ccc_32 ccc_51 ccc_61 ccc_63 ccc_81 clc_age clc_sex
    1       1       95      140      2      1      2      2      1      20       1
    2       1       85      130      1      2      2      2      2      30       2
    3       1       75      120      1      2      2      2      2      40       1
    4       1       65      110      1      2      2      2      1      50       2
      diab_drug2 diab_m lab_bcre lab_hba1 pgdcgt cardiov      gfr ckd dbp_adj diabx
    1          1      1       20     0.07      1       1 529.3541   2   94.45     1
    2          1      2       30     0.06      1       2 226.5658   2   86.15     1
    3          1      2       40     0.05      1       2 206.6563   2   77.85     1
    4          1  NA(b)       50       NA      2       1 137.0664   2   69.55     1
      sbp_adj highbp14090_adj
    1   141.6               1
    2   132.3               1
    3   123.0               1
    4   113.7               1
