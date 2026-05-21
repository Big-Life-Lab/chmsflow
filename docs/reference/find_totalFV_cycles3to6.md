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
find_totalFV_cycles3to6(
  WSDD34Y,
  WSDD35Y,
  GFVD17AY,
  GFVD17BY,
  GFVD17CY,
  GFVD17DY,
  GFVD18Y,
  GFVD19Y,
  GFVD20Y,
  GFVD22Y,
  GFVD23Y
)
```

## Arguments

- WSDD34Y:

  A numeric representing the number of times per year orange or
  grapefruit juice was consumed.

- WSDD35Y:

  A numeric representing the number of times per year other fruit juices
  were consumed.

- GFVD17AY:

  A numeric representing the number of times per year citrus fruits were
  consumed.

- GFVD17BY:

  A numeric representing the number of times per year strawberries were
  consumed (in summer).

- GFVD17CY:

  A numeric representing the number of times per year strawberries were
  consumed (outside summer).

- GFVD17DY:

  A numeric representing the number of times per year other fruits were
  consumed.

- GFVD18Y:

  A numeric representing the number of times per year tomato or tomato
  sauce was consumed.

- GFVD19Y:

  A numeric representing the number of times per year lettuce or green
  leafy salad was consumed.

- GFVD20Y:

  A numeric representing the number of times per year spinach, mustard
  greens, and cabbage were consumed.

- GFVD22Y:

  A numeric representing the number of times per year potatoes were
  consumed.

- GFVD23Y:

  A numeric representing the number of times per year other vegetables
  were consumed.

## Value

A numeric representing the average times per day fruits and vegetables
were consumed in a year.

## Details

The function calculates the total consumption of fruits and vegetables
in a year by summing up the consumption frequencies of all the input
items. It then divides the total by 365 to obtain the average daily
consumption of fruits and vegetables in a year. NA(b) is only returned
if all the parameters are missing or if the average ends up being NA.

## Examples

``` r

# Example: Calculate average daily fruit and vegetable consumption for a cycle 3-6 respondent
# Let's assume the following annual consumption frequencies for each item:
# WSDD34Y (orange or grapefruit juice) = 50 times
# WSDD35Y (other fruit juices) = 100 times
# GFVD17AY (citrus fruits) = 150 times
# GFVD17BY (strawberries in summer) = 80 times
# GFVD17CY (strawberries outside summer) = 40 times
# GFVD17DY (other fruits) = 200 times
# GFVD18Y (tomato or tomato sauce) = 100 times
# GFVD19Y (lettuce or green leafy salad) = 80 times
# GFVD20Y (spinach, mustard greens, and cabbage) = 60 times
# GFVD22Y (potatoes) = 120 times
# GFVD23Y (other vegetables) = 90 times
# Using the function:
find_totalFV_cycles3to6(
  WSDD34Y = 50, WSDD35Y = 100, GFVD17AY = 150, GFVD17BY = 80, GFVD17CY = 40,
  GFVD17DY = 200, GFVD18Y = 100, GFVD19Y = 80, GFVD20Y = 60, GFVD22Y = 120, GFVD23Y = 90
)
#> [1] 2.931507
# Output: 2.931507
```
