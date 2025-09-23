#' @title Average minutes of exercise per day for week-long accelerometer data
#'
#' @description This function calculates the average minutes of exercise per day across a week of accelerometer data. It takes seven
#' parameters, each representing the minutes of exercise on a specific day (Day 1 to Day 7) of accelerometer measurement.
#' The function computes the average of these values to obtain the average minutes of exercise per day.
#'
#' @param AMMDMVA1 [numeric] A numeric representing minutes of exercise on Day 1 of accelerometer measurement.
#' @param AMMDMVA2 [numeric] A numeric representing minutes of exercise on Day 2 of accelerometer measurement.
#' @param AMMDMVA3 [numeric] A numeric representing minutes of exercise on Day 3 of accelerometer measurement.
#' @param AMMDMVA4 [numeric] A numeric representing minutes of exercise on Day 4 of accelerometer measurement.
#' @param AMMDMVA5 [numeric] A numeric representing minutes of exercise on Day 5 of accelerometer measurement.
#' @param AMMDMVA6 [numeric] A numeric representing minutes of exercise on Day 6 of accelerometer measurement.
#' @param AMMDMVA7 [numeric] A numeric representing minutes of exercise on Day 7 of accelerometer measurement.
#'
#' @return [numeric] The average minutes of exercise per day across a week of accelerometer use.
#'
#' @details The function calculates the average minutes of exercise per day by taking the mean of the seven input parameters.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Calculate the average minutes of exercise per day for a week of accelerometer data.
#' find_week_accelerometer_average(30, 40, 25, 35, 20, 45, 50)
#' # Output: 35 (The average minutes of exercise per day across the week is 35 minutes.)
#'
#' # Multiple respondents
#' find_week_accelerometer_average(
#'   c(30, 20), c(40, 30), c(25, 35), c(35, 45),
#'   c(20, 25), c(45, 55), c(50, 60)
#' )
#' # Returns: c(35, 39.28571)
#'
#' @details This function processes physical activity data from accelerometer measurements
#'          to create a weekly activity summary.
#'
#'          **Data Quality Requirements:**
#'          - Requires complete 7-day data (missing days result in tagged NA)
#'          - This conservative approach ensures reliable activity estimates
#'          - Zero values are preserved (represent valid no-activity days)
#'
#'          **Clinical Context:**
#'          Accelerometer data provides objective measures of moderate-to-vigorous physical activity (MVPA),
#'          crucial for assessing adherence to physical activity guidelines.
#'
#' @seealso [minperday_to_minperweek()] for activity unit conversion, [categorize_minperweek()] for activity level classification
#' @references Physical Activity Guidelines for Adults, Health Canada
#' @keywords survey health exercise accelerometer physical-activity
#' @export
find_week_accelerometer_average <- function(AMMDMVA1, AMMDMVA2, AMMDMVA3, AMMDMVA4, AMMDMVA5, AMMDMVA6, AMMDMVA7) {
  measurements <- cbind(AMMDMVA1, AMMDMVA2, AMMDMVA3, AMMDMVA4, AMMDMVA5, AMMDMVA6, AMMDMVA7)

  MVPA_min <- rowMeans(measurements, na.rm = FALSE)

  dplyr::case_when(
    rowSums(measurements < 0, na.rm = TRUE) > 0 ~ haven::tagged_na("b"),
    is.na(MVPA_min) ~ haven::tagged_na("b"),
    TRUE ~ MVPA_min
  )
}

#' @title Minutes per week from minutes per day
#'
#' @description This function takes the average minutes of exercise per day across a week of accelerometer use as an input (`MVPA_min`) and
#' calculates the equivalent minutes of exercise per one week of accelerometer use. The result is returned as a numeric value.
#'
#' @param MVPA_min [numeric] A numeric representing the average minutes of exercise per day across a week of accelerometer use.
#'
#' @return [numeric] The average minutes of exercise per one week of accelerometer use.
#'
#' @details The function simply multiplies the average minutes of exercise per day (`MVPA_min`) by 7 to obtain the equivalent
#'          minutes of exercise per one week of accelerometer use.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Convert average minutes of exercise per day to minutes per week.
#' minperday_to_minperweek(35)
#' # Output: 245 (The equivalent minutes of exercise per one week is 245 minutes.)
#'
#' # Multiple respondents
#' minperday_to_minperweek(c(35, 40, 20))
#' # Returns: c(245, 280, 140)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(min_per_week = minperday_to_minperweek(avg_exercise))
#'
#' @export
minperday_to_minperweek <- function(MVPA_min) {
  minperweek <- MVPA_min * 7
  dplyr::case_when(
    is.na(minperweek) | minperweek < 0 ~ haven::tagged_na("b"),
    TRUE ~ minperweek
  )
}

#' @title Categorical weekly physical activity indicator
#'
#' @description This function categorizes individuals' weekly physical activity levels based on a threshold value.
#'
#' @param minperweek [numeric] A numeric representing an individual's minutes of moderate-to-vigorous
#'   physical activity (MVPA) per week.
#'
#' @return [integer] A categorical indicating the physical activity category:
#'   - 1: Meets or exceeds the recommended 150 minutes of MVPA per week (minperweek >= 150)
#'   - 2: Below the recommended 150 minutes of MVPA per week (minperweek < 150)
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize 180 minutes of MVPA per week as meeting the recommendation
#' categorize_minperweek(180)
#' # Output: 1
#'
#' # Example 2: Categorize 120 minutes of MVPA per week as below the recommendation
#' categorize_minperweek(120)
#' # Output: 2
#'
#' # Multiple respondents
#' categorize_minperweek(c(180, 120, 150))
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(pa_category = categorize_minperweek(min_per_week))
#'
#' @export
categorize_minperweek <- function(minperweek) {
  dplyr::case_when(
    is.na(minperweek) | minperweek < 0 ~ haven::tagged_na("b"),
    minperweek >= 150 ~ 1,
    minperweek < 150 ~ 2,
    .default = haven::tagged_na("b")
  )
}
