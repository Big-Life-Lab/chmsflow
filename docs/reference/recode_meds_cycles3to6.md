# Recode medication variables for cycles 3-6 (long format)

Recodes medication variables from cycles 3-6 long-format data (one row
per medication per respondent), aggregates to one row per respondent,
and merges into the main cycle dataset. Wraps
[`recodeflow::rec_with_table()`](https://rdrr.io/pkg/recodeflow/man/rec_with_table.html)
and
[`aggregate_meds_by_person()`](https://big-life-lab.github.io/chmsflow/reference/aggregate_meds_by_person.md).

## Usage

``` r
recode_meds_cycles3to6(
  data,
  meds_data,
  variables,
  by = "clinicid",
  meds_database_name = NULL,
  variable_details = chmsflow::variable_details
)
```

## Arguments

- data:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Main cycle data
  to merge medication variables into.

- meds_data:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Long-format
  medication data (cycles 3-6) with columns `clinicid`, `meucatc`, and
  `npi_25b`.

- variables:

  [character](https://rdrr.io/r/base/character.html) Medication variable
  names to derive (e.g., `"any_htn_med"`).

- by:

  [character](https://rdrr.io/r/base/character.html) Respondent
  identifier column. Default is `"clinicid"`.

- meds_database_name:

  [character](https://rdrr.io/r/base/character.html) Name of the meds
  database in `variable_details`. Defaults to the name of the
  `meds_data` argument. Override when passing a transformed object
  (e.g., [`head()`](https://rdrr.io/r/utils/head.html)).

- variable_details:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Variable details
  table. Defaults to
  [`chmsflow::variable_details`](https://big-life-lab.github.io/chmsflow/reference/variable_details.md).

## Value

[data.frame](https://rdrr.io/r/base/data.frame.html) `data` with derived
medication variables merged in as numeric columns.

## See also

[`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md),
[`aggregate_meds_by_person()`](https://big-life-lab.github.io/chmsflow/reference/aggregate_meds_by_person.md)

## Examples

``` r
result <- recode_meds_cycles3to6(
  cycle3,
  cycle3_meds,
  c("any_htn_med", "diab_med")
)
#> Warning:  is missing from variable details therefore cannot be recoded
head(result[, c("clinicid", "any_htn_med", "diab_med")])
#>   clinicid any_htn_med diab_med
#> 1        1           1        1
#> 2        2           1        1
#> 3        3           1        1
#> 4        4           1        1
#> 5        5           1        1
#> 6        6           1        1
```
