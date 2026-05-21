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
| clc_age  |
| clc_age  |
| clc_age  |
| clc_age  |

2.  **dummyVariable:** age is a continuous variable, so it does not have
    dummy variables.

|     | variable | dummyVariable |
|:----|:---------|:--------------|
| 275 | clc_age  | N/A           |
| 276 | clc_age  | N/A           |
| 277 | clc_age  | N/A           |
| 278 | clc_age  | N/A           |

3.  **typeEnd:** age was captured in the CHMS as a continuous variable.
    It does not make much sense to transform it into a categorical
    variable, so the toType should be `cont` in each row of age.

|     | variable | dummyVariable | typeEnd |
|:----|:---------|:--------------|:--------|
| 275 | clc_age  | N/A           | cont    |
| 276 | clc_age  | N/A           | cont    |
| 277 | clc_age  | N/A           | cont    |
| 278 | clc_age  | N/A           | cont    |

4.  **databaseStart:** age was captured in all CHMS surveys between
    cycles 1-6, so in the first row with the continuous “category” and
    the else row, the CHMS identifiers will be listed this column:

|  | variable | dummyVariable | typeEnd | databaseStart |
|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |

5.  **variableStart:** From cycles 1-6, the age variable is the same as
    the common name. Therefore for all the rows, the variableStart
    column will look like this:

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|
| 1 | acemed | N/A | cat | cycle1_meds, cycle2_meds | DerivedVar::\[atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a, atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a, atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a, mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b, mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b, mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b\] |
| 6 | acemed | acemed_cat2_1 | cat | cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds | DerivedVar::\[meucatc, npi_25b\] |

6.  **typeStart:** As mentioned previously, age was measured as a
    continuous variable in the CHMS, so the fromType should be `cont` in
    each row of age.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart |
|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont |

7.  **recEnd:** Since this is a continuous variable, the first row (the
    main “category”) has `copy` written. For the not applicable rows
    `NA::a` is written. For the missing and else rows `NA::b` is
    written. The `haven` package is used for tagging NA in numeric
    variables.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b |

8.  **numValidCat:** Since this is a continuous variable, there are no
    actual categories; so `N/A` is written in each row.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A |

9.  **catLabel:** For the first row `age` is written. Not applicable
    rows `not applicable` is written. Missing rows: `missing`. Else row:
    `else`

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing |

10. **catLabelLong:** For the first row, `body mass index` is written to
    give further detail on what age is. The other rows remain the same.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing |

11. **units:** age is measured in years, so `years` is written in each
    row.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years |

12. **recStart:** Going through the CHMS data documentation from cycles
    1-6, it was found that the lowest age value was 3 and the highest
    age value was 80. Therefore the recFrom for the first row is written
    as `[3,80]`. Not applicable was coded as 996 so the recFrom for this
    row would be `[996]`. Similarly, don’t know was coded as 997,
    refusal was coded as 998, and not stated was coded as 999. Therefore
    the recFrom for the missing row would be `[997,999]`. For the else
    row, just write `else`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years | \[3, 80\] |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years | 996 |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | \[997, 999\] |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | else |

13. **catStartLabel:** For the first row, `Years` is written as it is
    written in CHMS documentation. The other rows remain the same, and
    the values for each missing category are stated in the missing rows.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years | \[3, 80\] | Years |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years | 996 | Valid skip |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | \[997, 999\] | Don’t know (997); Refusal (998); Not stated (999) |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | else | else |

14. **variableStartShortLabel:** Writing `Age` for each row is
    sufficient for this variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years | \[3, 80\] | Years | Age |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years | 996 | Valid skip | Age |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | \[997, 999\] | Don’t know (997); Refusal (998); Not stated (999) | Age |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | else | else | Age |

15. **variableStartLabel:** As per CHMS documentation, the label for
    this variable is `Age at clinic visit`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years | \[3, 80\] | Years | Age | Age at clinic visit |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years | 996 | Valid skip | Age | Age at clinic visit |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | \[997, 999\] | Don’t know (997); Refusal (998); Not stated (999) | Age | Age at clinic visit |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | else | else | Age | Age at clinic visit |

16. **notes:** Notes are used to identify issues that may be relevant
    when transforming the variable or category. There are no known
    issues regarding age.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 275 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | copy | N/A | Years | Years | years | \[3, 80\] | Years | Age | Age at clinic visit |  |
| 276 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::a | N/A | not applicable | not applicable | years | 996 | Valid skip | Age | Age at clinic visit |  |
| 277 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | \[997, 999\] | Don’t know (997); Refusal (998); Not stated (999) | Age | Age at clinic visit |  |
| 278 | clc_age | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_age\] | cont | NA::b | N/A | missing | missing | years | else | else | Age | Age at clinic visit |  |

### Specifying the variable on `variables.csv`

Once mapped and specified on `variable_details.csv`, the age variable
can now be specified on `variables.csv`

| variable | role | label | labelLong | section | subject | variableType | units | databaseStart | variableStart | description |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| acemed |  | ACE inhibitors | Taking ACE inhibitors | Health status | Medication | Categorical | N/A | cycle1_meds, cycle2_meds, cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds | DerivedVar::\[atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a, atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a, atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a, mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b, mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b, mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b\]; DerivedVar::\[meucatc, npi_25b\] |  |

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

