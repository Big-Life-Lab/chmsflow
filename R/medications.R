#' @title Number of occurrences of a specific drug class based on given conditions
#'
#' @description This function calculates the number of occurrences of a specific drug class in a data frame.
#' The calculation is based on custom conditions specified by the user.
#'
#' @param df [data.frame] The data frame containing medication and last taken information.
#' @param class_var_name [character] The name of the new variable representing the drug class.
#' @param med_vars [character] A character vector containing the names of medication variables in the data frame.
#' @param last_taken_vars [character] A character vector containing the names of last taken variables in the data frame.
#' @param class_condition_fun [function] A custom condition function that determines whether a medication belongs to the drug class.
#'                            The function should accept two arguments: med_code (character) and last_taken (numeric).
#'                            It should return an integer, 1 if the medication belongs to the class, 0 otherwise.
#' @param log_level [character] The log level for logging messages (default is "INFO").
#' @param overwrite [logical] Logical value indicating whether to overwrite the 'class_var_name' if it already exists in the data frame (default is FALSE).
#'
#' @return [data.frame] The input data frame 'df' with an additional column representing the drug class.
#'
#' @details The 'class_condition_fun' is applied to each pair of medication and last taken variables.
#'          The resulting values (0 or 1) are summed for each row, and the sum is stored in the new 'class_var_name' column.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `class_condition_fun` and propagates them.
#'
#' @examples
#' # This is a generalized function and requires a user-defined condition function.
#' # See specific implementations like `is_beta_blocker` for concrete examples.
#' @export
is_taking_drug_class <- function(df, class_var_name, med_vars, last_taken_vars, class_condition_fun, log_level = "INFO", overwrite = FALSE) {
  # Validate input parameters
  if (!is.character(class_var_name) || class_var_name == "") {
    logger::log_fatal("The 'class_var_name' must be a non-empty character string.")
    stop()
  }

  if (!is.logical(overwrite)) {
    logger::log_fatal("'overwrite' must be a logical value (TRUE or FALSE).")
    stop()
  }

  if (!all(med_vars %in% names(df))) {
    missing_vars <- med_vars[!(med_vars %in% names(df))]
    error_msg <- paste0("The following medication variables are not in the data frame: ", paste(missing_vars, collapse = ", "))
    logger::log_error(error_msg)
    stop()
  }

  if (!all(last_taken_vars %in% names(df))) {
    missing_vars <- last_taken_vars[!(last_taken_vars %in% names(df))]
    error_msg <- paste0("The following 'last_taken' variables are not in the data frame: ", paste(missing_vars, collapse = ", "))
    logger::log_error(error_msg)
    stop()
  }

  if (length(med_vars) != length(last_taken_vars)) {
    error_msg <- "The lists of medication variables and 'last_taken' variables are not of the same length."
    logger::log_warn(error_msg)
    stop()
  }

  # Set the log level
  logger::log_threshold(log_level)

  # Check if class_var_name already exists in the data frame
  if (class_var_name %in% names(df)) {
    error_msg <- paste0("Variable '", class_var_name, "' already exists in the data frame.")
    if (overwrite) {
      logger::log_warn(paste0(error_msg, " The variable will be overwritten."))
    } else {
      logger::log_fatal(paste0(error_msg, " Use a new variable name or change 'overwrite=TRUE'."))
      stop()
    }
  }

  logger::log_info(paste0("Adding variable '", class_var_name, "' to the data frame."))

  # Create a list of data frames, one for each pair of med and last_taken vars
  class_values_list <- mapply(
    FUN = function(med_var, last_taken_var) {
      class_condition_fun(df[[med_var]], df[[last_taken_var]])
    },
    med_vars,
    last_taken_vars,
    SIMPLIFY = FALSE
  )

  # Sum the results for each row
  class_values <- do.call(cbind, class_values_list)
  df[[class_var_name]] <- rowSums(class_values, na.rm = TRUE)

  # Handle cases where all values for a row are NA
  all_na <- Reduce(`&`, lapply(class_values_list, is.na))
  df[[class_var_name]][all_na] <- haven::tagged_na("b")

  return(df)
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for beta blockers
    startsWith(meucatc, "C07") & !(meucatc %in% c("C07AA07", "C07AA12", "C07AG02")) & npi_25b <= 4 ~ 1,

    # Default to 0 (not a beta blocker)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for ACE inhibitors
    startsWith(meucatc, "C09") & npi_25b <= 4 ~ 1,

    # Default to 0 (not an ACE inhibitor)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for diuretics
    startsWith(meucatc, "C03") & !(meucatc %in% c("C03BA08", "C03CA01")) & npi_25b <= 4 ~ 1,

    # Default to 0 (not a diuretic)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for calcium channel blockers
    startsWith(meucatc, "C08") & npi_25b <= 4 ~ 1,

    # Default to 0 (not a calcium channel blocker)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for other anti-hypertensive medications
    startsWith(meucatc, "C02") & !(meucatc %in% c("C02KX01")) & npi_25b <= 4 ~ 1,

    # Default to 0 (not another anti-hypertensive medication)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for any anti-hypertensive medications
    grepl("^(C02|C03|C07|C08|C09)", meucatc) & !(meucatc %in% c("C07AA07", "C07AA12", "C07AG02", "C03BA08", "C03CA01", "C02KX01")) & npi_25b <= 4 ~ 1,

    # Default to 0 (not an anti-hypertensive medication)
    .default = 0
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for NSAIDs
    startsWith(meucatc, "M01A") & npi_25b <= 4 ~ 1,

    # Default to 0 (not an NSAID)
    .default = 0
  )
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
  dplyr::case_when(
    # Valid skip
    meucatc == 9999996 | npi_25b == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    meucatc %in% c(9999997, 9999998, 9999999) | npi_25b %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for diabetes drugs
    startsWith(meucatc, "A10") & npi_25b <= 4 ~ 1,

    # Default to 0 (not a diabetes drug)
    .default = 0
  )
}

