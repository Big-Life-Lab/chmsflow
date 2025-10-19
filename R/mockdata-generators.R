# ==============================================================================
# MockData Generators
# ==============================================================================
# Functions for generating categorical and continuous mock variables from
# recodeflow metadata specifications
#
# These generators work with any recodeflow project's metadata
# ==============================================================================

#' Create categorical variable for MockData
#'
#' Creates a categorical mock variable based on specifications from variable_details.
#'
#' @param var_raw character. The RAW variable name (as it appears in source data)
#' @param cycle character. The cycle identifier (e.g., "cycle1", "HC1")
#' @param variable_details data.frame. Variable details metadata
#' @param variables data.frame. Variables metadata (optional, for validation)
#' @param length integer. The desired length of the mock data vector
#' @param df_mock data.frame. The current mock data (to check if variable already exists)
#' @param prop_NA numeric. Optional. Proportion of NA values (0 to 1). If NULL, no NAs introduced.
#' @param seed integer. Random seed for reproducibility. Default is 100.
#'
#' @return data.frame with one column (the new categorical variable), or NULL if:
#'   - Variable details not found
#'   - Variable already exists in df_mock
#'   - No categories found
#'
#' @details
#' This function uses:
#' - `get_variable_details_for_raw()` to find variable specifications
#' - `get_variable_categories()` to extract category values
#'
#' The function handles:
#' - Simple categories: "1", "2", "3"
#' - Range notation: "[7,9]" → expands to c("7","8","9")
#' - NA codes: Categories where recEnd contains "NA"
#' - Special codes: "copy", "else", "NA::a"
#'
#' @examples
#' # Create a categorical variable
#' mock_gender <- create_cat_var(
#'   var_raw = "DHH_SEX",
#'   cycle = "cycle1",
#'   variable_details = variable_details,
#'   length = 1000
#' )
#'
#' # Create with NA values
#' mock_age_cat <- create_cat_var(
#'   var_raw = "clc_age",
#'   cycle = "cycle1",
#'   variable_details = variable_details,
#'   length = 1000,
#'   df_mock = existing_mock_data,
#'   prop_NA = 0.05
#' )
#'
#' @export
create_cat_var <- function(var_raw, cycle, variable_details, variables = NULL,
                            length, df_mock, prop_NA = NULL, seed = 100) {

  # Level 1: Get variable details for this raw variable + cycle
  var_details <- get_variable_details_for_raw(var_raw, cycle, variable_details, variables)

  if (nrow(var_details) == 0) {
    # No variable details found for this raw variable in this cycle
    return(NULL)
  }

  # Check if variable already exists in mock data
  if (var_raw %in% names(df_mock)) {
    # Variable already created, skip
    return(NULL)
  }

  # Level 2: Extract categories (non-NA values)
  labels <- get_variable_categories(var_details, include_na = FALSE)

  if (length(labels) == 0) {
    # No valid categories found
    return(NULL)
  }

  # Level 2: Extract NA codes (if prop_NA specified)
  na_labels <- NULL
  if (!is.null(prop_NA) && prop_NA > 0) {
    na_labels <- get_variable_categories(var_details, include_na = TRUE)

    if (length(na_labels) == 0) {
      # No NA codes found, but prop_NA requested
      # Use regular labels with NA values instead
      na_labels <- NULL
      prop_NA <- NULL
      warning(paste0(
        "prop_NA requested for ", var_raw, " but no NA codes found in variable_details. ",
        "Proceeding without NAs."
      ))
    }
  }

  # Generate mock data
  if (is.null(prop_NA) || is.null(na_labels)) {
    # Simple case: no NA values
    set.seed(seed)
    col <- data.frame(
      new = sample(labels, length, replace = TRUE),
      stringsAsFactors = FALSE
    )

  } else {
    # Case with NA values using NA codes
    set.seed(seed)

    # Calculate counts
    n_regular <- floor(length * (1 - prop_NA))
    n_na <- length - n_regular

    # Sample regular values
    vec_regular <- sample(labels, n_regular, replace = TRUE)

    # Sample NA codes
    vec_na <- sample(na_labels, n_na, replace = TRUE)

    # Combine and shuffle
    vec_combined <- c(vec_regular, vec_na)
    vec_shuffled <- sample(vec_combined)

    # Ensure exact length
    col <- data.frame(
      new = vec_shuffled[1:length],
      stringsAsFactors = FALSE
    )
  }

  # Set column name to raw variable name
  names(col)[1] <- var_raw

  return(col)
}

