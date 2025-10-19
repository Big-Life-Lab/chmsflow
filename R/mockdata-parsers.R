# ==============================================================================
# MockData Parsers
# ==============================================================================
# Functions for parsing recodeflow metadata conventions
#
# These parsers work with variableStart and range notation formats used across
# all recodeflow projects (CHMS, CCHS, etc.)
# ==============================================================================

#' Parse variableStart field to extract raw variable name
#'
#' This function parses the `variableStart` field from variable_details metadata
#' and extracts the raw variable name for a specific database/cycle. It supports
#' recodeflow-standard formats: database-prefixed ("database::varname"),
#' bracket ("[varname]"), mixed, and plain formats.
#'
#' @param variable_start Character string from variableStart field. Can contain
#'   multiple database specifications separated by commas (e.g., "cycle1::age, cycle2::AGE").
#' @param cycle Character string specifying the database/cycle to extract (e.g., "cycle1", "cchs2001").
#'
#' @return Character string with the raw variable name, or NULL if not found.
#'
#' @details
#' The function implements recodeflow-standard parsing strategies:
#' \enumerate{
#'   \item Database-prefixed format: "database::varname" - for database-specific names
#'   \item Bracket format (whole string): "[varname]" - for database-agnostic names
#'   \item Bracket format (segment): "database1::var1, [var2]" - [var2] is DEFAULT for other databases
#'   \item Plain format: "varname" - uses value as-is
#' }
#'
#' **Important**: [variable] represents the DEFAULT for all databases not explicitly
#' referenced with database:: notation. This reduces repetition when only one or a
#' few databases use different variable names.
#'
#' For DerivedVar format, returns NULL (requires custom derivation logic).
#'
#' @examples
#' # Database-prefixed format
#' parse_variable_start("cycle1::height, cycle2::HEIGHT", "cycle1")
#' # Returns: "height"
#'
#' # Bracket format (database-agnostic)
#' parse_variable_start("[gen_015]", "cycle1")
#' # Returns: "gen_015"
#'
#' # Mixed format - [variable] is DEFAULT for databases not explicitly listed
#' parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle2")
#' # Returns: "ammdmva1" (uses default for cycle2)
#'
#' # Plain format
#' parse_variable_start("bmi", "cycle1")
#' # Returns: "bmi"
#'
#' # No match for specified database
#' parse_variable_start("cycle2::age", "cycle1")
#' # Returns: NULL
#'
#' @export
parse_variable_start <- function(variable_start, cycle) {
  # Basic validation
  if (is.null(variable_start) || is.null(cycle)) return(NULL)
  if (variable_start == "" || cycle == "") return(NULL)

  # Trim whitespace
  variable_start <- trimws(variable_start)

  # Strategy 1: Database-prefixed format "database::varname"
  # Split by comma to handle multiple databases
  segments <- unlist(strsplit(variable_start, ","))
  segments <- trimws(segments)

  # Look for segment matching this database/cycle
  cycle_pattern <- paste0(cycle, "::")
  matching_segments <- segments[grepl(cycle_pattern, segments, fixed = TRUE)]

  if (length(matching_segments) > 0) {
    # Extract variable name after ::
    var_raw <- sub(paste0("^.*", cycle, "::"), "", matching_segments[1])
    return(trimws(var_raw))
  }

  # Strategy 2: Bracket format "[varname]" - entire string
  # Check if entire string is bracket format
  if (grepl("^\\[.*\\]$", variable_start)) {
    var_raw <- gsub("\\[|\\]", "", variable_start)
    return(trimws(var_raw))
  }

  # Strategy 2b: Bracket format (segment) - [varname] is DEFAULT
  # For mixed format like "database1::var1, [var2]"
  # The [var2] represents the DEFAULT for all databases not explicitly listed
  bracket_segments <- segments[grepl("^\\[.*\\]$", segments)]
  if (length(bracket_segments) > 0) {
    var_raw <- gsub("\\[|\\]", "", bracket_segments[1])
    return(trimws(var_raw))
  }

  # Strategy 3: Plain format "varname"
  # Check if it's NOT a DerivedVar, Func, or database-prefixed format
  if (!grepl("^DerivedVar::", variable_start) &&
      !grepl("^Func::", variable_start) &&
      !grepl("::", variable_start, fixed = TRUE)) {
    # Simple variable name, use as-is
    return(trimws(variable_start))
  }

  # Return NULL for DerivedVar and Func formats
  # These require custom logic beyond simple variable mapping
  return(NULL)
}

