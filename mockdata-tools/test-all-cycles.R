# ==============================================================================
# Test Modular MockData Across All Cycles
# ==============================================================================
#
# Purpose: Test modular functions across all cycles and compare to manual approach
# Date: 2025-10-17

library(readr)
library(dplyr)

# Source MockData functions (grouped by purpose)
source("R/mockdata-parsers.R")     # parse_variable_start, parse_range_notation
source("R/mockdata-helpers.R")      # get_cycle_variables, get_raw_variables, get-variable-categories, get-variable-details-for-raw
source("R/mockdata-generators.R")  # create_cat_var, create_con_var

# Load metadata
variables <- read_csv("inst/extdata/variables.csv", show_col_types = FALSE)
variable_details <- read_csv("inst/extdata/variable-details.csv", show_col_types = FALSE)

cat("\n=== Testing Modular MockData Across All Cycles ===\n\n")

# Define cycles to test (based on prep-dummy-data.R)
cycles <- c("cycle1", "cycle2", "cycle3", "cycle4", "cycle5", "cycle6")
cycle_meds <- c("cycle1_meds", "cycle2_meds", "cycle3_meds", "cycle4_meds", "cycle5_meds", "cycle6_meds")

# Storage for results
all_results <- list()

# ==============================================================================
# Test each cycle
# ==============================================================================

for (cycle in cycles) {
  cat(sprintf("Testing %s...\n", cycle))

  # Get raw variables for this cycle
  raw_vars_all <- get_raw_variables(cycle, variables, variable_details, include_derived = FALSE)

  if (nrow(raw_vars_all) == 0) {
    cat(sprintf("  No variables found for %s\n\n", cycle))
    next
  }

  raw_vars_cat <- raw_vars_all[raw_vars_all$variableType == "Categorical", ]
  raw_vars_con <- raw_vars_all[raw_vars_all$variableType == "Continuous", ]

  # Generate mock data
  df_mock <- data.frame()
  n_obs <- 50  # Match prep-dummy-data.R
  success_cat <- 0
  success_con <- 0
  failed_vars <- character()

  # Categorical variables
  for (i in seq_len(nrow(raw_vars_cat))) {
    var_raw <- raw_vars_cat$variable_raw[i]

    result <- create_cat_var(
      var_raw = var_raw,
      cycle = cycle,
      variable_details = variable_details,
      variables = variables,
      length = n_obs,
      df_mock = df_mock,
      prop_NA = NULL,
      seed = 123  # Match prep-dummy-data.R
    )

    if (!is.null(result)) {
      if (ncol(df_mock) == 0) {
        df_mock <- result
      } else {
        df_mock <- cbind(df_mock, result)
      }
      success_cat <- success_cat + 1
    } else {
      failed_vars <- c(failed_vars, var_raw)
    }
  }

  # Continuous variables
  for (i in seq_len(nrow(raw_vars_con))) {
    var_raw <- raw_vars_con$variable_raw[i]

    result <- suppressWarnings(create_con_var(
      var_raw = var_raw,
      cycle = cycle,
      variable_details = variable_details,
      variables = variables,
      length = n_obs,
      df_mock = df_mock,
      prop_NA = NULL,
      seed = 123,
      distribution = "uniform"
    ))

    if (!is.null(result)) {
      if (ncol(df_mock) == 0) {
        df_mock <- result
      } else {
        df_mock <- cbind(df_mock, result)
      }
      success_con <- success_con + 1
    } else {
      failed_vars <- c(failed_vars, var_raw)
    }
  }

  # Calculate statistics
  total_vars <- nrow(raw_vars_all)
  total_success <- success_cat + success_con
  coverage_pct <- if (total_vars > 0) 100 * total_success / total_vars else 0

  # Store results
  all_results[[cycle]] <- list(
    total_raw_vars = total_vars,
    categorical = nrow(raw_vars_cat),
    continuous = nrow(raw_vars_con),
    generated_cat = success_cat,
    generated_con = success_con,
    generated_total = total_success,
    coverage_pct = coverage_pct,
    failed_vars = failed_vars,
    mock_data_cols = ncol(df_mock)
  )

  # Print summary
  cat(sprintf("  Raw variables: %d (cat: %d, con: %d)\n",
              total_vars, nrow(raw_vars_cat), nrow(raw_vars_con)))
  cat(sprintf("  Generated: %d/%d (%.1f%%)\n",
              total_success, total_vars, coverage_pct))
  cat(sprintf("  Mock data: %d rows × %d columns\n",
              nrow(df_mock), ncol(df_mock)))

  if (length(failed_vars) > 0) {
    cat(sprintf("  Failed: %d variables\n", length(failed_vars)))
  }

  cat("\n")
}

