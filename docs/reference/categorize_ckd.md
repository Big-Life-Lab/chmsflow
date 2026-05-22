# Chronic kidney disease (CKD) derived variable

This function categorizes individuals' glomerular filtration rate (GFR)
into stages of Chronic Kidney Disease (CKD).

## Usage

``` r
categorize_ckd(gfr)
```

## Arguments

- gfr:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the glomerular filtration rate.

## Value

[integer](https://rdrr.io/r/base/integer.html) The CKD stage:

- 1: GFR of 60 or below (indicating CKD)

- 2: GFR above 60 (not indicating CKD)

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function applies the Kidney Disease: Improving Global Outcomes
(KDIGO) guideline to classify Chronic Kidney Disease (CKD) based on GFR.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `gfr`.

## References

Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group.
(2013). KDIGO 2012 clinical practice guideline for the evaluation and
management of chronic kidney disease. Kidney international supplements,
3(1), 1-150.

## See also

[`calculate_gfr()`](https://big-life-lab.github.io/chmsflow/reference/calculate_gfr.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Categorize a GFR of 45
categorize_ckd(45)
#> [1] 1
# Output: 1

# Example 2: Categorize a GFR of 75
categorize_ckd(75)
#> [1] 2
# Output: 2

# Example 3: Respondent has a non-response value for GFR.
result <- categorize_ckd(haven::tagged_na("b"))
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
categorize_ckd(c(45, 75, 60))
#> [1] 1 2 1
# Returns: c(1, 2, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(ckd = categorize_ckd(gfr))
```
