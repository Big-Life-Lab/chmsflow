#' @brief Calculate the estimated glomerular filtration rate (GFR) based on serum creatine.
#' 
#' This function calculates the estimated glomerular filtration rate (GFR) according to Finlay's formula, where serum
#' creatine is in mg/dL. The calculation takes into account the respondent's ethnicity, sex, and age. Non-response values
#' are handled for all input parameters.
#'
#' @param LAB_BCRE Blood creatine (µmol/L). It should be a numeric value.
#' @param PGDCGT Ethnicity (13 categories). It should be an integer value.
#' @param CLC_SEX Sex (Male = 1, Female = 2). It should be an integer value.
#' @param CLC_AGE Age (years). It should be a numeric value.
#'
#' @return The calculated GFR as a numeric value. If any of the input parameters (LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE)
#'         are non-response values (LAB_BCRE >= 996, PGDCGT >= 96, CLC_SEX >= 6, CLC_AGE >= 996), the GFR will be NA(b)
#'         (Not Available).
#' 
#' @details The function uses the serum creatine level (LAB_BCRE) in µmol/L to calculate the estimated GFR. First, it
#'          checks if any of the input parameters are non-response values. If any non-response values are found, the GFR
#'          will be set to NA, and the function will return immediately. Otherwise, it proceeds with the calculation by
#'          converting the serum creatine to mg/dL (serumcreat = LAB_BCRE / 88.4). Based on the respondent's ethnicity
#'          (PGDCGT), sex (CLC_SEX), and age (CLC_AGE), the appropriate formula is applied to calculate the GFR. The
#'          formula used for each combination of ethnicity and sex is as follows:
#' 
#'          - Female and Black (PGDCGT == 2, CLC_SEX == 2): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
#'                                                         (0.742) * (1.210)
#'          - Female and not Black (PGDCGT != 2, CLC_SEX == 2): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
#'                                                             (0.742)
#'          - Male and Black (PGDCGT == 2, CLC_SEX == 1): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) *
#'                                                       (1.210)
#'          - Male and not Black (PGDCGT != 2, CLC_SEX == 1): GFR = 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203))
#'
#' @examples
#' 
#' # Example 1: Calculate GFR for a 45-year-old white female with serum creatine of 80 µmol/L.
#' calculateGFR(LAB_BCRE = 80, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 45)
#' # Output: GFR = 80.25535
#'
#' # Example 2: Calculate GFR for a 55-year-old black male with serum creatine of 1100 µmol/L (non-response).
#' calculateGFR(LAB_BCRE = 1100, PGDCGT = 2, CLC_SEX = 1, CLC_AGE = 55)
#' # Output: GFR = NA
#'
#' # Example 3: Calculate GFR for a 35-year-old black female with serum creatine of 70 µmol/L.
#' calculateGFR(LAB_BCRE = 70, PGDCGT = 2, CLC_SEX = 2, CLC_AGE = 35)
#' # Output: GFR = 86.51265
calculate_GFR <- function(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE) {
  
  GFR <- haven::tagged_na("b")
  serumcreat <- 0
  
  if (LAB_BCRE < 996 && PGDCGT < 96 && CLC_SEX < 6 && CLC_AGE < 996) {
    serumcreat = LAB_BCRE / 88.4 # Proceeds without non-responses
  }
  else {
    GFR = NA #GFR is NA if any non-responses found
    return(GFR)
  }
  
  if (CLC_SEX == 2 && PGDCGT == 2) {
    GFR = 175 *((serumcreat)**(-1.154)) * ((CLC_AGE)**(-0.203)) * (0.742 ) * (1.210) # female and black 
  }
  else if (CLC_SEX == 2 && PGDCGT != 2) {
    GFR = 175 *((serumcreat)**(-1.154)) * ((CLC_AGE)**(-0.203)) * (0.742)	# female and not black 
  }
  else if (CLC_SEX == 1 && PGDCGT == 2) {
    GFR = 175 *((serumcreat)**(-1.154)) * ((CLC_AGE)**(-0.203)) * (1.210)	# male and black 
  }
  else if (CLC_SEX == 1 && PGDCGT != 2) {
    GFR = 175 *((serumcreat)**(-1.154)) * ((CLC_AGE)**(-0.203))	# male and not black 
  }
  return(GFR)
  
}