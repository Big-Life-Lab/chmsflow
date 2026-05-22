# How to add variables to chmsflow

## Introduction

This vignette explains how you can add variables to the *chmsflow*
package. There are two types of variables that can be added:

1.  Existing CHMS variables to be harmonized across cycles.
2.  Derived variables based on harmonized CHMS cycles.

## How to add existing CHMS variables to chmsflow

When adding variables that already exist across CHMS cycles, there are
two worksheets that need to be specified:

1.  `variable_details.csv`: This worksheet maps variables across CHMS
    cycles.
2.  `variables.csv`: This worksheet lists all the variables that exist
    in *chmsflow*

### Example of an existing CHMS variable: Age

This example will show how the existing CHMS age variable was developed
using `variable_details.csv` and `variables.csv`. **Note** this variable
is different from the derived age variable that is also included in
*chmsflow*. For this article, a sample `variable_details.csv` &
`variables.csv` will be loaded to demonstrate how to add variables.

``` r

variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"))
variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"))
```

### Specifying the variable on `variable_details.csv`

- For this variable, there are 4 rows, 1 for the continuous “category”,
  1 for not applicable, 1 for missing, and 1 for else. In many instances
  there are changes in how variable categories are coded between CHMS
  cycles. But since the overall variable structure remains intact, extra
  rows can be used to help rectify this issue to make sure all values
  feed into the newly transformed variable.

### Columns

1.  **variable:** the most common variable name for age is `clc_age`.
    This should be written for each row.

| variable |
|:---------|
| ccc_61   |
| ccc_61   |
| ccc_61   |
| ccc_63   |

2.  **dummyVariable:** age is a continuous variable, so it does not have
    dummy variables.

|     | variable | dummyVariable   |
|:----|:---------|:----------------|
| 275 | ccc_61   | ccc_61_cat2_NAa |
| 276 | ccc_61   | ccc_61_cat2_NAb |
| 277 | ccc_61   | ccc_61_cat2_NAb |
| 278 | ccc_63   | ccc_63_cat2_1   |

3.  **typeEnd:** age was captured in the CHMS as a continuous variable.
    It does not make much sense to transform it into a categorical
    variable, so the toType should be `cont` in each row of age.

|     | variable | dummyVariable   | typeEnd |
|:----|:---------|:----------------|:--------|
| 275 | ccc_61   | ccc_61_cat2_NAa | cat     |
| 276 | ccc_61   | ccc_61_cat2_NAb | cat     |
| 277 | ccc_61   | ccc_61_cat2_NAb | cat     |
| 278 | ccc_63   | ccc_63_cat2_1   | cat     |

4.  **databaseStart:** age was captured in all CHMS surveys between
    cycles 1–6, so in the first row with the continuous “category” and
    the else row, the CHMS identifiers will be listed this column:

|  | variable | dummyVariable | typeEnd | databaseStart |
|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |

5.  **variableStart:** From cycles 1–6, the age variable is the same as
    the common name. Therefore for all the rows, the variableStart
    column will look like this:

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|
| 1 | ace_med | N/A | cat | cycle1_meds, cycle2_meds | DerivedVar::\[atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a, atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a, atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a, mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b, mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b, mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b\] |
| 6 | ace_med | N/A | cat | cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds | DerivedVar::\[meucatc, npi_25b\] |

6.  **typeStart:** As mentioned previously, age was measured as a
    continuous variable in the CHMS, so the fromType should be `cont` in
    each row of age.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart |
|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat |

7.  **recEnd:** Since this is a continuous variable, the first row (the
    main “category”) has `copy` written. For the not applicable rows
    `NA::a` is written. For the missing and else rows `NA::b` is
    written. The `haven` package is used for tagging NA in numeric
    variables.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 |

8.  **numValidCat:** Since this is a continuous variable, there are no
    actual categories; so `N/A` is written in each row.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 |

9.  **catLabel:** For the first row `age` is written. Not applicable
    rows `not applicable` is written. Missing rows: `missing`. Else row:
    `else`

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes |

10. **catLabelLong:** For the first row, `body mass index` is written to
    give further detail on what age is. The other rows remain the same.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes |

11. **units:** age is measured in years, so `years` is written in each
    row.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A |

