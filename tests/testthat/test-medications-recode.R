# test-medications-recode.R

# Test for recode_meds_cycles1to2
test_that("recode_meds_cycles1to2 merges numeric med variables into main cycle data", {
  # General tests - wide-format meds data (one row per person, 80 ATC/MHR columns)
  mock_cycle1 <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  atc_cols <- paste0("atc_", c(101:115, 131:135, 201:215, 231:235), "a")
  mhr_cols <- paste0("mhr_", c(101:115, 131:135, 201:215, 231:235), "b")
  mock_meds <- cbind(
    data.frame(clinicid = c(1, 2)),
    setNames(data.frame(matrix(NA_character_, nrow = 2, ncol = length(atc_cols))), atc_cols),
    setNames(data.frame(matrix(NA_real_, nrow = 2, ncol = length(mhr_cols))), mhr_cols)
  )
  # Person 1 takes a beta blocker; person 2 has no medications
  mock_meds$atc_101a[1] <- "C07AA05"
  mock_meds$mhr_101b[1] <- 1

  result <- recode_meds_cycles1to2(
    mock_cycle1,
    mock_meds,
    "any_htn_med",
    meds_database_name = "cycle1_meds"
  )

  # Output structure - same rows as main cycle data with med column added
  expect_equal(nrow(result), 2)
  expect_true("some_var" %in% names(result))
  expect_true(is.numeric(result$any_htn_med))

  # General tests - person 1 has antihypertensive; person 2 does not
  expect_equal(result$any_htn_med[result$clinicid == 1], 1)
  expect_equal(result$any_htn_med[result$clinicid == 2], 0)
})

# Test for aggregate_meds_by_person
test_that("aggregate_meds_by_person returns one row per person with max value", {
  # General tests - multiple rows per person, max aggregation
  df <- data.frame(
    clinicid = c(1, 1, 2, 2),
    any_htn_med = c(0, 1, 0, 0),
    diab_med = c(1, 0, 0, 0)
  )
  result <- aggregate_meds_by_person(df, variables = c("any_htn_med", "diab_med"))

  # One row per person
  expect_equal(nrow(result), 2)
  # Person 1: max of (0,1)=1 for any_htn_med; max of (1,0)=1 for diab_med
  expect_equal(result$any_htn_med[result$clinicid == 1], 1)
  expect_equal(result$diab_med[result$clinicid == 1], 1)
  # Person 2: all zeros
  expect_equal(result$any_htn_med[result$clinicid == 2], 0)
  expect_equal(result$diab_med[result$clinicid == 2], 0)
})

test_that("aggregate_meds_by_person returns tagged_na('b') when all values are NA", {
  # Edge case tests - all NA rows for a person returns missing code
  df <- data.frame(clinicid = c(1, 1), any_htn_med = c(NA_real_, NA_real_))
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_true(haven::is_tagged_na(result$any_htn_med[1], "b"))
})

test_that("aggregate_meds_by_person returns tagged_na('a') when all values are tagged_na('a')", {
  # Respondent legitimately not in meds sub-sample - must not be reclassified as missing
  df <- data.frame(
    clinicid = c(1, 1, 1),
    any_htn_med = c(haven::tagged_na("a"), haven::tagged_na("a"), haven::tagged_na("a"))
  )
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_true(haven::is_tagged_na(result$any_htn_med[1], "a"))
})

test_that("aggregate_meds_by_person prefers concrete value over tagged_na('a')", {
  # Mixed valid skip + concrete: concrete wins via max()
  df <- data.frame(
    clinicid = c(1, 1, 1),
    any_htn_med = c(haven::tagged_na("a"), 0, 1)
  )
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_equal(unname(result$any_htn_med[1]), 1)
})

test_that("aggregate_meds_by_person prefers concrete value over tagged_na('b')", {
  # Mixed missing + concrete: concrete wins via max()
  df <- data.frame(
    clinicid = c(1, 1),
    any_htn_med = c(haven::tagged_na("b"), 0)
  )
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_equal(unname(result$any_htn_med[1]), 0)
})

