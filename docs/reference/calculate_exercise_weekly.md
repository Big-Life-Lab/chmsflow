# Weekly minutes of moderate-to-vigorous physical activity (MVPA) from daily average

This function takes the average daily minutes of moderate-to-vigorous
physical activity (MVPA) across a week of accelerometer use as an input
(`mvpa_min`) and calculates the equivalent weekly MVPA minutes. The
result is returned as a numeric value.

## Usage

``` r
calculate_exercise_weekly(mvpa_min)
```

## Arguments

- mvpa_min:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  the average daily minutes of moderate-to-vigorous physical activity
  (MVPA) across a week of accelerometer use.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The total weekly minutes
of MVPA. If inputs are invalid or out of bounds, the function returns a
tagged NA.

## Details

The function multiplies the average daily MVPA minutes (`mvpa_min`) by 7
to obtain the equivalent weekly MVPA minutes.

         **Missing Data Codes:**
         - Propagates tagged NAs from the input `mvpa_min`.

## See also

[`calculate_exercise_daily_avg()`](https://big-life-lab.github.io/chmsflow/reference/calculate_exercise_daily_avg.md),
[`categorize_exercise()`](https://big-life-lab.github.io/chmsflow/reference/categorize_exercise.md)

## Examples

``` r
# Scalar usage: Single respondent
# Example: Convert average daily MVPA minutes to weekly MVPA minutes.
calculate_exercise_weekly(35)
#> [1] 245
# Output: 245

# Multiple respondents
calculate_exercise_weekly(c(35, 40, 20))
#> [1] 245 280 140
# Returns: c(245, 280, 140)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(min_per_week = calculate_exercise_weekly(avg_exercise))
```