12. **recStart:** Going through the CHMS data documentation from cycles
    1–6, it was found that the lowest age value was 3 and the highest
    age value was 80. Therefore the recFrom for the first row is written
    as `[3,80]`. Not applicable was coded as 996 so the recFrom for this
    row would be `[996]`. Similarly, don’t know was coded as 997,
    refusal was coded as 998, and not stated was coded as 999. Therefore
    the recFrom for the missing row would be `[997,999]`. For the else
    row, just write `else`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | else |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A | 1 |

13. **catStartLabel:** For the first row, `Years` is written as it is
    written in CHMS documentation. The other rows remain the same, and
    the values for each missing category are stated in the missing rows.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | else | else |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A | 1 | Yes |

14. **variableStartShortLabel:** Writing `Age` for each row is
    sufficient for this variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Heart disease |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Heart disease |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Heart disease |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A | 1 | Yes | Heart attack |

15. **variableStartLabel:** As per CHMS documentation, the label for
    this variable is `Age at clinic visit`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Heart disease | Has heart disease |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Heart disease | Has heart disease |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Heart disease | Has heart disease |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A | 1 | Yes | Heart attack | Ever had a heart attack |

16. **notes:** Notes are used to identify issues that may be relevant
    when transforming the variable or category. There are no known
    issues regarding age.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes | X |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | ccc_61 | ccc_61_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Heart disease | Has heart disease |  |  |
| 276 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Heart disease | Has heart disease |  |  |
| 277 | ccc_61 | ccc_61_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_61\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Heart disease | Has heart disease |  |  |
| 278 | ccc_63 | ccc_63_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[ccc_63\] | cat | 1 | 2 | Yes | Yes | N/A | 1 | Yes | Heart attack | Ever had a heart attack |  |  |

### Specifying the variable on `variables.csv`

Once mapped and specified on `variable_details.csv`, the age variable
can now be specified on `variables.csv`

| variable | label | labelLong | section | subject | variableType | units | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| ace_med | ACE inhibitors | Taking ACE inhibitors | Health status | Medication | Categorical | N/A | cycle1_meds, cycle2_meds, cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds | DerivedVar::\[atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a, atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a, atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a, mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b, mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b, mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b\]; DerivedVar::\[meucatc, npi_25b\] |

## How to create derived variables and add them to chmsflow

Along with specifying the variable on `variable_details.csv` and
`variables.csv`, a previous step is required in creating derived
variables and that is creating a custom function that creates the
derived variable from existing CHMS variables.

    CustomFunctionName <- function(Vars from variableStart following same order){
      outputVar <- {Code on passed vars that generates a single value output}

      return(outputVar)
    }

### Example of a derived variable: Smoking pack-years

Pack-years is a complex derived variable often used by researchers to
quantify the amount of cigarette use over a period of time. Even given
its complex nature, pack-years can still be calculated. This derived
variable incorporates numerous CHMS smoking variables, along with age.

### Step 1. Creating a derived function

With complex derived variables, the function computes the output from
multiple input variables using clinical or epidemiological logic. For
pack-years, the function uses smoking status (`smkdsty`), age, and
several smoking history variables to calculate cumulative cigarette
exposure.