# ==============================================================================
# Test meds cycles
# ==============================================================================

for (cycle in cycle_meds) {
  cat(sprintf("Testing %s...\n", cycle))

  # Get raw variables for this cycle
  raw_vars_all <- get_raw_variables(cycle, variables, variable_details, include_derived = FALSE)

  if (nrow(raw_vars_all) == 0) {
    cat(sprintf("  No variables found for %s\n\n", cycle))
    all_results[[cycle]] <- list(
      total_raw_vars = 0,
      categorical = 0,
      continuous = 0,
      generated_cat = 0,
      generated_con = 0,
      generated_total = 0,
      coverage_pct = 0,
      failed_vars = character(),
      mock_data_cols = 0
    )
    next
  }

  raw_vars_cat <- raw_vars_all[raw_vars_all$variableType == "Categorical", ]
  raw_vars_con <- raw_vars_all[raw_vars_all$variableType == "Continuous", ]

  # Generate mock data
  df_mock <- data.frame()
  n_obs <- 50
  success_cat <- 0
  success_con <- 0
  failed_vars <- character()

  # Categorical variables
  for (i in seq_len(nrow(raw_vars_cat))) {
    var_raw <- raw_vars_cat$variable_raw[i]

    result <- create_cat_var(
      var_raw = var_raw,
      cycle = cycle,
      variable_details = variable_details,
      variables = variables,
      length = n_obs,
      df_mock = df_mock,
      prop_NA = NULL,
      seed = 123
    )

    if (!is.null(result)) {
      if (ncol(df_mock) == 0) {
        df_mock <- result
      } else {
        df_mock <- cbind(df_mock, result)
      }
      success_cat <- success_cat + 1
    } else {
      failed_vars <- c(failed_vars, var_raw)
    }
  }

  # Continuous variables
  for (i in seq_len(nrow(raw_vars_con))) {
    var_raw <- raw_vars_con$variable_raw[i]

    result <- suppressWarnings(create_con_var(
      var_raw = var_raw,
      cycle = cycle,
      variable_details = variable_details,
      variables = variables,
      length = n_obs,
      df_mock = df_mock,
      prop_NA = NULL,
      seed = 123,
      distribution = "uniform"
    ))

    if (!is.null(result)) {
      if (ncol(df_mock) == 0) {
        df_mock <- result
      } else {
        df_mock <- cbind(df_mock, result)
      }
      success_con <- success_con + 1
    } else {
      failed_vars <- c(failed_vars, var_raw)
    }
  }

  # Calculate statistics
  total_vars <- nrow(raw_vars_all)
  total_success <- success_cat + success_con
  coverage_pct <- if (total_vars > 0) 100 * total_success / total_vars else 0

  # Store results
  all_results[[cycle]] <- list(
    total_raw_vars = total_vars,
    categorical = nrow(raw_vars_cat),
    continuous = nrow(raw_vars_con),
    generated_cat = success_cat,
    generated_con = success_con,
    generated_total = total_success,
    coverage_pct = coverage_pct,
    failed_vars = failed_vars,
    mock_data_cols = ncol(df_mock)
  )

  # Print summary
  cat(sprintf("  Raw variables: %d (cat: %d, con: %d)\n",
              total_vars, nrow(raw_vars_cat), nrow(raw_vars_con)))
  cat(sprintf("  Generated: %d/%d (%.1f%%)\n",
              total_success, total_vars, coverage_pct))
  cat(sprintf("  Mock data: %d rows × %d columns\n",
              nrow(df_mock), ncol(df_mock)))

  if (length(failed_vars) > 0) {
    cat(sprintf("  Failed: %d variables (%s)\n",
                length(failed_vars),
                paste(head(failed_vars, 3), collapse=", ")))
  }

  cat("\n")
}

