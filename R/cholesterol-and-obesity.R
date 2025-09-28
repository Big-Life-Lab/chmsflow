#' @title Non-HDL cholesterol level
#'
#' @description This function calculates a respondent's non-HDL cholesterol level by subtracting their HDL cholesterol level
#' from their total cholesterol level. It first checks whether the input values `LAB_CHOL` (total cholesterol)
#' and `LAB_HDL` (HDL cholesterol) are both less than certain thresholds (99.6 mmol/L and 9.96 mmol/L, respectively).
#' If both conditions are met, it calculates the non-HDL cholesterol level; otherwise, it sets the non-HDL value to
#' NA to indicate that the calculation is not applicable.
#'
#' @param LAB_CHOL [numeric] A numeric representing a respondent's total cholesterol level in mmol/L.
#' @param LAB_HDL [numeric] A numeric representing a respondent's HDL cholesterol level in mmol/L.
#'
#' @return [numeric] The calculated non-HDL cholesterol level (in mmol.L) if both `LAB_CHOL` and
#' `LAB_HDL` are below the specified thresholds; otherwise, it returns NA(b) to indicate that the calculation is not applicable.
#'
#' @details The function calculates the non-HDL cholesterol level by subtracting the HDL cholesterol level from the total cholesterol level.
#' It first checks if both `LAB_CHOL` and `LAB_HDL` are less than the specified thresholds (99.6 mmol/L and 9.96 mmol/L, respectively).
#' If both conditions are met and neither input is missing, the non-HDL cholesterol level is calculated. If either of the conditions
#' is not met or if either input is missing (NA), the function returns NA(b) to indicate that the calculation is not applicable.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Respondent has total cholesterol of 50 mmol/L and HDL cholesterol of 5 mmol/L.
#' calculate_nonHDL(LAB_CHOL = 50, LAB_HDL = 5)
#' # Output: 45 (non-HDL cholesterol = total cholesterol - HDL cholesterol = 50 - 5 = 45)
#'
#' # Example: Respondent has non-response values for cholesterol.
#' calculate_nonHDL(LAB_CHOL = 99.98, LAB_HDL = 9.98)
#' # Output: NA
#'
#' # Multiple respondents
#' calculate_nonHDL(LAB_CHOL = c(50, 60, 70), LAB_HDL = c(5, 10, 15))
#' # Returns: c(45, 50, 55)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(non_hdl = calculate_nonHDL(LAB_CHOL, LAB_HDL))
#'
#' @export
calculate_nonHDL <- function(LAB_CHOL, LAB_HDL) {
  dplyr::case_when(
    LAB_CHOL == 99.96 | LAB_HDL == 9.96 ~ haven::tagged_na("a"), 
    (LAB_CHOL >= 99.97 & LAB_CHOL <= 99.99) | (LAB_HDL >= 9.97 & LAB_HDL <= 9.99) ~ haven::tagged_na("b"),
    LAB_CHOL < 1.88 | LAB_CHOL > 13.58 | LAB_HDL < 0.49 | LAB_HDL > 3.74 ~ haven::tagged_na("b"),
    TRUE ~ LAB_CHOL - LAB_HDL
  )
}

#' @title Categorical non-HDL cholesterol level
#'
#' @description This function categorizes individuals' non-HDL cholesterol levels based on a threshold value.
#'
#' @param nonHDL [numeric] A numeric representing an individual's non-HDL cholesterol level.
#'
#' @return [integer] A categorical indicating the non-HDL cholesterol category:
#'   - 1: High non-HDL cholesterol (nonHDL >= 4.3)
#'   - 2: Normal non-HDL cholesterol (nonHDL < 4.3)
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a nonHDL value of 5.0 as high non-HDL cholesterol
#' categorize_nonHDL(5.0)
#' # Output: 1
#'
#' # Example 2: Categorize a nonHDL value of 3.8 as normal non-HDL cholesterol
#' categorize_nonHDL(3.8)
#' # Output: 2
#'
#' # Multiple respondents
#' categorize_nonHDL(c(5.0, 3.8, 4.3))
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(non_hdl_category = categorize_nonHDL(non_hdl))
#'
#' @export
categorize_nonHDL <- function(nonHDL) {
  dplyr::case_when(
    haven::is_tagged_na(nonHDL, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(nonHDL, "b") ~ haven::tagged_na("b"),
    nonHDL >= 4.3 ~ 1,
    nonHDL < 4.3 ~ 2,
    .default = haven::tagged_na("b")
  )
}

#' @title Waist-to-height ratio (WHR)
#'
#' @description This function calculates the Waist-to-Height Ratio (WHR) by dividing the waist circumference by the height of the respondent.
#'
#' @param HWM_11CM [numeric] A numeric representing the height of the respondent in centimeters.
#' @param HWM_14CX [numeric] A numeric representing the waist circumference of the respondent in centimeters.
#'
#' @return [numeric] The WHR:
#'   - If both `HWM_11CM` and `HWM_14CX` are provided, the function returns the WHR (waist circumference divided by height).
#'   - If either `HWM_11CM` or `HWM_14CX` is missing, the function returns a tagged NA (`NA(b)`) indicating an invalid input or non-response.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Calculate WHR for a respondent with height = 170 cm and waist circumference = 85 cm.
#' calculate_WHR(HWM_11CM = 170, HWM_14CX = 85)
#' # Output: 0.5 (85/170)
#'
#' # Example 2: Calculate WHR for a respondent with missing height.
#' calculate_WHR(HWM_11CM = NA, HWM_14CX = 85)
#' # Output: NA(b)
#'
#' # Example 3: Respondent has non-response values for height and waist circumference.
#' calculate_WHR(HWM_11CM = 999.98, HWM_14CX = 999.8)
#' # Output: NA
#'
#' # Multiple respondents
#' calculate_WHR(HWM_11CM = c(170, 180, 160), HWM_14CX = c(85, 90, 80))
#' # Returns: c(0.5, 0.5, 0.5)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(whr = calculate_WHR(HWM_11CM, HWM_14CX))
#'
#' @export
calculate_WHR <- function(HWM_11CM, HWM_14CX) {
  dplyr::case_when(
    HWM_11_CM == 999.96 | HWM_14CX == 999.6 ~ haven::tagged_na("a"),
    (HWM_11CM >= 999.97 & HWM_11CM <= 999.99) | (HWM_14CX >= 999.7 & HWM_14CX <= 999.9) ~ haven::tagged_na("b")
    HWM_11CM < 0 | HWM_14CX < 0  ~ haven::tagged_na("b"),
    TRUE ~ HWM_14CX / HWM_11CM
  )
}
