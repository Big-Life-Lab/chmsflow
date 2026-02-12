#' @title Non-HDL cholesterol level
#'
#' @description This function calculates a respondent's non-HDL cholesterol level by subtracting their HDL cholesterol level
#' from their total cholesterol level. It first checks whether the input values `lab_chol` (total cholesterol)
#' and `lab_hdl` (HDL cholesterol) are within valid ranges.
#'
#' @param lab_chol [numeric] A numeric representing a respondent's total cholesterol level in mmol/L.
#' @param lab_hdl [numeric] A numeric representing a respondent's HDL cholesterol level in mmol/L.
#'
#' @return [numeric] The calculated non-HDL cholesterol level (in mmol/L). If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details The function calculates the non-HDL cholesterol level by subtracting the HDL cholesterol level from the total cholesterol level.
#'
#'          **Missing Data Codes:**
#'          - `lab_chol`:
#'            - `99.96`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `99.97-99.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `lab_hdl`:
#'            - `9.96`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `9.97-9.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Respondent has total cholesterol of 5.0 mmol/L and HDL cholesterol of 1.5 mmol/L.
#' calculate_nonhdl(lab_chol = 5.0, lab_hdl = 1.5)
#' # Output: 3.5
#'
#' # Example: Respondent has non-response values for cholesterol.
#' result <- calculate_nonhdl(lab_chol = 99.98, lab_hdl = 1.5)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_nonhdl(lab_chol = c(5.0, 6.0, 7.0), lab_hdl = c(1.5, 1.0, 2.0))
#' # Returns: c(3.5, 5.0, 5.0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(non_hdl = calculate_nonhdl(lab_chol, lab_hdl))
#'
#' @seealso [categorize_nonhdl()]
#' @export
calculate_nonhdl <- function(lab_chol, lab_hdl) {
  dplyr::case_when(
    # Valid skip
    lab_chol == 99.96 | lab_hdl == 9.96 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    (lab_chol >= 99.97 & lab_chol <= 99.99) | (lab_hdl >= 9.97 & lab_hdl <= 9.99) ~ haven::tagged_na("b"),

    # Handle out of range values
    lab_chol < 1.88 | lab_chol > 13.58 | lab_hdl < 0.49 | lab_hdl > 3.74 ~ haven::tagged_na("b"),

    # Calculate non-HDL cholesterol
    TRUE ~ lab_chol - lab_hdl
  )
}

#' @title Categorical non-HDL cholesterol level
#'
#' @description This function categorizes individuals' non-HDL cholesterol levels based on a threshold value.
#'
#' @param nonhdl [numeric] A numeric representing an individual's non-HDL cholesterol level.
#'
#' @return [integer] A categorical indicating the non-HDL cholesterol category:
#'   - 1: High non-HDL cholesterol (nonhdl >= 4.3)
#'   - 2: Normal non-HDL cholesterol (nonhdl < 4.3)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function categorizes non-HDL cholesterol levels into 'High' or 'Normal' based on a 4.3 mmol/L threshold.
#'
#'          **Missing Data Codes:**
#'          - Propagates tagged NAs from the input `nonhdl`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a nonhdl value of 5.0 as high non-HDL cholesterol
#' categorize_nonhdl(5.0)
#' # Output: 1
#'
#' # Example 2: Categorize a nonhdl value of 3.8 as normal non-HDL cholesterol
#' categorize_nonhdl(3.8)
#' # Output: 2
#'
#' # Multiple respondents
#' categorize_nonhdl(c(5.0, 3.8, 4.3))
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(non_hdl_category = categorize_nonhdl(non_hdl))
#'
#' @seealso [calculate_nonhdl()]
#' @export
categorize_nonhdl <- function(nonhdl) {
  dplyr::case_when(
    # Propagate tagged NAs
    haven::is_tagged_na(nonhdl, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(nonhdl, "b") ~ haven::tagged_na("b"),

    # Categorize non-HDL cholesterol
    nonhdl >= 4.3 ~ 1,
    nonhdl < 4.3 ~ 2,

    # Handle any other cases
    .default = haven::tagged_na("b")
  )
}

#' @title Waist-to-height ratio (WHtR)
#'
#' @description This function calculates the Waist-to-Height Ratio (WHtR) by dividing the waist circumference by the height of the respondent.
#'
#' @param hwm_11cm [numeric] A numeric representing the height of the respondent in centimeters.
#' @param hwm_14cx [numeric] A numeric representing the waist circumference of the respondent in centimeters.
#'
#' @return [numeric] The WHtR. If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details This function calculates the Waist-to-Height Ratio (WHtR), an indicator of central obesity.
#'
#'          **Missing Data Codes:**
#'          - `hwm_11cm`:
#'            - `999.96`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `999.97-999.99`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `hwm_14cx`:
#'            - `999.6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `999.7-999.9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Calculate WHtR for a respondent with height = 170 cm and waist circumference = 85 cm.
#' calculate_waist_height_ratio(hwm_11cm = 170, hwm_14cx = 85)
#' # Output: 0.5 (85/170)
#'
#' # Example 2: Calculate WHtR for a respondent with missing height.
#' result <- calculate_waist_height_ratio(hwm_11cm = 999.98, hwm_14cx = 85)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_waist_height_ratio(hwm_11cm = c(170, 180, 160), hwm_14cx = c(85, 90, 80))
#' # Returns: c(0.5, 0.5, 0.5)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(whtr = calculate_waist_height_ratio(hwm_11cm, hwm_14cx))
#'
#' @export
calculate_waist_height_ratio <- function(hwm_11cm, hwm_14cx) {
  dplyr::case_when(
    # Valid skip
    hwm_11cm == 999.96 | hwm_14cx == 999.6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    (hwm_11cm >= 999.97 & hwm_11cm <= 999.99) | (hwm_14cx >= 999.7 & hwm_14cx <= 999.9) ~ haven::tagged_na("b"),

    # Handle out of range values
    hwm_11cm < 0 | hwm_14cx < 0 ~ haven::tagged_na("b"),

    # Calculate WHtR
    TRUE ~ hwm_14cx / hwm_11cm
  )
}
