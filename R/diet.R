#' @title Daily fruit and vegetable consumption in a year - cycles 1-2
#'
#' @description This function calculates the daily fruit and vegetable consumption in a year for respondent in the Canadian Health Measures
#' Survey (CHMS) cycles 1-2. It takes seven parameters, each representing the number of times per year a specific fruit or vegetable item
#' was consumed. The function then sums up the consumption frequencies of all these items and divides the total by 365 to
#' obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param WSDD14Y [numeric] A numeric vector representing the number of times per year fruit juice was consumed.
#' @param GFVD17Y [numeric] A numeric vector representing the number of times per year fruit (excluding juice) was consumed.
#' @param GFVD18Y [numeric] A numeric vector representing the number of times per year tomato or tomato sauce was consumed.
#' @param GFVD19Y [numeric] A numeric vector representing the number of times per year lettuce or green leafy salad was consumed.
#' @param GFVD20Y [numeric] A numeric vector representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param GFVD22Y [numeric] A numeric vector representing the number of times per year potatoes were consumed.
#' @param GFVD23Y [numeric] A numeric vector representing the number of times per year other vegetables were consumed.
#'
#' @return [numeric] The average times per day fruits and vegetables were consumed in a year.
#'
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year. NA(b) is only returned if all the parameters are missing or if the average ends
#'          up being NA.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Calculate average daily fruit and vegetable consumption for a cycle 1-2 respondent.
#' # Let's assume the following annual consumption frequencies for each item:
#' # WSDD14Y (fruit juice) = 50 times
#' # GFVD17Y (fruit, excluding juice) = 150 times
#' # GFVD18Y (tomato or tomato sauce) = 200 times
#' # GFVD19Y (lettuce or green leafy salad) = 100 times
#' # GFVD20Y (spinach, mustard greens, and cabbage) = 80 times
#' # GFVD22Y (potatoes) = 120 times
#' # GFVD23Y (other vegetables) = 90 times
#' # Using the function:
#' find_totalFV_cycles1and2(
#'   WSDD14Y = 50, GFVD17Y = 150, GFVD18Y = 200, GFVD19Y = 100, GFVD20Y = 80,
#'   GFVD22Y = 120, GFVD23Y = 90
#' )
#' # Output: 2.164384
#'
#' # Multiple respondents
#' find_totalFV_cycles1and2(
#'   WSDD14Y = c(50, 60), GFVD17Y = c(150, 160), GFVD18Y = c(200, 210), GFVD19Y = c(100, 110),
#'   GFVD20Y = c(80, 90), GFVD22Y = c(120, 130), GFVD23Y = c(90, 100)
#' )
#' # Returns: c(2.164384, 2.356164)
#'
#' @seealso [find_totalFV_cycles3to6()] for cycles 3-6 fruit and vegetable consumption, [determine_gooddiet()] for overall diet quality
#' @references Health Canada food guide and dietary recommendations
#' @keywords survey nutrition diet fruit-vegetable health
#' @export
find_totalFV_cycles1and2 <- function(WSDD14Y, GFVD17Y, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) {
  measurements <- cbind(WSDD14Y, GFVD17Y, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y)
  totalFV <- rowSums(measurements, na.rm = TRUE) / 365

  dplyr::case_when(
    rowSums(is.na(measurements)) == ncol(measurements) ~ haven::tagged_na("b"),
    rowSums(measurements < 0, na.rm = TRUE) > 0 ~ haven::tagged_na("b"),
    TRUE ~ totalFV
  )
}

