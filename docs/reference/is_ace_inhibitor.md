# ACE inhibitors

This function checks if a given medication is an ACE inhibitor. This
function processes multiple inputs efficiently.

## Usage

``` r
is_ace_inhibitor(meucatc, npi_25b)
```

## Arguments

- meucatc:

  [character](https://rdrr.io/r/base/character.html) ATC code of the
  medication.

- npi_25b:

  [integer](https://rdrr.io/r/base/integer.html) Time when the
  medication was last taken.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) 1 if medication is an ACE
inhibitor, 0 otherwise. If inputs are invalid or out of bounds, the
function returns a tagged NA.

## Details

Identifies ACE inhibitors based on ATC codes starting with "C09".

         **Missing Data Codes:**
         - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
         - `npi_25b`: `6` (Not applicable), `7-9` (Missing)

## Examples

``` r
# Scalar usage: Single respondent
is_ace_inhibitor("C09AB03", 2)
#> [1] 1
# Returns: 1

# Example: Respondent has non-response values for all inputs.
result <- is_ace_inhibitor("9999998", 8)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
is_ace_inhibitor(c("C09AB03", "C01AA05"), c(2, 1))
#> [1] 1 0
# Returns: c(1, 0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(ace_inhibitor = is_ace_inhibitor(meucatc, npi_25b))
```
