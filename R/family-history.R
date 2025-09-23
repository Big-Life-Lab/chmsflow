#' @title Cardiovascular disease (CVD) personal history
#'
#' @description This function determines a respondent's cardiovascular disease (CVD) personal history based on the presence or absence
#' of specific conditions related to heart disease, heart attack, and stroke.
#'
#' @param CCC_61 [integer] An integer representing the respondent's personal history of heart disease. 1 for "Yes" if the person has
#'               heart disease, 2 for "No" if the person does not have heart disease.
#' @param CCC_63 [integer] An integer representing the respondent's personal history of heart attack. 1 for "Yes" if the person had
#'               a heart attack, 2 for "No" if the person did not have a heart attack.
#' @param CCC_81 [integer] An integer representing the respondent's personal history of stroke. 1 for "Yes" if the person had a stroke,
#'               2 for "No" if the person did not have a stroke.
#'
#' @return [integer] The CVD personal history: 1 for "Yes" if the person had heart disease, heart attack,
#'         or stroke; 2 for "No" if the person had neither of the conditions; and NA if all the input variables are a
#'         non-response.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Determine CVD personal history for a person with heart disease (CCC_61 = 1).
#' determine_CVD_personal_history(CCC_61 = 1, CCC_63 = 2, CCC_81 = 2)
#' # Output: 1 (CVD personal history is "Yes" as heart disease is present).
#'
#' # Multiple respondents
#' determine_CVD_personal_history(CCC_61 = c(1, 2, 2), CCC_63 = c(2, 1, 2), CCC_81 = c(2, 2, 1))
#' # Returns: c(1, 1, 1)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(cvd_personal_history = determine_CVD_personal_history(CCC_61, CCC_63, CCC_81))
#'
#' @export
determine_CVD_personal_history <- function(CCC_61, CCC_63, CCC_81) {
  dplyr::case_when(
    is.na(CCC_61) & is.na(CCC_63) & is.na(CCC_81) ~ haven::tagged_na("b"),
    (CCC_61 == 1) | (CCC_63 == 1) | (CCC_81 == 1) ~ 1,
    TRUE ~ 2
  )
}

#' @title Cardiovascular Disease (CVD) family history
#'
#' @description This function evaluates a respondent's family history of cardiovascular disease (CVD), based on data about diagnoses of heart disease and stroke in immediate family members and the ages at which these diagnoses occurred. It identifies premature CVD if any diagnosis occurred before age 60.
#'
#' @param FMH_11 [integer] An integer: Indicates whether an immediate family member was diagnosed with heart disease.
#'               - 1 for "Yes"
#'               - 2 for "No".
#' @param FMH_12 [numeric] A numeric: Represents the youngest age at diagnosis of heart disease in an immediate family member.
#' @param FMH_13 [integer] An integer: Indicates whether an immediate family member was diagnosed with stroke.
#'               - 1 for "Yes"
#'               - 2 for "No".
#' @param FMH_14 [numeric] A numeric: Represents the youngest age at diagnosis of stroke in an immediate family member.
#'
#' @return [integer] The CVD family history:
#'   - 1: "Yes" — Family history of premature CVD exists (diagnosis before age 60).
#'   - 2: "No" — No family history of premature CVD.
#'   - `NA(b)`: Missing/unknown — Due to non-responses, invalid inputs, or unknown diagnosis ages.
#'
#' @details
#' - If both `FMH_11` (heart disease history) and `FMH_13` (stroke history) are `NA`, the function returns `NA(b)`.
#' - If either `FMH_11` or `FMH_13` indicates a diagnosis (`1` for "Yes"), the corresponding age (`FMH_12` for heart disease and `FMH_14` for stroke) is evaluated:
#'     - Ages between 0 and 59 indicate premature CVD.
#'     - Ages between 60 and 79 indicate late-onset CVD.
#'     - Ages outside this range or invalid inputs (997, 998, 999) result in `NA(b)`.
#' - If both `FMH_11` and `FMH_13` are `2` ("No"), there is no family history of CVD (`2`).
#' - Any invalid inputs for `FMH_11` or `FMH_13` (values greater than 2) also result in `NA(b)`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Premature CVD due to heart disease diagnosis at age 50
#' determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 2, FMH_14 = NA)
#' # Output: 1
#'
#' # Multiple respondents
#' determine_CVD_family_history(
#'   FMH_11 = c(1, 2, 1), FMH_12 = c(50, NA, 70),
#'   FMH_13 = c(2, 1, 2), FMH_14 = c(NA, 55, NA)
#' )
#' # Returns: c(1, 1, 2)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(cvd_family_history = determine_CVD_family_history(FMH_11, FMH_12, FMH_13, FMH_14))
#'
#' @export
determine_CVD_family_history <- function(FMH_11, FMH_12, FMH_13, FMH_14) {
  famheart60 <- dplyr::case_when(
    FMH_11 == 1 & FMH_12 >= 0 & FMH_12 < 60 ~ 1,
    FMH_11 == 1 & (FMH_12 < 0 | FMH_12 > 79 | FMH_12 %in% c(997, 998, 999)) ~ NA_real_,
    FMH_11 > 2 ~ NA_real_,
    TRUE ~ 0
  )

  famstroke60 <- dplyr::case_when(
    FMH_13 == 1 & FMH_14 >= 0 & FMH_14 < 60 ~ 1,
    FMH_13 == 1 & (FMH_14 < 0 | FMH_14 > 79 | FMH_14 %in% c(997, 998, 999)) ~ NA_real_,
    FMH_13 > 2 ~ NA_real_,
    TRUE ~ 0
  )

  dplyr::case_when(
    # If both FMH_11 and FMH_13 are NA, return NA(b)
    is.na(FMH_11) & is.na(FMH_13) ~ haven::tagged_na("b"),
    # If either famheart60 or famstroke60 is 1, then premature CVD exists
    famheart60 == 1 | famstroke60 == 1 ~ 1,
    # If both are 0, then no premature CVD
    famheart60 == 0 & famstroke60 == 0 ~ 2,
    # Otherwise, if there are NAs that prevent a clear determination, return NA(b)
    .default = haven::tagged_na("b")
  )
}
