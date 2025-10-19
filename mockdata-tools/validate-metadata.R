#!/usr/bin/env Rscript
# Validate metadata consistency and identify potential issues
# This script checks for common metadata errors that could affect MockData generation

# Source MockData parser functions
source("R/mockdata-parsers.R")

# Load metadata
variables <- read.csv("inst/extdata/variables.csv", stringsAsFactors = FALSE)
variable_details <- read.csv("inst/extdata/variable-details.csv", stringsAsFactors = FALSE)

cat("=== METADATA VALIDATION REPORT ===\n\n")

# Valid cycle names
valid_cycles <- c("cycle1", "cycle2", "cycle3", "cycle4", "cycle5", "cycle6", "cycle7",
                  "cycle1_meds", "cycle2_meds", "cycle3_meds",
                  "cycle4_meds", "cycle5_meds", "cycle6_meds")

errors <- list()
warnings <- list()
info <- list()

# ============================================================================
# Check 1: databaseStart contains only valid cycles
# ============================================================================
cat("CHECK 1: Validating databaseStart cycles\n")
cat("-------------------------------------------\n")

for (i in 1:nrow(variables)) {
  var_name <- variables$variable[i]
  db_start <- variables$databaseStart[i]

  if (is.na(db_start) || db_start == "") {
    errors <- c(errors, paste0("Variable '", var_name, "': databaseStart is empty"))
    next
  }

  cycles <- strsplit(db_start, ",")[[1]]
  cycles <- trimws(cycles)

  invalid_cycles <- cycles[!cycles %in% valid_cycles]
  if (length(invalid_cycles) > 0) {
    errors <- c(errors, paste0("Variable '", var_name, "': Invalid cycles in databaseStart: ",
                               paste(invalid_cycles, collapse = ", ")))
  }
}

if (length(errors) == 0) {
  cat("✓ All databaseStart cycles are valid\n\n")
} else {
  cat("✗ Found", length(errors), "errors\n\n")
}

# ============================================================================
# Check 2: variableStart parses correctly for all declared cycles
# ============================================================================
cat("CHECK 2: Validating variableStart parsing\n")
cat("-------------------------------------------\n")

parse_errors <- list()
parse_warnings <- list()

for (i in 1:nrow(variables)) {
  var_name <- variables$variable[i]
  var_start <- variables$variableStart[i]
  db_start <- variables$databaseStart[i]

  if (is.na(var_start) || var_start == "") {
    errors <- c(errors, paste0("Variable '", var_name, "': variableStart is empty"))
    next
  }

  # Skip DerivedVar for this check (they're expected to return NULL)
  if (grepl("^DerivedVar::", var_start)) {
    next
  }

  # Get cycles for this variable
  cycles <- strsplit(db_start, ",")[[1]]
  cycles <- trimws(cycles)
  cycles <- cycles[cycles %in% valid_cycles]  # Only valid cycles

  # Try parsing for each cycle
  for (cycle in cycles) {
    result <- parse_variable_start(var_start, cycle)

    if (is.null(result)) {
      parse_errors <- c(parse_errors,
                       paste0("Variable '", var_name, "' (", cycle, "): ",
                              "Failed to parse variableStart: '", var_start, "'"))
    } else {
      # Check if parsed name makes sense
      # Warning: parsed name very different from variable name might indicate error
      if (nchar(result) > 0 && nchar(var_name) > 0) {
        # Simple check: do they share any common substring?
        result_lower <- tolower(result)
        var_lower <- tolower(var_name)

        # Remove common prefixes/suffixes for comparison
        result_clean <- gsub("^(gen_|lab_|ccc_|alc_|smk_)", "", result_lower)
        var_clean <- gsub("^(gen_|lab_|ccc_|alc_|smk_)", "", var_lower)

        # If completely different (no overlap), might be worth checking
        if (!grepl(substr(result_clean, 1, 3), var_clean) &&
            !grepl(substr(var_clean, 1, 3), result_clean)) {
          parse_warnings <- c(parse_warnings,
                             paste0("Variable '", var_name, "' (", cycle, "): ",
                                    "Parsed name '", result, "' differs significantly. ",
                                    "variableStart: '", var_start, "'"))
        }
      }
    }
  }
}

