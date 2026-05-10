#' Classify a medication against ATC-prefix and exclusion rules
#'
#' Internal helper that consolidates the shared skeleton of the eight scalar
#' medication predicates (`is_beta_blocker()`, `is_ace_inhibitor()`, etc.).
#' Each predicate calls this with its prefix(es) and exclusion list; behavior
#' for valid skips, missing/refused, and recency cutoffs lives in one place.
#'
#' @param meucatc [character] ATC code(s).
#' @param npi_25b [integer] Time(s) the medication was last taken.
#' @param prefix [character] One or more ATC prefixes. A medication matches if
#'   `meucatc` starts with any of them.
#' @param exclude [character] ATC codes to exclude even if they match a prefix.
#'   Defaults to no exclusions.
#' @return [numeric] 1 (matches), 0 (does not match), or `haven::tagged_na()`
#'   for sentinel missing codes.
#' @noRd
is_atc_class <- function(meucatc, npi_25b, prefix, exclude = character()) {
  has_prefix <- purrr::map(prefix, \(p) startsWith(meucatc, p)) |>
    purrr::reduce(`|`)

  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    # Match: starts with one of `prefix`, not on `exclude` list, taken recently
    has_prefix & !(meucatc %in% exclude) & npi_25b <= 4 ~ 1,
    .default = 0
  )
}

#' @title Beta blockers
#' @description This function determines whether a given medication is a beta blocker.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a beta blocker, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_beta_blocker("C07AA13", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_beta_blocker("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_beta_blocker(c("C07AA13", "C07AA07"), c(3, 4))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(beta_blocker = is_beta_blocker(meucatc, npi_25b))
#'
#' @export
is_beta_blocker <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "C07", c("C07AA07", "C07AA12", "C07AG02"))
}

#' @title ACE inhibitors
#' @description This function checks if a given medication is an ACE inhibitor.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an ACE inhibitor, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies ACE inhibitors based on ATC codes starting with "C09".
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_ace_inhibitor("C09AB03", 2)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_ace_inhibitor("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_ace_inhibitor(c("C09AB03", "C01AA05"), c(2, 1))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(ace_inhibitor = is_ace_inhibitor(meucatc, npi_25b))
#'
#' @export
is_ace_inhibitor <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "C09")
}

#' @title Diuretics
#' @description This function checks if a given medication is a diuretic.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diuretic, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies diuretics based on ATC codes starting with "C03", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_diuretic("C03AA03", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_diuretic("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_diuretic(c("C03AA03", "C03BA08"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(diuretic = is_diuretic(meucatc, npi_25b))
#'
#' @export
is_diuretic <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "C03", c("C03BA08", "C03CA01"))
}

#' @title Calcium channel blockers
#' @description This function checks if a given medication is a calcium channel blocker.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a calcium channel blocker, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies calcium channel blockers based on ATC codes starting with "C08".
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_calcium_channel_blocker("C08CA05", 1)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_calcium_channel_blocker("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_calcium_channel_blocker(c("C08CA05", "C01AA05"), c(1, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(ccb = is_calcium_channel_blocker(meucatc, npi_25b))
#'
#' @export
is_calcium_channel_blocker <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "C08")
}

#' @title Other anti-hypertensive medications
#' @description This function checks if a given medication is another anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is another anti-hypertensive drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code.
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_other_antihtn_med("C02AC04", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_other_antihtn_med("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_other_antihtn_med(c("C02AC04", "C02KX01"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(other_antihtn = is_other_antihtn_med(meucatc, npi_25b))
#'
#' @export
is_other_antihtn_med <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "C02", "C02KX01")
}

#' @title Any anti-hypertensive medications
#' @description This function checks if a given medication is any anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an anti-hypertensive drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_any_antihtn_med("C07AB02", 4)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_any_antihtn_med("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_any_antihtn_med(c("C07AB02", "C07AA07"), c(4, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(any_antihtn = is_any_antihtn_med(meucatc, npi_25b))
#'
#' @export
is_any_antihtn_med <- function(meucatc, npi_25b) {
  is_atc_class(
    meucatc, npi_25b,
    prefix  = c("C02", "C03", "C07", "C08", "C09"),
    exclude = c("C07AA07", "C07AA12", "C07AG02", "C03BA08", "C03CA01", "C02KX01")
  )
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs)
#' @description This function checks if a given medication is an NSAID.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an NSAID, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies NSAIDs based on ATC codes starting with "M01A".
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_nsaid("M01AB05", 1)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_nsaid("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_nsaid(c("M01AB05", "A10BB09"), c(1, 3))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(nsaid = is_nsaid(meucatc, npi_25b))
#'
#' @export
is_nsaid <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "M01A")
}

#' @title Diabetes medications
#' @description This function checks if a given medication is a diabetes drug.
#' This function processes multiple inputs efficiently.
#' @param meucatc [character] ATC code of the medication.
#' @param npi_25b [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diabetes drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies diabetes drugs based on ATC codes starting with "A10".
#'
#'          **Missing Data Codes:**
#'          - `meucatc`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `npi_25b`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_diabetes_med("A10BB09", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_diabetes_med("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_diabetes_med(c("A10BB09", "C09AA02"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(diabetes_med = is_diabetes_med(meucatc, npi_25b))
#'
#' @export
is_diabetes_med <- function(meucatc, npi_25b) {
  is_atc_class(meucatc, npi_25b, "A10")
}
