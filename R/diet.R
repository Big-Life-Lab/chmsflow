#' @title Daily fruit and vegetable consumption in a year - cycles 1-2
#'
#' @description This function calculates the daily fruit and vegetable consumption in a year for respondent in the Canadian Health Measures
#' Survey (CHMS) cycles 1-2. It takes seven parameters, each representing the number of times per year a specific fruit or vegetable item
#' was consumed. The function then sums up the consumption frequencies of all these items and divides the total by 365 to
#' obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param wsdd14y [numeric] A numeric vector representing the number of times per year fruit juice was consumed.
#' @param gfvd17y [numeric] A numeric vector representing the number of times per year fruit (excluding juice) was consumed.
#' @param gfvd18y [numeric] A numeric vector representing the number of times per year tomato or tomato sauce was consumed.
#' @param gfvd19y [numeric] A numeric vector representing the number of times per year lettuce or green leafy salad was consumed.
#' @param gfvd20y [numeric] A numeric vector representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param gfvd22y [numeric] A numeric vector representing the number of times per year potatoes were consumed.
#' @param gfvd23y [numeric] A numeric vector representing the number of times per year other vegetables were consumed.
#'
#' @return [numeric] The average times per day fruits and vegetables were consumed in a year. If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year.
#'
#'          **Missing Data Codes:**
#'          - For all input variables:
#'            - `9996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `9997-9999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Calculate average daily fruit and vegetable consumption for a cycle 1-2 respondent.
#' calculate_fv_daily_cycles1to2(
#'   wsdd14y = 50, gfvd17y = 150, gfvd18y = 200, gfvd19y = 100, gfvd20y = 80,
#'   gfvd22y = 120, gfvd23y = 90
#' )
#' # Output: 2.164384
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- calculate_fv_daily_cycles1to2(
#'   wsdd14y = 9998, gfvd17y = 9998, gfvd18y = 9998, gfvd19y = 9998, gfvd20y = 9998,
#'   gfvd22y = 9998, gfvd23y = 9998
#' )
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_fv_daily_cycles1to2(
#'   wsdd14y = c(50, 60), gfvd17y = c(150, 160), gfvd18y = c(200, 210), gfvd19y = c(100, 110),
#'   gfvd20y = c(80, 90), gfvd22y = c(120, 130), gfvd23y = c(90, 100)
#' )
#' # Returns: c(2.164384, 2.356164)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(total_fv = calculate_fv_daily_cycles1to2(wsdd14y, gfvd17y, gfvd18y,
#' #     gfvd19y, gfvd20y, gfvd22y, gfvd23y))
#'
#' @seealso [calculate_fv_daily_cycles3to6()] for cycles 3-6 fruit and vegetable consumption, [categorize_diet_quality()] for overall diet quality
#' @export
calculate_fv_daily_cycles1to2 <- function(wsdd14y, gfvd17y, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y) {
  # Combine all measurements into a data frame
  measurements <- data.frame(wsdd14y, gfvd17y, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y)

  # Replace missing data codes with NA
  measurements[measurements == 9996] <- haven::tagged_na("a") # Valid skip
  measurements[measurements >= 9997] <- haven::tagged_na("b") # Don't know, refusal, not stated

  # Calculate the total fruit and vegetable consumption per day
  fv_daily <- rowSums(measurements, na.rm = TRUE) / 365

  # Handle cases with all missing data or negative values
  dplyr::case_when(
    rowSums(is.na(measurements)) == ncol(measurements) ~ haven::tagged_na("b"),
    rowSums(measurements < 0, na.rm = TRUE) > 0 ~ haven::tagged_na("b"),
    TRUE ~ fv_daily
  )
}

#' @title Daily fruit and vegetable consumption in a year - cycles 3-6
#'
#' @description This function calculates the daily fruit and vegetable consumption in a year for respondents in the Canadian Health Measures
#' Survey (CHMS) cycles 3-6. It takes eleven parameters, each representing the number of times per year a specific fruit or
#' vegetable item was consumed. The function then sums up the consumption frequencies of all these items and divides the total
#' by 365 to obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param wsdd34y [numeric] A numeric vector representing the number of times per year orange or grapefruit juice was consumed.
#' @param wsdd35y [numeric] A numeric vector representing the number of times per year other fruit juices were consumed.
#' @param gfvd17ay [numeric] A numeric vector representing the number of times per year citrus fruits were consumed.
#' @param gfvd17by [numeric] A numeric vector representing the number of times per year strawberries were consumed (in summer).
#' @param gfvd17cy [numeric] A numeric vector representing the number of times per year strawberries were consumed (outside summer).
#' @param gfvd17dy [numeric] A numeric vector representing the number of times per year other fruits were consumed.
#' @param gfvd18y [numeric] A numeric vector representing the number of times per year tomato or tomato sauce was consumed.
#' @param gfvd19y [numeric] A numeric vector representing the number of times per year lettuce or green leafy salad was consumed.
#' @param gfvd20y [numeric] A numeric vector representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param gfvd22y [numeric] A numeric vector representing the number of times per year potatoes were consumed.
#' @param gfvd23y [numeric] A numeric vector representing the number of times per year other vegetables were consumed.
#'
#' @return [numeric] The average times per day fruits and vegetables were consumed in a year. If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year.
#'
#'          **Missing Data Codes:**
#'          - For all input variables:
#'            - `9996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `9997-9999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Calculate average daily fruit and vegetable consumption for a cycle 3-6 respondent
#' calculate_fv_daily_cycles3to6(
#'   wsdd34y = 50, wsdd35y = 100, gfvd17ay = 150, gfvd17by = 80, gfvd17cy = 40,
#'   gfvd17dy = 200, gfvd18y = 100, gfvd19y = 80, gfvd20y = 60, gfvd22y = 120, gfvd23y = 90
#' )
#' # Output: 2.931507
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- calculate_fv_daily_cycles3to6(
#'   wsdd34y = 9998, wsdd35y = 9998, gfvd17ay = 9998, gfvd17by = 9998, gfvd17cy = 9998,
#'   gfvd17dy = 9998, gfvd18y = 9998, gfvd19y = 9998, gfvd20y = 9998, gfvd22y = 9998, gfvd23y = 9998
#' )
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_fv_daily_cycles3to6(
#'   wsdd34y = c(50, 60), wsdd35y = c(100, 110), gfvd17ay = c(150, 160), gfvd17by = c(80, 90),
#'   gfvd17cy = c(40, 50), gfvd17dy = c(200, 210), gfvd18y = c(100, 110), gfvd19y = c(80, 90),
#'   gfvd20y = c(60, 70), gfvd22y = c(120, 130), gfvd23y = c(90, 100)
#' )
#' # Returns: c(2.931507, 3.232877)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(total_fv = calculate_fv_daily_cycles3to6(wsdd34y, wsdd35y, gfvd17ay,
#' #     gfvd17by, gfvd17cy, gfvd17dy, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y))
#'
#' @seealso [calculate_fv_daily_cycles1to2()] for cycles 1-2 fruit and vegetable consumption, [categorize_diet_quality()] for overall diet quality
#' @export
calculate_fv_daily_cycles3to6 <- function(wsdd34y, wsdd35y, gfvd17ay, gfvd17by, gfvd17cy, gfvd17dy, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y) {
  # Combine all measurements into a data frame
  measurements <- data.frame(wsdd34y, wsdd35y, gfvd17ay, gfvd17by, gfvd17cy, gfvd17dy, gfvd18y, gfvd19y, gfvd20y, gfvd22y, gfvd23y)

  # Replace missing data codes with NA
  measurements[measurements == 9996] <- haven::tagged_na("a") # Valid skip
  measurements[measurements >= 9997] <- haven::tagged_na("b") # Don't know, refusal, not stated

  # Calculate the total fruit and vegetable consumption per day
  fv_daily <- rowSums(measurements, na.rm = TRUE) / 365

  # Handle cases with all missing data or negative values
  dplyr::case_when(
    rowSums(is.na(measurements)) == ncol(measurements) ~ haven::tagged_na("b"),
    rowSums(measurements < 0, na.rm = TRUE) > 0 ~ haven::tagged_na("b"),
    TRUE ~ fv_daily
  )
}

#' @title Categorical diet indicator
#'
#' @description This function categorizes individuals' diet quality based on their total fruit and vegetable consumption.
#'
#' @param fv_daily [numeric] A numeric vector representing the average times per day fruits and vegetables were consumed in a year.
#'
#' @return [integer] A categorical indicating the diet quality:
#'   - 1: Good diet (fv_daily >= 5)
#'   - 2: Poor diet (fv_daily < 5)
#'   - `haven::tagged_na("a")`: Valid skip
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function categorizes diet quality based on the widely recognized "5-a-day" recommendation for fruit and vegetable intake.
#'
#'          **Missing Data Codes:**
#'          - Propagates tagged NAs from the input `fv_daily`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a fv_daily value of 3 as poor diet
#' categorize_diet_quality(3)
#' # Output: 2
#'
#' # Example 2: Categorize a fv_daily value of 7 as good diet
#' categorize_diet_quality(7)
#' # Output: 1
#'
#' # Multiple respondents
#' categorize_diet_quality(c(3, 7, 5))
#' # Returns: c(2, 1, 1)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(diet_quality = categorize_diet_quality(total_fv))
#'
#' @seealso [calculate_fv_daily_cycles1to2()], [calculate_fv_daily_cycles3to6()]
#' @export
categorize_diet_quality <- function(fv_daily) {
  dplyr::case_when(
    # Propagate tagged NAs
    haven::is_tagged_na(fv_daily, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(fv_daily, "b") | fv_daily < 0 ~ haven::tagged_na("b"),

    # Categorize diet quality
    fv_daily >= 5 ~ 1,
    fv_daily < 5 ~ 2,

    # Handle any other cases
    .default = haven::tagged_na("b")
  )
}
