# Average daily minutes of moderate-to-vigorous physical activity (MVPA) from accelerometer data

This function calculates the average daily minutes of
moderate-to-vigorous physical activity (MVPA) across a week of
accelerometer measurement. It takes seven parameters, each representing
the MVPA minutes on a specific day (Day 1 to Day 7). The function
computes the daily average across the week.

## Usage

``` r
calculate_exercise_daily_avg(
  ammdmva1,
  ammdmva2,
  ammdmva3,
  ammdmva4,
  ammdmva5,
  ammdmva6,
  ammdmva7
)
```

## Arguments

- ammdmva1:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of moderate-to-vigorous physical activity (MVPA) on Day 1 of
  accelerometer measurement.

- ammdmva2:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 2 of accelerometer measurement.

- ammdmva3:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 3 of accelerometer measurement.

- ammdmva4:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 4 of accelerometer measurement.

- ammdmva5:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 5 of accelerometer measurement.

- ammdmva6:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 6 of accelerometer measurement.

- ammdmva7:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric representing
  minutes of MVPA on Day 7 of accelerometer measurement.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The average daily minutes
of MVPA across a week of accelerometer use. If inputs are invalid or out
of bounds, the function returns a tagged NA.

## Details

This function processes physical activity data from accelerometer
measurements to create a weekly activity summary.

         **Data Quality Requirements:**
         - Requires complete 7-day data (missing days result in tagged NA)
         - This conservative approach ensures reliable activity estimates
         - Zero values are preserved (represent valid no-activity days)

         **Missing Data Codes:**
         - For all input variables:
           - `9996`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `9997-9999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`calculate_exercise_weekly()`](https://big-life-lab.github.io/chmsflow/reference/calculate_exercise_weekly.md)
for activity unit conversion,
[`categorize_exercise()`](https://big-life-lab.github.io/chmsflow/reference/categorize_exercise.md)
for activity level classification

## Examples

``` r
# Scalar usage: Single respondent
# Example: Calculate the average minutes of exercise per day for a week of accelerometer data.
calculate_exercise_daily_avg(30, 40, 25, 35, 20, 45, 50)
#> [1] 35
# Output: 35

# Example: Respondent has non-response values for all inputs.
result <- calculate_exercise_daily_avg(9998, 9998, 9998, 9998, 9998, 9998, 9998)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_exercise_daily_avg(
  c(30, 20), c(40, 30), c(25, 35), c(35, 45),
  c(20, 25), c(45, 55), c(50, 60)
)
#> [1] 35.00000 38.57143
# Returns: c(35, 39.28571)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(avg_exercise = calculate_exercise_daily_avg(ammdmva1, ammdmva2,
#     ammdmva3, ammdmva4, ammdmva5, ammdmva6, ammdmva7))
```
