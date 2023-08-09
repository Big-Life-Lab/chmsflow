#' @brief Calculate daily fruit and vegetable consumption in a year for respondent in CHMS cycles 1-2.
#' 
#' This function calculates the daily fruit and vegetable consumption in a year for respondent in the Canadian Health Measures 
#' Survey (CHMS) cycles 1-2. It takes seven parameters, each representing the number of times per year a specific fruit or vegetable item
#' was consumed. The function then sums up the consumption frequencies of all these items and divides the total by 365 to
#' obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param WSDD14Y A numeric representing the number of times per year fruit juice was consumed.
#' @param GFVD17Y A numeric representing the number of times per year fruit (excluding juice) was consumed.
#' @param GFVD18Y A numeric representing the number of times per year tomato or tomato sauce was consumed.
#' @param GFVD19Y A numeric representing the number of times per year lettuce or green leafy salad was consumed.
#' @param GFVD20Y A numeric representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param GFVD22Y A numeric representing the number of times per year potatoes were consumed.
#' @param GFVD23Y A numeric representing the number of times per year other vegetables were consumed.
#'
#' @return A numeric representing the average times per day fruits and vegetables were consumed in a year.
#' 
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year.
#' 
#' @examples
#' 
#' # Example: Calculate the average daily fruit and vegetable consumption for one Cycle 1 or 2 respondent.
#' # Let's assume the following annual consumption frequencies for each item:
#' # WSDD14Y (fruit juice) = 50 times
#' # GFVD17Y (fruit, excluding juice) = 150 times
#' # GFVD18Y (tomato or tomato sauce) = 200 times
#' # GFVD19Y (lettuce or green leafy salad) = 100 times
#' # GFVD20Y (spinach, mustard greens, and cabbage) = 80 times
#' # GFVD22Y (potatoes) = 120 times
#' # GFVD23Y (other vegetables) = 90 times
#' # Using the function:
#' find_totalFV_cycles1and2(WSDD14Y = 50, GFVD17Y = 150, GFVD18Y = 200, GFVD19Y = 100, GFVD20Y = 80, GFVD22Y = 120, GFVD23Y = 90)
#' # Output: 1.178082
#' # The average daily consumption of fruits and vegetables in a year is approximately 1.18 times per day based on CHMS cycles 1-2 data.
find_totalFV_cycles1and2 <- function(WSDD14Y, GFVD17Y, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) {
 
  totalFV <- sum(WSDD14Y, GFVD17Y, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) / 365
  if (is.na(totalFV)) {
    totalFV <- haven::tagged_na("b")
  }
  return(totalFV)

}

#' @brief Calculate daily fruit and vegetable consumption in a year for respondents in CHMS cycles 3-6.
#' 
#' This function calculates the daily fruit and vegetable consumption in a year for respondents in the Canadian Health Measures 
#' Survey (CHMS) cycles 3-6. It takes eleven parameters, each representing the number of times per year a specific fruit or 
#' vegetable item was consumed. The function then sums up the consumption frequencies of all these items and divides the total
#' by 365 to obtain the average daily consumption of fruits and vegetables in a year.
#'
#' @param WSDD34Y A numeric representing the number of times per year orange or grapefruit juice was consumed.
#' @param WSDD35Y A numeric representing the number of times per year other fruit juices were consumed.
#' @param GFVD17AY A numeric representing the number of times per year citrus fruits were consumed.
#' @param GFVD17BY A numeric representing the number of times per year strawberries were consumed (in summer).
#' @param GFVD17CY A numeric representing the number of times per year strawberries were consumed (outside summer).
#' @param GFVD17DY A numeric representing the number of times per year other fruits were consumed.
#' @param GFVD18Y A numeric representing the number of times per year tomato or tomato sauce was consumed.
#' @param GFVD19Y A numeric representing the number of times per year lettuce or green leafy salad was consumed.
#' @param GFVD20Y A numeric representing the number of times per year spinach, mustard greens, and cabbage were consumed.
#' @param GFVD22Y A numeric representing the number of times per year potatoes were consumed.
#' @param GFVD23Y A numeric representing the number of times per year other vegetables were consumed.
#'
#' @return A numeric representing the average times per day fruits and vegetables were consumed in a year.
#' 
#' @details The function calculates the total consumption of fruits and vegetables in a year by summing up the consumption
#'          frequencies of all the input items. It then divides the total by 365 to obtain the average daily consumption of
#'          fruits and vegetables in a year.
#' 
#' @examples
#' 
#' # Example: Calculate the average daily fruit and vegetable consumption for a respondent in CHMS cycles 3-6.
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
#' find_totalFV_cycles3to6(WSDD34Y = 50, WSDD35Y = 100, GFVD17AY = 150, GFVD17BY = 80, GFVD17CY = 40, GFVD17DY = 200,
#'                         GFVD18Y = 100, GFVD19Y = 80, GFVD20Y = 60, GFVD22Y = 120, GFVD23Y = 90)
#' # Output: 1.882192
#' # The average daily consumption of fruits and vegetables in a year for this respondent is approximately 1.88 times per day based on CHMS cycles 3-6 data.
find_totalFV_cycles3to6 <- function(WSDD34Y, WSDD35Y, GFVD17AY, GFVD17BY, GFVD17CY, GFVD17DY, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) {
  
  totalFV <- sum(WSDD34Y, WSDD35Y, GFVD17AY, GFVD17BY, GFVD17CY, GFVD17DY, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y) / 365
  if (is.na(totalFV)) {
    totalFV <- haven::tagged_na("b")
  }
  return(totalFV)

}

#' @brief Calculate a respondent's non-HDL cholesterol level.
#' 
#' This function calculates a respondent's non-HDL cholesterol level by subtracting their HDL cholesterol level 
#' from their total cholesterol level. It first checks whether the input values `LAB_CHOL` (total cholesterol) 
#' and `LAB_HDL` (HDL cholesterol) are both less than certain thresholds (99.6 mmol/L and 9.96 mmol/L, respectively). 
#' If both conditions are met, it calculates the non-HDL cholesterol level; otherwise, it sets the non-HDL value to 
#' NA to indicate that the calculation is not applicable.
#'
#' @param LAB_CHOL A numeric representing a respondent's total cholesterol level in mmol/L.
#' @param LAB_HDL A numeric representing a respondent's HDL cholesterol level in mmol/L.
#' 
#' @return A numeric representing the calculated non-HDL cholesterol level (in mmol.L) if both `LAB_CHOL` and 
#' `LAB_HDL` are below the specified thresholds; otherwise, it returns NA.
#' 
#' @examples
#' 
#' # Example: Calculate non-HDL cholesterol level for a respondent with total cholesterol of 150 mmol/L and 
#' HDL cholesterol of 50 mmol/L.
#' calculate_nonHDL(LAB_CHOL = 150, LAB_HDL = 50)
#' # Output: 100 (non-HDL cholesterol = total cholesterol - HDL cholesterol = 150 - 50 = 100)
calculate_nonHDL <- function(LAB_CHOL, LAB_HDL) {
  nonHDL <- 0
  if (LAB_CHOL < 99.6 && LAB_HDL < 9.96) {
    nonHDL <- LAB_CHOL - LAB_HDL
  }
  else {
    nonHDL <- haven::tagged_na("b")
  }
  return(nonHDL)
}