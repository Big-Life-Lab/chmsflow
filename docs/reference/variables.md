# variables.csv

This dataset lists all the variables that are present in chmsflow.

## Usage

``` r
data(variables)
```

## Source

See
<https://big-life-lab.github.io/chmsflow/articles/variables_sheet.html>
for more details.

## Examples

``` r
data(variables)
str(variables)
#> 'data.frame':    211 obs. of  9 variables:
#>  $ variable     : chr  "ace_med" "adj_hh_income" "agegroup2079" "agegroup4" ...
#>  $ label        : chr  "ACE inhibitors" "Adjusted household income" "Age " "Age " ...
#>  $ labelLong    : chr  "Taking ACE inhibitors" "Adjusted total household income based on household size" "Converted age (2 groups)" "Converted age (4 groups)" ...
#>  $ section      : chr  "Health status" "Socioeconomic" "Sociodemographics" "Sociodemographics" ...
#>  $ subject      : chr  "Medication" "Income" "Age" "Age" ...
#>  $ variableType : chr  "Categorical" "Continuous" "Categorical" "Categorical" ...
#>  $ units        : chr  "N/A" "$" "N/A" "N/A" ...
#>  $ databaseStart: chr  "cycle1_meds, cycle2_meds, cycle3_meds, cycle4_meds, cycle5_meds, cycle6_meds" "cycle1, cycle2, cycle3, cycle4, cycle5, cycle6" "cycle1, cycle2, cycle3, cycle4, cycle5, cycle6" "cycle1, cycle2, cycle3, cycle4, cycle5, cycle6" ...
#>  $ variableStart: chr  "DerivedVar::[atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a"| __truncated__ "DerivedVar::[thi_01, dhhdsz]" "cycle6::CLC_AGE, [clc_age]" "cycle6::CLC_AGE, [clc_age]" ...
```
