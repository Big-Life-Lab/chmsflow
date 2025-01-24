# test-medications.R
test_that("is_taking_drug_class computes correctly", {
  df <- data.frame(
    med1 = c("C07AA13", "C09AA02", "C07AG02"),
    last1 = c(3, 5, 1),
    med2 = c("C03AA03", NA, "C07AA12"),
    last2 = c(2, NA, 4)
  )

  class_condition_fun <- function(med_code, last_taken) {
    if (is.na(med_code) | is.na(last_taken)) {
      return(0)
    }
    return(as.numeric(startsWith(med_code, "C07") & last_taken <= 4))
  }

  result <- is_taking_drug_class(df, "class_var", c("med1", "med2"), c("last1", "last2"), class_condition_fun, overwrite = TRUE)
  # Expected: 1 (from med1), 0 (no valid combinations), 2 (from both med1 and med2)
  expect_equal(result$class_var, c(1, 0, 2))
})

test_that("is_beta_blocker identifies beta blockers correctly", {
  # Valid cases
  expect_equal(is_beta_blocker("C07AA13", 3), 1)
  expect_equal(is_beta_blocker("C07AA07", 3), 0) # Excluded code
  expect_equal(is_beta_blocker("C07AA13", 5), 0) # Taken more than a month ago

  # Edge cases
  expect_equal(is_beta_blocker(NA, 3), haven::tagged_na("b"))
  expect_equal(is_beta_blocker("C07AA13", NA), haven::tagged_na("b"))
})

test_that("is_ace_inhibitor identifies ACE inhibitors correctly", {
  # Valid cases
  expect_equal(is_ace_inhibitor("C09AA02", 2), 1)
  expect_equal(is_ace_inhibitor("C07AA13", 2), 0) # Not an ACE inhibitor

  # Edge cases
  expect_equal(is_ace_inhibitor(NA, 2), haven::tagged_na("b"))
  expect_equal(is_ace_inhibitor("C09AA02", NA), haven::tagged_na("b"))
})

test_that("is_diuretic identifies diuretics correctly", {
  # Valid cases
  expect_equal(is_diuretic("C03AA03", 3), 1)
  expect_equal(is_diuretic("C03BA08", 3), 0) # Excluded code
  expect_equal(is_diuretic("C03AA03", 5), 0) # Taken more than a month ago

  # Edge cases
  expect_equal(is_diuretic(NA, 3), haven::tagged_na("b"))
  expect_equal(is_diuretic("C03AA03", NA), haven::tagged_na("b"))
})

test_that("is_calcium_channel_blocker identifies calcium channel blockers correctly", {
  # Valid cases
  expect_equal(is_calcium_channel_blocker("C08CA05", 1), 1)
  expect_equal(is_calcium_channel_blocker("C03AA03", 1), 0) # Not a calcium channel blocker

  # Edge cases
  expect_equal(is_calcium_channel_blocker(NA, 1), haven::tagged_na("b"))
  expect_equal(is_calcium_channel_blocker("C08CA05", NA), haven::tagged_na("b"))
})

test_that("is_other_antiHTN_med works correctly", {
  # Valid cases
  expect_equal(is_other_antiHTN_med("C02AC04", 3), 1) # Valid anti-HTN medication
  expect_equal(is_other_antiHTN_med("C02KX01", 3), 0) # Excluded code
  expect_equal(is_other_antiHTN_med("C02AC04", 5), 0) # Taken more than a month ago

  # Edge cases
  expect_equal(is_other_antiHTN_med(NA, 3), haven::tagged_na("b")) # Missing ATC code
  expect_equal(is_other_antiHTN_med("C02AC04", NA), haven::tagged_na("b")) # Missing time response
})

test_that("is_any_antiHTN_med works correctly", {
  # Valid cases
  expect_equal(is_any_antiHTN_med("C07AB02", 4), 1) # Valid anti-HTN medication
  expect_equal(is_any_antiHTN_med("C07AA07", 2), 0) # Excluded code
  expect_equal(is_any_antiHTN_med("C03BA08", 4), 0) # Excluded code
  expect_equal(is_any_antiHTN_med("C03CA01", 3), 0) # Excluded code
  expect_equal(is_any_antiHTN_med("C09AA03", 2), 1) # Valid code and time taken

  # Edge cases
  expect_equal(is_any_antiHTN_med(NA, 4), haven::tagged_na("b")) # Missing ATC code
  expect_equal(is_any_antiHTN_med("C03BA08", NA), haven::tagged_na("b")) # Missing time response
})

