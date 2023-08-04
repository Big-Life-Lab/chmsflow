#' @brief Determine if a respondent has diabetes based on more inclusive classification.
#'
#' @param diab_m An integer indicating whether the respondent has diabetes based on HbA1c level. 1 for "Yes", 2 for "No".
#' @param diab_drug An integer indicating whether the respondent takes diabetes drugs. 1 for "Yes", 2 for "No".
#' @param CCC_51 An integer indicating whether the respondent has diabetes in general. 1 for "Yes", 2 for "No".
#'
#' @return An integer indicating the inclusive diabetes status.
#' 
#' @details The function evaluates the input variables `diab_m`, `diab_drug`, and `CCC_51` to determine the inclusive diabetes status.
#'   - If `diab_m`, `diab_drug`, or `CCC_51` is equal to 1, it indicates a positive response, and the function sets `diabX` to 1, representing "Yes".
#'   - If any of the input variables (`diab_m`, `diab_drug`, `CCC_51`) contains non-responses (i.e., not 1 or 2), the function sets `diabX` to NA,
#'     indicating that the inclusive diabetes status is not available.
#'   - If all else, it means the respondent answered "No" to all three questions, and the function sets `diabX` to 2, representing "No".
#'
#' @examples
#' # Determine the inclusive diabetes status for a respondent who has diabetes based on HbA1c.
#' determine_inclusive_diabetes(diab_m = 1, diab_drug = 2, CCC_51 = 2)
#' # Output: 1 (Inclusive diabetes status is "Yes" due to having diabetes based on HbA1c).
determine_inclusive_diabetes <- function(diab_m, diab_drug, CCC_51) {
  
  diabX <- 0
  
  if (diab_m == 1 || diab_drug == 1 || CCC_51 == 1) {
    diabX = 1 # "Yes" if one answered "Yes" for either of the three inputs
  }
  else if (diab_m >= 6 || is.na(diab_drug) || CCC_51 >= 6) {
    diabX = NA # NA if any input contains non-responses 
  }
  else {
    diabX = 2  # "No" if all else
  }
  
  return(diabX)
}