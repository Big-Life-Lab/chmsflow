# ==============================================================================
# Create Objective Comparison: Current vs MockData Functions
# ==============================================================================
#
# Purpose: Generate comparison table and CSV showing differences between
#          current manual approach and new mockdata functions approach
# Date: 2025-10-17

library(readr)
library(dplyr)

# Source MockData functions
source("R/mockdata-parsers.R")     # parse_variable_start
source("R/mockdata-helpers.R")      # get_cycle_variables, get_raw_variables

# Load metadata
variables <- read_csv("inst/extdata/variables.csv", show_col_types = FALSE)
variable_details <- read_csv("inst/extdata/variable-details.csv", show_col_types = FALSE)

# Load all current manual data
load("data/cycle1.rda")
load("data/cycle1_meds.rda")
load("data/cycle2.rda")
load("data/cycle2_meds.rda")
load("data/cycle3.rda")
load("data/cycle3_meds.rda")
load("data/cycle4.rda")
load("data/cycle4_meds.rda")
load("data/cycle5.rda")
load("data/cycle5_meds.rda")
load("data/cycle6.rda")
load("data/cycle6_meds.rda")

# Define cycles in canonical order
cycles_list <- list(
  cycle1 = cycle1,
  cycle1_meds = cycle1_meds,
  cycle2 = cycle2,
  cycle2_meds = cycle2_meds,
  cycle3 = cycle3,
  cycle3_meds = cycle3_meds,
  cycle4 = cycle4,
  cycle4_meds = cycle4_meds,
  cycle5 = cycle5,
  cycle5_meds = cycle5_meds,
  cycle6 = cycle6,
  cycle6_meds = cycle6_meds
)

cat("=== Creating Comparison ===\n\n")

# Storage for results
all_differences <- list()
summary_stats <- data.frame(
  cycle = character(),
  current_count = integer(),
  mockdata_functions_count = integer(),
  difference = integer(),
  stringsAsFactors = FALSE
)

# Function to categorize why a variable is missing
categorize_missing <- function(var, cycle, in_current, in_mockdata) {
  # Check if it's in variables.csv
  in_vars_csv <- var %in% variables$variable

  # Check if it's in variable_details for this cycle
  in_var_details <- nrow(variable_details[
    variable_details$variable == var &
    grepl(cycle, variable_details$databaseStart, fixed = TRUE), ]) > 0

  # Check if it exists in other cycles
  if (in_vars_csv) {
    var_row <- variables[variables$variable == var, ]
    cycles_available <- var_row$databaseStart[1]
  } else {
    cycles_available <- NA
  }

  # Categorize
  if (!in_current && in_mockdata) {
    # In mockdata functions but not current
    return(list(
      category = "Metadata-driven",
      detail = "Variable exists in metadata but not included in current manual data"
    ))
  } else if (in_current && !in_mockdata) {
    # In current but not mockdata functions
    if (!in_vars_csv) {
      return(list(
        category = "Not in metadata",
        detail = "Variable in current data but not found in variables.csv"
      ))
    } else if (!in_var_details) {
      # Check if it's in a different cycle
      if (!is.na(cycles_available) && !grepl(cycle, cycles_available, fixed = TRUE)) {
        return(list(
          category = "Wrong cycle",
          detail = sprintf("Variable only exists in: %s", cycles_available)
        ))
      } else {
        return(list(
          category = "Not in variable_details",
          detail = sprintf("Variable in variables.csv but no specs for %s in variable_details", cycle)
        ))
      }
    }
  }

  return(list(category = "Unknown", detail = "Needs investigation"))
}

# Function to check for naming differences
check_naming_difference <- function(var, cycle) {
  # Check if this is a harmonized variable name with different raw name
  if (var %in% variables$variable) {
    var_row <- variables[variables$variable == var, ]
    var_start <- var_row$variableStart[1]

    # Try to extract cycle-specific raw name
    cycle_pattern <- paste0(cycle, "::")
    if (grepl(cycle_pattern, var_start, fixed = TRUE)) {
      # Extract raw name for this cycle
      segments <- unlist(strsplit(var_start, ","))
      segments <- trimws(segments)
      matching <- segments[grepl(cycle_pattern, segments, fixed = TRUE)]
      if (length(matching) > 0) {
        raw_name <- sub(paste0("^.*", cycle, "::"), "", matching[1])
        raw_name <- trimws(raw_name)
        if (raw_name != var) {
          return(raw_name)
        }
      }
    }
  }
  return(NULL)
}

