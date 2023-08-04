#' @brief Adjusted systolic blood pressure
#' 
#' This function adjusts systolic blood pressure based on the respondent's systolic average blood pressure across 
#' six measurements. The adjustment is made using specific correction factors. The adjusted systolic blood pressure
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


#' @brief Adjusted diastolic blood pressure
#' 
#' This function adjusts diastolic blood pressure based on the respondent's diastolic average blood pressure across 
#' six measurements. The adjustment is made using specific correction factors. The adjusted diastolic blood pressure
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

determine_hypertension <- function(BPMDPBPS, BPMDPBPD, ANYmed) {
  
  highsys140 <- NA
  highdias90 <- NA
  highBP14090 <- NA
  
  # Check conditions and assign values to highsys140 and highdias90
  if (140 <= BPMDPBPS && BPMDPBPS < 996) {
    highsys140 <- 1
  } else if (0 <= BPMDPBPS && BPMDPBPS < 140) {
    highsys140 <- 2
  }
  else {
    return(highBP14090)
  }
  
  if (90 <= BPMDPBPD && BPMDPBPD < 996) {
    highdias90 <- 1
  } else if (0 <= BPMDPBPD && BPMDPBPD < 90) {
    highdias90 <- 2
  }
  else {
    return(highBP14090)
  }
  
  # Calculate highBP14090
  if (highsys140 == 1 || highdias90 == 1 || ANYmed == 1) {
    highBP14090 <- 1
  } else if (highsys140 == 2 && highdias90 == 2 && ANYmed == 2) {
    highBP14090 <- 2
  }

  return(highBP14090)
  
}

determine_adjusted_hypertension <- function(SBP_adj, DBP_adj, ANYmed) {
  
  highsys140_adj <- NA
  highdias90_adj <- NA
  highBP14090_adj <- NA
  
  # Check conditions and assign values to highsys140_adj and highdias90_adj
  if (140 <= SBP_adj && SBP_adj < 996) {
    highsys140_adj <- 1
  } else if (0 <= SBP_adj && SBP_adj < 140) {
    highsys140_adj <- 2
  }
  else {
    return(highBP14090_adj)
  }
  
  if (90 <= DBP_adj && DBP_adj < 996) {
    highdias90_adj <- 1
  } else if (0 <= DBP_adj && DBP_adj < 90) {
    highdias90_adj <- 2
  }
  else {
    return(highBP14090_adj)
  }
  
  # Initialize and calculate highBP14090_adj

  if (highsys140_adj == 1 || highdias90_adj == 1 || ANYmed == 1) {
    highBP14090_adj <- 1
  } else if (highsys140_adj == 2 && highdias90_adj == 2 && ANYmed == 2) {
    highBP14090_adj <- 2
  }
  
  return(highBP14090_adj)
  
}

determine_controlled_hypertension <- function(BPMDPBPS, BPMDPBPD, ANYmed) {
  
  highsys140 <- NA
  highdias90 <- NA
  Control14090 <- NA
  
  # Check conditions and assign values to highsys140 and highdias90
  if (140 <= BPMDPBPS && BPMDPBPS < 996) {
    highsys140 <- 1
  } else if (0 <= BPMDPBPS && BPMDPBPS < 140) {
    highsys140 <- 2
  }
  else {
    return(Control14090)
  }
  
  if (90 <= BPMDPBPD && BPMDPBPD < 996) {
    highdias90 <- 1
  } else if (0 <= BPMDPBPD && BPMDPBPD < 90) {
    highdias90 <- 2
  }
  else {
    return(Control14090)
  }
  

  
  # Check the conditions using nested ifelse statements
  if (ANYmed == 1) {
    Control14090 <- ifelse(highsys140 == 1 || highdias90 == 1, 2,
                           ifelse(highsys140 == 2 && highdias90 == 2, 1, NA))
  }
  
  return(Control14090)
  
}

determine_controlled_adjusted_hypertension <- function(SBP_adj, DBP_adj, ANYmed) {
  
  highsys140_adj <- NA
  highdias90_adj <- NA
  Control14090_adj <- NA
  
  # Check conditions and assign values to highsys140_adj and highdias90_adj
  if (140 <= SBP_adj && SBP_adj < 996) {
    highsys140_adj <- 1
  } else if (0 <= SBP_adj && SBP_adj < 140) {
    highsys140_adj <- 2
  }
  else {
    return(Control14090_adj)
  }
  
  if (90 <= DBP_adj && DBP_adj < 996) {
    highdias90_adj <- 1
  } else if (0 <= DBP_adj && DBP_adj < 90) {
    highdias90_adj <- 2
  }
  else {
    return(Control14090_adj)
  }
  
  # Check the conditions using nested ifelse statements
  if (ANYmed == 1) {
    Control14090_adj <- ifelse(highsys140_adj == 1 || highdias90_adj == 1, 2,
                               ifelse(highsys140_adj == 2 && highdias90_adj == 2, 1, NA))
  }
  
  return(Control14090_adj)
  
}
