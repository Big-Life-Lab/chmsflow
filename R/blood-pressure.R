#' @title Adjusted systolic blood pressure
#'
#' @description This function adjusts systolic blood pressure based on the respondent's systolic average blood pressure across
#' six measurements. The adjustment is made using specific correction factors. The adjusted systolic blood pressure
#' is returned as a numeric value.
#'
#' @param bpmdpbps [numeric] A numeric representing the respondent's systolic average blood pressure (in mmHg) across six measurements.
#'
#' @return [numeric] The adjusted systolic blood pressure as a numeric.
#'
#' @details Blood pressure measurements in survey settings may require adjustment to account for
#'          measurement conditions and equipment differences. This function applies a standardized adjustment
#'          using the formula: sbp_adj_mmhg = 11.4 + (0.93 * bpmdpbps).
#'
#'          **Missing Data Codes:**
#'          - `996`: Valid skip (e.g., measurement not taken). Handled as `haven::tagged_na("a")`.
#'          - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Adjust for a respondent with average systolic blood pressure of 120 mmHg.
#' adjust_sbp(bpmdpbps = 120)
#' # Output: 123
#'
#' # Example: Adjust for a respondent with a non-response systolic blood pressure of 996.
#' result <- adjust_sbp(bpmdpbps = 996)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' adjust_sbp(bpmdpbps = c(120, 130, 140))
#' # Returns: c(123, 132.3, 141.6)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(sbp_adj_mmhg = adjust_sbp(bpmdpbps))
#'
#' @seealso [adjust_dbp()] for diastolic blood pressure adjustment, [derive_hypertension()] for hypertension classification
#' @export
adjust_sbp <- function(bpmdpbps) {
  dplyr::case_when(
    # Valid skip
    bpmdpbps == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbps < 0 | bpmdpbps %in% 997:999 ~ haven::tagged_na("b"),

    # Apply adjustment formula
    TRUE ~ 11.4 + (0.93 * bpmdpbps)
  )
}

#' @title Adjusted diastolic blood pressure
#'
#' @description This function adjusts diastolic blood pressure based on the respondent's diastolic average blood pressure across
#' six measurements. The adjustment is made using specific correction factors. The adjusted diastolic blood pressure
#' is returned as a numeric value.
#'
#' @param bpmdpbpd [numeric] A numeric representing the respondent's diastolic average blood pressure (in mmHg) across six measurements.
#'
#' @return [numeric] The adjusted diastolic blood pressure as a numeric.
#'
#' @details Blood pressure measurements in survey settings may require adjustment to account for
#'          measurement conditions and equipment differences. This function applies a standardized adjustment
#'          using the formula: dbp_adj_mmhg = 15.6 + (0.83 * bpmdpbpd).
#'
#'          **Missing Data Codes:**
#'          - `996`: Valid skip (e.g., measurement not taken). Handled as `haven::tagged_na("a")`.
#'          - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Adjust for a respondent with average diastolic blood pressure of 80 mmHg.
#' adjust_dbp(bpmdpbpd = 80)
#' # Output: 82
#'
#' # Example: Adjust for a respondent with a non-response diastolic blood pressure of 996.
#' result <- adjust_dbp(bpmdpbpd = 996)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' adjust_dbp(bpmdpbpd = c(80, 90, 100))
#' # Returns: c(82, 90.3, 98.6)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(dbp_adj_mmhg = adjust_dbp(bpmdpbpd))
#'
#' @seealso [adjust_sbp()] for systolic blood pressure adjustment, [derive_hypertension()] for hypertension classification
#' @export
adjust_dbp <- function(bpmdpbpd) {
  dplyr::case_when(
    # Valid skip
    bpmdpbpd == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbpd < 0 | bpmdpbpd %in% 997:999 ~ haven::tagged_na("b"),

    # Apply adjustment formula
    TRUE ~ 15.6 + (0.83 * bpmdpbpd)
  )
}