#' @title Beta blockers - cycles 1-2
#'
#' @description This function checks if a person is taking beta blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the respondent is taking beta blockers, 0 otherwise. If all medication information is missing, returns a tagged NA.
#'
#' @details The function identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_beta_blocker` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_beta_blocker` for usage examples.
#' @seealso `is_beta_blocker`
#' @export
is_bb_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_beta_blocker, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title ACE inhibitors - cycles 1-2
#'
#' @description This function checks if a person is taking ACE inhibitors based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking ACE inhibitors, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies ACE inhibitors based on ATC codes starting with "C09". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_ace_inhibitor` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_ace_inhibitor` for usage examples.
#' @seealso `is_ace_inhibitor`
#' @export
is_ace_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_ace_inhibitor, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Diuretics - cycles 1-2
#'
#' @description This function checks if a person is taking diuretics based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking diuretics, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies diuretics based on ATC codes starting with "C03", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_diuretic` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_diuretic` for usage examples.
#' @seealso `is_diuretic`
#' @export
is_diur_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_diuretic, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Calcium channel blockers - cycles 1-2
#'
#' @description This function checks if a person is taking calcium channel blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking calcium channel blockers, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies calcium channel blockers based on ATC codes starting with "C08". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_calcium_channel_blocker` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_calcium_channel_blocker` for usage examples.
#' @seealso `is_calcium_channel_blocker`
#' @export
is_ccb_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_calcium_channel_blocker, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Other anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking another type of anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking another type of anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_other_antihtn_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_other_antihtn_med` for usage examples.
#' @seealso `is_other_antihtn_med`
#' @export
is_misc_htn_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_other_antihtn_med, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Any anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking any anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking any anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_any_antihtn_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_any_antihtn_med` for usage examples.
#' @seealso `is_any_antihtn_med`
#' @export
is_any_htn_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_any_antihtn_med, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs) - cycles 1-2
#'
#' @description This function checks if a person is taking any NSAIDs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking any NSAIDs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies NSAIDs based on ATC codes starting with "M01A". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_nsaid` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_nsaid` for usage examples.
#' @seealso `is_nsaid`
#' @export
is_nsaid_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_nsaid, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' @title Diabetes medications - cycles 1-2
#'
#' @description This function checks if a person is taking diabetes drugs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1–6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1–6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1–6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1–6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1–6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1–6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1–6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1–6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1–6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1–6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1–6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1–6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1–6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1–6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1–6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1–6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1–6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1–6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1–6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1–6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1–6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1–6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1–6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1–6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1–6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1–6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1–6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1–6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1–6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1–6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1–6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1–6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1–6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1–6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1–6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1–6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1–6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1–6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1–6).
#'
#' @return [numeric] Returns 1 if the person is taking any diabetes drugs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies diabetes drugs based on ATC codes starting with "A10". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_diabetes_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_diabetes_med` for usage examples.
#' @seealso `is_diabetes_med`
#' @export
is_diab_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  # Collect all arguments
  atc_args <- list(
    atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
    atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
    atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
    atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
    atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
    atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
    atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
    atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
  )

  mhr_args <- list(
    mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
    mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
    mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
    mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
    mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
    mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
    mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
    mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
  )

  # Determine the maximum length of the input vectors
  max_len <- max(unlist(sapply(c(atc_args, mhr_args), length)), 0)

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Combine into a temporary data frame
  drugs_df <- data.frame(
    atc_code = unlist(atc_padded),
    last_taken = unlist(mhr_padded)
  )

  # Apply the condition function to each pair of med and last_taken vars
  results_list <- mapply(is_diabetes_med, drugs_df$atc_code, drugs_df$last_taken, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  results_matrix <- do.call(cbind, results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  has_one <- rowSums(results_matrix == 1, na.rm = TRUE) > 0
  # Check if any result is 0 (explicit non-match with valid data)
  has_zero <- rowSums(results_matrix == 0, na.rm = TRUE) > 0
  # Only consider tagged NAs when there are no valid results (0 or 1)
  has_na_a <- apply(results_matrix, 1, function(row) all(is.na(row)) & any(haven::is_tagged_na(row, "a")))
  has_na_b <- apply(results_matrix, 1, function(row) all(is.na(row)) & (any(haven::is_tagged_na(row, "b")) | any(is.na(row) & !haven::is_tagged_na(row))))

  # If any result is 1, return 1; if any result is 0, return 0; if all NA "a", return NA "a"; if all NA "b", return NA "b"
  med_vector <- dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )

  return(med_vector)
}

