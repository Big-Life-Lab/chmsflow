#' @title Adjusted systolic blood pressure
#'
#' @description This function adjusts systolic blood pressure based on the respondent's systolic average blood pressure across
#' six measurements. The adjustment is made using specific correction factors. The adjusted systolic blood pressure
#' is returned as a numeric value.
#'
#' @param BPMDPBPS [numeric] A numeric representing the respondent's systolic average blood pressure (in mmHg) across six measurements.
#'
#' @return [numeric] The adjusted systolic blood pressure as a numeric.
#'
#' @details Blood pressure measurements in survey settings may require adjustment to account for 
#'          measurement conditions and equipment differences. This function applies a standardized adjustment
#'          using the formula: SBP_adj = 11.4 + (0.93 * BPMDPBPS).
#'          
#'          Non-response handling: Values >= 996 indicate survey non-response and are converted to 
#'          tagged NA ("b") to distinguish from missing measurements. Negative values are also 
#'          treated as invalid and converted to tagged NA.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Adjust for a respondent with average systolic blood pressure of 120 mmHg.
#' adjust_SBP(BPMDPBPS = 120)
#' # Output: 123
#'
#' # Multiple respondents
#' adjust_SBP(BPMDPBPS = c(120, 130, 140))
#' # Returns: c(123, 132.3, 141.6)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(sbp_adj = adjust_SBP(BPMDPBPS))
#'
#' @seealso [adjust_DBP()] for diastolic blood pressure adjustment, [determine_hypertension()] for hypertension classification
#' @keywords survey health cardiovascular
#' @export
adjust_SBP <- function(BPMDPBPS) {
  dplyr::case_when(
    is.na(BPMDPBPS) | BPMDPBPS < 0 | BPMDPBPS >= 996 ~ haven::tagged_na("b"),
    TRUE ~ 11.4 + (0.93 * BPMDPBPS)
  )
}

#' @title Adjusted diastolic blood pressure
#'
#' @description This function adjusts diastolic blood pressure based on the respondent's diastolic average blood pressure across
#' six measurements. The adjustment is made using specific correction factors. The adjusted diastolic blood pressure
#' is returned as a numeric value.
#'
#' @param BPMDPBPD [numeric] A numeric representing the respondent's diastolic average blood pressure (in mmHg) across six measurements.
#'
#' @return [numeric] The adjusted diastolic blood pressure as a numeric.
#'
#' @details Blood pressure measurements in survey settings may require adjustment to account for 
#'          measurement conditions and equipment differences. This function applies a standardized adjustment
#'          using the formula: DBP_adj = 15.6 + (0.83 * BPMDPBPD).
#'          
#'          Non-response handling: Values >= 996 indicate survey non-response and are converted to 
#'          tagged NA ("b") to distinguish from missing measurements. Negative values are also 
#'          treated as invalid and converted to tagged NA.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Adjust for a respondent with average diastolic blood pressure of 80 mmHg.
#' adjust_DBP(BPMDPBPD = 80)
#' # Output: 82
#'
#' # Multiple respondents
#' adjust_DBP(BPMDPBPD = c(80, 90, 100))
#' # Returns: c(82, 90.3, 98.6)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(dbp_adj = adjust_DBP(BPMDPBPD))
#'
#' @seealso [adjust_SBP()] for systolic blood pressure adjustment, [determine_hypertension()] for hypertension classification
#' @keywords survey health cardiovascular
#' @export
adjust_DBP <- function(BPMDPBPD) {
  dplyr::case_when(
    is.na(BPMDPBPD) | BPMDPBPD < 0 | BPMDPBPD >= 996 ~ haven::tagged_na("b"),
    TRUE ~ 15.6 + (0.83 * BPMDPBPD)
  )
}