#' @title Daily fruit and vegetable consumption in a year - cycles 3-6
#'
#' @description This function calculates the daily fruit and vegetable consumption in a year for respondents in the Canadian Health Measures
#' Survey (CHMS) cycles 3-6. It takes eleven parameters, each representing the number of times per year a specific fruit or
#' vegetable item was consumed. The function then sums up the consumption frequencies of all these items and divides the total
#' by 365 to obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param WSDD34Y [numeric] A numeric vector representing the number of times per year orange or grapefruit juice was consumed.
#' @param WSDD35Y [numeric] A numeric vector representing the number of times per year other fruit juices were consumed.
#' @param GFVD17AY [numeric] A numeric vector representing the number of times per year citrus fruits were consumed.
#' @param GFVD17BY [numeric] A numeric vector representing the number of times per year strawberries were consumed (in summer).
#' @param GFVD17CY [numeric] A numeric vector representing the number of times per year strawberries were consumed (outside summer).
#' @param GFVD17DY [numeric] A numeric vector representing the number of times per year other fruits were consumed.
#' @param GFVD18Y [numeric] A numeric vector representing the number of times per year tomato or tomato sauce was consumed.
#' @param GFVD19Y [numeric] A numeric vector representing the number of times per year lettuce or green leafy salad was consumed.
#' @param GFVD20Y [numeric] A numeric vector representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param GFVD22Y [numeric] A numeric vector representing the number of times per year potatoes were consumed.
#' @param GFVD23Y [numeric] A numeric vector representing the number of times per year other vegetables were consumed.
#'
#' @return [numeric] The average times per day fruits and vegetables were consumed in a year.
#'
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year. NA(b) is only returned if all the parameters are missing or if the average ends
#'          up being NA.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Calculate average daily fruit and vegetable consumption for a cycle 3-6 respondent
#' # Let's assume the following annual consumption frequencies for each item:
#' # WSDD34Y (orange or grapefruit juice) = 50 times
#' # WSDD35Y (other fruit juices) = 100 times
#' # GFVD17AY (citrus fruits) = 150 times
#' # GFVD17BY (strawberries in summer) = 80 times
#' # GFVD17CY (strawberries outside summer) = 40 times
#' # GFVD17DY (other fruits) = 200 times
#' # GFVD18Y (tomato or tomato sauce) = 100 times
#' # GFVD19Y (lettuce or green leafy salad) = 80 times
#' # GFVD20Y (spinach, mustard greens, and cabbage) = 60 times
#' # GFVD22Y (potatoes) = 120 times
#' # GFVD23Y (other vegetables) = 90 times
#' # Using the function:
#' find_totalFV_cycles3to6(
#'   WSDD34Y = 50, WSDD35Y = 100, GFVD17AY = 150, GFVD17BY = 80, GFVD17CY = 40,
#'   GFVD17DY = 200, GFVD18Y = 100, GFVD19Y = 80, GFVD20Y = 60, GFVD22Y = 120, GFVD23Y = 90
#' )
#' # Output: 2.931507
#'
#' # Multiple respondents
#' find_totalFV_cycles3to6(
#'   WSDD34Y = c(50, 60), WSDD35Y = c(100, 110), GFVD17AY = c(150, 160), GFVD17BY = c(80, 90),
#'   GFVD17CY = c(40, 50), GFVD17DY = c(200, 210), GFVD18Y = c(100, 110), GFVD19Y = c(80, 90),
#'   GFVD20Y = c(60, 70), GFVD22Y = c(120, 130), GFVD23Y = c(90, 100)
#' )
#' # Returns: c(2.931507, 3.232877)
#'
#' @export
find_totalFV_cycles3to6 <- function(WSDD34Y, WSDD35Y, GFVD17AY, GFVD17BY, GFVD17CY, GFVD17DY, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) {
  measurements <- cbind(WSDD34Y, WSDD35Y, GFVD17AY, GFVD17BY, GFVD17CY, GFVD17DY, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y)
  totalFV <- rowSums(measurements, na.rm = TRUE) / 365

  dplyr::case_when(
    rowSums(is.na(measurements)) == ncol(measurements) ~ haven::tagged_na("b"),
    rowSums(measurements < 0, na.rm = TRUE) > 0 ~ haven::tagged_na("b"),
    TRUE ~ totalFV
  )
}

#' @title Categorical diet indicator
#'
#' @description This function categorizes individuals' diet quality based on their total fruit and vegetable consumption.
#'
#' @param totalFV [numeric] A numeric vector representing the average times per day fruits and vegetables were consumed in a year.
#'
#' @return [integer] A categorical indicating the diet quality:
#'   - 1: Good diet (totalFV >= 5)
#'   - 2: Poor diet (totalFV < 5)
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a totalFV value of 3 as poor diet
#' determine_gooddiet(3)
#' # Output: 2
#'
#' # Example 2: Categorize a totalFV value of 7 as good diet
#' determine_gooddiet(7)
#' # Output: 1
#'
#' # Multiple respondents
#' determine_gooddiet(c(3, 7, 5))
#' # Returns: c(2, 1, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(diet_quality = determine_gooddiet(total_fv))
#'
#' @export
determine_gooddiet <- function(totalFV) {
  dplyr::case_when(
    is.na(totalFV) | totalFV < 0 ~ haven::tagged_na("b"),
    totalFV >= 5 ~ 1,
    totalFV < 5 ~ 2,
    .default = haven::tagged_na("b")
  )
}
