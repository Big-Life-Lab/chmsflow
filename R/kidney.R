#' @title Estimated glomerular filtration rate (GFR)
#'
#' @description This function calculates the estimated glomerular filtration rate (GFR) according to Finlay's formula,
#'              where serum creatine is in mg/dL. The calculation takes into account the respondent's ethnicity, sex, and age.
#'
#' @param lab_bcre [numeric] Blood creatine (µmol/L). It should be a numeric between 14 and 785.
#' @param pgdcgt [integer] Ethnicity (13 categories). It should be an integer between 1 and 13.
#' @param clc_sex [integer] Sex (Male = 1, Female = 2). It should be an integer of either 1 or 2.
#' @param clc_age [numeric] Age (years). It should be a numeric between 3 and 79.
#'
#' @return [numeric] The calculated GFR. If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details This function implements the Modification of Diet in Renal Disease (MDRD) equation
#'          to estimate glomerular filtration rate, a key indicator of kidney function.
#'
#'          **Clinical Significance:**
#'          GFR estimates are essential for:
#'          - Chronic kidney disease (CKD) classification
#'          - Medication dosing adjustments
#'          - Cardiovascular risk assessment
#'
#'          **Formula Application:**
#'          Base: GFR = 175 × (creatinine^-1.154) × (age^-0.203)
#'          Adjustments:
#'          - Female: × 0.742
#'          - Black ethnicity: × 1.210
#'
#'          **Unit Conversion:**
#'          Serum creatinine converted from µmol/L to mg/dL (÷ 88.4)
#'
#'          **Missing Data Codes:**
#'          - `lab_bcre`: `9996` (Not applicable), `9997-9999` (Missing)
#'          - `pgdcgt`: `96` (Not applicable), `97-99` (Missing)
#'          - `clc_sex`: `6` (Not applicable), `7-9` (Missing)
#'          - `clc_age`: `96` (Not applicable), `97-99` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Calculate gfr for a 45-year-old white female with serum creatine of 80 µmol/L.
#' calculate_gfr(lab_bcre = 80, pgdcgt = 1, clc_sex = 2, clc_age = 45)
#' # Output: 67.27905
#'
#' # Example 2: Respondent has non-response values for all inputs.
#' result <- calculate_gfr(lab_bcre = 9998, pgdcgt = 98, clc_sex = 8, clc_age = 98)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_gfr(
#'   lab_bcre = c(80, 70, 90), pgdcgt = c(1, 2, 1),
#'   clc_sex = c(2, 2, 1), clc_age = c(45, 35, 50)
#' )
#' # Returns: c(67.27905, 99.94114, 70.38001)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(gfr = calculate_gfr(lab_bcre, pgdcgt, clc_sex, clc_age))
#'
#' @seealso [categorize_ckd()] for CKD classification based on GFR values
#' @export
calculate_gfr <- function(lab_bcre, pgdcgt, clc_sex, clc_age) {
  # Convert serum creatinine from µmol/L to mg/dL
  serumcreat <- lab_bcre / 88.4

  # Calculate GFR using the MDRD equation
  gfr <- dplyr::case_when(
    # Valid skip
    lab_bcre == 9996 | clc_sex == 6 | pgdcgt == 96 | clc_age == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    lab_bcre %in% 9997:9999 | clc_sex %in% 7:9 | pgdcgt %in% 97:99 | clc_age %in% 997:999 ~ haven::tagged_na("b"),

    # Handle out of range values
    !lab_bcre %in% 14:785 | !clc_sex %in% c(1, 2) | !pgdcgt %in% 1:13 | !clc_age %in% 3:79 ~ haven::tagged_na("b"),

    # Apply the MDRD equation with adjustments for sex and ethnicity
    clc_sex == 2 & pgdcgt == 2 ~ 175 * ((serumcreat)^(-1.154)) * ((clc_age)^(-0.203)) * (0.742) * (1.210),
    clc_sex == 2 & pgdcgt != 2 ~ 175 * ((serumcreat)^(-1.154)) * ((clc_age)^(-0.203)) * (0.742),
    clc_sex == 1 & pgdcgt == 2 ~ 175 * ((serumcreat)^(-1.154)) * ((clc_age)^(-0.203)) * (1.210),
    clc_sex == 1 & pgdcgt != 2 ~ 175 * ((serumcreat)^(-1.154)) * ((clc_age)^(-0.203)),

    # Default to missing if no other condition is met
    .default = haven::tagged_na("b")
  )

  return(gfr)
}

#' @title Chronic kidney disease (CKD) derived variable
#'
#' @description This function categorizes individuals' glomerular filtration rate (GFR) into stages of Chronic Kidney Disease (CKD).
#'
#' @param gfr [numeric] A numeric representing the glomerular filtration rate.
#'
#' @return [integer] The CKD stage:
#'   - 1: GFR of 60 or below (indicating CKD)
#'   - 2: GFR above 60 (not indicating CKD)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function applies the Kidney Disease: Improving Global Outcomes (KDIGO) guideline to classify Chronic Kidney Disease (CKD) based on GFR.
#'
#'          **Missing Data Codes:**
#'          - Propagates tagged NAs from the input `gfr`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a GFR of 45
#' categorize_ckd(45)
#' # Output: 1
#'
#' # Example 2: Categorize a GFR of 75
#' categorize_ckd(75)
#' # Output: 2
#'
#' # Example 3: Respondent has a non-response value for GFR.
#' result <- categorize_ckd(haven::tagged_na("b"))
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' categorize_ckd(c(45, 75, 60))
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(ckd = categorize_ckd(gfr))
#'
#' @seealso [calculate_gfr()]
#' @references Kidney Disease: Improving Global Outcomes (KDIGO) CKD Work Group. (2013). KDIGO 2012 clinical practice guideline for the evaluation and management of chronic kidney disease. Kidney international supplements, 3(1), 1-150.
#' @export
categorize_ckd <- function(gfr) {
  # Categorize GFR into CKD stages
  ckd <- dplyr::case_when(
    # Valid skip
    haven::is_tagged_na(gfr, "a") ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    haven::is_tagged_na(gfr, "b") | gfr < 0 ~ haven::tagged_na("b"),

    # Categorize CKD based on GFR
    gfr <= 60 ~ 1,
    gfr > 60 ~ 2,

    # Handle any other cases
    .default = haven::tagged_na("b")
  )
  return(ckd)
}