test_that("is_diabetes_drug works correctly", {
  # Valid cases
  expect_equal(is_diabetes_drug("A10BB09", 3), 1) # Valid diabetes drug
  expect_equal(is_diabetes_drug("A10BB09", 5), 0) # Taken more than a month ago
  expect_equal(is_diabetes_drug("A11CC04", 2), 0) # Not a diabetes drug (prefix mismatch)

  # Edge cases
  expect_equal(is_diabetes_drug(NA, 3), haven::tagged_na("b")) # Missing ATC code
  expect_equal(is_diabetes_drug("A10BB09", NA), haven::tagged_na("b")) # Missing time response
})

test_that("cycles1to2_beta_blockers works correctly", {
  expect_equal(cycles1to2_beta_blockers(atc_101a = "C07AA13", mhr_101b = 3), 1)
  expect_equal(cycles1to2_beta_blockers(atc_101a = "C07AA07", mhr_101b = 5), 0)
  expect_equal(cycles1to2_beta_blockers(atc_101a = "C07AA13", mhr_101b = 6, atc_102a = "C09AA01", mhr_102b = 2), 0)
})

test_that("cycles1to2_ace_inhibitors works correctly", {
  expect_equal(cycles1to2_ace_inhibitors(atc_101a = "C09AA13", mhr_101b = 1), 1)
  expect_equal(cycles1to2_ace_inhibitors(atc_101a = "C07AA07", mhr_101b = 1), 0)
  expect_equal(cycles1to2_ace_inhibitors(atc_101a = "C09AA13", mhr_101b = 1, atc_102a = "C07AA07", mhr_102b = 2), 1)
})

test_that("cycles1to2_diuretics works as expected", {
  expect_equal(cycles1to2_diuretics(atc_101a = "C03AA13", mhr_101b = 1), 1)
  expect_equal(cycles1to2_diuretics(atc_101a = "C03BA08", mhr_101b = 1), 0)
  expect_equal(cycles1to2_diuretics(atc_101a = "C03AA13", mhr_101b = 1, atc_102a = "C07BA08", mhr_102b = 2), 1)
})

test_that("cycles1to2_calcium_channel_blockers works correctly", {
  expect_equal(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_calcium_channel_blockers(atc_101a = "C09AA01", mhr_101b = 1), 0)
  expect_equal(cycles1to2_calcium_channel_blockers(atc_101a = "C08CA01", mhr_101b = 1, atc_102a = "C09AA01", mhr_102b = 2), 1)
})

test_that("cycles1to2_other_antiHTN_meds works correctly", {
  expect_equal(cycles1to2_other_antiHTN_meds(atc_101a = "C02AA01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_other_antiHTN_meds(atc_101a = "C08CA01", mhr_101b = 1), 0)
  expect_equal(cycles1to2_other_antiHTN_meds(atc_101a = "C02AA01", mhr_101b = 1, atc_102a = "C08CA01", mhr_102b = 2), 1)
})

test_that("cycles1to2_any_antiHTN_meds works correctly", {
  expect_equal(cycles1to2_any_antiHTN_meds(atc_101a = "C08CA01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_any_antiHTN_meds(atc_101a = "C09AA01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_any_antiHTN_meds(atc_101a = "C08CA01", mhr_101b = 1, atc_102a = "C09AA01", mhr_102b = 2), 1)
})

test_that("cycles1to2_nsaid works correctly", {
  expect_equal(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = 1), 1)
  expect_equal(cycles1to2_nsaid(atc_101a = "C09AA01", mhr_101b = 1), 0)
  expect_equal(cycles1to2_nsaid(atc_101a = "M01AE01", mhr_101b = 1, atc_102a = "C09AA01", mhr_102b = 2), 1)
})

test_that("cycles1to2_diabetes_drugs works correctly", {
  expect_equal(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = 1), 1)
  expect_equal(cycles1to2_diabetes_drugs(atc_101a = "C09AA01", mhr_101b = 1), 0)
  expect_equal(cycles1to2_diabetes_drugs(atc_101a = "A10BA02", mhr_101b = 1, atc_102a = "C09AA01", mhr_102b = 2), 1)
})