#' @title Hypertension derived variable
#'
#' @description
#' This function determines the hypertension status of a respondent based on their systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param BPMDPBPS [integer] An integer representing the systolic blood pressure measurement of the respondent.
#' @param BPMDPBPD [integer] An integer representing the diastolic blood pressure measurement of the respondent.
#' @param ANYMED2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param CCC_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CARDIOV [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param DIABX [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CKD [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: High blood pressure (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) or on hypertension medication)
#'   - 2: Normal blood pressure (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) and not on hypertension medication)
#'   - NA(b): Invalid input or non-response
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has systolic BP = 150, diastolic BP = 95, and on medication.
#' determine_hypertension(BPMDPBPS = 150, BPMDPBPD = 95, ANYMED2 = 1)
#' # Output: 1 (High blood pressure due to systolic BP, diastolic BP, and medication usage).
#'
#' # Example 2: Respondent has systolic BP = 120, diastolic BP = 80, and not on medication.
#' determine_hypertension(BPMDPBPS = 120, BPMDPBPD = 80, ANYMED2 = 0)
#' # Output: 2 (Normal blood pressure as BP is below 140/90 mmHg and not on medication).
#'
#' # Multiple respondents
#' determine_hypertension(
#'   BPMDPBPS = c(150, 120, 135), BPMDPBPD = c(95, 80, 85),
#'   ANYMED2 = c(1, 0, 1), DIABX = c(2, 2, 1)
#' )
#' # Returns: c(1, 2, 1)
#'
#' @details This function implements clinical guidelines for hypertension classification:
#'          
#'          **Blood Pressure Thresholds:**
#'          - General population: >= 140/90 mmHg indicates hypertension
#'          - Diabetes or CKD patients: >= 130/80 mmHg indicates hypertension (lower threshold)
#'          
#'          **Medication Logic:**
#'          - Anyone taking hypertension medication is classified as hypertensive
#'          - Medication status may be adjusted based on comorbidities (diabetes, CKD, cardiovascular disease)
#'          
#'          **Non-response Handling:**
#'          - Values >= 996 indicate survey non-response codes
#'          - Invalid blood pressure readings result in tagged NA ("b")
#'
#' @seealso [adjust_SBP()], [adjust_DBP()] for blood pressure adjustment, [determine_adjusted_hypertension()] for adjusted BP classification
#' @references Clinical guidelines for blood pressure classification and management
#' @keywords survey health cardiovascular hypertension
#' @export
determine_hypertension <- function(BPMDPBPS, BPMDPBPD, ANYMED2, CCC_32 = 2, CARDIOV = 2, DIABX = 2, CKD = 2) {
  ANYMED2 <- dplyr::case_when(
    CCC_32 == 2 & (CARDIOV == 1 | CKD == 1 | DIABX == 1) ~ 0,
    (!is.na(ANYMED2) & ANYMED2 == "NA(b)") ~ NA_real_,
    TRUE ~ as.numeric(ANYMED2)
  )

  highsys140 <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & BPMDPBPS >= 130 & BPMDPBPS < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & BPMDPBPS >= 0 & BPMDPBPS < 130 ~ 2,
    !(DIABX == 1 | CKD == 1) & BPMDPBPS >= 140 & BPMDPBPS < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & BPMDPBPS >= 0 & BPMDPBPS < 140 ~ 2,
    TRUE ~ NA_real_
  )

  highdias90 <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & BPMDPBPD >= 80 & BPMDPBPD < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & BPMDPBPD >= 0 & BPMDPBPD < 80 ~ 2,
    !(DIABX == 1 | CKD == 1) & BPMDPBPD >= 90 & BPMDPBPD < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & BPMDPBPD >= 0 & BPMDPBPD < 90 ~ 2,
    TRUE ~ NA_real_
  )

  dplyr::case_when(
    !is.na(ANYMED2) & ANYMED2 == 1 ~ 1,
    BPMDPBPS < 0 | BPMDPBPS >= 996 | is.na(BPMDPBPS) | BPMDPBPD < 0 | BPMDPBPD >= 996 | is.na(BPMDPBPD) ~ NA_real_,
    highsys140 == 1 | highdias90 == 1 ~ 1,
    highsys140 == 2 & highdias90 == 2 & (ANYMED2 == 0 | is.na(ANYMED2)) ~ 2,
    TRUE ~ NA_real_
  )
}