#' @title Hypertension derived variable
#'
#' @description
#' This function determines the hypertension status of a respondent based on their systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param bpmdpbps [integer] An integer representing the systolic blood pressure measurement of the respondent.
#' @param bpmdpbpd [integer] An integer representing the diastolic blood pressure measurement of the respondent.
#' @param any_htn_med2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param ccc_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param cvd_status [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param diab_status [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param ckd_status [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: High blood pressure (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) or on hypertension medication)
#'   - 2: Normal blood pressure (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) and not on hypertension medication)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
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
#'          **Missing Data Codes:**
#'          - `bpmdpbps`, `bpmdpbpd`:
#'            - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `any_htn_med2`:
#'            - Tagged NA "a": Valid skip.
#'            - Tagged NA "b": Don't know, refusal, or not stated.
#'          - `ccc_32`, `cvd_status`, `diab_status`, `ckd_status`:
#'            - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has systolic BP = 150, diastolic BP = 95, and on medication.
#' derive_hypertension(bpmdpbps = 150, bpmdpbpd = 95, any_htn_med2 = 1)
#' # Output: 1 (High blood pressure due to systolic BP, diastolic BP, and medication usage).
#'
#' # Example 2: Respondent has systolic BP = 120, diastolic BP = 80, and not on medication.
#' derive_hypertension(bpmdpbps = 120, bpmdpbpd = 80, any_htn_med2 = 0)
#' # Output: 2 (Normal blood pressure as BP is below 140/90 mmHg and not on medication).
#'
#' # Example 3: Respondent has non-response BP values of 996 for both systolic and diastolic.
#' result <- derive_hypertension(bpmdpbps = 996, bpmdpbpd = 996, any_htn_med2 = 0)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' derive_hypertension(
#'   bpmdpbps = c(150, 120, 135), bpmdpbpd = c(95, 80, 85),
#'   any_htn_med2 = c(1, 0, 1), diab_status = c(2, 2, 1)
#' )
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(hypertension = derive_hypertension(bpmdpbps, bpmdpbpd, any_htn_med2))
#'
#' @seealso [adjust_sbp()], [adjust_dbp()] for blood pressure adjustment, [derive_hypertension_adj()] for adjusted BP classification
#' @export
derive_hypertension <- function(bpmdpbps, bpmdpbpd, any_htn_med2, ccc_32 = 2, cvd_status = 2, diab_status = 2, ckd_status = 2) {
  # Adjust medication status based on other health conditions
  any_htn_med2 <- dplyr::case_when(
    ccc_32 == 2 & (cvd_status == 1 | ckd_status == 1 | diab_status == 1) ~ 0,
    haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    TRUE ~ as.numeric(any_htn_med2)
  )

  # Determine high systolic blood pressure status
  highsys140 <- dplyr::case_when(
    # Valid skip
    bpmdpbps == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbps %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & bpmdpbps >= 130 ~ 1,
    (diab_status == 1 | ckd_status == 1) & bpmdpbps < 130 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbps >= 140 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbps < 140 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine high diastolic blood pressure status
  highdias90 <- dplyr::case_when(
    # Valid skip
    bpmdpbpd == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbpd %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & bpmdpbpd >= 80 ~ 1,
    (diab_status == 1 | ckd_status == 1) & bpmdpbpd < 80 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbpd >= 90 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbpd < 90 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine overall hypertension status
  dplyr::case_when(
    !is.na(any_htn_med2) & any_htn_med2 == 1 ~ 1,
    highsys140 == 1 | highdias90 == 1 ~ 1,
    highsys140 == 2 & highdias90 == 2 & (any_htn_med2 == 0 | is.na(any_htn_med2)) ~ 2,
    haven::is_tagged_na(highsys140, "a") | haven::is_tagged_na(highdias90, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(highsys140, "b") | haven::is_tagged_na(highdias90, "b") |
      haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    .default = haven::tagged_na("b")
  )
}

#' @title Hypertension derived variable with adjusted blood pressures
#'
#' @description
#' This function determines the hypertension status of a respondent based on their adjusted systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param sbp_adj_mmhg [integer] An integer representing the adjusted systolic blood pressure measurement of the respondent.
#' @param dbp_adj_mmhg [integer] An integer representing the adjusted diastolic blood pressure measurement of the respondent.
#' @param any_htn_med2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param ccc_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param cvd_status [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param diab_status [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param ckd_status [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: High blood pressure (adjusted BP ≥ 140/90 mmHg (or ≥ 130/80 mmHg if diabetes or CKD) or on hypertension medication)
#'   - 2: Normal blood pressure (adjusted BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) and not on hypertension medication)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function implements clinical guidelines for hypertension classification using adjusted blood pressure values:
#'
#'          **Blood Pressure Thresholds:**
#'          - General population: >= 140/90 mmHg indicates hypertension
#'          - Diabetes or CKD patients: >= 130/80 mmHg indicates hypertension (lower threshold)
#'
#'          **Medication Logic:**
#'          - Anyone taking hypertension medication is classified as hypertensive
#'          - Medication status may be adjusted based on comorbidities (diabetes, CKD, cardiovascular disease)
#'
#'          **Missing Data Codes:**
#'          - `sbp_adj_mmhg`, `dbp_adj_mmhg`:
#'            - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `any_htn_med2`:
#'            - Tagged NA "a": Valid skip.
#'            - Tagged NA "b": Don't know, refusal, or not stated.
#'          - `ccc_32`, `cvd_status`, `diab_status`, `ckd_status`:
#'            - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
#' derive_hypertension_adj(sbp_adj_mmhg = 150, dbp_adj_mmhg = 95, any_htn_med2 = 1)
#' # Output: 1 (High blood pressure due to adjusted SBP, adjusted DBP, and medication usage).
#'
#' # Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and not on medication.
#' derive_hypertension_adj(sbp_adj_mmhg = 120, dbp_adj_mmhg = 80, any_htn_med2 = 2)
#' # Output: 2 (Normal blood pressure as adjusted BP is below 140/90 mmHg and not on medication).
#'
#' # Example 3: Respondent has non-response BP values of 996 for both systolic and diastolic.
#' result <- derive_hypertension_adj(sbp_adj_mmhg = 996, dbp_adj_mmhg = 996, any_htn_med2 = 0)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' derive_hypertension_adj(
#'   sbp_adj_mmhg = c(150, 120, 135), dbp_adj_mmhg = c(95, 80, 85),
#'   any_htn_med2 = c(1, 0, 1), diab_status = c(2, 2, 1)
#' )
#' # Returns: c(1, 2, 1)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(hypertension_adj = derive_hypertension_adj(sbp_adj_mmhg, dbp_adj_mmhg, any_htn_med2))
#'
#' @seealso [derive_hypertension()] for unadjusted BP classification
#' @export
derive_hypertension_adj <- function(sbp_adj_mmhg, dbp_adj_mmhg, any_htn_med2, ccc_32 = 2, cvd_status = 2, diab_status = 2, ckd_status = 2) {
  # Adjust medication status based on other health conditions
  any_htn_med2 <- dplyr::case_when(
    ccc_32 == 2 & (cvd_status == 1 | ckd_status == 1 | diab_status == 1) ~ 0,
    haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    TRUE ~ as.numeric(any_htn_med2)
  )

  # Determine high systolic blood pressure status
  highsys140 <- dplyr::case_when(
    # Valid skip
    sbp_adj_mmhg == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    sbp_adj_mmhg %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg >= 130 ~ 1,
    (diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg < 130 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg >= 140 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg < 140 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine high diastolic blood pressure status
  highdias90 <- dplyr::case_when(
    # Valid skip
    dbp_adj_mmhg == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    dbp_adj_mmhg %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg >= 80 ~ 1,
    (diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg < 80 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg >= 90 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg < 90 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine overall hypertension status
  dplyr::case_when(
    !is.na(any_htn_med2) & any_htn_med2 == 1 ~ 1,
    highsys140 == 1 | highdias90 == 1 ~ 1,
    highsys140 == 2 & highdias90 == 2 & (any_htn_med2 == 0 | is.na(any_htn_med2)) ~ 2,
    haven::is_tagged_na(highsys140, "a") | haven::is_tagged_na(highdias90, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(highsys140, "b") | haven::is_tagged_na(highdias90, "b") |
      haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    .default = haven::tagged_na("b")
  )
}

#' @title Controlled hypertension derived variable
#'
#' @description
#' This function determines the controlled hypertension status of a respondent based on their systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param bpmdpbps [integer] An integer representing the systolic blood pressure measurement of the respondent.
#' @param bpmdpbpd [integer] An integer representing the diastolic blood pressure measurement of the respondent.
#' @param any_htn_med2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param ccc_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param cvd_status [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param diab_status [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param ckd_status [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: Hypertension controlled (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - 2: Hypertension not controlled (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function assesses whether a respondent's hypertension is controlled:
#'
#'          **Control Thresholds:**
#'          - General population: < 140/90 mmHg
#'          - Diabetes or CKD patients: < 130/80 mmHg
#'
#'          **Logic:**
#'          - Only applies to respondents taking hypertension medication.
#'          - If BP is below the threshold, hypertension is "controlled" (1).
#'          - If BP is at or above the threshold, it is "not controlled" (2).
#'
#'          **Missing Data Codes:**
#'          - `bpmdpbps`, `bpmdpbpd`:
#'            - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `any_htn_med2`:
#'            - Tagged NA "a": Valid skip.
#'            - Tagged NA "b": Don't know, refusal, or not stated.
#'          - `ccc_32`, `cvd_status`, `diab_status`, `ckd_status`:
#'            - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has systolic BP = 150, diastolic BP = 95, and on medication.
#' derive_hypertension_control(bpmdpbps = 150, bpmdpbpd = 95, any_htn_med2 = 1)
#' # Output: 2 (Hypertension not controlled due to high SBP and SBP despite medication usage).
#'
#' # Example 2: Respondent has systolic BP = 120, diastolic BP = 80, and on medication.
#' derive_hypertension_control(bpmdpbps = 120, bpmdpbpd = 80, any_htn_med2 = 1)
#' # Output: 1 (Hypertension controlled as BP is below 140/90 mmHg and on medication).
#'
#' # Example 3: Respondent has non-response BP values of 996 for both systolic and diastolic.
#' result <- derive_hypertension_control(bpmdpbps = 996, bpmdpbpd = 996, any_htn_med2 = 0)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' derive_hypertension_control(
#'   bpmdpbps = c(150, 120, 135), bpmdpbpd = c(95, 80, 85),
#'   any_htn_med2 = c(1, 1, 1), diab_status = c(2, 2, 1)
#' )
#' # Returns: c(2, 1, 2)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(controlled_htn = derive_hypertension_control(bpmdpbps, bpmdpbpd, any_htn_med2))
#'
#' @seealso [derive_hypertension_control_adj()] for controlled status with adjusted BP
#' @export
derive_hypertension_control <- function(bpmdpbps, bpmdpbpd, any_htn_med2, ccc_32 = 2, cvd_status = 2, diab_status = 2, ckd_status = 2) {
  # Adjust medication status based on other health conditions
  any_htn_med2 <- dplyr::case_when(
    ccc_32 == 2 & (cvd_status == 1 | ckd_status == 1 | diab_status == 1) ~ 0,
    haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    TRUE ~ as.numeric(any_htn_med2)
  )

  # Determine high systolic blood pressure status
  highsys140 <- dplyr::case_when(
    # Valid skip
    bpmdpbps == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbps %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & bpmdpbps >= 130 ~ 1,
    (diab_status == 1 | ckd_status == 1) & bpmdpbps < 130 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbps >= 140 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbps < 140 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine high diastolic blood pressure status
  highdias90 <- dplyr::case_when(
    # Valid skip
    bpmdpbpd == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    bpmdpbpd %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & bpmdpbpd >= 80 ~ 1,
    (diab_status == 1 | ckd_status == 1) & bpmdpbpd < 80 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbpd >= 90 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & bpmdpbpd < 90 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine overall controlled hypertension status
  dplyr::case_when(
    # On meds
    any_htn_med2 == 1 & (highsys140 == 1 | highdias90 == 1) ~ 2, # Not controlled
    any_htn_med2 == 1 & (highsys140 == 2 & highdias90 == 2) ~ 1, # Controlled

    # Not on meds
    any_htn_med2 == 0 ~ 2,

    # Propagate NA(a) if any relevant measure is NA(a)
    haven::is_tagged_na(highsys140, "a") |
      haven::is_tagged_na(highdias90, "a") |
      haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),

    # Otherwise NA(b) if missing/invalid
    haven::is_tagged_na(highsys140, "b") |
      haven::is_tagged_na(highdias90, "b") |
      haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),

    # Default fallback
    .default = haven::tagged_na("b")
  )
}

#' @title Controlled hypertension derived variable with adjusted blood pressures
#'
#' @description
#' This function determines the controlled hypertension status of a respondent based on their adjusted systolic and diastolic blood pressure measurements and medication usage.
#'
#' @param sbp_adj_mmhg [integer] An integer representing the adjusted systolic blood pressure measurement of the respondent.
#' @param dbp_adj_mmhg [integer] An integer representing the adjusted diastolic blood pressure measurement of the respondent.
#' @param any_htn_med2 [integer] An integer indicating whether the respondent is on medication for hypertension.
#'   - 1: Yes
#'   - 0: No
#' @param ccc_32 [integer] An optional integer indicating whether the respondent is actually on medication for hypertension.
#'   - 1: Yes
#'   - 2: No (default)
#' @param cvd_status [integer] An optional integer indicating the presence of cardiovascular disease, affecting medication status.
#'   - 1: Yes
#'   - 2: No (default)
#' @param diab_status [integer] An optional integer indicating the presence of diabetes, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#' @param ckd_status [integer] An optional integer indicating the presence of chronic kidney disease, affecting blood pressure thresholds.
#'   - 1: Yes
#'   - 2: No (default)
#'
#' @return [integer] The hypertension status:
#'   - 1: Hypertension controlled (BP < 140/90 mmHg (or < 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - 2: Hypertension not controlled (BP >= 140/90 mmHg (or >= 130/80 mmHg if diabetes or CKD) when on hypertension medication)
#'   - `haven::tagged_na("a")`: Not applicable
#'   - `haven::tagged_na("b")`: Missing
#'
#' @details This function assesses whether a respondent's hypertension is controlled using adjusted BP values:
#'
#'          **Control Thresholds:**
#'          - General population: < 140/90 mmHg
#'          - Diabetes or CKD patients: < 130/80 mmHg
#'
#'          **Logic:**
#'          - Only applies to respondents taking hypertension medication.
#'          - If adjusted BP is below the threshold, hypertension is "controlled" (1).
#'          - If adjusted BP is at or above the threshold, it is "not controlled" (2).
#'
#'          **Missing Data Codes:**
#'          - `sbp_adj_mmhg`, `dbp_adj_mmhg`:
#'            - `996`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `997-999`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'          - `any_htn_med2`:
#'            - Tagged NA "a": Valid skip.
#'            - Tagged NA "b": Don't know, refusal, or not stated.
#'          - `ccc_32`, `cvd_status`, `diab_status`, `ckd_status`:
#'            - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent has adjusted SBP = 150, adjusted DBP = 95, and on medication.
#' derive_hypertension_control_adj(sbp_adj_mmhg = 150, dbp_adj_mmhg = 95, any_htn_med2 = 1)
#' # Output: 2 (Hypertension not controlled due to high adjusted SBP and DBP despite medication usage).
#'
#' # Example 2: Respondent has adjusted SBP = 120, adjusted DBP = 80, and on medication.
#' derive_hypertension_control_adj(sbp_adj_mmhg = 120, dbp_adj_mmhg = 80, any_htn_med2 = 1)
#' # Output: 1 (Hypertension controlled as adjusted BP is below 140/90 mmHg and on medication).
#'
#' # Example 3: Respondent has non-response BP values of 996 for both systolic and diastolic.
#' result <- derive_hypertension_control_adj(sbp_adj_mmhg = 996, dbp_adj_mmhg = 996, any_htn_med2 = 0)
#' result # Shows: NA
#' haven::is_tagged_na(result, "a") # Shows: TRUE (confirms it's tagged NA(a))
#' format(result, tag = TRUE) # Shows: "NA(a)" (displays the tag)
#'
#' # Multiple respondents
#' derive_hypertension_control_adj(
#'   sbp_adj_mmhg = c(150, 120, 135), dbp_adj_mmhg = c(95, 80, 85),
#'   any_htn_med2 = c(1, 1, 1), diab_status = c(2, 2, 1)
#' )
#' # Returns: c(2, 1, 2)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(controlled_htn_adj = derive_hypertension_control_adj(sbp_adj_mmhg,
#' #     dbp_adj_mmhg, any_htn_med2))
#'
#' @seealso [derive_hypertension_control()] for controlled status with unadjusted BP
#' @export
derive_hypertension_control_adj <- function(sbp_adj_mmhg, dbp_adj_mmhg, any_htn_med2, ccc_32 = 2, cvd_status = 2, diab_status = 2, ckd_status = 2) {
  # Adjust medication status based on other health conditions
  any_htn_med2 <- dplyr::case_when(
    ccc_32 == 2 & (cvd_status == 1 | ckd_status == 1 | diab_status == 1) ~ 0,
    haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),
    haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),
    TRUE ~ as.numeric(any_htn_med2)
  )

  # Determine high systolic blood pressure status
  highsys140_adj <- dplyr::case_when(
    # Valid skip
    sbp_adj_mmhg == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    sbp_adj_mmhg %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg >= 130 ~ 1,
    (diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg < 130 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg >= 140 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & sbp_adj_mmhg < 140 ~ 2,
    .default = haven::tagged_na("b")
  )

  # Determine high diastolic blood pressure status
  highdias90_adj <- dplyr::case_when(
    # Valid skip
    dbp_adj_mmhg == 996 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    dbp_adj_mmhg %in% 997:999 ~ haven::tagged_na("b"),
    (diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg >= 80 ~ 1,
    (diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg < 80 ~ 2,
    !(diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg >= 90 ~ 1,
    !(diab_status == 1 | ckd_status == 1) & dbp_adj_mmhg < 90 ~ 2,
    .default = haven::tagged_na("b")
  )

  dplyr::case_when(
    # On meds
    any_htn_med2 == 1 & (highsys140_adj == 1 | highdias90_adj == 1) ~ 2, # Not controlled
    any_htn_med2 == 1 & (highsys140_adj == 2 & highdias90_adj == 2) ~ 1, # Controlled

    # Not on meds
    any_htn_med2 == 0 ~ 2,

    # Propagate NA(a) if any relevant measure is NA(a)
    haven::is_tagged_na(highsys140_adj, "a") |
      haven::is_tagged_na(highdias90_adj, "a") |
      haven::is_tagged_na(any_htn_med2, "a") ~ haven::tagged_na("a"),

    # Otherwise NA(b) if missing/invalid
    haven::is_tagged_na(highsys140_adj, "b") |
      haven::is_tagged_na(highdias90_adj, "b") |
      haven::is_tagged_na(any_htn_med2, "b") ~ haven::tagged_na("b"),

    # Default fallback
    .default = haven::tagged_na("b")
  )
}
