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

  # Edge case tests - empty/NA strings
  expect_equal(is_beta_blocker("", 1), 0) # missing inputs
  expect_true(haven::is_tagged_na(is_beta_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 6), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 7), "b"))

  # Vector tests
  expect_equal(is_beta_blocker(c("C07AA05", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C07AA05", "C07AA07"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(bb = is_beta_blocker(med, last)) %>% dplyr::pull(bb), c(1, 0))
})

# Test for is_ace_inhibitor
test_that("is_ace_inhibitor returns correct values", {
  # General tests
  expect_equal(is_ace_inhibitor("C09AA02", 1), 1)
  expect_equal(is_ace_inhibitor("C08AA02", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_ace_inhibitor("", 1), 0)
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 7), "b"))

  # Vector tests
  expect_equal(is_ace_inhibitor(c("C09AA02", "C08AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C09AA02", "C08AA02"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(ace = is_ace_inhibitor(med, last)) %>% dplyr::pull(ace), c(1, 0))
})

# Test for is_diuretic
test_that("is_diuretic returns correct values", {
  # General tests
  expect_equal(is_diuretic("C03AA03", 1), 1)
  expect_equal(is_diuretic("C03BA08", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_diuretic("", 1), 0)
  expect_true(haven::is_tagged_na(is_diuretic("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 6), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 7), "b"))

  # Vector tests
  expect_equal(is_diuretic(c("C03AA03", "C03BA08"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C03AA03", "C03BA08"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(diur = is_diuretic(med, last)) %>% dplyr::pull(diur), c(1, 0))
})

# Test for is_calcium_channel_blocker
test_that("is_calcium_channel_blocker returns correct values", {
  # General tests
  expect_equal(is_calcium_channel_blocker("C08CA01", 1), 1)
  expect_equal(is_calcium_channel_blocker("C07CA01", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_calcium_channel_blocker("", 1), 0)
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 6), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 7), "b"))

  # Vector tests
  expect_equal(is_calcium_channel_blocker(c("C08CA01", "C07CA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C08CA01", "C07CA01"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(ccb = is_calcium_channel_blocker(med, last)) %>% dplyr::pull(ccb), c(1, 0))
})

# Test for is_other_antiHTN_med
test_that("is_other_antiHTN_med returns correct values", {
  # General tests
  expect_equal(is_other_antiHTN_med("C02AB01", 1), 1)
  expect_equal(is_other_antiHTN_med("C02KX01", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_other_antiHTN_med("", 1), 0)
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_other_antiHTN_med(c("C02AB01", "C02KX01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C02KX01"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(other = is_other_antiHTN_med(med, last)) %>% dplyr::pull(other), c(1, 0))
})

# Test for is_any_antiHTN_med
test_that("is_any_antiHTN_med returns correct values", {
  # General tests
  expect_equal(is_any_antiHTN_med("C02AB01", 1), 1)
  expect_equal(is_any_antiHTN_med("C03AA03", 1), 1)
  expect_equal(is_any_antiHTN_med("C07AA05", 1), 1)
  expect_equal(is_any_antiHTN_med("C08CA01", 1), 1)
  expect_equal(is_any_antiHTN_med("C09AA02", 1), 1)
  expect_equal(is_any_antiHTN_med("C07AA07", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_any_antiHTN_med("", 1), 0)
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_any_antiHTN_med(c("C02AB01", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C07AA07"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(any = is_any_antiHTN_med(med, last)) %>% dplyr::pull(any), c(1, 0))
})

# Test for is_NSAID
test_that("is_NSAID returns correct values", {
  # General tests
  expect_equal(is_NSAID("M01AE01", 1), 1)
  expect_equal(is_NSAID("M02AA01", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_NSAID("", 1), 0)
  expect_true(haven::is_tagged_na(is_NSAID("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_NSAID("M01AE01", 6), "a"))
  expect_true(haven::is_tagged_na(is_NSAID("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_NSAID("M01AE01", 7), "b"))

  # Vector tests
  expect_equal(is_NSAID(c("M01AE01", "M02AA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("M01AE01", "M02AA01"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(nsaid = is_NSAID(med, last)) %>% dplyr::pull(nsaid), c(1, 0))
})

# Test for is_diabetes_drug
test_that("is_diabetes_drug returns correct values", {
  # General tests
  expect_equal(is_diabetes_drug("A10BA02", 1), 1)
  expect_equal(is_diabetes_drug("A09AA02", 1), 0)

  # Edge case tests - missing inputs
  expect_equal(is_diabetes_drug("", 1), 0)
  expect_true(haven::is_tagged_na(is_diabetes_drug("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("A10BA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("A10BA02", 7), "b"))

  # Vector tests
  expect_equal(is_diabetes_drug(c("A10BA02", "A09AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("A10BA02", "A09AA02"), last = c(1, 1))
  expect_equal(df %>% dplyr::mutate(diab = is_diabetes_drug(med, last)) %>% dplyr::pull(diab), c(1, 0))
})

# Test for cycles1to2_ace_inhibitors
test_that("cycles1to2_ace_inhibitors returns correct values", {
  # General tests
  expect_equal(cycles1to2_ace_inhibitors(atc_101a = "C09AA02", mhr_101b = 1), 1)
  expect_equal(cycles1to2_ace_inhibitors(atc_101a = "C08AA02", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = "C09AA02", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = "C09AA02", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_ace_inhibitors(atc_101a = "C09AA02", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_beta_blockers
test_that("cycles1to2_beta_blockers returns correct values", {
  # General tests
  expect_equal(cycles1to2_beta_blockers(atc_101a = "C07AA05", mhr_101b = 1), 1)
  expect_equal(cycles1to2_beta_blockers(atc_101a = "C07AA07", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = "C07AA05", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = "C07AA05", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_beta_blockers(atc_101a = "C07AA05", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_diuretics
test_that("cycles1to2_diuretics returns correct values", {
  # General tests
  expect_equal(cycles1to2_diuretics(atc_101a = "C03AA03", mhr_101b = 1), 1)
  expect_equal(cycles1to2_diuretics(atc_101a = "C03BA08", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = "C03AA03", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = "C03AA03", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_diuretics(atc_101a = "C03AA03", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_calcium_channel_blockers
test_that("cycles1to2_calcium_channel_blockers returns correct values", {
  # General tests
  expect_equal(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_calcium_channel_blockers(atc_101a = "C07CA01", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_other_antiHTN_meds
test_that("cycles1to2_other_antiHTN_meds returns correct values", {
  # General tests
  expect_equal(cycles1to2_other_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_other_antiHTN_meds(atc_101a = "C02KX01", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_other_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_any_antiHTN_meds
test_that("cycles1to2_any_antiHTN_meds returns correct values", {
  # General tests
  expect_equal(cycles1to2_any_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_any_antiHTN_meds(atc_101a = "C07AA07", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_any_antiHTN_meds(atc_101a = "C02AB01", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_nsaid
test_that("cycles1to2_nsaid returns correct values", {
  # General tests
  expect_equal(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_nsaid(atc_101a = "M02AA01", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = NA_real_), "b"))
})

# Test for cycles1to2_diabetes_drugs
test_that("cycles1to2_diabetes_drugs returns correct values", {
  # General tests
  expect_equal(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = 1), 1)
  expect_equal(cycles1to2_diabetes_drugs(atc_101a = "A09AA02", mhr_101b = 1), 0)

  # Edge case tests - missing data should return tagged NA
  # Valid skip (code 9999996 or mhr 6) returns tagged NA "a"
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = "9999996", mhr_101b = 1), "a"))
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = 6), "a"))

  # Don't know/refusal (codes 9999997+ or mhr 7+) returns tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = "9999997", mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = 7), "b"))

  # R NA values return tagged NA "b"
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = NA_character_, mhr_101b = 1), "b"))
  expect_true(haven::is_tagged_na(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = NA_real_), "b"))
})