The current implementation in chmsflow uses
[`dplyr::case_when()`](https://dplyr.tidyverse.org/reference/case-and-replace-when.html)
for clarity:

``` r

calculate_pack_years <- function(smkdsty, clc_age, smk_54, smk_52, smk_31, smk_41, smk_53, smk_42, smk_21, smk_11) {
  pack_years <- dplyr::case_when(
    # Age: valid skip
    clc_age == 96 ~ haven::tagged_na("a"),
    # Age: don't know, refusal, not stated
    clc_age < 0 | clc_age %in% 97:99 ~ haven::tagged_na("b"),

    # Pack-years by smoking status
    smkdsty == 1 ~ pmax(((clc_age - smk_52) * (smk_31 / 20)), 0.0137),
    smkdsty == 2 ~ pmax(((clc_age - smk_52 - (clc_age - smk_54)) * (smk_53 / 20)), 0.0137) +
      ((pmax((smk_41 * smk_42 / 30), 1) / 20) * (clc_age - smk_54)),
    smkdsty == 3 ~ (pmax((smk_41 * smk_42 / 30), 1) / 20) * (clc_age - smk_21),
    smkdsty == 4 ~ pmax(((smk_54 - smk_52) * (smk_53 / 20)), 0.0137),
    smkdsty == 5 & smk_11 == 1 ~ 0.0137,
    smkdsty == 5 & smk_11 == 2 ~ 0.007,
    smkdsty == 6 ~ 0,

    # Smoking status: valid skip
    smkdsty == 96 ~ haven::tagged_na("a"),
    # Smoking status: don't know, refusal, not stated
    smkdsty %in% 97:99 ~ haven::tagged_na("b"),
    .default = haven::tagged_na("b")
  )
  return(pack_years)
}
```

More information on what each smoking variable means can be found in the
[Reference](https://big-life-lab.github.io/chmsflow/reference/calculate_pack_years.md)
section.

### Steps 2 and 3. Specifying pack-years in `variable_details.csv` and `variables.csv`

This is how the `variable_details.csv` sheet would look for the derived
pack-years row

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes | X |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 953 | misc_htn_med | misc_htn_med_cat2_1 | cat | cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds | DerivedVar::\[exercise_avg_min_day\] | N/A | 1 | 2 | Yes | Yes | N/A | N/A | N/A | Other antihypertension drugs | Taking other antihypertension drugs |  |  |

And this is how the `variables.csv` sheet would look for the derived
pack-years row

|  | variable | label | labelLong | section | subject | variableType | units | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 189 | pgdcgt | Ethnicity | Cultural or racial group - (D) | Sociodemographics | Ethnicity | Categorical | N/A | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | cycle1::sdcdcgt, cycle2::sdcdcgt, cycle6::PGDCGT, \[pgdcgt\] |

### Adding labels to a derived variable

For a continuous derived variable like pack-years, the labels specified
in `variables.csv` are sufficient for the variable to be properly
labelled. For categorical derived variables, extra rows will need to be
added on `variable_details.csv` so that labels are generated for each
category. The example below shows how diab_status, a derived categorical
variable flagging respondents who have diabetes based on more inclusive
factors, is specified in `variable_details.csv`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes | X |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 308 | cvd_status | N/A | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | Func::derive_cvd_personal_history | N/A | N/A | N/A | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 309 | cvd_status | cvd_status_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | 1 | 2 | Yes | Yes | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 310 | cvd_status | cvd_status_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | 2 | 2 | No | No | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 311 | cvd_status | cvd_status_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle5 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | NA::a | 2 | not applicable | not applicable | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |

As you can see, the first row for diab_status specifies the function for
the derived variable and the base variables included. The second and
third rows specify the categories of the variables, which are then
labelled.

### Creating a derived variable using derived variables

It is possible to create a derived variable that involves derived
variables. When creating the custom function for it, use the derived
variable name inside the function. Similarly, when specifying the
variable in `variable_details.csv` and `variables.csv`, use the derived
variable in the **variableStart** column. The example below shows how
diab_status uses the derived diabetes drug variable, is specified in
`variable_details.csv` and `variables.csv`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes | X |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 308 | cvd_status | N/A | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | Func::derive_cvd_personal_history | N/A | N/A | N/A | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 309 | cvd_status | cvd_status_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | 1 | 2 | Yes | Yes | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 310 | cvd_status | cvd_status_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | 2 | 2 | No | No | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |
| 311 | cvd_status | cvd_status_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle5 | DerivedVar::\[ccc_61, ccc_63, ccc_81\] | N/A | NA::a | 2 | not applicable | not applicable | N/A | N/A | N/A | Cardiovascular disease | Cardiovascular disease - heart disease OR stroke |  |  |

|  | variable | label | labelLong | section | subject | variableType | units | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 80 | diab_a1c | Diabetes | Diabetes prevalence based on HbA1C level | Health status | Chronic disease | Categorical | N/A | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | cycle6::LAB_HBA1, \[lab_hba1\] |

## Next steps

- **Understand the schema** – For a column-by-column reference of
  `variables.csv` and `variable-details.csv`, see [Variable schema
  reference](https://big-life-lab.github.io/chmsflow/articles/variables_and_variable_details.md).
- **See derived variables in context** – Learn how `Func::` and
  `DerivedVar::` entries are used in [Derived
  variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.md).
- **Contribute to chmsflow** – See the [contributing
  guide](https://github.com/Big-Life-Lab/chmsflow/blob/dev/CONTRIBUTING.md)
  for how to submit your additions.
