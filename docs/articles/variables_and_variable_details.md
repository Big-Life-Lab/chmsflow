# Variable schema reference

## Overview

chmsflow uses two CSV metadata files to define how raw CHMS variables
are harmonized. These files are bundled with the package in
`inst/extdata/` and are also available as data objects (`variables` and
`variable_details`).

- **`variables.csv`** – lists every harmonized variable with its name,
  label, type, and unit
- **`variable-details.csv`** – defines the row-by-row recoding rules
  that
  [`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
  applies

This vignette is a column-by-column reference for both files. For an
explanation of how these files fit into the harmonization workflow, see
[Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).

## `variables.csv`

    #> There are 211 variables, grouped in 24 subjects and 5 sections.

### Columns

**1. `variable`** – the name of the harmonized variable.

**2. `label`** – a short label for the variable.

**3. `labelLong`** – a more detailed label for the variable.

**4. `section`** – the broad grouping where this variable belongs (e.g.,
sociodemographics, health behaviour, health status).

**5. `subject`** – the specific topic the variable pertains to (e.g.,
age, smoking, blood pressure).

**6. `variableType`** – whether the harmonized variable is `Categorical`
or `Continuous`.

**7. `units`** – the units of the harmonized variable, or `N/A` if
unitless.

**8. `databaseStart`** – the CHMS cycles that contain the variable,
separated by commas.

**9. `variableStart`** – the source variable names as listed in each
CHMS cycle. Uses the same format conventions as `variable-details.csv`
(see below).

## `variable-details.csv`

    #> There are 1111 rows and 17 columns.

### Row structure

Each row defines the recoding rule for one category of one variable. For
a categorical variable with 4 categories, plus a not-applicable
category, a missing category, and an else row, there are 7 rows.

Missing data rows use
[`haven::tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html):

- `NA::a` – valid skip (not applicable)
- `NA::b` – missing (don’t know, refusal, not stated)

The `else` row catches values not matched by any other row.

### Columns

We use `clc_sex` as a running example.

**1. `variable`** – name of the harmonized variable.

| variable |
|:---------|
| clc_sex  |
| clc_sex  |
| clc_sex  |
| clc_sex  |
| clc_sex  |

**2. `dummyVariable`** – dummy variable name for each category
(categorical variables only; `N/A` for continuous).

|     | variable | dummyVariable    |
|:----|:---------|:-----------------|
| 297 | clc_sex  | clc_sex_cat2_1   |
| 298 | clc_sex  | clc_sex_cat2_2   |
| 299 | clc_sex  | clc_sex_cat2_NAa |
| 300 | clc_sex  | clc_sex_cat2_NAb |
| 301 | clc_sex  | clc_sex_cat2_NAb |

**3. `typeEnd`** – variable type of the harmonized variable (`cat` or
`cont`).

|     | variable | dummyVariable    | typeEnd |
|:----|:---------|:-----------------|:--------|
| 297 | clc_sex  | clc_sex_cat2_1   | cat     |
| 298 | clc_sex  | clc_sex_cat2_2   | cat     |
| 299 | clc_sex  | clc_sex_cat2_NAa | cat     |
| 300 | clc_sex  | clc_sex_cat2_NAb | cat     |
| 301 | clc_sex  | clc_sex_cat2_NAb | cat     |

**4. `databaseStart`** – CHMS cycles containing this variable, separated
by commas.

|  | variable | dummyVariable | typeEnd | databaseStart |
|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |

**5. `variableStart`** – source variable names in each CHMS cycle.
Supports several formats:

| Format | Meaning | Example |
|----|----|----|
| `[variable_name]` | Same name across all cycles | `[clc_sex]` |
| `cycle1::name1, [default_name]` | Cycle-specific exception with a default | `cycle1::amsdmva1, [ammdmva1]` |
| `DerivedVar::[var1, var2, ...]` | Computed by a function from listed inputs | `DerivedVar::[lab_bcre, pgdcgt, clc_sex, clc_age]` |

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |

**6. `typeStart`** – variable type in the source CHMS data (`cat` or
`cont`).

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart |
|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |

**7. `recEnd`** – the value to recode each category to. Special values:

- `copy` – pass through unchanged (for continuous variables)
- `NA::a` – not applicable
- `NA::b` – missing
- `Func::function_name` – derived variable computed by the named
  function

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b |

**8. `numValidCat`** – number of non-missing categories (categorical
only; `N/A` for continuous). Not used by
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 |

**9. `catLabel`** – short label for the category.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing |

**10. `catLabelLong`** – detailed label, matching CHMS documentation
where possible.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing |

**11. `units`** – units of the variable, or `N/A`. Must be consistent
across all rows of the same variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A |

**12. `recStart`** – the source value or range to match. Uses [interval
notation](https://en.wikipedia.org/wiki/Interval_(mathematics)#Notations_for_intervals):

- `[1, 4]` – all integer values from 1 to 4
- `[1, 2.5]` – all values from 1 to 2.5 (2.55 would not match)
- `else` – all values not matched by other rows
- `copy` – combined with `else`, copies unmatched values unchanged

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else |

**13. `catStartLabel`** – label for the source category, matching CHMS
documentation. For missing rows, describes each missing code and its
value.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else |

**14. `variableStartShortLabel`** – short label for the source variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex |

**15. `variableStartLabel`** – detailed label for the source variable,
matching CHMS documentation.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex | Sex |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex | Sex |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex | Sex |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex | Sex |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex | Sex |

**16. `notes`** – relevant notes about changes between CHMS cycles,
missing categories, or variable type changes.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 297 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex | Sex |  |
| 298 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex | Sex |  |
| 299 | clc_sex | clc_sex_cat2_NAa | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex | Sex |  |
| 300 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex | Sex |  |
| 301 | clc_sex | clc_sex_cat2_NAb | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex | Sex |  |

### Derived variables

Derived variables use two special column values:

- **`variableStart`**: `DerivedVar::[var1, var2, var3]` – lists the
  input variables
- **`recEnd`**: `Func::function_name` – names the R function that
  computes the derived variable

See [Derived
variables](https://big-life-lab.github.io/chmsflow/articles/derived_variables.md)
for details on how derived variables work.

## Next steps

- **See it in action** – Follow the [Analysis
  walkthrough](https://big-life-lab.github.io/chmsflow/articles/analysis_walkthrough.md)
  to see how these metadata files drive a real analysis.
- **Understand the methodology** – For the design rationale behind the
  rules-as-data approach, see
  [Methodology](https://big-life-lab.github.io/chmsflow/articles/methodology.md).
- **Add your own variables** – To extend the schema with custom
  variables, see [How to add
  variables](https://big-life-lab.github.io/chmsflow/articles/how_to_add_variables.md).
