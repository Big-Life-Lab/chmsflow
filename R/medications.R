## @file
# Load packages
library(logger)
library(purrr)

## @brief Calculate the number of occurrences of a specific drug class based on given conditions.
# 
# This function calculates the number of occurrences of a specific drug class in the data frame.
# The calculation is based on custom conditions specified by the user.
# 
# @param df The data frame containing medication and last taken information.
# @param class_var_name The name of the new variable representing the drug class.
# @param med_vars A character vector containing the names of medication variables in the data frame.
# @param last_taken_vars A character vector containing the names of last taken variables in the data frame.
# @param class_condition_fun A custom condition function that determines whether a medication belongs to the drug class.
#                            The function should accept two arguments: med_code (character) and last_taken (numeric).
#                            It should return an integer, 1 if the medication belongs to the class, 0 otherwise.
# @param log_level The log level for logging messages (default is "INFO").
# @param overwrite Logical value indicating whether to overwrite the 'class_var_name' if it already exists in the data frame (default is FALSE).
# 
# @return The input data frame 'df' with an additional column representing the drug class.
# 
# @details The 'class_condition_fun' is applied to each pair of medication and last taken variables.
#          The resulting values (0 or 1) are summed for each row, and the sum is stored in the new 'class_var_name' column.
#          The function performs logging to provide information about the process and potential issues.
#          If 'overwrite' is TRUE, the function will overwrite the existing 'class_var_name' column in the data frame.
#          If 'overwrite' is FALSE and the variable already exists, the function will log an error and stop the execution.
#          The function also checks if 'med_vars' and 'last_taken_vars' are present in the data frame and have the same length.
#          If any issues are encountered, appropriate log messages are generated, and the function stops.
is_taking_drug_class <- function(df, class_var_name, med_vars, last_taken_vars, class_condition_fun, log_level = "INFO", overwrite = FALSE) {
  # Validate input parameters
  if (!is.character(class_var_name) || class_var_name == "") {
    log_fatal("The 'class_var_name' must be a non-empty character string.")
    stop()
  }
  
  if (!is.logical(overwrite)) {
    log_fatal("'overwrite' must be a logical value (TRUE or FALSE).")
    stop()
  }
  
  if (!all(med_vars %in% names(df))) {
    missing_vars <- med_vars[!(med_vars %in% names(df))]
    error_msg <- paste0("The following medication variables are not in the data frame: ", paste(missing_vars, collapse = ", "))
    log_error(error_msg)
    stop()
  }
  
  if (!all(last_taken_vars %in% names(df))) {
    missing_vars <- last_taken_vars[!(last_taken_vars %in% names(df))]
    error_msg <- paste0("The following 'last_taken' variables are not in the data frame: ", paste(missing_vars, collapse = ", "))
    log_error(error_msg)
    stop()
  }
  
  if (length(med_vars) != length(last_taken_vars)) {
    error_msg <- "The lists of medication variables and 'last_taken' variables are not of the same length."
    log_warn(error_msg)
    stop()
  }
  
  # Set the log level
  log_threshold(log_level)
  
  # Check if class_var_name already exists in the data frame
  if (class_var_name %in% names(df)) {
    error_msg <- paste0("Variable '", class_var_name, "' already exists in the data frame.")
    if (overwrite) {
      log_warn(paste0(error_msg, " The variable will be overwritten."))
    } else {
      log_fatal(paste0(error_msg, " Use a new variable name or change 'overwrite=TRUE'."))
      stop()
    }
  }
  
  log_info(paste0("Adding variable '", class_var_name, "' to the data frame."))
  
  # Initialize the class variable column
  df[[class_var_name]] <- 0 
  
  # Apply the condition function to each pair of med and last_taken vars
  for (i in seq_along(med_vars)) {
    df[[class_var_name]] <- df[[class_var_name]] + purrr::map2_int(df[[med_vars[i]]], df[[last_taken_vars[i]]], class_condition_fun)
  }
  
  return(df)
}

## @brief An example condition function to determine if a medication is a beta blocker.
# 
# This function checks if a given medication belongs to the beta blocker drug class.
# The specific conditions for identifying a beta blocker are based on Anatomical Therapeutic Chemical (ATC) codes
# and the number of weeks since the medication was last taken.
# 
# @param atc_code A character vector representing the Anatomical Therapeutic Chemical (ATC) code of the medication.
# @param weeks_ago An integer representing the number of weeks since the medication was last taken.
# 
# @return An integer, n = the number of medications taken that are in the beta blocker class.
#         0 if not taking a beta blocker.
# 
# @details The function uses the ATC code to identify beta blockers. Beta blockers have ATC codes that start with 'C07',
#          but specific sub-codes 'C07AA07', 'C07AA12', and 'C07AG02' are excluded from the beta blocker class.
#          Additionally, the function considers the 'weeks_ago' parameter to check if the medication was recently taken.
#          If 'weeks_ago' is less than 4, the medication is considered a beta blocker; otherwise, it is not.
is_beta_blocker <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "C07") && !(atc_code %in% c('C07AA07', 'C07AA12', 'C07AG02')) && weeks_ago <= 4
}

is_ace_inhibitor <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "C09") && weeks_ago <= 4
}

is_diuretic <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "C03") && !(atc_code %in% c('C03BA08', 'C03CA01')) && weeks_ago <= 4
}

is_calcium_channel_blocker <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "C08") && weeks_ago <= 4
}

is_other_antiHTN_med <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "C02") && !(atc_code %in% c('C02KX01')) && weeks_ago <= 4
}

is_any_antiHTN_med <- function(atc_code, weeks_ago) {
  grepl('^C0[2, 3, 7, 8, 9]', atc_code) && !(atc_code %in% c('C07AA07', 'C07AA12', 'C07AG02', 'C03BA08', 'C03CA01', 'C02KX01')) && weeks_ago <= 4
}

is_NSAID <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "M01A") && weeks_ago <= 4
}

is_diabetes_drug <- function(atc_code, weeks_ago) {
  startsWith(atc_code, "A10") && weeks_ago <= 4
}