# Any anti-hypertensive medications

This function checks if a given medication is any anti-hypertensive
drug. This function processes multiple inputs efficiently.

## Usage

``` r
is_any_antihtn_med(meucatc, npi_25b)
```

## Arguments

- meucatc:

  [character](https://rdrr.io/r/base/character.html) ATC code of the
  medication.

- npi_25b:

  [integer](https://rdrr.io/r/base/integer.html) Time when the
  medication was last taken.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) 1 if medication is an
anti-hypertensive drug, 0 otherwise. If inputs are invalid or out of
bounds, the function returns a tagged NA.

## Details

Identifies anti-hypertensive drugs based on ATC codes starting with
"C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes.

         **Missing Data Codes:**
         - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
         - `npi_25b`: `6` (Not applicable), `7-9` (Missing)

## Examples

``` r
# Scalar usage: Single respondent
is_any_antihtn_med("C07AB02", 4)
#> [1] 1
# Returns: 1

# Example: Respondent has non-response values for all inputs.
result <- is_any_antihtn_med("9999998", 8)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
is_any_antihtn_med(c("C07AB02", "C07AA07"), c(4, 2))
#> [1] 1 0
# Returns: c(1, 0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(any_antihtn = is_any_antihtn_med(meucatc, npi_25b))
```
