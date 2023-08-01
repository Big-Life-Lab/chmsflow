#' @brief Calculate glomerular filtration rate 
#' 
#' This function calculates the estimated glomerular filtration rate according to Finlay - where serum creatine is in mg/dL
#' The calculation is also based on the respondent's ethnicity, sex, and age.
# 
#' @param LAB_BCRE Blood creatine (µmol/L)
#' @param PGDCGT Ethnicity (13 categories)
#' @param CLC_SEX Sex (Male = 1, Female = 2)
#' @param CLC_AGE Age (years)
#' 
#' @return The calculated GFR, which can be NA if the blood creatine is a non-response
calculateGFR <- function(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE) {
  
  GFR <- 0
  serumcreat <- 0
  
  if (LAB_BCRE < 996) {
    serumcreat = LAB_BCRE / 88.4
  }
  else {
    GFR = NA
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