errors <- c(errors, parse_errors)
warnings <- c(warnings, parse_warnings)

if (length(parse_errors) == 0) {
  cat("✓ All non-DerivedVar variableStart entries parse successfully\n")
} else {
  cat("✗ Found", length(parse_errors), "parse errors\n")
}

if (length(parse_warnings) > 0) {
  cat("⚠ Found", length(parse_warnings), "potential naming inconsistencies\n")
}
cat("\n")

# ============================================================================
# Check 3: Identify variableStart format patterns
# ============================================================================
cat("CHECK 3: variableStart format patterns\n")
cat("---------------------------------------\n")

format_counts <- list(
  bracket = 0,           # [varname]
  cycle_prefixed = 0,    # cycle1::varname
  mixed = 0,             # cycle1::var1, [var2]
  derived_var = 0,       # DerivedVar::[...]
  plain = 0,             # varname
  unknown = 0
)

format_examples <- list(
  bracket = c(),
  cycle_prefixed = c(),
  mixed = c(),
  derived_var = c(),
  plain = c(),
  unknown = c()
)

for (i in 1:nrow(variables)) {
  var_name <- variables$variable[i]
  var_start <- variables$variableStart[i]

  if (is.na(var_start) || var_start == "") next

  # Classify format
  if (grepl("^DerivedVar::", var_start)) {
    format_counts$derived_var <- format_counts$derived_var + 1
    if (length(format_examples$derived_var) < 3) {
      format_examples$derived_var <- c(format_examples$derived_var,
                                       paste0(var_name, ": ", substr(var_start, 1, 50)))
    }
  } else if (grepl("::", var_start) && grepl("\\[", var_start)) {
    # Has both :: and []
    format_counts$mixed <- format_counts$mixed + 1
    if (length(format_examples$mixed) < 5) {
      format_examples$mixed <- c(format_examples$mixed,
                                paste0(var_name, ": ", var_start))
    }
  } else if (grepl("::", var_start)) {
    format_counts$cycle_prefixed <- format_counts$cycle_prefixed + 1
    if (length(format_examples$cycle_prefixed) < 3) {
      format_examples$cycle_prefixed <- c(format_examples$cycle_prefixed,
                                         paste0(var_name, ": ", var_start))
    }
  } else if (grepl("^\\[.*\\]$", var_start)) {
    format_counts$bracket <- format_counts$bracket + 1
    if (length(format_examples$bracket) < 3) {
      format_examples$bracket <- c(format_examples$bracket,
                                  paste0(var_name, ": ", var_start))
    }
  } else if (!grepl("\\[", var_start) && !grepl("::", var_start)) {
    format_counts$plain <- format_counts$plain + 1
    if (length(format_examples$plain) < 3) {
      format_examples$plain <- c(format_examples$plain,
                                paste0(var_name, ": ", var_start))
    }
  } else {
    format_counts$unknown <- format_counts$unknown + 1
    format_examples$unknown <- c(format_examples$unknown,
                                paste0(var_name, ": ", var_start))
  }
}

cat("Format distribution:\n")
cat(sprintf("  Bracket format [varname]:           %4d variables\n", format_counts$bracket))
cat(sprintf("  Cycle-prefixed cycle::varname:      %4d variables\n", format_counts$cycle_prefixed))
cat(sprintf("  Mixed cycle::var, [var]:            %4d variables\n", format_counts$mixed))
cat(sprintf("  DerivedVar::                        %4d variables\n", format_counts$derived_var))
cat(sprintf("  Plain varname:                      %4d variables\n", format_counts$plain))
cat(sprintf("  Unknown format:                     %4d variables\n", format_counts$unknown))
cat("\n")

