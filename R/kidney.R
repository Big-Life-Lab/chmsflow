#' @title Estimated glomerular filtration rate (GFR)
#'
#' @description This function calculates the estimated glomerular filtration rate (GFR) according to Finlay's formula,
#'              where serum creatine is in mg/dL. The calculation takes into account the respondent's ethnicity, sex, and age. This function supports vector operations.
#'
#' @param LAB_BCRE [numeric] Blood creatine (µmol/L). It should be a numeric between 14 and 785.
#' @param PGDCGT [integer] Ethnicity (13 categories). It should be an integer between 1 and 13.
#' @param CLC_SEX [integer] Sex (Male = 1, Female = 2). It should be an integer of either 1 or 2.
#' @param CLC_AGE [numeric] Age (years). It should be a numeric between 3 and 79.
#'
#' @return [numeric] The calculated GFR. If any of the input parameters (LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE)
#'         are non-response values (LAB_BCRE >= 996, PGDCGT >= 96, CLC_SEX >= 6, CLC_AGE >= 996) or out of bounds, the GFR will be NA(b).
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
#' # Scalar usage: Single respondent
#' # Example 1: Calculate GFR for a 45-year-old white female with serum creatine of 80 µmol/L.
#' calculate_GFR(LAB_BCRE = 80, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 45)
#' # Output: GFR = 67.27905
#'
#' # Example 2: Calculate GFR for a 35-year-old black female with serum creatine of 70 µmol/L.
#' calculate_GFR(LAB_BCRE = 70, PGDCGT = 2, CLC_SEX = 2, CLC_AGE = 35)
#' # Output: GFR = 99.94114
#'
#' # Vector usage: Multiple respondents
#' calculate_GFR(
#'   LAB_BCRE = c(80, 70, 90), PGDCGT = c(1, 2, 1),
#'   CLC_SEX = c(2, 2, 1), CLC_AGE = c(45, 35, 50)
#' )
#' # Returns: c(67.27905, 99.94114, 70.38001)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(gfr = calculate_GFR(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE))
#'
#' @export
calculate_GFR <- function(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE) {
  serumcreat <- LAB_BCRE / 88.4

  GFR <- dplyr::case_when(
    !LAB_BCRE %in% 14:785 | !CLC_SEX %in% c(1, 2) | !PGDCGT %in% 1:13 | !CLC_AGE %in% 3:79 ~ haven::tagged_na("b"),
    CLC_SEX == 2 & PGDCGT == 2 ~ 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) * (0.742) * (1.210),
    CLC_SEX == 2 & PGDCGT != 2 ~ 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) * (0.742),
    CLC_SEX == 1 & PGDCGT == 2 ~ 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)) * (1.210),
    CLC_SEX == 1 & PGDCGT != 2 ~ 175 * ((serumcreat)^(-1.154)) * ((CLC_AGE)^(-0.203)),
    TRUE ~ haven::tagged_na("b")
  )

  return(GFR)
}

#' @title Chronic kidney disease (CKD) derived variable
#'
#' @description This function categorizes individuals' glomerular filtration rate (GFR) into stages of Chronic Kidney Disease (CKD). This function supports vector operations.
#'
#' @param GFR [numeric] A numeric representing the glomerular filtration rate.
#'
#' @return [integer] The CKD stage:
#'   - 1: GFR of 60 or below (indicating CKD)
#'   - 2: GFR above 60 (not indicating CKD)
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a GFR of 45
#' categorize_GFR_to_CKD(45)
#' # Output: 1
#'
#' # Example 2: Categorize a GFR of 75
#' categorize_GFR_to_CKD(75)
#' # Output: 2
#'
#' # Vector usage: Multiple respondents
#' categorize_GFR_to_CKD(c(45, 75, 60))
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(ckd = categorize_GFR_to_CKD(gfr))
#'
#' @export
categorize_GFR_to_CKD <- function(GFR) {
  CKD <- dplyr::case_when(
    is.na(GFR) | GFR < 0 ~ haven::tagged_na("b"),
    GFR <= 60 ~ 1,
    GFR > 60 ~ 2,
    TRUE ~ haven::tagged_na("b")
  )
  return(CKD)
}
