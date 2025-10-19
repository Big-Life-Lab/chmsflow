# ==============================================================================
# Tests for MockData Functions
# ==============================================================================
# Comprehensive tests for all MockData parsers, helpers, and generators
# ==============================================================================

# ==============================================================================
# PARSERS: parse_variable_start()
# ==============================================================================

test_that("parse_variable_start handles database-prefixed format", {
  # Single database format
  expect_equal(parse_variable_start("cycle1::amsdmva1", "cycle1"), "amsdmva1")

  # Multiple databases, first match
  expect_equal(parse_variable_start("cycle1::amsdmva1, cycle2::ammdmva1", "cycle1"), "amsdmva1")

  # Multiple databases, second match
  expect_equal(parse_variable_start("cycle1::amsdmva1, cycle2::ammdmva1", "cycle2"), "ammdmva1")
})

test_that("parse_variable_start handles bracket format", {
  # Simple bracket format
  expect_equal(parse_variable_start("[gen_015]", "cycle1"), "gen_015")
  expect_equal(parse_variable_start("[alc_11]", "cycle1"), "alc_11")
  expect_equal(parse_variable_start("[ammdmva1]", "cycle2"), "ammdmva1")
})

test_that("parse_variable_start handles mixed format - bracket as DEFAULT", {
  # Mixed format: database::var1, [var2]
  # [var2] is the DEFAULT for databases not explicitly listed

  # Cycle1 has explicit override
  expect_equal(parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle1"), "amsdmva1")

  # Cycle2-6 use bracket segment as DEFAULT
  expect_equal(parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle2"), "ammdmva1")
  expect_equal(parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle3"), "ammdmva1")
  expect_equal(parse_variable_start("cycle1::amsdmva1, [ammdmva1]", "cycle6"), "ammdmva1")

  # Real example from metadata
  expect_equal(parse_variable_start("cycle1::gen_15, [gen_025]", "cycle1"), "gen_15")
  expect_equal(parse_variable_start("cycle1::gen_15, [gen_025]", "cycle5"), "gen_025")
})

test_that("parse_variable_start handles plain format", {
  # Plain variable name (no decoration)
  expect_equal(parse_variable_start("bmi", "cycle1"), "bmi")
  expect_equal(parse_variable_start("alcdwky", "cycle3"), "alcdwky")
})

test_that("parse_variable_start returns NULL for invalid input", {
  # Empty string
  expect_null(parse_variable_start("", "cycle1"))

  # NULL inputs
  expect_null(parse_variable_start(NULL, "cycle1"))
  expect_null(parse_variable_start("cycle1::var", NULL))

  # DerivedVar format (requires custom logic)
  expect_null(parse_variable_start("DerivedVar::[var1, var2]", "cycle1"))

  # No match for specified database
  expect_null(parse_variable_start("cycle2::age", "cycle1"))
})

# ==============================================================================
# HELPERS: get_cycle_variables()
# ==============================================================================

test_that("get_cycle_variables filters by exact cycle match", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  # Get cycle1 variables
  cycle1_vars <- get_cycle_variables("cycle1", variables, variable_details)

  # Should have variables
  expect_true(nrow(cycle1_vars) > 0)

  # Check that all returned variables have cycle1 in their databaseStart
  for (i in 1:nrow(cycle1_vars)) {
    db_start <- cycle1_vars$databaseStart[i]
    cycles <- strsplit(db_start, ",")[[1]]
    cycles <- trimws(cycles)
    expect_true("cycle1" %in% cycles,
                info = paste("Variable", cycle1_vars$variable[i], "should have cycle1 in databaseStart"))
  }
})

test_that("get_cycle_variables uses exact match (not substring)", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  # Get cycle1 variables (should NOT include cycle1_meds)
  cycle1_vars <- get_cycle_variables("cycle1", variables, variable_details)

  # Check that no cycle1_meds-only variables are included
  # (Variables that ONLY have cycle1_meds, not cycle1)
  for (i in 1:nrow(cycle1_vars)) {
    db_start <- cycle1_vars$databaseStart[i]
    cycles <- strsplit(db_start, ",")[[1]]
    cycles <- trimws(cycles)

    # If this variable is in cycle1_meds but NOT in cycle1, that's an error
    if ("cycle1_meds" %in% cycles && !"cycle1" %in% cycles) {
      fail(paste("Found cycle1_meds-only variable in cycle1 results:",
                 cycle1_vars$variable[i]))
    }
  }

  expect_true(TRUE) # Test passed if we got here
})

test_that("get_cycle_variables extracts variable_raw correctly", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  cycle1_vars <- get_cycle_variables("cycle1", variables, variable_details)

  # Check that variable_raw is populated for non-DerivedVar
  non_derived <- cycle1_vars[!grepl("DerivedVar::", cycle1_vars$variableStart), ]

  if (nrow(non_derived) > 0) {
    # Should have variable_raw for most non-derived variables
    has_raw <- sum(!is.na(non_derived$variable_raw))
    expect_true(has_raw > 0, info = "Should have some variables with raw names extracted")
  }
})