# Show examples of mixed format (key concern)
if (format_counts$mixed > 0) {
  cat("⚠ MIXED FORMAT EXAMPLES (cycle::var, [var]):\n")
  for (ex in format_examples$mixed) {
    cat("  ", ex, "\n")
  }
  cat("\n")
  cat("QUESTION: Are mixed formats intentional?\n")
  cat("  - Is [var] a fallback for cycles without explicit cycle::var?\n")
  cat("  - Should Strategy 2b in parse_variable_start use bracket segment?\n")
  cat("  - Or should metadata be expanded to have cycle2::var2, cycle3::var3, etc?\n\n")
}

# ============================================================================
# Check 4: Case sensitivity issues
# ============================================================================
cat("CHECK 4: Case sensitivity check\n")
cat("--------------------------------\n")

# Check if any variable names differ only by case
var_names_lower <- tolower(variables$variable)
duplicates <- var_names_lower[duplicated(var_names_lower)]

if (length(duplicates) > 0) {
  cat("⚠ Found variables that differ only by case:\n")
  for (dup in unique(duplicates)) {
    matches <- variables$variable[var_names_lower == dup]
    cat("  ", paste(matches, collapse = " vs "), "\n")
  }
  cat("\n")
} else {
  cat("✓ No case-only duplicates found\n\n")
}

# ============================================================================
# Check 5: Categorical variables have variable_details
# ============================================================================
cat("CHECK 5: Categorical variables have specifications\n")
cat("----------------------------------------------------\n")

missing_details <- c()

categorical_vars <- variables[variables$variableType == "Categorical", ]
for (i in 1:nrow(categorical_vars)) {
  var_name <- categorical_vars$variable[i]
  db_start <- categorical_vars$databaseStart[i]
  var_start <- categorical_vars$variableStart[i]

  # Skip DerivedVar (they don't need variable_details)
  if (grepl("^DerivedVar::", var_start)) {
    next
  }

  # Check if variable has any variable_details entries
  has_details <- any(variable_details$variable == var_name)

  if (!has_details) {
    missing_details <- c(missing_details,
                        paste0("Variable '", var_name, "': Categorical but no variable_details entries"))
  }
}

if (length(missing_details) > 0) {
  cat("⚠ Found", length(missing_details), "categorical variables without variable_details\n")
  cat("First 10:\n")
  for (i in 1:min(10, length(missing_details))) {
    cat("  ", missing_details[i], "\n")
  }
  if (length(missing_details) > 10) {
    cat("  ... and", length(missing_details) - 10, "more\n")
  }
  cat("\n")
} else {
  cat("✓ All non-DerivedVar categorical variables have variable_details\n\n")
}

warnings <- c(warnings, missing_details)

# ============================================================================
# SUMMARY
# ============================================================================
cat("=== VALIDATION SUMMARY ===\n\n")

cat("ERRORS:", length(errors), "\n")
if (length(errors) > 0) {
  for (err in errors) {
    cat("  ✗", err, "\n")
  }
  cat("\n")
}

cat("WARNINGS:", length(warnings), "\n")
if (length(warnings) > 0 && length(warnings) <= 20) {
  for (warn in warnings) {
    cat("  ⚠", warn, "\n")
  }
  cat("\n")
} else if (length(warnings) > 20) {
  cat("  (Too many to display - see detailed output above)\n\n")
}

cat("INFO:\n")
cat("  Total variables:", nrow(variables), "\n")
cat("  Total variable_details entries:", nrow(variable_details), "\n")
cat("  Unique variables in variable_details:", length(unique(variable_details$variable)), "\n")

# Exit code
if (length(errors) > 0) {
  cat("\n❌ VALIDATION FAILED\n")
  quit(status = 1)
} else if (length(warnings) > 0) {
  cat("\n⚠️  VALIDATION PASSED WITH WARNINGS\n")
  quit(status = 0)
} else {
  cat("\n✅ VALIDATION PASSED\n")
  quit(status = 0)
}
