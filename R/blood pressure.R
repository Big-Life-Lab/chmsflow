#' @brief Calculate adjusted systolic blood pressure
#' 
#' This function calculates the adjusted systolic blood pressure based on the respondent's systolic average blood pressure
#' across six measurements. The adjustment is made using specific correction factors. The adjusted systolic blood pressure
#' is returned as a numeric value.
#'
#' @param BPMDPBPS A numeric representing the respondent's systolic average blood pressure (in mmHg) across six measurements.
#'
#' @return The adjusted systolic blood pressure as a numeric value.
#' 
#' @details The function calculates the adjusted systolic blood pressure (SBP_adj) based on the value of BPMDPBPS. If
#'          BPMDPBPS is greater than or equal to 0 and less than 996, the adjustment is made using the formula:
#'          SBP_adj = 11.4 + (0.93 * BPMDPBPS). Otherwise, if BPMDPBPS is a non-response value (BPMDPBPS >= 996), the
#'          adjusted systolic blood pressure is set to NA, indicating that the measurement is not available. The adjusted
#'          systolic blood pressure is returned as the final output.
#'
#' @examples
#' 
#' # Example: Calculate adjusted systolic blood pressure for a respondent with an average systolic blood pressure of 120 mmHg.
#' adjust_SBP(BPMDPBPS = 120)
#' # Output: 123.6
adjust_SBP <- function(BPMDPBPS) {
  
  SBP_adj <- 0
  
  if (0 <= BPMDPBPS && BPMDPBPS < 996) { # Proceeds without non-responses
    SBP_adj <- 11.4 + (0.93 * BPMDPBPS)
  }
  else {
    SBP_adj <- NA # SBP_adj is set to NA for non-response values
  }
  
  return(SBP_adj)
}


#' @brief Calculate adjusted diastolic blood pressure
#' 
#' This function calculates the adjusted diastolic blood pressure based on the respondent's diastolic average blood pressure
#' across six measurements. The adjustment is made using specific correction factors. The adjusted diastolic blood pressure
#' is returned as a numeric value.
#'
#' @param BPMDPBPD A numeric representing the respondent's diastolic average blood pressure (in mmHg) across six measurements.
#'
#' @return The adjusted diastolic blood pressure as a numeric value.
#' 
#' @details The function calculates the adjusted diastolic blood pressure (DBP_adj) based on the value of BPMDPBPD. If
#'          BPMDPBPD is greater than or equal to 0 and less than 996, the adjustment is made using the formula:
#'          DBP_adj = 15.6 + (0.83 * BPMDPBPD). Otherwise, if BPMDPBPD is a non-response value (BPMDPBPD >= 996), the
#'          adjusted diastolic blood pressure is set to NA, indicating that the measurement is not available. The adjusted
#'          diastolic blood pressure is returned as the final output.
#'
#' @examples
#' 
#' # Example: Calculate adjusted diastolic blood pressure for a respondent with an average diastolic blood pressure of 80 mmHg.
#' adjust_DBP(BPMDPBPD = 80)
#' # Output: 83.4
adjust_DBP <- function(BPMDPBPD) {
  
  DBP_adj <- 0
  
  if (0 <= BPMDPBPD && BPMDPBPD < 996) { # Proceeds without non-responses
    DBP_adj <- 15.6 + (0.83 * BPMDPBPD)
  }
  else {
    DBP_adj <- NA # DBP_adj is set to NA for non-response values
  }
  
  return(DBP_adj)
}
