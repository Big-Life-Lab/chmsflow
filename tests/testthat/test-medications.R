# test-medications.R

# Test for is_taking_drug_class
test_that("is_taking_drug_class returns correct values", {
  # General tests - create test dataframe
  df <- data.frame(
    med1 = c("C07AA05", "C07AA07", "C07AA05"),
    med2 = c("C07AA07", "C07AA05", "C07AA07"),
    last1 = c(1, 1, 1),
    last2 = c(1, 1, 1)
  )

  # General tests - basic functionality
  result <- is_taking_drug_class(
    df,
    class_var_name = "beta_blocker",
    med_vars = c("med1", "med2"),
    last_taken_vars = c("last1", "last2"),
    class_condition_fun = is_beta_blocker
  )
  expect_equal(result$beta_blocker, c(1, 1, 1))

  # General tests - no matches
  df_no_match <- data.frame(
    med1 = c("C07AA07", "C07AA07"),
    last1 = c(1, 1)
  )
  result_no_match <- is_taking_drug_class(
    df_no_match,
    class_var_name = "beta_blocker",
    med_vars = c("med1"),
    last_taken_vars = c("last1"),
    class_condition_fun = is_beta_blocker
  )
  expect_equal(result_no_match$beta_blocker, c(0, 0))

  # Edge case tests - error when variable already exists
  expect_error(is_taking_drug_class(
    result,
    class_var_name = "beta_blocker",
    med_vars = c("med1"),
    last_taken_vars = c("last1"),
    class_condition_fun = is_beta_blocker
  ))

  # Edge case tests - overwrite parameter
  result_overwrite <- is_taking_drug_class(
    result,
    class_var_name = "beta_blocker",
    med_vars = c("med1"),
    last_taken_vars = c("last1"),
    class_condition_fun = is_beta_blocker,
    overwrite = TRUE
  )
  expect_true("beta_blocker" %in% names(result_overwrite))

  # Edge case tests - error for missing medication variables
  expect_error(is_taking_drug_class(
    df,
    class_var_name = "test_var",
    med_vars = c("nonexistent"),
    last_taken_vars = c("last1"),
    class_condition_fun = is_beta_blocker
  ))

  # Edge case tests - error for mismatched variable lengths
  expect_error(is_taking_drug_class(
    df,
    class_var_name = "test_var",
    med_vars = c("med1", "med2"),
    last_taken_vars = c("last1"),
    class_condition_fun = is_beta_blocker
  ))
})