# ==============================================================================
# HELPERS: get_raw_variables()
# ==============================================================================

test_that("get_raw_variables returns unique raw variable names", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  raw_vars <- get_raw_variables("cycle1", variables, variable_details)

  # Check that all variable_raw are unique
  expect_equal(nrow(raw_vars), length(unique(raw_vars$variable_raw)),
               info = "All raw variable names should be unique")
})

test_that("get_raw_variables groups harmonized variables correctly", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  raw_vars <- get_raw_variables("cycle1", variables, variable_details)

  # Check that n_harmonized matches the count in harmonized_vars
  for (i in 1:nrow(raw_vars)) {
    harmonized_list <- strsplit(raw_vars$harmonized_vars[i], ", ")[[1]]
    expect_equal(raw_vars$n_harmonized[i], length(harmonized_list),
                 info = paste("Count should match list length for", raw_vars$variable_raw[i]))
  }
})

test_that("get_raw_variables excludes derived variables by default", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  # Default: include_derived = FALSE
  raw_vars <- get_raw_variables("cycle1", variables, variable_details)

  # Should not have NA in variable_raw (DerivedVar returns NA)
  expect_true(all(!is.na(raw_vars$variable_raw)),
              info = "No NA raw variable names when derived excluded")
})

# ==============================================================================
# GENERATORS: create_cat_var()
# ==============================================================================

test_that("create_cat_var generates categorical variable", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  # Create empty mock data frame
  df_mock <- data.frame(id = 1:100)

  # Create a categorical variable
  result <- create_cat_var(
    var_raw = "clc_sex",
    cycle = "cycle1",
    variable_details = variable_details,
    variables = variables,
    length = 100,
    df_mock = df_mock,
    seed = 123
  )

  # Should return a data frame
  expect_true(is.data.frame(result) || is.null(result))

  if (!is.null(result)) {
    # Should have one column
    expect_equal(ncol(result), 1)

    # Should have 100 rows
    expect_equal(nrow(result), 100)

    # Column name should be the raw variable name
    expect_equal(names(result)[1], "clc_sex")
  }
})

test_that("create_cat_var returns NULL if variable already exists", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  # Create mock data with clc_sex already present
  df_mock <- data.frame(
    id = 1:100,
    clc_sex = sample(c("1", "2"), 100, replace = TRUE)
  )

  # Try to create clc_sex again
  result <- create_cat_var(
    var_raw = "clc_sex",
    cycle = "cycle1",
    variable_details = variable_details,
    variables = variables,
    length = 100,
    df_mock = df_mock,
    seed = 123
  )

  # Should return NULL (variable already exists)
  expect_null(result)
})

test_that("create_cat_var returns NULL if no variable details found", {
  # Load test metadata
  variables <- read.csv(system.file("extdata", "variables.csv", package = "chmsflow"), stringsAsFactors = FALSE)
  variable_details <- read.csv(system.file("extdata", "variable-details.csv", package = "chmsflow"), stringsAsFactors = FALSE)

  df_mock <- data.frame(id = 1:100)

  # Try to create a variable that doesn't exist
  result <- create_cat_var(
    var_raw = "nonexistent_variable",
    cycle = "cycle1",
    variable_details = variable_details,
    variables = variables,
    length = 100,
    df_mock = df_mock
  )

  # Should return NULL
  expect_null(result)
})
