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
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a beta blocker, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
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
#' @export
is_beta_blocker <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for beta blockers
    startsWith(MEUCATC, "C07") & !(MEUCATC %in% c("C07AA07", "C07AA12", "C07AG02")) & NPI_25B <= 4 ~ 1,

    # Default to 0 (not a beta blocker)
    .default = 0
  )
}

#' @title ACE inhibitors
#' @description This function checks if a given medication is an ACE inhibitor.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an ACE inhibitor, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies ACE inhibitors based on ATC codes starting with "C09".
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
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
#' @export
is_ace_inhibitor <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for ACE inhibitors
    startsWith(MEUCATC, "C09") & NPI_25B <= 4 ~ 1,

    # Default to 0 (not an ACE inhibitor)
    .default = 0
  )
}

#' @title Diuretics
#' @description This function checks if a given medication is a diuretic.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diuretic, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies diuretics based on ATC codes starting with "C03", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
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
#' @export
is_diuretic <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for diuretics
    startsWith(MEUCATC, "C03") & !(MEUCATC %in% c("C03BA08", "C03CA01")) & NPI_25B <= 4 ~ 1,

    # Default to 0 (not a diuretic)
    .default = 0
  )
}

#' @title Calcium channel blockers
#' @description This function checks if a given medication is a calcium channel blocker.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a calcium channel blocker, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies calcium channel blockers based on ATC codes starting with "C08".
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
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
#' @export
is_calcium_channel_blocker <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for calcium channel blockers
    startsWith(MEUCATC, "C08") & NPI_25B <= 4 ~ 1,

    # Default to 0 (not a calcium channel blocker)
    .default = 0
  )
}

#' @title Other anti-hypertensive medications
#' @description This function checks if a given medication is another anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is another anti-hypertensive drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code.
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_other_antiHTN_med("C02AC04", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_other_antiHTN_med("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_other_antiHTN_med(c("C02AC04", "C02KX01"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' @export
is_other_antiHTN_med <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for other anti-hypertensive medications
    startsWith(MEUCATC, "C02") & !(MEUCATC %in% c("C02KX01")) & NPI_25B <= 4 ~ 1,

    # Default to 0 (not another anti-hypertensive medication)
    .default = 0
  )
}

#' @title Any anti-hypertensive medications
#' @description This function checks if a given medication is any anti-hypertensive drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an anti-hypertensive drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes.
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_any_antiHTN_med("C07AB02", 4)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_any_antiHTN_med("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_any_antiHTN_med(c("C07AB02", "C07AA07"), c(4, 2))
#' # Returns: c(1, 0)
#'
#' @export
is_any_antiHTN_med <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for any anti-hypertensive medications
    grepl("^(C02|C03|C07|C08|C09)", MEUCATC) & !(MEUCATC %in% c("C07AA07", "C07AA12", "C07AG02", "C03BA08", "C03CA01", "C02KX01")) & NPI_25B <= 4 ~ 1,

    # Default to 0 (not an anti-hypertensive medication)
    .default = 0
  )
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs)
#' @description This function checks if a given medication is an NSAID.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is an NSAID, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies NSAIDs based on ATC codes starting with "M01A".
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_NSAID("M01AB05", 1)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_NSAID("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_NSAID(c("M01AB05", "A10BB09"), c(1, 3))
#' # Returns: c(1, 0)
#'
#' @export
is_NSAID <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for NSAIDs
    startsWith(MEUCATC, "M01A") & NPI_25B <= 4 ~ 1,

    # Default to 0 (not an NSAID)
    .default = 0
  )
}

#' @title Diabetes medications
#' @description This function checks if a given medication is a diabetes drug.
#' This function processes multiple inputs efficiently.
#' @param MEUCATC [character] ATC code of the medication.
#' @param NPI_25B [integer] Time when the medication was last taken.
#' @return [numeric] 1 if medication is a diabetes drug, 0 otherwise. If inputs are invalid or out of bounds, the function returns a tagged NA.
#' @details Identifies diabetes drugs based on ATC codes starting with "A10".
#'
#'          **Missing Data Codes:**
#'          - `MEUCATC`: `9999996` (Not applicable), `9999997-9999999` (Missing)
#'          - `NPI_25B`: `6` (Not applicable), `7-9` (Missing)
#'
#' @examples
#' # Scalar usage: Single respondent
#' is_diabetes_drug("A10BB09", 3)
#' # Returns: 1
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- is_diabetes_drug("9999998", 8)
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' is_diabetes_drug(c("A10BB09", "C09AA02"), c(3, 2))
#' # Returns: c(1, 0)
#'
#' @export
is_diabetes_drug <- function(MEUCATC, NPI_25B) {
  dplyr::case_when(
    # Valid skip
    MEUCATC == 9999996 | NPI_25B == 6 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    MEUCATC %in% c(9999997, 9999998, 9999999) | NPI_25B %in% c(7, 8, 9) ~ haven::tagged_na("b"),

    # Check for diabetes drugs
    startsWith(MEUCATC, "A10") & NPI_25B <= 4 ~ 1,

    # Default to 0 (not a diabetes drug)
    .default = 0
  )
}

