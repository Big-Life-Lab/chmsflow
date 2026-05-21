# variable_details.csv

## Introduction

The **variable_details.csv** worksheet contain details for the variables
in `variables.csv`. Information from `variable_details.csv` worksheet is
used by the
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
function to transform variables identified in
`variable_details$variableStart` to the newly transformed variable in
`variable_details$variable`.

    #> In the `variable_details.csv` worksheet there are 1074 rows and 16 columns

## Structure of variable_details.csv

### Rows

Each row in `variable_details.csv` holds the recode rules for
transforming a single category for a variable in `variables.csv`. An
exception to this rule are the “don’t know”, “refusal”, and “not stated”
categories, which are combined as a single missing category. For each
unique variable, an `else` row is used to assign values not identified
in other rows and are outside identified ranges. We recommend not
combining variables across the CHMS if variable has an important change
between CHMS cycles `variable_details$notes` is used to identify issues
that may be relevant when transforming the variable or category.

If a categorical variable has 4 distinct categories, along with a “not
applicable” category and the 3 missing categories, there will be 7 rows:

- 4 for each distinct category

- 1 for the not applicable category

- 1 for the missing categories

- 1 else row.

### Naming convention for not applicable and missing values

[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
uses the
[`tagged_na()`](https://haven.tidyverse.org/reference/tagged_na.html)
function from the
[haven](https://www.rdocumentation.org/packages/haven/versions/2.1.1)
package to tag not applicable responses as `NA(a)`, and missing values
(don’t know, refusal, not stated) as `NA(b)`. As you will see later, not
applicable values are transformed to `NA::a`, and missing values are
transformed to `NA::b`.

### Columns

The following are the columns that are listed in `variable_details.csv`.
Many of these columns need to be specified in order for
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
to be functional. We will use the `sex` variable to illustrate how each
column is specified:

1.  **variable:** the name of the final transformed variable.

| variable |
|:---------|
| clc_sex  |
| clc_sex  |
| clc_sex  |
| clc_sex  |
| clc_sex  |

2.  **dummyVariable:** the dummy variable for each category in a
    transformed categorical variable. This is only applicable for
    categorical variables; for continuous variables it is set as `N/A`.
    The name of a dummy variable consists of the final variable name,
    the number of categories in the variable, and the category level for
    each category. Note that this column is not necessary for
    [`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).

|     | variable | dummyVariable      |
|:----|:---------|:-------------------|
| 279 | clc_sex  | clc_sex_cat2_1     |
| 280 | clc_sex  | clc_sex_cat2_2     |
| 281 | clc_sex  | clc_sex_cat2_NA::a |
| 282 | clc_sex  | clc_sex_cat2_NA::b |
| 283 | clc_sex  | clc_sex_cat2_NA::b |

3.  **typeEnd:** the variable type of the final transformed variable. In
    this column, a transformed variable that is categorical will be
    specified as `cat`; while a transformed variable that is continuous
    will be specified as `cont`.

|     | variable | dummyVariable      | typeEnd |
|:----|:---------|:-------------------|:--------|
| 279 | clc_sex  | clc_sex_cat2_1     | cat     |
| 280 | clc_sex  | clc_sex_cat2_2     | cat     |
| 281 | clc_sex  | clc_sex_cat2_NA::a | cat     |
| 282 | clc_sex  | clc_sex_cat2_NA::b | cat     |
| 283 | clc_sex  | clc_sex_cat2_NA::b | cat     |

4.  **databaseStart:** the CHMS cycles that contain the variable of
    interest, separated by commas. Each cycle’s medication data is
    separate from the rest of their respective data.

|  | variable | dummyVariable | typeEnd | databaseStart |
|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 |

5.  **variableStart:** the original names of the variables as they are
    listed in each respective CHMS cycle, separated by commas. If the
    variable name in a particular CHMS cycle is different from the
    transformed variable name, write out the CHMS cycle identifier, add
    two colons, and write out the original variable name for that cycle.
    If the variable name in a particular CHMS cycle is the same as the
    transformed variable name, the variable name is written out
    surrounded by square brackets. Note: this only needs to be written
    out **once**.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart |
|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] |

- Hypothetically, let’s say the categorical `sex` variable in CHMS cycle
  1 is `DHHA_SEX`. If the final variable name for categorical sex in the
  **variable** column is `clc_sex`, you would write the following in
  this column: `cycle1::DHHA_SEX`.

- In reality, the categorical sex variable in all six CHMS cycles is
  `clc_sex`. Since it is the same as the final variable name, you would
  write in this column `[clc_sex]` **once**. The variable name that is
  denoted within the square brackets is the default variable name.

6.  **typeStart:** the variable type as indicated in the CHMS cycles. As
    indicated in the **toType** column, categorical variables are
    denoted as `cat` and continuous variables are denoted as `cont`.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart |
|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat |

7.  **recEnd:** the value you would like to recode each category value
    to. For continuous variables that are not transformed in type, you
    would write in this column `copy` so that the function copies the
    values without any transformations. For the not applicable category,
    write `NA::a`. For missing & else categories, write `NA::b`

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd |
|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b |

- For categorical variables that are not changing variable types
  (i.e. cat to cat), it is ideal to retain the same values as indicated
  in each CHMS cycle. But for transformed categorical variables that
  have changed in type (i.e cat to cont), you will have to develop
  values that make the most sense to your analysis. In
  `variable_details.csv`, variables that have gone from cat to cont have
  used midpoints of each category.

8.  **numValidCat:** the number of categories for a variable. This only
    applies to variables in which the **toType** is cat. For continuous
    variables, `numValidCat = N/A`. Not applicable, missing, and else
    categories are not included in the category count. Note that this
    column is not necessary for
    [`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 |

9.  **catLabel:** short form label describing the category of a
    particular variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing |

10. **catLabelLong:** more detailed label describing the category of a
    particular variable. This label should be identical to what is shown
    in the CHMS data documentation, unless you are creating derived
    variables and would like to create your own label for it.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing |

11. **units:** the units of a particular variable. If there are no units
    for the variable, write `N/A`. Note, the function will not work if
    there different units between the rows of the same variable
    (i.e. height using both m and ft).

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A |

12. **recStart:** the range of values for a particular category in a
    variable as indicated in the CHMS. See CHMS data documentation for
    each cycle and use the smallest and large values as your range to
    capture all values between the cycles.

The rules for each category of a new variable are a string in `recFrom`
and value in `recTo`. These recode pairs are the same syntax as interval
notation in which a closed range of values are specified using square
brackets. See
[here](https://en.wikipedia.org/wiki/Interval_(mathematics)#Notations_for_intervals)
for more information on interval notation. Recode pairs are obtained
from the RecFrom and RecTo columns *value range* is indicated by a
comma, e.g. `recFrom= [1,4]; recTo = 1` (recodes all values from 1 to 4
into 1} *value range* for double vectors (with fractional part), all
values within the specified range are recoded;
e.g. `recFrom = [1,2.5]; recTo = 1` recodes 1 to 2.5 into 1, but 2.55
would not be recoded (since it’s not included in the specified range).
*NA* is used for missing values (don’t know, refusal, not stated) *else*
is used all other values, which have not been specified yet, are
indicated by `else`, e.g. `recFrom = "else"; recTo = NA` (recode all
other values (not specified in other rows) to “NA”)} *copy* the `else`
token can be combined with `copy`, indicating that all remaining, not
yet recoded values should stay the same (are copied from the original
value), e.g. `recFrom = "else"; recTo = "copy"`

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else |

13. **catStartLabel:** label describing each category. This label should
    be identical to what is shown in the CHMS data documentation. For
    the missing row, each missing category is described along with their
    coded values.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else |

14. **variableStartShortLabel:** short form label describing the
    variable.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex |

15. **variableStartLabel:** more detailed label describing the variable.
    This label should be identical to what is shown in the CHMS data
    documentation.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex | Sex |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex | Sex |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex | Sex |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex | Sex |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex | Sex |

16. **notes:** any relevant notes to inform the user running the
    `recode-with-table` function. Things to include here would be
    changes in wording between CHMS cycles, missing/changes in
    categories, and changes in variable type between CHMS cycles.

|  | variable | dummyVariable | typeEnd | databaseStart | variableStart | typeStart | recEnd | numValidCat | catLabel | catLabelLong | units | recStart | catStartLabel | variableStartShortLabel | variableStartLabel | notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 279 | clc_sex | clc_sex_cat2_1 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 1 | 2 | Male | Male | N/A | 1 | Male | Sex | Sex |  |
| 280 | clc_sex | clc_sex_cat2_2 | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | 2 | 2 | Female | Female | N/A | 2 | Female | Sex | Sex |  |
| 281 | clc_sex | clc_sex_cat2_NA::a | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::a | 2 | not applicable | not applicable | N/A | 6 | Valid skip | Sex | Sex |  |
| 282 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | \[7, 9\] | Don’t know (7); Refusal (8); Not stated (9) | Sex | Sex |  |
| 283 | clc_sex | clc_sex_cat2_NA::b | cat | cycle1, cycle2, cycle3, cycle4, cycle5, cycle6 | \[clc_sex\] | cat | NA::b | 2 | missing | missing | N/A | else | else | Sex | Sex |  |

## Derived Variables

The same naming convention applies to derived variables with the
exception of two columns:

1.  In **variableStart**, instead of database names being listed,
    **DerivedVar::** is written followed with the list of CHMS variables
    used inside square brackets.

- `DerivedVar::[var1, var2, var3]`

2.  In **recEnd**, write **Func::** followed with the name of the custom
    function used to create the derived variable.

- `Func::derivedFunction`
