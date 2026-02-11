#' @title Diabetes derived variable
#'
#' @description This function evaluates diabetes status using a comprehensive approach that combines
#' laboratory measurements, self-reported diagnosis, and medication usage to create an inclusive
#' diabetes classification.
#'
#' @param diab_a1c [integer] An integer indicating whether the respondent has diabetes based on HbA1c level. 1 for "Yes", 2 for "No".
#' @param ccc_51 [integer] An integer indicating whether the respondent self-reported diabetes. 1 for "Yes", 2 for "No".
#' @param diab_med2 [integer] An integer indicating whether the respondent is on diabetes medication. 1 for "Yes", 0 for "No".
#'
#' @return [integer] The inclusive diabetes status:
#'         - 1 ("Yes") if any of `diab_a1c`, `ccc_51`, or `diab_med2` is 1.
#'         - 2 ("No") if all of `diab_a1c`, `ccc_51`, and `diab_med2` are 2 or 0.
#'         - `haven::tagged_na("a")`: Not applicable
#'         - `haven::tagged_na("b")`: Missing
#'
#' @details This function classifies diabetes status based that considers:
#'
#'          **Data Sources:**
#'          - Laboratory: HbA1c levels indicating diabetes (diab_a1c)
#'          - Self-report: Participant-reported diabetes diagnosis (ccc_51)
#'          - Medication: Current diabetes medication usage (diab_med2)
#'
#'          **Classification Logic:**
#'          - ANY positive indicator results in diabetes classification
#'          - ALL negative indicators required for "no diabetes" classification
#'          - Sophisticated missing data handling preserves available information
#'
#'          **Missing Data Codes:**
#'          - `diab_a1c`, `diab_med2`:
#'            - Tagged NA "a": Valid skip.
#'            - Tagged NA "b": Don't know, refusal, or not stated.
#'          - `ccc_51`:
#'            - `6`: Valid skip. Handled as `haven::tagged_na("a")`.
#'            - `7-9`: Don't know, refusal, or not stated. Handled as `haven::tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example: Determine the inclusive diabetes status for a respondent with diabetes based on HbA1c.
#' derive_diabetes_status(diab_a1c = 1, ccc_51 = 2, diab_med2 = 0)
#' # Output: 1 (Inclusive diabetes status is "Yes").
#'
#' # Example: Determine the inclusive diabetes status for a respondent no diabetes all around.
#' derive_diabetes_status(diab_a1c = 2, ccc_51 = 2, diab_med2 = 0)
#' # Output: 2 (Inclusive diabetes status is "No").
#'
#' # Example: Determine inclusive diabetes status when only one parameter is NA.
#' derive_diabetes_status(diab_a1c = 2, ccc_51 = NA, diab_med2 = 1)
#' # Output: 1 (Based on `diab_med2`, inclusive diabetes status is "Yes").
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- derive_diabetes_status(haven::tagged_na("b"), 8, haven::tagged_na("b"))
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' derive_diabetes_status(diab_a1c = c(1, 2, 2), ccc_51 = c(2, 1, 2), diab_med2 = c(0, 0, 1))
#' # Returns: c(1, 1, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(diabetes_status = derive_diabetes_status(diab_a1c, ccc_51, diab_med2))
#'
#' @seealso Related health condition functions: [derive_hypertension()], [calculate_gfr()]
#' @export
derive_diabetes_status <- function(diab_a1c, ccc_51, diab_med2) {
  vals <- c(diab_a1c, ccc_51, diab_med2)
  non_missing <- vals[!is.na(vals) & !haven::is_tagged_na(vals, "a") & !haven::is_tagged_na(vals, "b")]

  dplyr::case_when(
    # Positive evidence always first
    diab_a1c == 1 | ccc_51 == 1 | diab_med2 == 1 ~ 1,

    # Explicit negatives if there is at least one observed value and ALL observed are negative
    length(non_missing) > 0 & all(non_missing %in% c(0, 2)) ~ 2,

    # NA(a) takes precedence over NA(b)
    haven::is_tagged_na(diab_a1c, "a") |
      haven::is_tagged_na(ccc_51, "a") | ccc_51 == 6 |
      haven::is_tagged_na(diab_med2, "a") ~ haven::tagged_na("a"),

    # NA(b) next in precedence
    haven::is_tagged_na(diab_a1c, "b") |
      haven::is_tagged_na(ccc_51, "b") | ccc_51 %in% 7:9 |
      haven::is_tagged_na(diab_med2, "b") |
      all(is.na(vals)) ~ haven::tagged_na("b"),

    # Default fallback
    .default = haven::tagged_na("b")
  )
}
