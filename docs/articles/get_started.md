# Get started

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

## 2. Transform variables into harmonized versions

Use
[`rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
of recodeflow to transform the variables of a CHMS dataset. Cycle data
object always has to be called “cyclex” in order for recoding to work
properly.

At the RDC, each cycle is split into multiple components (e.g.,
household data, clinic data, laboratory data, etc.), so it is the
analyst’s responsibility to merge their required components in one
database named “cyclex”. However, keep medication data separate from the
rest of the cycle data ([see
here](https://big-life-lab.github.io/chmsflow/articles/recoding_medications.md)).
Note that row headers for cycle 6 must be put to lower case prior to
recoding.

``` r

# Load recodeflow
library(recodeflow)

# Recoding basic variables
cycle4_ages <- rec_with_table(cycle4, "clc_age", variable_details = variable_details, log = TRUE)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    The variable clc_age was recoded into clc_age for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1     copy    [3, 80]         1000
    2    NA::a        996            0
    3    NA::b [997, 999]            0
    4     <NA>       else            0

``` r

head(cycle4_ages)
```

      clc_age
    1      50
    2      34
    3      70
    4      33
    5      22
    6      61

``` r

cycle4_sexes <- rec_with_table(cycle4, "clc_sex", variable_details = variable_details, log = TRUE)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    The variable clc_sex was recoded into clc_sex for the database cycle4 the following recodes were made: 

      value_to   From rows_recoded
    1        1      1          516
    2        2      2          484
    3    NA::a      6            0
    4    NA::b [7, 9]            0
    5    NA(b)   else            0

``` r

head(cycle4_sexes)
```

      clc_sex
    1       2
    2       2
    3       1
    4       1
    5       1
    6       2

``` r

# Recoding a transformed variable (cont to cat)
cycle4_categorical_ages <- rec_with_table(cycle4, "agegroup4", variable_details = variable_details, log = TRUE)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    The variable clc_age was recoded into agegroup4 for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1        1   [20, 39]          337
    2        2   [40, 59]          332
    3        3   [60, 69]          161
    4        4   [70, 79]          170
    5    NA::a        996            0
    6    NA::b [997, 999]            0
    7    NA(b)       else            0

``` r

head(cycle4_categorical_ages)
```

      agegroup4
    1         2
    2         1
    3         4
    4         1
    5         1
    6         3

``` r

# Recoding a derived variable
cycle4_adjusted_SBPs <- rec_with_table(cycle4, c("bpmdpbps", "sbp_adj"), variable_details = variable_details, log = TRUE)
```

    Using the passed data variable name as database_name

    Warning in recode_call(variables = variables, data = data, database_name =
    database_name, : is missing from variable details therefore cannot be recoded

    The variable bpmdpbps was recoded into bpmdpbps for the database cycle4 the following recodes were made: 

      value_to       From rows_recoded
    1     copy  [73, 216]          977
    2    NA::a        996            1
    3    NA::b [997, 999]           22
    4     <NA>       else            0

``` r

head(cycle4_adjusted_SBPs)
```

      bpmdpbps sbp_adj
    1      118  121.14
    2      123  125.79
    3      104  108.12
    4      201  198.33
    5       82   87.66
    6      141  142.53