#' @title Hypertension derived variable with adjusted blood pressures
#'
#' @description
#' This function determines the hypertension status of a respondent based on their adjusted systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param SBP_adj [integer] An integer representing the adjusted systolic blood pressure measurement of the respondent.
#' @param DBP_adj [integer] An integer representing the adjusted diastolic blood pressure measurement of the respondent.
#' @param ANYMED2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param CCC_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CARDIOV [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param DIABX [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CKD [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: High blood pressure (adjusted BP ≥ 140/90 mmHg (or ≥ 130/80 mmHg if diabetes or CKD) or on hypertension medication)
#'   - 2: Normal blood pressure (adjusted BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) and not on hypertension medication)
#'   - NA(b): Invalid input or non-response
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
#' determine_adjusted_hypertension(SBP_adj = 150, DBP_adj = 95, ANYMED2 = 1)
#' # Output: 1 (High blood pressure due to adjusted SBP, adjusted DBP, and medication usage).
#'
#' # Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and not on medication.
#' determine_adjusted_hypertension(SBP_adj = 120, DBP_adj = 80, ANYMED2 = 2)
#' # Output: 2 (Normal blood pressure as adjusted BP is below 140/90 mmHg and not on medication).
#'
#' # Multiple respondents
#' determine_adjusted_hypertension(
#'   SBP_adj = c(150, 120, 135), DBP_adj = c(95, 80, 85),
#'   ANYMED2 = c(1, 0, 1), DIABX = c(2, 2, 1)
#' )
#' # Returns: c(1, 2, 1)
#'
#' @export
determine_adjusted_hypertension <- function(SBP_adj, DBP_adj, ANYMED2, CCC_32 = 2, CARDIOV = 2, DIABX = 2, CKD = 2) {
  ANYMED2_adjusted <- dplyr::case_when(
    CCC_32 == 2 & (CARDIOV == 1 | CKD == 1 | DIABX == 1) ~ 0,
    (!is.na(ANYMED2) & ANYMED2 == "NA(b)") ~ NA_real_,
    TRUE ~ as.numeric(ANYMED2)
  )

  highsys140_adj <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & SBP_adj >= 130 & SBP_adj < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & SBP_adj >= 0 & SBP_adj < 130 ~ 2,
    !(DIABX == 1 | CKD == 1) & SBP_adj >= 140 & SBP_adj < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & SBP_adj >= 0 & SBP_adj < 140 ~ 2,
    TRUE ~ NA_real_
  )

  highdias90_adj <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & DBP_adj >= 80 & DBP_adj < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & DBP_adj >= 0 & DBP_adj < 80 ~ 2,
    !(DIABX == 1 | CKD == 1) & DBP_adj >= 90 & DBP_adj < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & DBP_adj >= 0 & DBP_adj < 90 ~ 2,
    TRUE ~ NA_real_
  )

  dplyr::case_when(
    !is.na(ANYMED2_adjusted) & ANYMED2_adjusted == 1 ~ 1,
    is.na(SBP_adj) | is.na(DBP_adj) | SBP_adj < 0 | SBP_adj >= 996 | DBP_adj < 0 | DBP_adj >= 996 ~ NA_real_,
    highsys140_adj == 1 | highdias90_adj == 1 ~ 1,
    highsys140_adj == 2 & highdias90_adj == 2 & (ANYMED2_adjusted == 0 | is.na(ANYMED2_adjusted)) ~ 2,
    TRUE ~ NA_real_
  )
}

#' @title Controlled hypertension derived variable
#'
#' @description
#' This function determines the controlled hypertension status of a respondent based on their systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param BPMDPBPS [integer] An integer representing the systolic blood pressure measurement of the respondent.
#' @param BPMDPBPD [integer] An integer representing the diastolic blood pressure measurement of the respondent.
#' @param ANYMED2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param CCC_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CARDIOV [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param DIABX [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CKD [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: Hypertension controlled (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - 2: Hypertension not controlled (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - NA(b): Invalid input or non-response
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has systolic BP = 150, diastolic BP = 95, and on medication.
#' determine_controlled_hypertension(BPMDPBPS = 150, BPMDPBPD = 95, ANYMED2 = 1)
#' # Output: 2 (Hypertension not controlled due to high SBP and SBP despite medication usage).
#'
#' # Example 2: Respondent has systolic BP = 120, diastolic BP = 80, and on medication.
#' determine_controlled_hypertension(BPMDPBPS = 120, BPMDPBPD = 80, ANYMED2 = 1)
#' # Output: 1 (Hypertension controlled as BP is below 140/90 mmHg and on medication).
#'
#' # Multiple respondents
#' determine_controlled_hypertension(
#'   BPMDPBPS = c(150, 120, 135), BPMDPBPD = c(95, 80, 85),
#'   ANYMED2 = c(1, 1, 1), DIABX = c(2, 2, 1)
#' )
#' # Returns: c(2, 1, 2)
#'
#' @export
determine_controlled_hypertension <- function(BPMDPBPS, BPMDPBPD, ANYMED2, CCC_32 = 2, CARDIOV = 2, DIABX = 2, CKD = 2) {
  ANYMED2_adjusted <- dplyr::case_when(
    CCC_32 == 2 & (CARDIOV == 1 | CKD == 1 | DIABX == 1) ~ 0,
    (!is.na(ANYMED2) & ANYMED2 == "NA(b)") ~ NA_real_,
    TRUE ~ as.numeric(ANYMED2)
  )

  highsys140 <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & BPMDPBPS >= 130 & BPMDPBPS < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & BPMDPBPS >= 0 & BPMDPBPS < 130 ~ 2,
    !(DIABX == 1 | CKD == 1) & BPMDPBPS >= 140 & BPMDPBPS < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & BPMDPBPS >= 0 & BPMDPBPS < 140 ~ 2,
    TRUE ~ NA_real_
  )

  highdias90 <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & BPMDPBPD >= 80 & BPMDPBPD < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & BPMDPBPD >= 0 & BPMDPBPD < 80 ~ 2,
    !(DIABX == 1 | CKD == 1) & BPMDPBPD >= 90 & BPMDPBPD < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & BPMDPBPD >= 0 & BPMDPBPD < 90 ~ 2,
    TRUE ~ NA_real_
  )

  dplyr::case_when(
    BPMDPBPS < 0 | BPMDPBPS >= 996 | is.na(BPMDPBPS) | BPMDPBPD < 0 | BPMDPBPD >= 996 | is.na(BPMDPBPD) ~ NA_real_,
    ANYMED2_adjusted == 1 ~ dplyr::case_when(
      highsys140 == 1 | highdias90 == 1 ~ 2, # Not controlled
      highsys140 == 2 & highdias90 == 2 ~ 1, # Controlled
      TRUE ~ NA_real_
    ),
    ANYMED2_adjusted != 1 ~ 2, # Not on medication, so not controlled hypertension
    TRUE ~ NA_real_
  )
}

