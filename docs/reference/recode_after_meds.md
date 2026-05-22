# Recode variables that depend on derived medication variable inputs

Wraps
[`recodeflow::rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
for use after derived medication variables (e.g., `any_htn_med`,
`diab_med`) have been recoded and merged into the main cycle dataset.
Use this instead of `rec_with_table()` when deriving variables whose
inputs include derived medication variables: it automatically excludes
medication-specific rows from `variable_details` so that pre-computed
medication columns are passed through via the `copy` entries rather than
re-derived from raw ATC/MHR columns.

## Usage

``` r
recode_after_meds(
  data,
  variables,
  by = "clinicid",
  database_name = NULL,
  variable_details = chmsflow::variable_details
)
```

## Arguments

- data:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Main cycle data
  with derived medication variables already merged.

- variables:

  [character](https://rdrr.io/r/base/character.html) Variable names to
  recode.

- by:

  [character](https://rdrr.io/r/base/character.html) Respondent
  identifier column. Default is `"clinicid"`.

- database_name:

  [character](https://rdrr.io/r/base/character.html) Name of the
  database in `variable_details`. Defaults to the name of the `data`
  argument.

- variable_details:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Variable details
  table. Defaults to
  [`chmsflow::variable_details`](https://big-life-lab.github.io/chmsflow/reference/variable_details.md).

## Value

[data.frame](https://rdrr.io/r/base/data.frame.html) Recoded data frame
returned by
[`recodeflow::rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html).

## See also

[`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md),
[`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)

## Examples

``` r
cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
#> Warning:  is missing from variable details therefore cannot be recoded
cycle3_diab <- recode_after_meds(
  cycle3,
  c("lab_hba1", "diab_a1c", "diab_med", "ccc_51", "diab_status")
)
#> Warning:  is missing from variable details therefore cannot be recoded
head(cycle3_diab[, c("clinicid", "diab_status")])
#>   clinicid diab_status
#> 1        1           1
#> 2        2           1
#> 3        3           1
#> 4        4           1
#> 5        5           1
#> 6        6           1
```