# Process each cycle
for (cycle_name in names(cycles_list)) {
  cat(sprintf("Processing %s...\n", cycle_name))

  current_data <- cycles_list[[cycle_name]]
  current_vars <- names(current_data)

  # Get mockdata functions variables
  raw_vars_all <- get_raw_variables(cycle_name, variables, variable_details, include_derived = FALSE)
  mockdata_vars <- if (nrow(raw_vars_all) > 0) raw_vars_all$variable_raw else character()

  # Find differences
  only_in_current <- setdiff(current_vars, mockdata_vars)
  only_in_mockdata <- setdiff(mockdata_vars, current_vars)

  # Store summary stats
  summary_stats <- rbind(summary_stats, data.frame(
    cycle = cycle_name,
    current_count = length(current_vars),
    mockdata_functions_count = length(mockdata_vars),
    difference = length(mockdata_vars) - length(current_vars),
    stringsAsFactors = FALSE
  ))

  # Process variables only in current
  for (var in only_in_current) {
    # Check if this is a naming difference
    raw_name <- check_naming_difference(var, cycle_name)

    if (!is.null(raw_name) && raw_name %in% mockdata_vars) {
      # This is a naming difference
      cat_info <- list(
        category = "Raw vs harmonized name",
        detail = sprintf("Current uses harmonized name '%s', mockdata functions uses raw name '%s'",
                        var, raw_name)
      )
    } else {
      # Variable genuinely missing from mockdata functions
      cat_info <- categorize_missing(var, cycle_name, TRUE, FALSE)
    }

    all_differences[[length(all_differences) + 1]] <- data.frame(
      cycle = cycle_name,
      variable = var,
      in_current = TRUE,
      in_mockdata_functions = FALSE,
      explanation_category = cat_info$category,
      explanation_detail = cat_info$detail,
      stringsAsFactors = FALSE
    )
  }

  # Process variables only in mockdata functions
  for (var in only_in_mockdata) {
    # Check if current has the harmonized version
    harmonized_in_current <- FALSE
    harmonized_name <- NULL

    # Check if this raw variable corresponds to a harmonized variable in current
    matching_vars <- variables[grepl(paste0("\\[", var, "\\]"), variables$variableStart, fixed = TRUE) |
                                grepl(paste0(cycle_name, "::", var), variables$variableStart, fixed = TRUE), ]

    if (nrow(matching_vars) > 0) {
      for (i in seq_len(nrow(matching_vars))) {
        harmonized_name <- matching_vars$variable[i]
        if (harmonized_name %in% current_vars) {
          harmonized_in_current <- TRUE
          break
        }
      }
    }

    if (harmonized_in_current) {
      # This is a naming difference (reverse direction)
      cat_info <- list(
        category = "Raw vs harmonized name",
        detail = sprintf("Mockdata functions uses raw name '%s', current uses harmonized name '%s'",
                        var, harmonized_name)
      )
    } else {
      # Variable genuinely not in current
      cat_info <- categorize_missing(var, cycle_name, FALSE, TRUE)
    }

    all_differences[[length(all_differences) + 1]] <- data.frame(
      cycle = cycle_name,
      variable = var,
      in_current = FALSE,
      in_mockdata_functions = TRUE,
      explanation_category = cat_info$category,
      explanation_detail = cat_info$detail,
      stringsAsFactors = FALSE
    )
  }
}

# Combine all differences
differences_df <- do.call(rbind, all_differences)

# Write CSV
write.csv(differences_df, "MOCKDATA_COMPARISON.csv", row.names = FALSE)
cat("\nWrote MOCKDATA_COMPARISON.csv\n")

# Create markdown
md_lines <- c(
  "# MockData Comparison: Current vs MockData Functions",
  "",
  "**Date**: 2025-10-17",
  "**Purpose**: Objective comparison of variable coverage between current manual approach (prep-dummy-data.R) and new metadata-driven mockdata functions",
  "",
  "## Overview",
  "",
  "This document compares two approaches to generating mock data for chmsflow:",
  "",
  "1. **Current**: Manual approach in `data-raw/prep-dummy-data.R` - hand-coded variable ranges",
  "2. **MockData Functions**: Automated metadata-driven approach using modular functions in `R/`",
  "",
  "### Methodology",
  "",
  "- Loaded all 12 existing mock datasets (cycle1-6 and cycle1_meds-cycle6_meds)",
  "- Generated variable lists using mockdata functions for same 12 cycles",
  "- Compared variable names between approaches",
  "- Categorized differences by type",
  "- **Only differences are shown** (variables present in both approaches are not listed)",
  "",
  "---",
  "",
  "## Summary Statistics",
  "",
  "| Cycle | Current | MockData Functions | Difference | Notes |",
  "|-------|---------|-------------------|------------|-------|"
)

