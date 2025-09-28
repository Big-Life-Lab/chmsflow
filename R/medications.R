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
#'          The function performs logging to provide information about the process and potential issues.
#'          If 'overwrite' is TRUE, the function will overwrite the existing 'class_var_name' column in the data frame.
#'          If 'overwrite' is FALSE and the variable already exists, the function will log an error and stop the execution.
#'          The function also checks if 'med_vars' and 'last_taken_vars' are present in the data frame and have the same length.
#'          If any issues are encountered, appropriate log messages are generated, and the function stops.
#'
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
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a beta blocker, 0 otherwise.
#' @details Identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes.
#' @examples
#' # Scalar usage: Single respondent
#' is_beta_blocker("C07AA13", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_beta_blocker("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_beta_blocker(c("C07AA13", "C07AA07"), c(3, 4))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C07AA13", "C07AA07", "C01AA05"),
#'   NPI_25B = c(3, 4, 2)
#' )
#' survey_data %>%
#'   mutate(is_bb = is_beta_blocker(MEUCATC, NPI_25B)) %>%
#'   select(is_bb)
#' @export
is_beta_blocker <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "C07") & !(MEUCATC %in% c("C07AA07", "C07AA12", "C07AG02")) & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title ACE inhibitors
#' @description This function checks if a given medication is an ACE inhibitor.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an ACE inhibitor, 0 otherwise.
#' @details Identifies ACE inhibitors based on ATC codes starting with "C09".
#' @examples
#' # Scalar usage: Single respondent
#' is_ace_inhibitor("C09AB03", 2)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_ace_inhibitor("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_ace_inhibitor(c("C09AB03", "C01AA05"), c(2, 1))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C09AB03", "C01AA05", "C09AA02"),
#'   NPI_25B = c(2, 1, 3)
#' )
#' survey_data %>%
#'   mutate(is_ace = is_ace_inhibitor(MEUCATC, NPI_25B)) %>%
#'   select(is_ace)
#' @export
is_ace_inhibitor <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "C09") & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Diuretics
#' @description This function checks if a given medication is a diuretic.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diuretic, 0 otherwise.
#' @details Identifies diuretics based on ATC codes starting with "C03", excluding specific sub-codes.
#' @examples
#' # Scalar usage: Single respondent
#' is_diuretic("C03AA03", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_diuretic("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_diuretic(c("C03AA03", "C03BA08"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C03AA03", "C03BA08", "C01AA05"),
#'   NPI_25B = c(3, 2, 1)
#' )
#' survey_data %>%
#'   mutate(is_diuretic = is_diuretic(MEUCATC, NPI_25B)) %>%
#'   select(is_diuretic)
#' @export
is_diuretic <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "C03") & !(MEUCATC %in% c("C03BA08", "C03CA01")) & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Calcium channel blockers
#' @description This function checks if a given medication is a calcium channel blocker.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a calcium channel blocker, 0 otherwise.
#' @details Identifies calcium channel blockers based on ATC codes starting with "C08".
#' @examples
#' # Scalar usage: Single respondent
#' is_calcium_channel_blocker("C08CA05", 1)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_calcium_channel_blocker("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_calcium_channel_blocker(c("C08CA05", "C01AA05"), c(1, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C08CA05", "C01AA05", "C08DB01"),
#'   NPI_25B = c(1, 2, 4)
#' )
#' survey_data %>%
#'   mutate(is_ccb = is_calcium_channel_blocker(MEUCATC, NPI_25B)) %>%
#'   select(is_ccb)
#' @export
is_calcium_channel_blocker <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "C08") & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Other anti-hypertensive medications
#' @description This function checks if a given medication is another anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is another anti-hypertensive drug, 0 otherwise.
#' @details Identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code.
#' @examples
#' # Scalar usage: Single respondent
#' is_other_antiHTN_med("C02AC04", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_other_antiHTN_med("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_other_antiHTN_med(c("C02AC04", "C02KX01"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C02AC04", "C02KX01", "C02AB01"),
#'   NPI_25B = c(3, 2, 1)
#' )
#' survey_data %>%
#'   mutate(is_other_antihtn = is_other_antiHTN_med(MEUCATC, NPI_25B)) %>%
#'   select(is_other_antihtn)
#' @export
is_other_antiHTN_med <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "C02") & !(MEUCATC %in% c("C02KX01")) & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Any anti-hypertensive medications
#' @description This function checks if a given medication is any anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an anti-hypertensive drug, 0 otherwise.
#' @details Identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes.
#' @examples
#' # Scalar usage: Single respondent
#' is_any_antiHTN_med("C07AB02", 4)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_any_antiHTN_med("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_any_antiHTN_med(c("C07AB02", "C07AA07"), c(4, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("C07AB02", "C07AA07", "C09AA02"),
#'   NPI_25B = c(4, 2, 3)
#' )
#' survey_data %>%
#'   mutate(is_any_antihtn = is_any_antiHTN_med(MEUCATC, NPI_25B)) %>%
#'   select(is_any_antihtn)
#' @export
is_any_antiHTN_med <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    grepl("^(C02|C03|C07|C08|C09)", MEUCATC) & !(MEUCATC %in% c("C07AA07", "C07AA12", "C07AG02", "C03BA08", "C03CA01", "C02KX01")) & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs)
#' @description This function checks if a given medication is an NSAID.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an NSAID, 0 otherwise.
#' @details Identifies NSAIDs based on ATC codes starting with "M01A".
#' @examples
#' # Scalar usage: Single respondent
#' is_NSAID("M01AB05", 1)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_NSAID("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_NSAID(c("M01AB05", "A10BB09"), c(1, 3))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("M01AB05", "A10BB09", "M01AE01"),
#'   NPI_25B = c(1, 3, 2)
#' )
#' survey_data %>%
#'   mutate(is_nsaid = is_NSAID(MEUCATC, NPI_25B)) %>%
#'   select(is_nsaid)
#' @export
is_NSAID <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "M01A") & NPI_25B <= 4 ~ 1,
    .default = 0
  )
}

