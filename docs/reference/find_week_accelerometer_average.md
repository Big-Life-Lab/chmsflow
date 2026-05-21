# Average minutes of exercise per day for week-long accelerometer data

This function calculates the average minutes of exercise per day across
a week of accelerometer data. It takes seven parameters, each
representing the minutes of exercise on a specific day (Day 1 to Day 7)
of accelerometer measurement. The function computes the average of these
values to obtain the average minutes of exercise per day.

## Usage

``` r
find_week_accelerometer_average(
  AMMDMVA1,
  AMMDMVA2,
  AMMDMVA3,
  AMMDMVA4,
  AMMDMVA5,
  AMMDMVA6,
  AMMDMVA7
)
```

## Arguments

- AMMDMVA1:

  A numeric representing minutes of exercise on Day 1 of accelerometer
  measurement.

- AMMDMVA2:

  A numeric representing minutes of exercise on Day 2 of accelerometer
  measurement.

- AMMDMVA3:

  A numeric representing minutes of exercise on Day 3 of accelerometer
  measurement.

- AMMDMVA4:

  A numeric representing minutes of exercise on Day 4 of accelerometer
  measurement.

- AMMDMVA5:

  A numeric representing minutes of exercise on Day 5 of accelerometer
  measurement.

- AMMDMVA6:

  A numeric representing minutes of exercise on Day 6 of accelerometer
  measurement.

- AMMDMVA7:

  A numeric representing minutes of exercise on Day 7 of accelerometer
  measurement.

## Value

A numeric representing the average minutes of exercise per day across a
week of accelerometer use.

## Details

The function calculates the average minutes of exercise per day by
taking the mean of the seven input parameters.

## Examples

``` r

# Example: Calculate the average minutes of exercise per day for a week of accelerometer data.
find_week_accelerometer_average(30, 40, 25, 35, 20, 45, 50)
#> [1] 35
# Output: 35 (The average minutes of exercise per day across the week is 35 minutes.)
```