test_that("aggregate_meds_by_person treats mixed tags without concretes as missing", {
  # Mixed tagged_na('a') and tagged_na('b'): falls through to 'b'
  df <- data.frame(
    clinicid = c(1, 1),
    any_htn_med = c(haven::tagged_na("a"), haven::tagged_na("b"))
  )
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_true(haven::is_tagged_na(result$any_htn_med[1], "b"))
})

# Test for recode_meds_cycles3to6
test_that("recode_meds_cycles3to6 merges numeric med variables into main cycle data", {
  # General tests - long-format meds data (one row per medication per person)
  mock_cycle3 <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  mock_meds <- data.frame(
    clinicid = c(1, 1, 2),
    meucatc  = c("C07AA05", "A10BA02", "M01AE01"),
    npi_25b  = c(1, 1, 1)
  )
  result <- recode_meds_cycles3to6(
    mock_cycle3,
    mock_meds,
    c("any_htn_med", "diab_med"),
    meds_database_name = "cycle3_meds"
  )

  # Output structure - same rows as main cycle data with med columns added
  expect_equal(nrow(result), 2)
  expect_true("some_var" %in% names(result))
  expect_true(is.numeric(result$any_htn_med))
  expect_true(is.numeric(result$diab_med))

  # General tests - person 1 has beta blocker (any_htn_med=1) and diabetes med (diab_med=1)
  expect_equal(result$any_htn_med[result$clinicid == 1], 1)
  expect_equal(result$diab_med[result$clinicid == 1], 1)

  # General tests - person 2 has NSAID only (neither htn nor diab med)
  expect_equal(result$any_htn_med[result$clinicid == 2], 0)
  expect_equal(result$diab_med[result$clinicid == 2], 0)
})

# Test for recode_after_meds
test_that("recode_after_meds passes through derived medication variables", {
  # General tests - derived medication variable already in main cycle data is passed through
  mock_cycle <- data.frame(clinicid = c(1, 2), any_htn_med = c(1, 0))
  result <- recode_after_meds(mock_cycle, "any_htn_med", database_name = "cycle3")

  expect_true("clinicid" %in% names(result))
  expect_true("any_htn_med" %in% names(result))
  expect_equal(as.numeric(as.character(result$any_htn_med)), c(1, 0))
})

test_that("recode_after_meds excludes _meds rows from variable_details", {
  # Edge case tests - without the filter, rec_with_table would try to derive
  # any_htn_med from meucatc/npi_25b which are absent from main cycle data
  mock_cycle <- data.frame(clinicid = c(1, 2), any_htn_med = c(1, 0))
  expect_no_error(recode_after_meds(mock_cycle, "any_htn_med", database_name = "cycle3"))
})

test_that("recode_after_meds returns exactly one `by` column", {
  # Edge case tests - guard against bind_cols silently emitting clinicid...1 / clinicid...2
  # if rec_with_table ever passes the by column through itself
  mock_cycle <- data.frame(clinicid = c(1, 2), any_htn_med = c(1, 0))
  result <- recode_after_meds(mock_cycle, "any_htn_med", database_name = "cycle3")
  expect_equal(sum(names(result) == "clinicid"), 1)
})