#' Convert a recoded factor or character to numeric while preserving tagged NAs
#'
#' Internal helper used by [recode_meds_cycles1to2()] and [aggregate_meds_by_person()].
#' `as.numeric(as.character(.x))` strips `haven::tagged_na()` information, collapsing
#' valid skips (`NA::a`) and missing/refused (`NA::b`) into plain `NA_real_`. This
#' helper restores those tags so downstream consumers (e.g. `derive_hypertension()`
#' checking `is_tagged_na(any_htn_med, "b")`) behave correctly.
#'
#' @param x A factor, character, or numeric vector. Tagged-NA inputs are preserved.
#' @return Numeric vector with `tagged_na("a")` / `tagged_na("b")` restored where present.
#' @noRd
factor_to_tagged_numeric <- function(x) {
  was_a <- if (is.numeric(x)) haven::is_tagged_na(x, "a") else rep(FALSE, length(x))
  was_b <- if (is.numeric(x)) haven::is_tagged_na(x, "b") else rep(FALSE, length(x))

  s <- as.character(x)
  out <- suppressWarnings(as.numeric(s))

  not_na_s <- !is.na(s)
  out[not_na_s & s == "NA::a"] <- haven::tagged_na("a")
  out[not_na_s & s == "NA::b"] <- haven::tagged_na("b")

  out[was_a] <- haven::tagged_na("a")
  out[was_b] <- haven::tagged_na("b")

  out
}