# Add summary table rows
for (i in seq_len(nrow(summary_stats))) {
  row <- summary_stats[i, ]
  diff_str <- sprintf("%+d", row$difference)
  if (row$difference > 0) {
    diff_str <- paste0(diff_str, " mockdata functions")
  } else if (row$difference < 0) {
    diff_str <- paste0(diff_str, " current")
  } else {
    diff_str <- "0"
  }

  md_lines <- c(md_lines,
                sprintf("| %s | %d | %d | %s | |",
                       row$cycle, row$current_count, row$mockdata_functions_count, diff_str))
}

# Add totals
total_current <- sum(summary_stats$current_count)
total_mockdata <- sum(summary_stats$mockdata_functions_count)
total_diff <- total_mockdata - total_current

md_lines <- c(md_lines,
              sprintf("| **TOTAL** | **%d** | **%d** | **%+d** | |",
                     total_current, total_mockdata, total_diff))

md_lines <- c(md_lines,
              "",
              "---",
              "",
              "## Detailed Differences by Cycle",
              "",
              "**Legend**:",
              "- ✓ = Variable present in this approach",
              "- ✗ = Variable absent from this approach",
              "")

# Add detailed differences by cycle
for (cycle_name in names(cycles_list)) {
  cycle_diffs <- differences_df[differences_df$cycle == cycle_name, ]

  if (nrow(cycle_diffs) == 0) {
    next
  }

  md_lines <- c(md_lines,
                sprintf("### %s", cycle_name),
                "",
                sprintf("**Differences**: %d variables", nrow(cycle_diffs)),
                "",
                "| Variable | Current | MockData Functions | Explanation |",
                "|----------|---------|-------------------|-------------|")

  for (i in seq_len(nrow(cycle_diffs))) {
    diff <- cycle_diffs[i, ]
    current_mark <- if (diff$in_current) "✓" else "✗"
    mockdata_mark <- if (diff$in_mockdata_functions) "✓" else "✗"

    md_lines <- c(md_lines,
                  sprintf("| %s | %s | %s | %s |",
                         diff$variable, current_mark, mockdata_mark, diff$explanation_detail))
  }

  md_lines <- c(md_lines, "")
}

# Add methodology notes
md_lines <- c(md_lines,
              "---",
              "",
              "## Explanation Categories",
              "",
              "**Raw vs harmonized name**: Variable exists in both but with different names. Current uses harmonized name (e.g., `ammdmva1`), mockdata functions uses raw cycle-specific name (e.g., `amsdmva1` for cycle1).",
              "",
              "**Not in metadata**: Variable present in current data but not found in `variables.csv`. May be real CHMS variable not included in harmonization, or outdated/incorrect variable name.",
              "",
              "**Wrong cycle**: Variable exists in metadata but for different cycles. Example: `paadtot` exists in cycle3+ but current includes it in cycle1.",
              "",
              "**Metadata-driven**: Variable exists in metadata with harmonization specifications but was not included in current manual data. Mockdata functions includes all variables from metadata.",
              "",
              "**Not in variable_details**: Variable found in `variables.csv` but no recoding specifications for this cycle in `variable_details.csv`.",
              "",
              "---",
              "",
              "## Files",
              "",
              "**Machine-readable data**: [MOCKDATA_COMPARISON.csv](MOCKDATA_COMPARISON.csv)",
              "",
              "**Current approach**: [data-raw/prep-dummy-data.R](data-raw/prep-dummy-data.R)",
              "",
              "**MockData functions**:",
              "- [R/create_cat_var.R](R/create_cat_var.R)",
              "- [R/create_con_var.R](R/create_con_var.R)",
              "- [R/parse-range-notation.R](R/parse-range-notation.R)",
              "- [data-raw/test-all-cycles.R](data-raw/test-all-cycles.R)",
              "",
              "---",
              "",
              "## Next Steps",
              "",
              "This comparison identifies differences for team review. Key questions:",
              "",
              "1. Should mock data use raw or harmonized variable names?",
              "2. Should variables not in metadata (e.g., gen_015) be included?",
              "3. Is current coverage (72-75 vars/cycle) intentionally minimal or should it be comprehensive?",
              "4. Should variables from wrong cycles (e.g., paadtot in cycle1) be removed?",
              "",
              "See [MOCKDATA_QUESTIONS.md](MOCKDATA_QUESTIONS.md) for detailed questions.")

# Write markdown
writeLines(md_lines, "MOCKDATA_COMPARISON.md")
cat("Wrote MOCKDATA_COMPARISON.md\n")

cat(sprintf("\n=== Summary ===\n"))
cat(sprintf("Total differences identified: %d\n", nrow(differences_df)))
cat(sprintf("Total current variables: %d\n", total_current))
cat(sprintf("Total mockdata functions variables: %d\n", total_mockdata))
cat(sprintf("Difference: %+d\n", total_diff))
