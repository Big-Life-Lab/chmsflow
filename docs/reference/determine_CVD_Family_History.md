# Cardiovascular Disease (CVD) family history

This function evaluates a respondent's family history of cardiovascular
disease (CVD), based on data about diagnoses of heart disease and stroke
in immediate family members and the ages at which these diagnoses
occurred. It identifies premature CVD if any diagnosis occurred before
age 60.

## Usage

``` r
determine_CVD_family_history(FMH_11, FMH_12, FMH_13, FMH_14)
```

## Arguments

- FMH_11:

  Integer: Indicates whether an immediate family member was diagnosed
  with heart disease. - 1 for "Yes" - 2 for "No".

- FMH_12:

  Numeric: Represents the youngest age at diagnosis of heart disease in
  an immediate family member.

- FMH_13:

  Integer: Indicates whether an immediate family member was diagnosed
  with stroke. - 1 for "Yes" - 2 for "No".

- FMH_14:

  Numeric: Represents the youngest age at diagnosis of stroke in an
  immediate family member.

## Value

An integer indicating the CVD family history:

- 1: "Yes" — Family history of premature CVD exists (diagnosis before
  age 60).

- 2: "No" — No family history of premature CVD.

- `NA(b)`: Missing/unknown — Due to non-responses, invalid inputs, or
  unknown diagnosis ages.

## Details

- If both `FMH_11` (heart disease history) and `FMH_13` (stroke history)
  are `NA`, the function returns `NA(b)`.

- If either `FMH_11` or `FMH_13` indicates a diagnosis (`1` for "Yes"),
  the corresponding age (`FMH_12` for heart disease and `FMH_14` for
  stroke) is evaluated:

  - Ages between 0 and 59 indicate premature CVD.

  - Ages between 60 and 100 indicate late-onset CVD.

  - Ages outside this range or invalid inputs (997, 998, 999) result in
    `NA(b)`.

- If both `FMH_11` and `FMH_13` are `2` ("No"), there is no family
  history of CVD (`2`).

- Any invalid inputs for `FMH_11` or `FMH_13` (values greater than 2)
  also result in `NA(b)`.

## Examples

``` r
# Example 1: Premature CVD due to heart disease diagnosis at age 50
determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 2, FMH_14 = NA)
#> [1] 1
# Output: 1
```
