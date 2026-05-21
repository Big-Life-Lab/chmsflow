# Categorical weekly physical activity indicator

This function categorizes individuals' weekly physical activity levels
based on a threshold value.

## Usage

``` r
categorize_minperweek(minperweek)
```

## Arguments

- minperweek:

  Numeric value representing an individual's minutes of
  moderate-to-vigorous physical activity (MVPA) per week.

## Value

A categorical value indicating the physical activity category:

- 1: Meets or exceeds the recommended 150 minutes of MVPA per week
  (minperweek \>= 150)

- 2: Below the recommended 150 minutes of MVPA per week (minperweek \<
  150)

- NA(b): Missing or invalid input

## Examples

``` r
# Example 1: Categorize 180 minutes of MVPA per week as meeting the recommendation
categorize_minperweek(180)
#> [1] 1
# Output: 1

# Example 2: Categorize 120 minutes of MVPA per week as below the recommendation
categorize_minperweek(120)
#> [1] 2
# Output: 2
```
