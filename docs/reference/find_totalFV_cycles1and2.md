# Daily fruit and vegetable consumption in a year - cycles 1-2

This function calculates the daily fruit and vegetable consumption in a
year for respondent in the Canadian Health Measures Survey (CHMS) cycles
1-2. It takes seven parameters, each representing the number of times
per year a specific fruit or vegetable item was consumed. The function
then sums up the consumption frequencies of all these items and divides
the total by 365 to obtain the average daily consumption of fruits and
vegetables in a year.

## Usage

``` r
find_totalFV_cycles1and2(
  WSDD14Y,
  GFVD17Y,
  GFVD18Y,
  GFVD19Y,
  GFVD20Y,
  GFVD22Y,
  GFVD23Y
)
```

## Arguments

- WSDD14Y:

  A numeric representing the number of times per year fruit juice was
  consumed.

- GFVD17Y:

  A numeric representing the number of times per year fruit (excluding
  juice) was consumed.

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

# Example: Calculate average daily fruit and vegetable consumption for a cycle 1-2 respondent.
# Let's assume the following annual consumption frequencies for each item:
# WSDD14Y (fruit juice) = 50 times
# GFVD17Y (fruit, excluding juice) = 150 times
# GFVD18Y (tomato or tomato sauce) = 200 times
# GFVD19Y (lettuce or green leafy salad) = 100 times
# GFVD20Y (spinach, mustard greens, and cabbage) = 80 times
# GFVD22Y (potatoes) = 120 times
# GFVD23Y (other vegetables) = 90 times
# Using the function:
find_totalFV_cycles1and2(
  WSDD14Y = 50, GFVD17Y = 150, GFVD18Y = 200, GFVD19Y = 100, GFVD20Y = 80,
  GFVD22Y = 120, GFVD23Y = 90
)
#> [1] 2.164384
# Output: 2.164384
```