#' @title Controlled hypertension derived variable with adjusted blood pressures
#'
#' @description
#' This function determines the controlled hypertension status of a respondent based on their adjusted systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param SBP_adj [integer] An integer representing the adjusted systolic blood pressure measurement of the respondent.
#' @param DBP_adj [integer] An integer representing the adjusted diastolic blood pressure measurement of the respondent.
#' @param ANYMED2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param CCC_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CARDIOV [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param DIABX [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param CKD [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: Hypertension controlled (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - 2: Hypertension not controlled (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - NA(b): Invalid input or non-response
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
#' determine_controlled_adjusted_hypertension(SBP_adj = 150, DBP_adj = 95, ANYMED2 = 1)
#' # Output: 2 (Hypertension not controlled due to high adjusted SBP and DBP despite medication usage).
#'
#' # Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and on medication.
#' determine_controlled_adjusted_hypertension(SBP_adj = 120, DBP_adj = 80, ANYMED2 = 1)
#' # Output: 1 (Hypertension controlled as adjusted BP is below 140/90 mmHg and on medication).
#'
#' # Multiple respondents
#' determine_controlled_adjusted_hypertension(
#'   SBP_adj = c(150, 120, 135), DBP_adj = c(95, 80, 85),
#'   ANYMED2 = c(1, 1, 1), DIABX = c(2, 2, 1)
#' )
#' # Returns: c(2, 1, 2)
#'
#' @export
determine_controlled_adjusted_hypertension <- function(SBP_adj, DBP_adj, ANYMED2, CCC_32 = 2, CARDIOV = 2, DIABX = 2, CKD = 2) {
  ANYMED2_adjusted <- dplyr::case_when(
    CCC_32 == 2 & (CARDIOV == 1 | CKD == 1 | DIABX == 1) ~ 0,
    (!is.na(ANYMED2) & ANYMED2 == "NA(b)") ~ NA_real_,
    TRUE ~ as.numeric(ANYMED2)
  )

  highsys140_adj <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & SBP_adj >= 130 & SBP_adj < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & SBP_adj >= 0 & SBP_adj < 130 ~ 2,
    !(DIABX == 1 | CKD == 1) & SBP_adj >= 140 & SBP_adj < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & SBP_adj >= 0 & SBP_adj < 140 ~ 2,
    TRUE ~ NA_real_
  )

  highdias90_adj <- dplyr::case_when(
    (DIABX == 1 | CKD == 1) & DBP_adj >= 80 & DBP_adj < 996 ~ 1,
    (DIABX == 1 | CKD == 1) & DBP_adj >= 0 & DBP_adj < 80 ~ 2,
    !(DIABX == 1 | CKD == 1) & DBP_adj >= 90 & DBP_adj < 996 ~ 1,
    !(DIABX == 1 | CKD == 1) & DBP_adj >= 0 & DBP_adj < 90 ~ 2,
    TRUE ~ NA_real_
  )

  dplyr::case_when(
    SBP_adj < 0 | SBP_adj >= 996 | is.na(SBP_adj) | DBP_adj < 0 | DBP_adj >= 996 | is.na(DBP_adj) ~ haven::tagged_na("b"),
    ANYMED2_adjusted == 1 ~ dplyr::case_when(
      highsys140_adj == 1 | highdias90_adj == 1 ~ 2, # Not controlled
      highsys140_adj == 2 & highdias90_adj == 2 ~ 1, # Controlled
      TRUE ~ haven::tagged_na("b")
    ),
    ANYMED2_adjusted != 1 ~ 2, # Not on medication, so not controlled hypertension
    TRUE ~ haven::tagged_na("b")
  )
}