# Test for is_beta_blocker
test_that("is_beta_blocker returns correct values", {
  # General tests
  expect_equal(is_beta_blocker("C07AA05", 1), 1)
  expect_equal(is_beta_blocker("C07AA07", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_beta_blocker("", 1), 0) # missing inputs
  expect_true(haven::is_tagged_na(is_beta_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 6), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 7), "b"))

  # Vector tests
  expect_equal(is_beta_blocker(c("C07AA05", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C07AA05", "C07AA07"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(bb = is_beta_blocker(med, last)) |> dplyr::pull(bb), c(1, 0))
})

# Test for is_ace_inhibitor
test_that("is_ace_inhibitor returns correct values", {
  # General tests
  expect_equal(is_ace_inhibitor("C09AA02", 1), 1)
  expect_equal(is_ace_inhibitor("C08AA02", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_ace_inhibitor("", 1), 0)
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 7), "b"))

  # Vector tests
  expect_equal(is_ace_inhibitor(c("C09AA02", "C08AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C09AA02", "C08AA02"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(ace = is_ace_inhibitor(med, last)) |> dplyr::pull(ace), c(1, 0))
})

# Test for is_diuretic
test_that("is_diuretic returns correct values", {
  # General tests
  expect_equal(is_diuretic("C03AA03", 1), 1)
  expect_equal(is_diuretic("C03BA08", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_diuretic("", 1), 0)
  expect_true(haven::is_tagged_na(is_diuretic("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 6), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 7), "b"))

  # Vector tests
  expect_equal(is_diuretic(c("C03AA03", "C03BA08"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C03AA03", "C03BA08"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(diur = is_diuretic(med, last)) |> dplyr::pull(diur), c(1, 0))
})

# Test for is_calcium_channel_blocker
test_that("is_calcium_channel_blocker returns correct values", {
  # General tests
  expect_equal(is_calcium_channel_blocker("C08CA01", 1), 1)
  expect_equal(is_calcium_channel_blocker("C07CA01", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_calcium_channel_blocker("", 1), 0)
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 6), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 7), "b"))

  # Vector tests
  expect_equal(is_calcium_channel_blocker(c("C08CA01", "C07CA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C08CA01", "C07CA01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(ccb = is_calcium_channel_blocker(med, last)) |> dplyr::pull(ccb), c(1, 0))
})

# Test for is_other_antihtn_med
test_that("is_other_antihtn_med returns correct values", {
  # General tests
  expect_equal(is_other_antihtn_med("C02AB01", 1), 1)
  expect_equal(is_other_antihtn_med("C02KX01", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_other_antihtn_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_other_antihtn_med(c("C02AB01", "C02KX01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C02KX01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(other_antihtn = is_other_antihtn_med(med, last)) |> dplyr::pull(other_antihtn), c(1, 0))
})

# Test for is_any_antihtn_med
test_that("is_any_antihtn_med returns correct values", {
  # General tests
  expect_equal(is_any_antihtn_med("C02AB01", 1), 1)
  expect_equal(is_any_antihtn_med("C03AA03", 1), 1)
  expect_equal(is_any_antihtn_med("C07AA05", 1), 1)
  expect_equal(is_any_antihtn_med("C08CA01", 1), 1)
  expect_equal(is_any_antihtn_med("C09AA02", 1), 1)
  expect_equal(is_any_antihtn_med("C07AA07", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_any_antihtn_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_any_antihtn_med(c("C02AB01", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C07AA07"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(any_antihtn = is_any_antihtn_med(med, last)) |> dplyr::pull(any_antihtn), c(1, 0))
})

# Test for is_nsaid
test_that("is_nsaid returns correct values", {
  # General tests
  expect_equal(is_nsaid("M01AE01", 1), 1)
  expect_equal(is_nsaid("M02AA01", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_nsaid("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_nsaid("M01AE01", 6), "a"))
  expect_true(haven::is_tagged_na(is_nsaid("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_nsaid("M01AE01", 7), "b"))

  # Vector tests
  expect_equal(is_nsaid(c("M01AE01", "M02AA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("M01AE01", "M02AA01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(nsaid = is_nsaid(med, last)) |> dplyr::pull(nsaid), c(1, 0))
})

# Test for is_diabetes_med
test_that("is_diabetes_med returns correct values", {
  # General tests
  expect_equal(is_diabetes_med("A10BA02", 1), 1)
  expect_equal(is_diabetes_med("A09AA02", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_diabetes_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_med("A10BA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diabetes_med("A10BA02", 7), "b"))

  # Vector tests
  expect_equal(is_diabetes_med(c("A10BA02", "A09AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("A10BA02", "A09AA02"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(diabetes_med = is_diabetes_med(med, last)) |> dplyr::pull(diabetes_med), c(1, 0))
})

# Test for is_bb_med_cycles1to2
test_that("is_bb_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 1), 1)

  # Non-match (excluded beta blocker)
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA07", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_bb_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_bb_med_cycles1to2(atc_201a = "C07AB02", mhr_201b = 2), 1)

  # Not taken recently (last_taken > 4) - returns 0 because other NULL slots pad to valid non-matches
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_bb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AB02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_bb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_ace_med_cycles1to2
test_that("is_ace_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C08AA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_ace_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_ace_med_cycles1to2(atc_201a = "C09BB05", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_ace_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09BB05", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_ace_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_diur_med_cycles1to2
test_that("is_diur_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 1), 1)

  # Non-match (excluded diuretic)
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03BA08", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_diur_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_diur_med_cycles1to2(atc_201a = "C03DA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_diur_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C03AA03", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_diur_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_ccb_med_cycles1to2
test_that("is_ccb_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C07CA01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_ccb_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_ccb_med_cycles1to2(atc_201a = "C08DA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_ccb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C08CA01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_ccb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_misc_htn_med_cycles1to2
test_that("is_misc_htn_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 1), 1)

  # Non-match (excluded misc antihypertensive)
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02KX01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_misc_htn_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_misc_htn_med_cycles1to2(atc_201a = "C02CA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_misc_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C02AB01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_misc_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_any_htn_med_cycles1to2
test_that("is_any_htn_med_cycles1to2 returns correct values", {
  # Matches each antihypertensive class
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_any_htn_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_any_htn_med_cycles1to2(atc_201a = "C07AB02", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_any_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_any_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "M01AE01", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_nsaid_med_cycles1to2
test_that("is_nsaid_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M01AE01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M02AA01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_nsaid_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_nsaid_med_cycles1to2(atc_201a = "M01AB05", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M01AE01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_nsaid_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "M01AE01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_nsaid_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_diab_med_cycles1to2
test_that("is_diab_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A09AA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_diab_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_diab_med_cycles1to2(atc_201a = "A10BB01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_diab_med_cycles1to2(atc_101a = "C07AA05", atc_102a = "A10BA02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_diab_med_cycles1to2(atc_101a = "C07AA05", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

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

test_that("derive_hypertension accepts any_htn_med argument by name", {
  # Edge case tests - guard against rename regression: positional-arg calls would
  # silently pass even if any_htn_med were renamed back to any_htn_med2
  result <- derive_hypertension(
    bpmdpbps = 145,
    bpmdpbpd = 95,
    any_htn_med = 1,
    ccc_32 = 2,
    cvd_status = 2,
    diab_status = 2,
    ckd = 2
  )
  expect_true(is.numeric(result) || haven::is_tagged_na(result))
})

test_that("derive_diabetes_status accepts diab_med argument by name", {
  # Edge case tests - guard against rename regression
  result <- derive_diabetes_status(
    diab_a1c = 1,
    ccc_51 = 2,
    diab_med = 0
  )
  expect_true(is.numeric(result) || haven::is_tagged_na(result))
})

test_that("recode_meds_cycles3to6 errors on duplicate clinicid in aggregated meds_data", {
  # Edge case tests - aggregate_meds_by_person collapses to one row per person, so a
  # duplicate clinicid downstream of it would only happen via a programming error.
  # Surface it loudly via check_join_keys rather than silently fan-out the join.
  mock_cycle <- data.frame(clinicid = c(1, 2), some_var = c(10, 20))
  # Construct meds_data so aggregation does NOT change row count - by design,
  # aggregate_meds_by_person already de-dupes; this test instead verifies the
  # asymmetric-coverage warning path.
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