#' @title Recode medication variables for cycles 1-2 (wide format)
#'
#' @description Recodes medication variables from cycles 1-2 wide-format data (one row per
#' respondent, up to 80 ATC/MHR columns), and merges into the main cycle dataset. Wraps
#' `recodeflow::rec_with_table()` and converts factor outputs to numeric.
#'
#' @param data [data.frame] Main cycle data to merge medication variables into.
#' @param meds_data [data.frame] Wide-format medication data (cycles 1-2). Must contain
#'   `clinicid`, `atc_101a` through `atc_235a`, and `mhr_101b` through `mhr_235b` as columns.
#' @param variables [character] Medication variable names to derive (e.g., `"any_htn_med"`).
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param meds_database_name [character] Name of the meds database in `variable_details`.
#'   Defaults to the name of the `meds_data` argument. Override when passing a transformed
#'   object (e.g., `head()`).
#' @param variable_details [data.frame] Variable details table. Defaults to `chmsflow::variable_details`.
#'
#' @return [data.frame] `data` with derived medication variables merged in as numeric columns.
#'
#' @examples
#' # cycle1 <- recode_meds_cycles1to2(
#' #   cycle1,
#' #   cycle1_meds,
#' #   c("any_htn_med", "diab_med")
#' # )
#'
#' @seealso [recode_meds_cycles3to6()], [aggregate_meds_by_person()]
#' @export
recode_meds_cycles1to2 <- function(data, meds_data, variables, by = "clinicid",
                                   meds_database_name = NULL,
                                   variable_details = chmsflow::variable_details) {
  if (is.null(meds_database_name)) meds_database_name <- deparse(substitute(meds_data))
  names(meds_data) <- tolower(names(meds_data))
  atc_mhr_cols <- c(
    paste0("atc_", c(101:115, 131:135, 201:215, 231:235), "a"),
    paste0("mhr_", c(101:115, 131:135, 201:215, 231:235), "b")
  )
  meds_recoded <- recodeflow::rec_with_table(
    meds_data,
    c(by, atc_mhr_cols, variables),
    database_name = meds_database_name,
    variable_details = variable_details
  ) |>
    dplyr::select(dplyr::all_of(c(by, variables))) |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(variables),
      ~ factor_to_tagged_numeric(.x)
    ))
  dplyr::left_join(data, meds_recoded, by = by)
}

#' @title Aggregate medication variables to one row per person
#'
#' @description Collapses long-format medication data (cycles 3-6) to one row per respondent
#' by taking the maximum value of each medication variable across all rows. A result of 1
#' (taking the medication) takes precedence over 0. Tagged NAs are propagated only when
#' all rows for a respondent are missing.
#'
#' @param data [data.frame] Long-format medication data with multiple rows per respondent.
#' @param variables [character] Variable names to aggregate.
#' @param by [character] The respondent identifier column. Default is `"clinicid"`.
#'
#' @return [data.frame] One row per respondent with aggregated medication variables as numeric.
#'
#' @examples
#' # This function is typically called via recode_meds_cycles3to6()
#' # See that function for usage examples.
#'
#' @seealso [recode_meds_cycles3to6()], [recode_meds_cycles1to2()]
#' @export
aggregate_meds_by_person <- function(data, variables, by = "clinicid") {
  data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::summarize(dplyr::across(
      dplyr::all_of(variables),
      ~ {
        vals <- factor_to_tagged_numeric(.x)
        if (all(haven::is_tagged_na(vals, "a"))) {
          haven::tagged_na("a")
        } else if (all(is.na(vals))) {
          haven::tagged_na("b")
        } else {
          max(vals, na.rm = TRUE)
        }
      }
    ))
}