#' Parse range notation from variable_details
#'
#' Parses recodeflow-standard range notation strings from variable_details.csv
#' (recodes column) into structured data for mock data generation. Supports
#' integer ranges, continuous ranges, special codes, and function calls.
#'
#' @param range_string Character string containing range notation
#' @param range_type Character. One of:
#'   - "auto" (default): Auto-detect based on bracket notation and decimal values
#'   - "integer": Force integer range interpretation (generates sequence)
#'   - "continuous": Force continuous range interpretation
#' @param expand_integers Logical. If TRUE and range_type is "integer",
#'   returns all integers in the range as a vector
#'
#' @return For continuous ranges: List with min, max, min_inclusive, max_inclusive
#'   For integer ranges: List with min, max, values (if expand_integers=TRUE)
#'   Returns NULL if parsing fails
#'
#' @details
#' **Recodeflow-Standard Range Notation:**
#'
#' These patterns work across all recodeflow projects (CHMS, CCHS, etc.):
#'
#' - Integer ranges: `[7,9]` → integers 7,8,9
#' - Continuous ranges: `[18.5,25)` → 18.5 ≤ x < 25
#' - Continuous ranges: `[18.5,25]` → 18.5 ≤ x ≤ 25
#' - Infinity ranges: `[30,inf)` → x ≥ 30
#' - Special codes: `NA::a`, `NA::b`, `copy`, `else` (passed through unchanged)
#' - Function calls: `Func::function_name` (passed through unchanged)
#'
#' **Mathematical Bracket Notation:**
#' - `[a,b]` - Closed interval: a ≤ x ≤ b
#' - `[a,b)` - Half-open interval: a ≤ x < b
#' - `(a,b]` - Half-open interval: a < x ≤ b
#' - `(a,b)` - Open interval: a < x < b
#'
#' **Auto-Detection Logic:**
#' - Contains decimal values → continuous range
#' - Uses mathematical bracket notation `[a,b)` → continuous range
#' - Simple `[integer,integer]` → integer range (generates sequence)
#' - Contains "inf" → continuous range
#'
#' @examples
#' # Integer ranges
#' parse_range_notation("[7,9]")
#' # Returns: list(min=7, max=9, values=c(7,8,9), type="integer")
#'
#' # Continuous ranges
#' parse_range_notation("[18.5,25)")
#' # Returns: list(min=18.5, max=25, min_inclusive=TRUE, max_inclusive=FALSE, type="continuous")
#'
#' parse_range_notation("[30,inf)")
#' # Returns: list(min=30, max=Inf, min_inclusive=TRUE, max_inclusive=FALSE, type="continuous")
#'
#' # Special cases
#' parse_range_notation("NA::a")   # Returns: list(type="special", value="NA::a")
#' parse_range_notation("copy")    # Returns: list(type="special", value="copy")
#' parse_range_notation("else")    # Returns: list(type="special", value="else")
#'
#' @note Adapted from cchsflow v4.0.0 (2025-07-27) - universal across recodeflow projects
#' @export
parse_range_notation <- function(range_string, range_type = "auto", expand_integers = TRUE) {
  # Handle NULL, NA, or empty inputs
  if (is.null(range_string) || is.na(range_string) || range_string == "" || range_string == "N/A") {
    return(NULL)
  }

  # Clean input
  range_clean <- trimws(range_string)

  # Handle special codes (NA::a, NA::b, copy, else, etc.)
  if (grepl("^(NA::[ab]|copy|else)$", range_clean)) {
    return(list(
      type = "special",
      value = range_clean
    ))
  }

  # Handle function calls (Func::function_name)
  if (grepl("^Func::", range_clean)) {
    return(list(
      type = "function",
      value = range_clean
    ))
  }

  # Handle single numeric values (not ranges)
  if (grepl("^[0-9]+\\.?[0-9]*$", range_clean)) {
    numeric_val <- as.numeric(range_clean)
    return(list(
      type = "single_value",
      value = numeric_val,
      min = numeric_val,
      max = numeric_val
    ))
  }

  # Parse bracket notation ranges using simple character analysis
  # Support both [] and () bracket types for mathematical notation

  # Check for bracket structure
  first_char <- substr(range_clean, 1, 1)
  last_char <- substr(range_clean, nchar(range_clean), nchar(range_clean))

  if (!first_char %in% c("[", "(") || !last_char %in% c("]", ")")) {
    return(NULL)
  }

  # Extract bracket types
  left_bracket <- first_char
  right_bracket <- last_char

  # Extract content between brackets
  inner_content <- substr(range_clean, 2, nchar(range_clean) - 1)

  # Find comma position
  comma_pos <- regexpr(",", inner_content)
  if (comma_pos[1] == -1) {
    return(NULL)
  }

  min_str <- trimws(substr(inner_content, 1, comma_pos[1] - 1))
  max_str <- trimws(substr(inner_content, comma_pos[1] + 1, nchar(inner_content)))

  # Parse min value (handle "inf" and numeric values)
  if (tolower(min_str) == "inf") {
    min_val <- Inf
  } else {
    min_val <- suppressWarnings(as.numeric(min_str))
    if (is.na(min_val)) {
      return(NULL)
    }
  }

  # Parse max value (handle "inf" and numeric values)
  if (tolower(max_str) == "inf") {
    max_val <- Inf
  } else {
    max_val <- suppressWarnings(as.numeric(max_str))
    if (is.na(max_val)) {
      return(NULL)
    }
  }

  # Determine inclusivity from bracket types
  min_inclusive <- (left_bracket == "[")
  max_inclusive <- (right_bracket == "]")

  # Auto-detect range type if not specified
  if (range_type == "auto") {
    # Detect continuous ranges by:
    # 1. Mathematical bracket notation (half-open intervals)
    # 2. Decimal values
    # 3. Infinity values
    # 4. Explicitly non-inclusive brackets
    has_mathematical_notation <- (!min_inclusive || !max_inclusive)
    has_decimals <- (min_val != floor(min_val)) || (max_val != floor(max_val))
    has_infinity <- is.infinite(min_val) || is.infinite(max_val)

    if (has_mathematical_notation || has_decimals || has_infinity) {
      range_type <- "continuous"
    } else {
      range_type <- "integer"
    }
  }

  # Build result based on detected/specified type
  if (range_type == "integer") {
    # Generate integer sequence if requested and bounds are finite
    if (expand_integers && is.finite(min_val) && is.finite(max_val)) {
      integer_values <- seq(from = as.integer(min_val), to = as.integer(max_val), by = 1)
    } else {
      integer_values <- NULL
    }

    return(list(
      type = "integer",
      min = as.integer(min_val),
      max = as.integer(max_val),
      values = integer_values,
      min_inclusive = min_inclusive,
      max_inclusive = max_inclusive
    ))

  } else if (range_type == "continuous") {
    return(list(
      type = "continuous",
      min = min_val,
      max = max_val,
      min_inclusive = min_inclusive,
      max_inclusive = max_inclusive
    ))
  }

  # Fallback for unrecognized type
  return(NULL)
}