#' @title Beta blockers - cycles 1-2
#'
#' @description This function checks if a person is taking beta blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
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
cycles1to2_beta_blockers <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  bb_results_list <- mapply(is_beta_blocker, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  bb_matrix <- do.call(cbind, bb_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  bb_med <- as.numeric(rowSums(bb_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(bb_matrix), 1, all)
  bb_med[all_na_for_row] <- haven::tagged_na("b")

  return(bb_med)
}

#' @title ACE inhibitors - cycles 1-2
#'
#' @description This function checks if a person is taking ACE inhibitors based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
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
cycles1to2_ace_inhibitors <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  ace_results_list <- mapply(is_ace_inhibitor, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  ace_matrix <- do.call(cbind, ace_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  ace_med <- as.numeric(rowSums(ace_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(ace_matrix), 1, all)
  ace_med[all_na_for_row] <- haven::tagged_na("b")

  return(ace_med)
}

#' @title Diuretics - cycles 1-2
#'
#' @description This function checks if a person is taking diuretics based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
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
cycles1to2_diuretics <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  diuretic_results_list <- mapply(is_diuretic, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  diuretic_matrix <- do.call(cbind, diuretic_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  diuretic_med <- as.numeric(rowSums(diuretic_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(diuretic_matrix), 1, all)
  diuretic_med[all_na_for_row] <- haven::tagged_na("b")

  return(diuretic_med)
}

#' @title Calcium channel blockers - cycles 1-2
#'
#' @description This function checks if a person is taking calcium channel blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
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
cycles1to2_calcium_channel_blockers <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  ccb_results_list <- mapply(is_calcium_channel_blocker, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  ccb_matrix <- do.call(cbind, ccb_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  ccb_med <- as.numeric(rowSums(ccb_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(ccb_matrix), 1, all)
  ccb_med[all_na_for_row] <- haven::tagged_na("b")

  return(ccb_med)
}

#' @title Other anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking another type of anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
#'
#' @return [numeric] Returns 1 if the person is taking another type of anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_other_antiHTN_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_other_antiHTN_med` for usage examples.
#' @seealso `is_other_antiHTN_med`
#' @export
cycles1to2_other_antiHTN_meds <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  other_antihtn_results_list <- mapply(is_other_antiHTN_med, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  other_antihtn_matrix <- do.call(cbind, other_antihtn_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  other_antihtn_med <- as.numeric(rowSums(other_antihtn_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(other_antihtn_matrix), 1, all)
  other_antihtn_med[all_na_for_row] <- haven::tagged_na("b")

  return(other_antihtn_med)
}

#' @title Any anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking any anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
#'
#' @return [numeric] Returns 1 if the person is taking any anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_any_antiHTN_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_any_antiHTN_med` for usage examples.
#' @seealso `is_any_antiHTN_med`
#' @export
cycles1to2_any_antiHTN_meds <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  any_antihtn_results_list <- mapply(is_any_antiHTN_med, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  any_antihtn_matrix <- do.call(cbind, any_antihtn_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  any_antihtn_med <- as.numeric(rowSums(any_antihtn_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(any_antihtn_matrix), 1, all)
  any_antihtn_med[all_na_for_row] <- haven::tagged_na("b")

  return(any_antihtn_med)
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs) - cycles 1-2
#'
#' @description This function checks if a person is taking any NSAIDs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
#'
#' @return [numeric] Returns 1 if the person is taking any NSAIDs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies NSAIDs based on ATC codes starting with "M01A". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_NSAID` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_NSAID` for usage examples.
#' @seealso `is_NSAID`
#' @export
cycles1to2_nsaid <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  nsaid_results_list <- mapply(is_NSAID, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  nsaid_matrix <- do.call(cbind, nsaid_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  nsaid_med <- as.numeric(rowSums(nsaid_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(nsaid_matrix), 1, all)
  nsaid_med[all_na_for_row] <- haven::tagged_na("b")

  return(nsaid_med)
}

#' @title Diabetes medications - cycles 1-2
#'
#' @description This function checks if a person is taking diabetes drugs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param ... Medication and last taken variables.
#'
#' @return [numeric] Returns 1 if the person is taking any diabetes drugs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies diabetes drugs based on ATC codes starting with "A10". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_diabetes_drug` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_diabetes_drug` for usage examples.
#' @seealso `is_diabetes_drug`
#' @export
cycles1to2_diabetes_drugs <- function(...) {
  # Collect all arguments
  args <- list(...)

  # Separate atc and mhr arguments
  atc_args <- args[grep("^atc", names(args))]
  mhr_args <- args[grep("^mhr", names(args))]

  # Determine the maximum length of the input vectors
  max_len <- max(sapply(c(atc_args, mhr_args), length))

  # If max_len is 0 (all inputs are NULL), return tagged NA
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  # Pad shorter vectors with NA to match the longest vector length
  atc_padded <- lapply(atc_args, function(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len))
  mhr_padded <- lapply(mhr_args, function(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len))

  # Apply the condition function to each pair of med and last_taken vars
  diabetes_results_list <- mapply(is_diabetes_drug, atc_padded, mhr_padded, SIMPLIFY = FALSE)

  # Combine the results into a matrix
  diabetes_matrix <- do.call(cbind, diabetes_results_list)

  # For each row (respondent), check if any of the results are 1 (taking the drug)
  diabetes_med <- as.numeric(rowSums(diabetes_matrix == 1, na.rm = TRUE) > 0)

  # Handle cases where all medication information for a respondent is missing
  all_na_for_row <- apply(is.na(diabetes_matrix), 1, all)
  diabetes_med[all_na_for_row] <- haven::tagged_na("b")

  return(diabetes_med)
}
