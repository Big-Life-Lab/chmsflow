# ==============================================================================
# MockData Metadata Helpers
# ==============================================================================
# Functions for querying and filtering recodeflow metadata (variables.csv and
# variable_details.csv) to support mock data generation
#
# These helpers work with any recodeflow project's metadata structure
# ==============================================================================

#' Get list of variables used in a specific database/cycle
#'
#' Returns a data frame containing all variables that are available in a
#' specified database/cycle, with their metadata and extracted raw variable names.
#'
#' @param cycle Character string specifying the database/cycle (e.g., "cycle1",
#'   "cycle1_meds" for CHMS; "cchs2001", "cchs2017_p" for CCHS).
#' @param variables Data frame from variables.csv containing variable metadata.
#' @param variable_details Data frame from variable_details.csv containing detailed recoding specifications.
#' @param include_derived Logical. Should derived variables be included? Default is TRUE.
#'
#' @return Data frame with columns:
#' \itemize{
#'   \item variable - Harmonized variable name
#'   \item variable_raw - Raw source variable name (extracted from variableStart)
#'   \item label - Human-readable label
#'   \item variableType - "Categorical" or "Continuous"
#'   \item databaseStart - Which databases/cycles the variable appears in
#'   \item variableStart - Original variableStart string (for reference)
#' }
#'
#' Returns empty data frame if no variables found for the database/cycle.
#'
#' @details
#' The function filters variables.csv by checking if the database/cycle appears
#' in the `databaseStart` field (exact match), then uses \code{\link{parse_variable_start}}
#' to extract the raw variable name from the `variableStart` field.
#'
#' **Important**: Uses exact matching to avoid false positives (e.g., "cycle1"
#' should not match "cycle1_meds").
#'
#' Derived variables (those with "DerivedVar::" in variableStart) return NA for
#' variable_raw since they require custom derivation logic.
#'
#' @examples
#' # Load metadata
#' variables <- read.csv("inst/extdata/variables.csv")
#' variable_details <- read.csv("inst/extdata/variable-details.csv")
#'
#' # CHMS example
#' cycle1_vars <- get_cycle_variables("cycle1", variables, variable_details)
#'
#' # CCHS example
#' cchs2001_vars <- get_cycle_variables("cchs2001", variables, variable_details)
#'
#' # Exclude derived variables
#' cycle1_original <- get_cycle_variables("cycle1", variables, variable_details,
#'                                         include_derived = FALSE)
#'
#' @seealso \code{\link{parse_variable_start}}
#'
#' @export
get_cycle_variables <- function(cycle, variables, variable_details,
                                 include_derived = TRUE) {
  # Basic validation
  if (is.null(cycle) || cycle == "") {
    return(data.frame(
      variable = character(),
      variable_raw = character(),
      label = character(),
      variableType = character(),
      databaseStart = character(),
      variableStart = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Filter variables by cycle using EXACT match
  # Split databaseStart by comma and check for exact cycle match
  # This prevents "cycle1" from matching "cycle1_meds"
  cycle_vars <- variables[sapply(variables$databaseStart, function(db_start) {
    cycles <- strsplit(db_start, ",")[[1]]
    cycles <- trimws(cycles)
    cycle %in% cycles
  }), ]

  # If no variables found, return empty data frame
  if (nrow(cycle_vars) == 0) {
    return(data.frame(
      variable = character(),
      variable_raw = character(),
      label = character(),
      variableType = character(),
      databaseStart = character(),
      variableStart = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Extract raw variable names using parse_variable_start
  cycle_vars$variable_raw <- sapply(cycle_vars$variableStart, function(vs) {
    raw_name <- parse_variable_start(vs, cycle)
    if (is.null(raw_name)) return(NA_character_)
    return(raw_name)
  })

  # Filter out derived variables if requested
  if (!include_derived) {
    cycle_vars <- cycle_vars[!grepl("DerivedVar::", cycle_vars$variableStart, fixed = TRUE), ]
  }

  # Select and return relevant columns
  result <- data.frame(
    variable = cycle_vars$variable,
    variable_raw = cycle_vars$variable_raw,
    label = cycle_vars$label,
    variableType = cycle_vars$variableType,
    databaseStart = cycle_vars$databaseStart,
    variableStart = cycle_vars$variableStart,
    stringsAsFactors = FALSE
  )

  return(result)
}

#' Get list of unique raw variables for a database/cycle
#'
#' Returns a data frame of unique raw (source) variables that should be generated
#' for a specific database/cycle. This is the correct approach for generating mock
#' data, as we want to create the raw source data, not the harmonized variables.
#'
#' @param cycle Character string specifying the database/cycle (e.g., "cycle1",
#'   "cycle1_meds" for CHMS; "cchs2001" for CCHS).
#' @param variables Data frame from variables.csv containing variable metadata.
#' @param variable_details Data frame from variable_details.csv containing detailed specifications.
#' @param include_derived Logical. Should derived variables be included? Default is FALSE
#'   (since derived variables are computed from other variables, not in raw data).
#'
#' @return Data frame with columns:
#' \itemize{
#'   \item variable_raw - Raw source variable name (unique)
#'   \item variableType - "Categorical" or "Continuous"
#'   \item harmonized_vars - Comma-separated list of harmonized variables that use this raw variable
#'   \item n_harmonized - Count of how many harmonized variables use this raw variable
#' }
#'
#' @details
#' This function:
#' \enumerate{
#'   \item Gets all variables available in the database/cycle using \code{\link{get_cycle_variables}}
#'   \item Extracts unique raw variable names
#'   \item Groups harmonized variables by their raw source
#'   \item Returns one row per unique raw variable
#' }
#'
#' This is the correct approach because:
#' \itemize{
#'   \item Mock data should represent raw source data (before harmonization)
#'   \item Each raw variable should appear exactly once
#'   \item Multiple harmonized variables can derive from the same raw variable
#' }
#'
#' @examples
#' # Load metadata
#' variables <- read.csv("inst/extdata/variables.csv")
#' variable_details <- read.csv("inst/extdata/variable-details.csv")
#'
#' # CHMS example
#' raw_vars <- get_raw_variables("cycle1", variables, variable_details)
#'
#' # CCHS example
#' raw_vars_cchs <- get_raw_variables("cchs2001", variables, variable_details)
#'
#' # Generate mock data from raw variables
#' for (i in 1:nrow(raw_vars)) {
#'   var_raw <- raw_vars$variable_raw[i]
#'   var_type <- raw_vars$variableType[i]
#'   # Generate the raw variable...
#' }
#'
#' @seealso \code{\link{get_cycle_variables}}, \code{\link{parse_variable_start}}
#'
#' @export
get_raw_variables <- function(cycle, variables, variable_details,
                               include_derived = FALSE) {
  # Get all cycle variables (harmonized)
  cycle_vars <- get_cycle_variables(cycle, variables, variable_details,
                                     include_derived = include_derived)

  # Remove rows with NA raw variable names (e.g., DerivedVar that couldn't be parsed)
  cycle_vars <- cycle_vars[!is.na(cycle_vars$variable_raw), ]

  # If no variables, return empty data frame
  if (nrow(cycle_vars) == 0) {
    return(data.frame(
      variable_raw = character(),
      variableType = character(),
      harmonized_vars = character(),
      n_harmonized = integer(),
      stringsAsFactors = FALSE
    ))
  }

  # Group by raw variable name
  # For each unique raw variable, collect the harmonized variables that use it
  raw_var_list <- unique(cycle_vars$variable_raw)

  result <- lapply(raw_var_list, function(raw_var) {
    # Find all harmonized variables that map to this raw variable
    matching_rows <- cycle_vars[cycle_vars$variable_raw == raw_var, ]

    # Get variable type (should be same for all harmonized vars using this raw var)
    var_type <- matching_rows$variableType[1]

    # Get list of harmonized variable names
    harmonized_list <- matching_rows$variable

    data.frame(
      variable_raw = raw_var,
      variableType = var_type,
      harmonized_vars = paste(harmonized_list, collapse = ", "),
      n_harmonized = length(harmonized_list),
      stringsAsFactors = FALSE
    )
  })

  # Combine into single data frame
  result_df <- do.call(rbind, result)

  # Sort by variable name for consistency
  result_df <- result_df[order(result_df$variable_raw), ]
  rownames(result_df) <- NULL

  return(result_df)
}

#' Get variable details for a raw variable in a specific database/cycle
#'
#' Retrieves all variable_details rows for a given raw variable name and database/cycle.
#' This is useful when you have a raw variable name (from the source data) and need
#' to find all the harmonized variables and their recoding specifications.
#'
#' @param var_raw Character. The raw variable name (as it appears in source data)
#' @param cycle Character. The database/cycle identifier (e.g., "cycle1", "cchs2001")
#' @param variable_details Data frame. The complete variable_details data frame
#' @param variables Data frame. Optional. The variables data frame (for validation)
#'
#' @return Data frame with variable_details rows for this raw variable + cycle.
#'   Returns empty data frame if not found.
#'
#' @details
#' This function searches variable_details for rows where:
#' - variableStart contains the raw variable name (in any format: database::name, [name], or plain name)
#' - databaseStart contains the cycle identifier
#'
#' The function handles multiple recodeflow metadata formats:
#' - Database-prefixed: "cycle1::clc_age", "cchs2001::HGT_CM"
#' - Bracket format: "[clc_age]"
#' - Plain format: "clc_age"
#'
#' @examples
#' # CHMS: Get all harmonized variables derived from raw variable "clc_age" in cycle1
#' details <- get_variable_details_for_raw("clc_age", "cycle1", variable_details)
#'
#' # CCHS: Get harmonized variables from "HGT_CM" in cchs2001
#' details_cchs <- get_variable_details_for_raw("HGT_CM", "cchs2001", variable_details)
#'
#' # This might return multiple rows for different harmonized variables
#'
#' @keywords internal
get_variable_details_for_raw <- function(var_raw, cycle, variable_details, variables = NULL) {
  if (is.null(var_raw) || is.null(cycle) || var_raw == "" || cycle == "") {
    return(data.frame(
      variable = character(),
      variableStart = character(),
      databaseStart = character(),
      variableType = character(),
      recStart = character(),
      recEnd = character(),
      stringsAsFactors = FALSE
    ))
  }

  # Strategy 1: Find by database-prefixed format (cycle::var_raw)
  cycle_pattern <- paste0(cycle, "::", var_raw)
  matches <- variable_details[grepl(cycle_pattern, variable_details$variableStart, fixed = TRUE), ]

  # Strategy 2: Find by bracket format ([var_raw]) with databaseStart filtering
  if (nrow(matches) == 0) {
    bracket_pattern <- paste0("[", var_raw, "]")
    bracket_matches <- variable_details[grepl(bracket_pattern, variable_details$variableStart, fixed = TRUE), ]

    if (nrow(bracket_matches) > 0) {
      # Filter by databaseStart to ensure correct cycle
      bracket_matches <- bracket_matches[grepl(cycle, bracket_matches$databaseStart, fixed = TRUE), ]
      matches <- bracket_matches
    }
  }

  # Strategy 3: Find by plain format (var_raw) with strict filtering
  if (nrow(matches) == 0) {
    # Only match if variableStart is EXACTLY the var_raw (no :: or [] or Func:: or DerivedVar::)
    plain_matches <- variable_details[
      variable_details$variableStart == var_raw &
      grepl(cycle, variable_details$databaseStart, fixed = TRUE), ]

    matches <- plain_matches
  }

  # Return matches
  return(matches)
}

#' Extract categories from variable details
#'
#' Extracts categorical values (labels) from variable_details recStart/recEnd columns,
#' handling recodeflow-standard range notation, special codes, and NA patterns.
#'
#' @param var_details Data frame. Filtered variable_details rows for specific variable + cycle
#' @param include_na Logical. If TRUE, return NA codes (recEnd contains "NA").
#'   If FALSE, return regular labels.
#'
#' @return Character vector of category values (expanded from ranges if needed)
#'
#' @details
#' This function handles recodeflow-standard notation:
#' - Simple category values: "1", "2", "3"
#' - Integer ranges: "[7,9]" → c("7", "8", "9")
#' - Continuous ranges: "[18.5,25)" → kept as single value for continuous vars
#' - Special codes: "copy", "else", "NA::a", "NA::b"
#' - Function calls: "Func::function_name"
#'
#' Uses parse_range_notation() for robust range handling.
#'
#' @examples
#' # Get regular categories (non-NA)
#' categories <- get_variable_categories(var_details, include_na = FALSE)
#'
#' # Get NA codes
#' na_codes <- get_variable_categories(var_details, include_na = TRUE)
#'
#' @keywords internal
get_variable_categories <- function(var_details, include_na = FALSE) {
  if (nrow(var_details) == 0) {
    return(character(0))
  }

  # Filter based on whether we want NA codes or regular labels
  if (include_na) {
    # Get rows where recEnd contains "NA"
    rows <- var_details[grepl("NA", var_details$recEnd, fixed = TRUE), ]
  } else {
    # Get rows where recEnd does NOT contain "NA"
    rows <- var_details[!grepl("NA", var_details$recEnd, fixed = TRUE), ]
  }

  if (nrow(rows) == 0) {
    return(character(0))
  }

  # Extract recStart values
  rec_start_values <- rows$recStart

  # Process each value through parse_range_notation
  all_values <- character(0)

  for (value in rec_start_values) {
    if (is.na(value) || value == "") {
      next
    }

    parsed <- parse_range_notation(value)

    if (is.null(parsed)) {
      # If parsing failed, use raw value
      all_values <- c(all_values, as.character(value))
      next
    }

    # Handle different parsed types
    if (parsed$type == "integer") {
      # For integer ranges, use the expanded values
      if (!is.null(parsed$values)) {
        all_values <- c(all_values, as.character(parsed$values))
      } else {
        # If values not expanded, just use min-max representation
        all_values <- c(all_values, as.character(value))
      }

    } else if (parsed$type == "single_value") {
      # Single numeric value
      all_values <- c(all_values, as.character(parsed$value))

    } else if (parsed$type == "continuous") {
      # For continuous ranges, keep as-is (don't expand)
      # These will be used for continuous variable generation
      all_values <- c(all_values, as.character(value))

    } else if (parsed$type == "special") {
      # Special codes: copy, else, NA::a, NA::b
      all_values <- c(all_values, parsed$value)

    } else if (parsed$type == "function") {
      # Function calls: Func::function_name
      all_values <- c(all_values, parsed$value)

    } else {
      # Unknown type, use raw value
      all_values <- c(all_values, as.character(value))
    }
  }

  # Return unique values
  return(unique(all_values))
}
