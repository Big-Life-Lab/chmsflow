# Daily fruit and vegetable consumption in a year - cycles 3-6

This function calculates the daily fruit and vegetable consumption in a
year for respondents in the Canadian Health Measures Survey (CHMS)
cycles 3-6. It takes eleven parameters, each representing the number of
times per year a specific fruit or vegetable item was consumed. The
function then sums up the consumption frequencies of all these items and
divides the total by 365 to obtain the average daily consumption of
fruits and vegetables in a year.

## Usage

``` r
calculate_fv_daily_cycles3to6(
  wsdd34y,
  wsdd35y,
  gfvd17ay,
  gfvd17by,
  gfvd17cy,
  gfvd17dy,
  gfvd18y,
  gfvd19y,
  gfvd20y,
  gfvd22y,
  gfvd23y
)
```

## Arguments

- wsdd34y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year orange or grapefruit juice
  was consumed.

- wsdd35y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year other fruit juices were
  consumed.

- gfvd17ay:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year citrus fruits were consumed.

- gfvd17by:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year strawberries were consumed
  (in summer).

- gfvd17cy:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year strawberries were consumed
  (outside summer).

- gfvd17dy:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year other fruits were consumed.

- gfvd18y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year tomato or tomato sauce was
  consumed.

- gfvd19y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year lettuce or green leafy salad
  was consumed.

- gfvd20y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year spinach, mustard greens, and
  cabbage were consumed.

- gfvd22y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year potatoes were consumed.

- gfvd23y:

  [numeric](https://rdrr.io/r/base/numeric.html) A numeric vector
  representing the number of times per year other vegetables were
  consumed.

## Value

[numeric](https://rdrr.io/r/base/numeric.html) The average times per day
fruits and vegetables were consumed in a year. If inputs are invalid or
out of bounds, the function returns a tagged NA.

## Details

The function calculates the total consumption of fruits and vegetables
in a year by summing up the consumption frequencies of all the input
items. It then divides the total by 365 to obtain the average daily
consumption of fruits and vegetables in a year.

         **Missing Data Codes:**
         - For all input variables:
           - `9996`: Valid skip. Handled as `haven::tagged_na("a")`.
           - `9997-9999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.

## See also

[`calculate_fv_daily_cycles1to2()`](https://big-life-lab.github.io/chmsflow/reference/calculate_fv_daily_cycles1to2.md)
for cycles 1-2 fruit and vegetable consumption,
[`categorize_diet_quality()`](https://big-life-lab.github.io/chmsflow/reference/categorize_diet_quality.md)
for overall diet quality

## Examples

``` r
# Scalar usage: Single respondent
# Example: Calculate average daily fruit and vegetable consumption for a cycle 3-6 respondent
calculate_fv_daily_cycles3to6(
  wsdd34y = 50, wsdd35y = 100, gfvd17ay = 150, gfvd17by = 80, gfvd17cy = 40,
  gfvd17dy = 200, gfvd18y = 100, gfvd19y = 80, gfvd20y = 60, gfvd22y = 120, gfvd23y = 90
)
#> [1] 2.931507
# Output: 2.931507

# Example: Respondent has non-response values for all inputs.
result <- calculate_fv_daily_cycles3to6(
  wsdd34y = 9998, wsdd35y = 9998, gfvd17ay = 9998, gfvd17by = 9998, gfvd17cy = 9998,
  gfvd17dy = 9998, gfvd18y = 9998, gfvd19y = 9998, gfvd20y = 9998, gfvd22y = 9998, gfvd23y = 9998
)
result # Shows: NA
#> [1] NA
haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#> [1] TRUE
format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#> [1] "NA"

# Multiple respondents
calculate_fv_daily_cycles3to6(
  wsdd34y = c(50, 60), wsdd35y = c(100, 110), gfvd17ay = c(150, 160), gfvd17by = c(80, 90),
  gfvd17cy = c(40, 50), gfvd17dy = c(200, 210), gfvd18y = c(100, 110), gfvd19y = c(80, 90),
  gfvd20y = c(60, 70), gfvd22y = c(120, 130), gfvd23y = c(90, 100)
)
#> [1] 2.931507 3.232877
# Returns: c(2.931507, 3.232877)

# Database usage: Applied to survey datasets
# library(dplyr)
# dataset |>
#   mutate(total_fv = calculate_fv_daily_cycles3to6(wsdd34y, wsdd35y, gfvd17ay,
#     gfvd17by, gfvd17cy, gfvd17dy, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y))
```