#' @title Recode medication variables for cycles 3-6 (long format)
#'
#' @description Recodes medication variables from cycles 3-6 long-format data (one row per
#' medication per respondent), aggregates to one row per respondent, and merges into the
#' main cycle dataset. Wraps `recodeflow::rec_with_table()` and [aggregate_meds_by_person()].
#'
#' @param data [data.frame] Main cycle data to merge medication variables into.
#' @param meds_data [data.frame] Long-format medication data (cycles 3-6) with columns
#'   `clinicid`, `meucatc`, and `npi_25b`.
#' @param variables [character] Medication variable names to derive (e.g., `"any_htn_med"`).
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param meds_database_name [character] Name of the meds database in `variable_details`.
#'   Defaults to the name of the `meds_data` argument. Override when passing a transformed
#'   object (e.g., `head()`).
#' @param variable_details [data.frame] Variable details table. Defaults to `chmsflow::variable_details`.
#'
#' @return [data.frame] `data` with derived medication variables merged in as numeric columns.
#'
#' @examples
#' # cycle3 <- recode_meds_cycles3to6(
#' #   cycle3,
#' #   cycle3_meds,
#' #   c("any_htn_med", "diab_med")
#' # )
#'
#' @seealso [recode_meds_cycles1to2()], [aggregate_meds_by_person()]
#' @export
recode_meds_cycles3to6 <- function(data, meds_data, variables, by = "clinicid",
                                   meds_database_name = NULL,
                                   variable_details = chmsflow::variable_details) {
  if (is.null(meds_database_name)) meds_database_name <- deparse(substitute(meds_data))
  meds_recoded <- recodeflow::rec_with_table(
    meds_data,
    c(by, "meucatc", "npi_25b", variables),
    database_name = meds_database_name,
    variable_details = variable_details
  ) |>
    aggregate_meds_by_person(variables = variables, by = by)
  dplyr::left_join(data, meds_recoded, by = by)
}

#' @title Recode variables that depend on derived medication variable inputs
#'
#' @description Wraps `recodeflow::rec_with_table()` for use after derived medication
#' variables (e.g., `any_htn_med`, `diab_med`) have been recoded and merged into
#' the main cycle dataset. Automatically excludes medication-specific rows from
#' `variable_details` so that `rec_with_table()` does not attempt to re-derive
#' medication variables from raw ATC/MHR columns.
#'
#' Use this instead of `rec_with_table()` when deriving variables whose inputs
#' include derived medication variables.
#'
#' @param data [data.frame] Main cycle data with derived medication variables already merged.
#' @param variables [character] Variable names to recode.
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param database_name [character] Name of the database in `variable_details`.
#'   Defaults to the name of the `data` argument.
#' @param variable_details [data.frame] Variable details table. Defaults to
#'   `chmsflow::variable_details`.
#'
#' @return [data.frame] Recoded data frame returned by `recodeflow::rec_with_table()`.
#'
#' @examples
#' # cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
#' # cycle3_diab <- recode_after_meds(
#' #   cycle3,
#' #   c("lab_hba1", "diab_a1c", "diab_med", "ccc_51", "diab_status")
#' # )
#'
#' @seealso [recode_meds_cycles3to6()], [recode_meds_cycles1to2()]
#' @export
recode_after_meds <- function(data, variables, by = "clinicid",
                              database_name = NULL,
                              variable_details = chmsflow::variable_details) {
  if (is.null(database_name)) database_name <- deparse(substitute(data))
  variable_details <- variable_details[!grepl("_meds", variable_details$databaseStart), ]
  recoded <- recodeflow::rec_with_table(
    data,
    variables,
    database_name = database_name,
    variable_details = variable_details
  )
  stopifnot(
    "rec_with_table() returned a different number of rows than `data`; row alignment cannot be trusted" =
      nrow(recoded) == nrow(data)
  )
  if (!(by %in% names(recoded))) {
    recoded <- dplyr::bind_cols(data[, by, drop = FALSE], recoded)
  }
  recoded
}
