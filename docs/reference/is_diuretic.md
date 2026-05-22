# Diuretics

This function checks if a given medication is a diuretic. This function
processes multiple inputs efficiently.

## Usage

``` r
is_diuretic(meucatc, npi_25b)
```

## Arguments

- meucatc:

  [character](https://rdrr.io/r/base/character.html) ATC code of the
  medication.

- npi_25b:

  [integer](https://rdrr.io/r/base/integer.html) Time when the
  medication was last taken.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) 1 if medication is a
diuretic, 0 otherwise. If inputs are invalid or out of bounds, the
function returns a tagged NA.

## Details

Identifies diuretics based on ATC codes starting with "C03", excluding
specific sub-codes.

         **Missing Data Codes:**
         - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
         - `npi_25b`: `6` (Not applicable), `7-9` (Missing)

## Examples

``` r
# Scalar usage: Single respondent
is_diuretic("C03AA03", 3)
#> [1] 1
# Returns: 1

# Example: Respondent has non-response values for all inputs.
result <- is_diuretic("9999998", 8)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
is_diuretic(c("C03AA03", "C03BA08"), c(3, 2))
#> [1] 1 0
# Returns: c(1, 0)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(diuretic = is_diuretic(meucatc, npi_25b))
```
