# Cardiovascular disease (CVD) personal history

This function determines a respondent's cardiovascular disease (CVD)
personal history based on the presence or absence of specific conditions
related to heart disease, heart attack, and stroke.

## Usage

``` r
determine_CVD_personal_history(CCC_61, CCC_63, CCC_81)
```

## Arguments

- CCC_61:

  An integer representing the respondent's personal history of heart
  disease. 1 for "Yes" if the person has heart disease, 2 for "No" if
  the person does not have heart disease.

- CCC_63:

  An integer representing the respondent's personal history of heart
  attack. 1 for "Yes" if the person had a heart attack, 2 for "No" if
  the person did not have a heart attack.

- CCC_81:

  An integer representing the respondent's personal history of stroke. 1
  for "Yes" if the person had a stroke, 2 for "No" if the person did not
  have a stroke.

## Value

An integer indicating the CVD personal history: 1 for "Yes" if the
person had heart disease, heart attack, or stroke; 2 for "No" if the
person had neither of the conditions; and NA if all the input variables
are a non-response.

## Examples

``` r

# Determine CVD personal history for a person with heart disease (CCC_61 = 1).
determine_CVD_personal_history(CCC_61 = 1, CCC_63 = 2, CCC_81 = 2)
#> [1] 1
# Output: 1 (CVD personal history is "Yes" as heart disease is present).
```