# ==============================================================================
# Summary comparison
# ==============================================================================

cat("=== Overall Summary ===\n\n")

# Create summary table
summary_df <- data.frame(
  cycle = names(all_results),
  total_vars = sapply(all_results, function(x) x$total_raw_vars),
  categorical = sapply(all_results, function(x) x$categorical),
  continuous = sapply(all_results, function(x) x$continuous),
  generated = sapply(all_results, function(x) x$generated_total),
  coverage_pct = sapply(all_results, function(x) x$coverage_pct),
  stringsAsFactors = FALSE
)

print(summary_df)

cat("\n")

# Overall statistics
total_vars_all_cycles <- sum(summary_df$total_vars)
total_generated_all_cycles <- sum(summary_df$generated)
overall_coverage <- if (total_vars_all_cycles > 0) {
  100 * total_generated_all_cycles / total_vars_all_cycles
} else {
  0
}

cat(sprintf("Overall across all cycles:\n"))
cat(sprintf("  Total raw variables: %d\n", total_vars_all_cycles))
cat(sprintf("  Generated: %d (%.1f%%)\n", total_generated_all_cycles, overall_coverage))

# Compare to prep-dummy-data.R
cat("\n=== Comparison to prep-dummy-data.R ===\n\n")

# Count variables in prep-dummy-data.R (manually coded)
prep_dummy_counts <- list(
  cycle1 = 72,       # Counted from lines 13-92
  cycle1_meds = 70,  # Counted from lines 94-171
  cycle2 = 72,       # Counted from lines 179-258
  cycle2_meds = 70,  # Counted from lines 260-337
  cycle3 = 73,       # Counted from lines 345-428
  cycle3_meds = 3,   # Lines 434-438 (clinicid, meucatc, npi_25b)
  cycle4 = 73,       # Counted from lines 446-529
  cycle4_meds = 3,   # Lines 535-539
  cycle5 = 75,       # Counted from lines 547-626
  cycle5_meds = 3,   # Lines 632-636
  cycle6 = 75,       # Counted from lines 644-722
  cycle6_meds = 3    # Lines 728-732
)

cat("prep-dummy-data.R manually codes:\n")
for (cycle_name in names(prep_dummy_counts)) {
  manual_count <- prep_dummy_counts[[cycle_name]]
  modular_count <- if (cycle_name %in% names(all_results)) {
    all_results[[cycle_name]]$mock_data_cols
  } else {
    0
  }

  diff <- modular_count - manual_count
  pct_of_manual <- if (manual_count > 0) 100 * modular_count / manual_count else 0

  cat(sprintf("  %s: manual=%d, modular=%d (%.1f%%) %s\n",
              cycle_name,
              manual_count,
              modular_count,
              pct_of_manual,
              if (diff > 0) sprintf("+%d more", diff) else if (diff < 0) sprintf("%d fewer", abs(diff)) else "equal"))
}

cat("\n=== CONCLUSION ===\n\n")
cat("The modular approach automatically generates mock data from metadata,\n")
cat("eliminating the need to manually code each variable's range for each cycle.\n")
cat(sprintf("Overall coverage: %.1f%% of raw variables across all cycles\n", overall_coverage))