test_that("recode_meds_cycles1to2 normalizes uppercase column names", {
  # Edge case tests - cycles 1-2 RDC data ships with uppercase columns (CLINICID,
  # ATC_101A, etc.); the function tolower()s them internally
  mock_cycle1 <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  atc_cols_upper <- paste0("ATC_", c(101:115, 131:135, 201:215, 231:235), "A")
  mhr_cols_upper <- paste0("MHR_", c(101:115, 131:135, 201:215, 231:235), "B")
  mock_meds <- cbind(
    data.frame(CLINICID = c(1, 2)),
    setNames(data.frame(matrix(NA_character_, nrow = 2, ncol = length(atc_cols_upper))), atc_cols_upper),
    setNames(data.frame(matrix(NA_real_, nrow = 2, ncol = length(mhr_cols_upper))), mhr_cols_upper)
  )
  mock_meds$ATC_101A[1] <- "C07AA05"
  mock_meds$MHR_101B[1] <- 1
  result <- recode_meds_cycles1to2(
    mock_cycle1, mock_meds, "any_htn_med",
    meds_database_name = "cycle1_meds"
  )
  expect_equal(result$any_htn_med[result$clinicid == 1], 1)
  expect_equal(result$any_htn_med[result$clinicid == 2], 0)
})
test_that("recode_meds_cycles3to6 warns when meds respondents are absent from cycle data", {
  # Edge case tests - clinicid 99 exists in meds_data but not in cycle data,
  # so check_join_keys should warn that those rows will be dropped from result.
  mock_cycle <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  mock_meds <- data.frame(
    clinicid = c(1, 1, 2, 99),
    meucatc  = c("C07AA05", "A10BA02", "M01AE01", "C07AA05"),
    npi_25b  = c(1, 1, 1, 1)
  )
  expect_warning(
    recode_meds_cycles3to6(
      mock_cycle, mock_meds, c("any_htn_med", "diab_med"),
      meds_database_name = "cycle3_meds"
    ),
    "respondent.*not found in `data`"
  )
})

test_that("recode_meds_cycles3to6 warns when cycle respondents are absent from meds_data", {
  # Edge case tests - clinicid 3 exists in cycle data but not in meds_data,
  # so check_join_keys should warn that medication columns will be NA.
  mock_cycle <- data.frame(clinicid = c(1, 2, 3), some_var = c(10, 20, 30))
  mock_meds <- data.frame(
    clinicid = c(1, 2),
    meucatc  = c("C07AA05", "M01AE01"),
    npi_25b  = c(1, 1)
  )
  expect_warning(
    recode_meds_cycles3to6(
      mock_cycle, mock_meds, "any_htn_med",
      meds_database_name = "cycle3_meds"
    ),
    "respondent.*not found in.*meds_data"
  )
})

test_that("recode_meds_cycles1to2 errors when inferred meds_database_name is unknown", {
  # Edge case tests - deparse(substitute(meds_data)) under aliasing or pipes can
  # yield a name that does not match any variable_details databaseStart entry,
  # which would otherwise produce silent NA columns.
  mock_cycle <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  atc_cols <- paste0("atc_", c(101:115, 131:135, 201:215, 231:235), "a")
  mhr_cols <- paste0("mhr_", c(101:115, 131:135, 201:215, 231:235), "b")
  mock_meds <- cbind(
    data.frame(clinicid = c(1, 2)),
    setNames(data.frame(matrix(NA_character_, nrow = 2, ncol = length(atc_cols))), atc_cols),
    setNames(data.frame(matrix(NA_real_, nrow = 2, ncol = length(mhr_cols))), mhr_cols)
  )
  expect_error(
    recode_meds_cycles1to2(
      mock_cycle, mock_meds, "any_htn_med",
      meds_database_name = "totally_made_up_db"
    ),
    "No rows in `variable_details`"
  )
})

test_that("aggregate_meds_by_person returns an ungrouped tibble", {
  # Edge case tests - .groups = "drop" prevents downstream surprises for callers
  # that don't expect a grouped result
  df <- data.frame(clinicid = c(1, 1, 2), any_htn_med = c(0, 1, 0))
  result <- aggregate_meds_by_person(df, variables = "any_htn_med")
  expect_false(dplyr::is_grouped_df(result))
})

test_that("recode_after_meds preserves row alignment when data is row-shuffled", {
  # Edge case tests - row-shuffled input must produce row-aligned output, otherwise
  # respondents get paired with the wrong recoded values
  mock_cycle <- data.frame(clinicid = 1:4, any_htn_med = c(1, 0, 1, 0))
  shuffled <- mock_cycle[c(3, 1, 4, 2), ]
  result <- recode_after_meds(shuffled, "any_htn_med", database_name = "cycle3")
  expect_equal(result$clinicid, c(3, 1, 4, 2))
  expect_equal(as.numeric(as.character(result$any_htn_med)), c(1, 1, 0, 0))
})
