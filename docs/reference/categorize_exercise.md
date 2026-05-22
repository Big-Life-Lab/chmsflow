# Categorical weekly moderate-to-vigorous physical activity (MVPA) indicator

This function categorizes individuals' weekly moderate-to-vigorous
physical activity (MVPA) levels against the 150 minutes/week guideline.

## Usage

``` r
categorize_exercise(exercise_min_week)
```

## Arguments

- exercise_min_week:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  an individual's minutes of moderate-to-vigorous physical activity
  (MVPA) per week.

## Value

[integer](https://rdrr.io/r/base/integer.html) A categorical indicating
the MVPA category:

- 1: Meets or exceeds the recommended 150 minutes of MVPA per week
  (exercise_min_week \>= 150)

- 2: Below the recommended 150 minutes of MVPA per week
  (exercise_min_week \< 150)

- `haven::tagged_na("a")`: Not applicable

- `haven::tagged_na("b")`: Missing

## Details

This function applies the national physical activity guideline of 150
minutes of moderate-to-vigorous physical activity (MVPA) per week.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `exercise_min_week`.

## See also

[`calculate_exercise_weekly()`](https://big-life-lab.github.io/chmsflow/reference/calculate_exercise_weekly.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example 1: Categorize 180 minutes of MVPA per week as meeting the recommendation
categorize_exercise(180)
#> [1] 1
# Output: 1

# Example 2: Categorize 120 minutes of MVPA per week as below the recommendation
categorize_exercise(120)
#> [1] 2
# Output: 2

# Multiple respondents
categorize_exercise(c(180, 120, 150))
#> [1] 1 2 1
# Returns: c(1, 2, 1)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(pa_category = categorize_exercise(min_per_week))
```
