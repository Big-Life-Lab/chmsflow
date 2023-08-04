#' @brief Calculate the average minutes of exercise per day for week-long accelerometer data. 
#' 
#' This function calculates the average minutes of exercise per day across a week of accelerometer data. It takes seven
#' parameters, each representing the minutes of exercise on a specific day (Day 1 to Day 7) of accelerometer measurement.
#' The function computes the average of these values to obtain the average minutes of exercise per day.
#'
#' @param AMMDMVA1 A numeric representing minutes of exercise on Day 1 of accelerometer measurement. 
#' @param AMMDMVA2 A numeric representing minutes of exercise on Day 2 of accelerometer measurement. 
#' @param AMMDMVA3 A numeric representing minutes of exercise on Day 3 of accelerometer measurement. 
#' @param AMMDMVA4 A numeric representing minutes of exercise on Day 4 of accelerometer measurement. 
#' @param AMMDMVA5 A numeric representing minutes of exercise on Day 5 of accelerometer measurement. 
#' @param AMMDMVA6 A numeric representing minutes of exercise on Day 6 of accelerometer measurement. 
#' @param AMMDMVA7 A numeric representing minutes of exercise on Day 7 of accelerometer measurement. 
#'
#' @return A numeric representing the average minutes of exercise per day across a week of accelerometer use.
#' 
#' @details The function calculates the average minutes of exercise per day by taking the mean of the seven input parameters.
#' 
#' @examples
#' 
#' # Example: Calculate the average minutes of exercise per day for a week of accelerometer data.
#' find_week_accelerometer_average(30, 40, 25, 35, 20, 45, 50)
#' # Output: 35 (The average minutes of exercise per day across the week is 35 minutes.)
find_week_accelerometer_average <- function(AMMDMVA1, AMMDMVA2, AMMDMVA3, AMMDMVA4, AMMDMVA5, AMMDMVA6, AMMDMVA7) {
  MVPA_min <- mean(AMMDMVA1, AMMDMVA2, AMMDMVA3, AMMDMVA4, AMMDMVA5, AMMDMVA6, AMMDMVA7)
  return(MVPA_min)
}

#' @brief Convert minutes per day to minutes per week. 
#' 
#' This function takes the average minutes of exercise per day across a week of accelerometer use as an input (`MVPA_min`) and
#' calculates the equivalent minutes of exercise per one week of accelerometer use. The result is returned as a numeric value.
#'
#' @param MVPA_min A numeric representing the average minutes of exercise per day across a week of accelerometer use. 
#'
#' @return A numeric representing the average minutes of exercise per one week of accelerometer use.
#' 
#' @details The function simply multiplies the average minutes of exercise per day (`MVPA_min`) by 7 to obtain the equivalent
#'          minutes of exercise per one week of accelerometer use.
#' 
#' @examples
#' 
#' # Example: Convert average minutes of exercise per day to minutes per week.
#' minperday_to_minperweek(35)
#' # Output: 245 (The equivalent minutes of exercise per one week is 245 minutes.)
minperday_to_minperweek <- function(MVPA_min) {
  minperweek <- MVPA_min * 7
  return(minperweek)
}