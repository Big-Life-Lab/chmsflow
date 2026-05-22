# Other anti-hypertensive medications

This function checks if a given medication is another anti-hypertensive
drug. This function processes multiple inputs efficiently.

## Usage

``` r
is_other_antihtn_med(meucatc, npi_25b)
```

## Arguments

- meucatc:

  [character](https://rdrr.io/r/base/character.html) ATC code of the
  medication.

- npi_25b:

  [integer](https://rdrr.io/r/base/integer.html) Time when the
  medication was last taken.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) 1 if medication is
another anti-hypertensive drug, 0 otherwise. If inputs are invalid or
out of bounds, the function returns a tagged NA.

## Details

Identifies other anti-hypertensive drugs based on ATC codes starting
with "C02", excluding a specific sub-code.

         **Missing Data Codes:**
         - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
         - `npi_25b`: `6` (Not applicable), `7-9` (Missing)

## Examples

``` r
# Scalar usage: Single respondent
is_other_antihtn_med("C02AC04", 3)
#> [1] 1
# Returns: 1

# Example: Respondent has non-response values for all inputs.
result <- is_other_antihtn_med("9999998", 8)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
is_other_antihtn_med(c("C02AC04", "C02KX01"), c(3, 2))
#> [1] 1 0
# Returns: c(1, 0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(other_antihtn = is_other_antihtn_med(meucatc, npi_25b))
```
