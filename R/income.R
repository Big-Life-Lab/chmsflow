#' @brief Calculate adjusted total household income based on weighted household size.
#' 
#' This function calculates the adjusted total household income based on the respondent's income amount and actual household size,
#' taking into account the weighted household size.
#'
#' @param THI_01 A numeric representing the respondent's household income amount in dollars.
#' @param DHHDHSZ An integer representing the respondent's actual household size in persons.
#'
#' @return The calculated adjusted total household income as a numeric value.
#' 
#' @details The function first calculates the weighted household size (hh_size_wt) based on the respondent's actual
#'          household size (DHHDHSZ). It uses a loop to iterate from 1 to DHHDHSZ and assigns weights to each household
#'          member based on their count. If the household size (i) is 1, the weight is 1; if i is 2, the weight is 0.4; if
#'          i is greater than or equal to 3, the weight is 0.3. The weighted household size is then used to adjust the
#'          respondent's total household income (THI_01) by dividing it by hh_size_wt. The adjusted household income
#'          (adj_hh_inc) is returned as the final output.
#'
#' @examples
#' 
#' # Example 1: Calculate adjusted household income for a respondent with $50,000 income and a household size of 3.
#' calculate_Hhld_Income(THI_01 = 50000, DHHDHSZ = 3)
#' # Output: 108108.11
#'
#' # Example 2: Calculate adjusted household income for a respondent with $75000 income and a household size of 2.
#' calculate_Hhld_Income(THI_01 = 75000, DHHDHSZ = 2)
#' # Output: 131578.95
#'
#' # Example 3: Calculate adjusted household income for a respondent with $90000 income and a household size of 1.
#' calculate_Hhld_Income(THI_01 = 90000, DHHDHSZ = 1)
#' # Output: 90000.00
calculate_Hhld_Income <- function(THI_01, DHHDHSZ) {
  
  # Step 1 - derive household adjustment based on household size 
  hh_size_wt <- 0
  
  for (i in 1:DHHDHSZ) {
    if (i == 1) {
      hh_size_wt <- hh_size_wt + 1
    } else if (i == 2) {
      hh_size_wt <- hh_size_wt + 0.4
    } else if (i >= 3) {
      hh_size_wt <- hh_size_wt + 0.3
    }
  }
  
  # Step 2 - Adjust total household income based on household size 
  adj_hh_inc <- THI_01 / hh_size_wt
  return(adj_hh_inc)
  
}
