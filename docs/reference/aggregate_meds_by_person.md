# Aggregate medication variables to one row per person

Collapses long-format medication data (cycles 3-6) to one row per
respondent by taking the maximum value of each medication variable
across all rows. A result of 1 (taking the medication) takes precedence
over 0. Tagged NAs are propagated only when all rows for a respondent
are missing.

## Usage

``` r
aggregate_meds_by_person(data, variables, by = "clinicid")
```

## Arguments

- data:

  [data.frame](https://rdrr.io/r/base/data.frame.html) Long-format
  medication data with multiple rows per respondent.

- variables:

  [character](https://rdrr.io/r/base/character.html) Variable names to
  aggregate.

- by:

  [character](https://rdrr.io/r/base/character.html) The respondent
  identifier column. Default is `"clinicid"`.

## Value

[data.frame](https://rdrr.io/r/base/data.frame.html) One row per
respondent with aggregated medication variables as numeric.

## See also

[`recode_meds_cycles3to6()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles3to6.md),
[`recode_meds_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/recode_meds_cycles1to2.md)

## Examples

``` r
df <- data.frame(
  clinicid    = c(1, 1, 2, 2),
  any_htn_med = c(0, 1, 0, 0),
  diab_med    = c(1, 0, 0, 0)
)
aggregate_meds_by_person(df, variables = c("any_htn_med", "diab_med"))
#> # A tibble: 2 × 3
#>   clinicid any_htn_med diab_med
#>      <dbl>       <dbl>    <dbl>
#> 1        1           1        1
#> 2        2           0        0
```
