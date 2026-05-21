# Minutes per week from minutes per day

This function takes the average minutes of exercise per day across a
week of accelerometer use as an input (`MVPA_min`) and calculates the
equivalent minutes of exercise per one week of accelerometer use. The
result is returned as a numeric value.

## Usage

``` r
minperday_to_minperweek(MVPA_min)
```

## Arguments

- MVPA_min:

  A numeric representing the average minutes of exercise per day across
  a week of accelerometer use.

## Value

A numeric representing the average minutes of exercise per one week of
accelerometer use.

## Details

The function simply multiplies the average minutes of exercise per day
(`MVPA_min`) by 7 to obtain the equivalent minutes of exercise per one
week of accelerometer use.

## Examples

``` r

# Example: Convert average minutes of exercise per day to minutes per week.
minperday_to_minperweek(35)
#> [1] 245
# Output: 245 (The equivalent minutes of exercise per one week is 245 minutes.)
```