#' @title Diabetes medications
#' @description This function checks if a given medication is a diabetes drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diabetes drug, 0 otherwise.
#' @details Identifies diabetes drugs based on ATC codes starting with "A10".
#' @examples
#' # Scalar usage: Single respondent
#' is_diabetes_drug("A10BB09", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' is_diabetes_drug("9999998", 8)
#' # Returns: NA
#'
#' # Multiple respondents
#' is_diabetes_drug(c("A10BB09", "C09AA02"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   MEUCATC = c("A10BB09", "C09AA02", "A10BA02"),
#'   NPI_25B = c(3, 2, 1)
#' )
#' survey_data %>%
#'   mutate(is_diabetes = is_diabetes_drug(MEUCATC, NPI_25B)) %>%
#'   select(is_diabetes)
#' @export
is_diabetes_drug <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),
    startsWith(MEUCATC, "A10") & NPI_25B <= 4 ~ 1,
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
#'
#' @details The function identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_beta_blockers(atc_101a = "C07AA13", mhr_101b = 3)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_beta_blockers(
#'   atc_101a = c("C07AA13", "C01AA05", "C07AB02"),
#'   mhr_101b = c(3, 1, 4)
#' )
#' # Returns: c(1, 0, 1)
#'
#' @seealso `is_beta_blocker`
#'
#' @export
cycles1to2_beta_blockers <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  bb_results_list <- mapply(is_beta_blocker, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  bb_matrix <- do.call(cbind, bb_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  bb_med <- as.numeric(rowSums(bb_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(bb_matrix), 1, all)
  bb_med[all_na_for_row] <- haven::tagged_na("b")

  return(bb_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_ace_inhibitors(atc_101a = "C09AA02", mhr_101b = 3)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_ace_inhibitors(
#'   atc_101a = c("C09AA02", "C01AA05", "C09AB03"),
#'   mhr_101b = c(3, 1, 2)
#' )
#' # Returns: c(1, 0, 1)
#'
#' # Database usage: Apply to survey data
#' #' @seealso `is_ace_inhibitor`
#'
#' @export
cycles1to2_ace_inhibitors <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  ace_results_list <- mapply(is_ace_inhibitor, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  ace_matrix <- do.call(cbind, ace_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  ace_med <- as.numeric(rowSums(ace_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(ace_matrix), 1, all)
  ace_med[all_na_for_row] <- haven::tagged_na("b")

  return(ace_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_diuretics(atc_101a = "C03AA03", mhr_101b = 3)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_diuretics(
#'   atc_101a = c("C03AA03", "C03BA08", "C01AA05"),
#'   mhr_101b = c(3, 2, 1)
#' )
#' # Returns: c(1, 0, 0)
#'
#' @seealso `is_diuretic`
#'
#' @export
cycles1to2_diuretics <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  diuretic_results_list <- mapply(is_diuretic, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  diuretic_matrix <- do.call(cbind, diuretic_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  diuretic_med <- as.numeric(rowSums(diuretic_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(diuretic_matrix), 1, all)
  diuretic_med[all_na_for_row] <- haven::tagged_na("b")

  return(diuretic_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_calcium_channel_blockers(atc_101a = "C08CA05", mhr_101b = 1)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_calcium_channel_blockers(
#'   atc_101a = c("C08CA05", "C01AA05", "C08DB01"),
#'   mhr_101b = c(1, 2, 4)
#' )
#' # Returns: c(1, 0, 1)
#'
#' @seealso `is_calcium_channel_blocker`
#'
#' @export
cycles1to2_calcium_channel_blockers <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  ccb_results_list <- mapply(is_calcium_channel_blocker, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  ccb_matrix <- do.call(cbind, ccb_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  ccb_med <- as.numeric(rowSums(ccb_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(ccb_matrix), 1, all)
  ccb_med[all_na_for_row] <- haven::tagged_na("b")

  return(ccb_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_other_antiHTN_meds(atc_101a = "C02AC04", mhr_101b = 3)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_other_antiHTN_meds(
#'   atc_101a = c("C02AC04", "C02KX01", "C02AB01"),
#'   mhr_101b = c(3, 2, 1)
#' )
#' # Returns: c(1, 0, 1)
#'
#' @seealso `is_other_antiHTN_med`
#'
#' @export
cycles1to2_other_antiHTN_meds <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  other_antihtn_results_list <- mapply(is_other_antiHTN_med, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  other_antihtn_matrix <- do.call(cbind, other_antihtn_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  other_antihtn_med <- as.numeric(rowSums(other_antihtn_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(other_antihtn_matrix), 1, all)
  other_antihtn_med[all_na_for_row] <- haven::tagged_na("b")

  return(other_antihtn_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_any_antiHTN_meds(atc_101a = "C07AB02", mhr_101b = 4)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_any_antiHTN_meds(
#'   atc_101a = c("C07AB02", "C07AA07", "C09AA02"),
#'   mhr_101b = c(4, 2, 3)
#' )
#' # Returns: c(1, 0, 1)
#'
#' # Database usage: Apply to survey data
#' library(dplyr)
#' survey_data <- data.frame(
#'   atc_101a = c("C07AB02", "C07AA07", "C09AA02"),
#'   mhr_101b = c(4, 2, 3),
#'   atc_102a = c("C08CA05", as.character(NA), "C02AB01"),
#'   mhr_102b = c(1, as.numeric(NA), 1)
#' )
#' survey_data %>%
#'   mutate(
#'     is_taking_any_antihtn =
#'       cycles1to2_any_antiHTN_meds(atc_101a, atc_102a, mhr_101b, mhr_102b)
#'   ) %>%
#'   select(is_taking_any_antihtn)
#'
#' @seealso `is_any_antiHTN_med`
#'
#' @export
cycles1to2_any_antiHTN_meds <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  any_antihtn_results_list <- mapply(is_any_antiHTN_med, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  any_antihtn_matrix <- do.call(cbind, any_antihtn_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  any_antihtn_med <- as.numeric(rowSums(any_antihtn_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(any_antihtn_matrix), 1, all)
  any_antihtn_med[all_na_for_row] <- haven::tagged_na("b")

  return(any_antihtn_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_nsaid(atc_101a = "M01AB05", mhr_101b = 1)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_nsaid(
#'   atc_101a = c("M01AB05", "A10BB09", "M01AE01"),
#'   mhr_101b = c(1, 3, 2)
#' )
#' # Returns: c(1, 0, 1)
#'
#' @seealso `is_NSAID`
#'
#' @export
cycles1to2_nsaid <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  nsaid_results_list <- mapply(is_NSAID, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  nsaid_matrix <- do.call(cbind, nsaid_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  nsaid_med <- as.numeric(rowSums(nsaid_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(nsaid_matrix), 1, all)
  nsaid_med[all_na_for_row] <- haven::tagged_na("b")

  return(nsaid_med)
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
#' @examples
#' # Scalar usage: Single respondent
#' cycles1to2_diabetes_drugs(atc_101a = "A10BB09", mhr_101b = 3)
#' # Returns: 1
#'
#' # Multiple respondents
#' cycles1to2_diabetes_drugs(
#'   atc_101a = c("A10BB09", "C09AA02", "A10BA02"),
#'   mhr_101b = c(3, 2, 1)
#' )
#' # Returns: c(1, 0, 1)
#'
#' @seealso `is_diabetes_drug`
#'
#' @export
cycles1to2_diabetes_drugs <- function(
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
    mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL) {
  # Collect all atc and mhr arguments into lists, handling NULLs
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
  max_len <- max(sapply(c(atc_args, mhr_args), length))

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
  # This will return a vector of results for each pair
  diabetes_results_list <- mapply(is_diabetes_drug, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix/data.frame where each column is a result from a med/last_taken pair
  diabetes_matrix <- do.call(cbind, diabetes_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  diabetes_med <- as.numeric(rowSums(diabetes_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  # A respondent is considered to have all missing info if all their atc/mhr pairs are NA
  all_na_for_row <- apply(is.na(diabetes_matrix), 1, all)
  diabetes_med[all_na_for_row] <- haven::tagged_na("b")

  return(diabetes_med)
}