#' Create continuous variable for MockData
#'
#' Creates a continuous mock variable based on specifications from variable_details.
#'
#' @param var_raw character. The RAW variable name (as it appears in source data)
#' @param cycle character. The cycle identifier (e.g., "cycle1", "HC1")
#' @param variable_details data.frame. Variable details metadata
#' @param variables data.frame. Variables metadata (optional, for validation)
#' @param length integer. The desired length of the mock data vector
#' @param df_mock data.frame. The current mock data (to check if variable already exists)
#' @param prop_NA numeric. Optional. Proportion of NA values (0 to 1). If NULL, no NAs introduced.
#' @param seed integer. Random seed for reproducibility. Default is 100.
#' @param distribution character. Distribution type: "uniform" (default) or "normal"
#'
#' @return data.frame with one column (the new continuous variable), or NULL if:
#'   - Variable details not found
#'   - Variable already exists in df_mock
#'   - No valid range found
#'
#' @details
#' This function uses:
#' - `get_variable_details_for_raw()` to find variable specifications
#'
#' The function handles continuous ranges:
#' - Closed intervals: "[18.5,25]" → 18.5 ≤ x ≤ 25
#' - Half-open intervals: "[18.5,25)" → 18.5 ≤ x < 25
#' - Open intervals: "(18.5,25)" → 18.5 < x < 25
#' - Infinity ranges: "[30,inf)" → x ≥ 30
#'
#' For variables with multiple ranges (e.g., age categories), uses the overall min/max.
#'
#' @examples
#' # Create a continuous variable with uniform distribution
#' mock_bmi <- create_con_var(
#'   var_raw = "HWTGBMI",
#'   cycle = "cycle1",
#'   variable_details = variable_details,
#'   length = 1000,
#'   df_mock = data.frame()
#' )
#'
#' # Create with normal distribution and NA values
#' mock_age <- create_con_var(
#'   var_raw = "DHHAGAGE",
#'   cycle = "cycle1",
#'   variable_details = variable_details,
#'   length = 1000,
#'   df_mock = existing_data,
#'   prop_NA = 0.02,
#'   distribution = "normal"
#' )
#'
#' @export
create_con_var <- function(var_raw, cycle, variable_details, variables = NULL,
                            length, df_mock, prop_NA = NULL, seed = 100,
                            distribution = "uniform") {

  # Level 1: Get variable details for this raw variable + cycle
  var_details <- get_variable_details_for_raw(var_raw, cycle, variable_details, variables)

  if (nrow(var_details) == 0) {
    # No variable details found for this raw variable in this cycle
    return(NULL)
  }

  # Check if variable already exists in mock data
  if (var_raw %in% names(df_mock)) {
    # Variable already created, skip
    return(NULL)
  }

  # Level 2: Extract continuous ranges from recStart
  # For continuous variables, we need to find the overall min/max from all ranges
  rec_start_values <- var_details$recStart[!grepl("NA", var_details$recEnd, fixed = TRUE)]

  if (length(rec_start_values) == 0) {
    # No valid ranges found
    return(NULL)
  }

  # Parse all ranges to find overall min/max
  all_mins <- c()
  all_maxs <- c()
  has_else <- FALSE

  for (value in rec_start_values) {
    if (is.na(value) || value == "") next

    parsed <- parse_range_notation(value)

    if (is.null(parsed)) next

    if (parsed$type %in% c("integer", "continuous", "single_value")) {
      all_mins <- c(all_mins, parsed$min)
      all_maxs <- c(all_maxs, parsed$max)
    } else if (parsed$type == "special" && parsed$value == "else") {
      # "else" means pass-through - we need to generate default values
      has_else <- TRUE
    }
  }

  if (length(all_mins) == 0 || length(all_maxs) == 0) {
    if (has_else) {
      # For "else" (pass-through) variables with no explicit range,
      # use reasonable defaults based on common continuous variable ranges
      warning(paste0(
        "Variable '", var_raw, "' has recStart='else' with no explicit range. ",
        "Using default range [0, 100]."
      ))
      all_mins <- c(0)
      all_maxs <- c(100)
    } else {
      # No valid numeric ranges found and no "else"
      return(NULL)
    }
  }

  # Get overall range
  overall_min <- min(all_mins, na.rm = TRUE)
  overall_max <- max(all_maxs, na.rm = TRUE)

  # Handle infinity
  if (is.infinite(overall_min)) overall_min <- 0
  if (is.infinite(overall_max)) overall_max <- overall_min + 100  # Arbitrary upper bound

  # Level 2: Extract NA codes (if prop_NA specified)
  na_labels <- NULL
  if (!is.null(prop_NA) && prop_NA > 0) {
    na_labels <- get_variable_categories(var_details, include_na = TRUE)

    if (length(na_labels) == 0) {
      # No NA codes found, use actual NA
      na_labels <- NA
    }
  }

  # Generate mock data
  set.seed(seed)

  # Calculate counts
  n_regular <- if (!is.null(prop_NA)) floor(length * (1 - prop_NA)) else length
  n_na <- if (!is.null(prop_NA)) (length - n_regular) else 0

  # Generate continuous values
  if (distribution == "normal") {
    # Normal distribution centered at midpoint
    midpoint <- (overall_min + overall_max) / 2
    spread <- (overall_max - overall_min) / 4  # Use 1/4 of range as SD

    values <- rnorm(n_regular, mean = midpoint, sd = spread)

    # Clip to range
    values <- pmax(overall_min, pmin(overall_max, values))

  } else {
    # Uniform distribution (default)
    values <- runif(n_regular, min = overall_min, max = overall_max)
  }

  # Add NA values if requested
  if (n_na > 0) {
    if (length(na_labels) > 0 && !is.na(na_labels[1])) {
      # Use NA codes from variable_details
      na_values <- sample(na_labels, n_na, replace = TRUE)
    } else {
      # Use actual NA
      na_values <- rep(NA, n_na)
    }

    # Combine and shuffle
    all_values <- c(values, na_values)
    all_values <- sample(all_values)
  } else {
    all_values <- values
  }

  # Ensure exact length
  col <- data.frame(
    new = all_values[1:length],
    stringsAsFactors = FALSE
  )

  # Set column name to raw variable name
  names(col)[1] <- var_raw

  return(col)
}