With complex derived variables, sometimes it is necessary to create
functions within the custom function. For pack-years, a nested function
was used to create an intermediate smoking variable that was used in the
main function.

``` r

pack_years_fun <- function(SMKDSTY, CLC_AGE, SMK_54, SMK_52, SMK_31, SMK_41, SMK_53, SMK_42, SMK_21, SMK_11) {
  # Age verification
  if (is.na(CLC_AGE)) {
    return(haven::tagged_na("b"))
  } else if (CLC_AGE < 0) {
    return(haven::tagged_na("b"))
  }

  # PackYears for Daily Smoker
  pack_years <-
    ifelse(
      SMKDSTY == 1,
      pmax(((CLC_AGE - SMK_52) * (SMK_31 / 20)), 0.0137),
      # PackYears for Occasional Smoker (former daily)
      ifelse(
        SMKDSTY == 2,
        pmax(((CLC_AGE - SMK_52 - (CLC_AGE - SMK_54)) * (SMK_53 / 20)), 0.0137) +
          ((pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_54)),
        # PackYears for Occasional Smoker (never daily)
        ifelse(
          SMKDSTY == 3,
          (pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_21),
          # PackYears for former daily smoker (non-smoker now)
          ifelse(
            SMKDSTY == 4,
            pmax(((SMK_54 - SMK_52) * (SMK_53 / 20)), 0.0137),
            # PackYears for former occasional smoker (non-smoker now) who
            # smoked at least 100 cigarettes lifetime
            ifelse(
              SMKDSTY == 5 & SMK_11 == 1,
              0.0137,
              # PackYears for former occasional smoker (non-smoker now) who
              # have not smoked at least 100 cigarettes lifetime
              ifelse(
                SMKDSTY == 5 & SMK_11 == 2,
                0.007,
                # Non-smoker
                ifelse(
                  SMKDSTY == 6,
                  0,
                  # Account for NA(a)
                  ifelse(
                    SMKDSTY == "NA(a)",
                    haven::tagged_na("a"),
                    haven::tagged_na("b")
                  )
                )
              )
            )
          )
        )
      )
    )
  return(pack_years)
}
```

More information on what each smoking variable means can be found in the
[Reference](https://big-life-lab.github.io/chmsflow/reference/pack_years_fun.md)
section.

### Steps 2 and 3. Specifying pack-years in `variable_details.csv` and `variables.csv`

This is how the `variable_details.csv` sheet would look for the derived
pack-years row

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 953 | pack_years_der | N/A | cont | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[smkdsty, clc_age, smk_54, smk_52, smk_31, smk_41, smk_53, smk_42, smk_21, smk_11\] | N/A | Func::pack_years_fun | N/A | N/A | N/A | years | N/A | N/A | Pack-years | Smoking pack-years |  |

And this is how the `variables.csv` sheet would look for the derived
pack-years row

|  | variable | role | label | labelLong | section | subject | variableType | units | databaseStart | variableStart | description |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 189 | pack_years_der |  | Pack-years | Smoking pack-years | Health behaviour | Smoking | Continuous | years | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[smkdsty, clc_age, smk_54, smk_52, smk_31, smk_41, smk_53, smk_42, smk_21, smk_11\] |  |

### Adding labels to a derived variable

For a continuous derived variable like pack-years, the labels specified
in `variables.csv` are sufficient for the variable to be properly
labelled. For categorical derived variables, extra rows will need to be
added on `variable_details.csv` so that labels are generated for each
category. The example below shows how diabx, a derived categorical
variable flagging respondents who have diabetes based on more inclusive
factors, is specified in `variable_details.csv`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 308 | diabx | N/A | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | Func::determine_inclusive_diabetes | N/A | N/A | N/A | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 309 | diabx | diabx_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | 1 | 2 | Yes | Yes | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 310 | diabx | diabx_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | 2 | 2 | No | No | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 311 | diabx | diabx_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | NA::b | 2 | missing | missing | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |

As you can see, the first row for diabx specifies the function for the
derived variable and the base variables included. The second and third
rows specify the categories of the variables, which are then labelled.

### Creating a derived variable using derived variables

It is possible to create a derived variable that involves derived
variables. When creating the custom function for it, use the derived
variable name inside the function. Similarly, when specifying the
variable in `variable_details.csv` and `variables.csv`, use the derived
variable in the **variableStart** column. The example below shows how
diabx uses the derived diabetes drug variable, is specified in
`variable_details.csv` and `variables.csv`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 308 | diabx | N/A | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | Func::determine_inclusive_diabetes | N/A | N/A | N/A | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 309 | diabx | diabx_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | 1 | 2 | Yes | Yes | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 310 | diabx | diabx_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | 2 | 2 | No | No | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |
| 311 | diabx | diabx_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] | N/A | NA::b | 2 | missing | missing | N/A | N/A | N/A | Diabetes | Diabetes prevalence based on more inclusive classification |  |

|  | variable | role | label | labelLong | section | subject | variableType | units | databaseStart | variableStart | description |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 80 | diabx | Test | Diabetes | Diabetes prevalence based on more inclusive classification | Health status | Chronic disease | Categorical | N/A | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | DerivedVar::\[diab_m, ccc_51, diab_drug2\] |  |
