#test-medications.R
test_that("is_taking_drug_class validates input parameters", {
  df <- data.frame(med1 = c("C07AA13", "C09AA02"), 
                   last1 = c(3, 5), 
                   med2 = c("C03AA03", NA), 
                   last2 = c(2, NA))
  
  class_condition_fun <- function(med_code, last_taken) {
    if (is.na(med_code) | is.na(last_taken)) {
      return(0)
    }
    return(as.numeric(startsWith(med_code, "C07") & last_taken <= 4))
  }
  
  # Test for errors with missing parameters
  expect_error(is_taking_drug_class(df, "", c("med1"), c("last1"), class_condition_fun))
  expect_error(is_taking_drug_class(df, "class_var", c("med1", "non_existent"), c("last1"), class_condition_fun))
  expect_error(is_taking_drug_class(df, "class_var", c("med1"), c("last1", "non_existent"), class_condition_fun))
  
  # Test overwrite functionality
  df$class_var <- 1
  expect_error(is_taking_drug_class(df, "class_var", c("med1"), c("last1"), class_condition_fun))
  expect_silent(is_taking_drug_class(df, "class_var", c("med1"), c("last1"), class_condition_fun, overwrite = TRUE))
})

test_that("is_taking_drug_class computes correctly", {
  df <- data.frame(med1 = c("C07AA13", "C09AA02", "C07AG02"), 
                   last1 = c(3, 5, 1), 
                   med2 = c("C03AA03", NA, "C07AA12"), 
                   last2 = c(2, NA, 4))
  
  class_condition_fun <- function(med_code, last_taken) {
    if (is.na(med_code) | is.na(last_taken)) {
      return(0)
    }
    return(as.numeric(startsWith(med_code, "C07") & last_taken <= 4))
  }
  
  result <- is_taking_drug_class(df, "class_var", c("med1", "med2"), c("last1", "last2"), class_condition_fun, overwrite = TRUE)
  expect_equal(result$class_var, c(1, 0, 2))
})

test_that("is_beta_blocker identifies beta blockers correctly", {
  # Valid cases
  expect_equal(is_beta_blocker("C07AA13", 3), 1)
  expect_equal(is_beta_blocker("C07AA07", 3), 0)  # Excluded code
  expect_equal(is_beta_blocker("C07AA13", 5), 0)  # Taken more than a month ago
  
  # Edge cases
  expect_equal(is_beta_blocker(NA, 3), haven::tagged_na("b"))
  expect_equal(is_beta_blocker("C07AA13", NA), haven::tagged_na("b"))
})

test_that("is_ace_inhibitor identifies ACE inhibitors correctly", {
  # Valid cases
  expect_equal(is_ace_inhibitor("C09AA02", 2), 1)
  expect_equal(is_ace_inhibitor("C07AA13", 2), 0)  # Not an ACE inhibitor
  
  # Edge cases
  expect_equal(is_ace_inhibitor(NA, 2), haven::tagged_na("b"))
  expect_equal(is_ace_inhibitor("C09AA02", NA), haven::tagged_na("b"))
})

test_that("is_diuretic identifies diuretics correctly", {
  # Valid cases
  expect_equal(is_diuretic("C03AA03", 3), 1)
  expect_equal(is_diuretic("C03BA08", 3), 0)  # Excluded code
  expect_equal(is_diuretic("C03AA03", 5), 0)  # Taken more than a month ago
  
  # Edge cases
  expect_equal(is_diuretic(NA, 3), haven::tagged_na("b"))
  expect_equal(is_diuretic("C03AA03", NA), haven::tagged_na("b"))
})

test_that("is_calcium_channel_blocker identifies calcium channel blockers correctly", {
  # Valid cases
  expect_equal(is_calcium_channel_blocker("C08CA05", 1), 1)
  expect_equal(is_calcium_channel_blocker("C03AA03", 1), 0)  # Not a calcium channel blocker
  
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

test_that("cycles1to2_beta_blockers works as expected", {
  # Test 1: Case when taking beta-blockers
  test_data_1 <- list(
    atc_101a = "C07", mhr_101b = 1,  # Beta-blocker ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_beta_blockers(!!!test_data_1), 1)
  
  # Test 2: Case when not taking beta-blockers
  test_data_2 <- list(
    atc_101a = "C09", mhr_101b = 1,  # Non-beta-blocker ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_beta_blockers(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_beta_blockers(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with ambiguous data (mixed beta-blocker and other drugs)
  test_data_4 <- list(
    atc_101a = "C07", mhr_101b = 2,  # Beta-blocker, taken yesterday
    atc_102a = "C09", mhr_102b = 1   # Non-beta-blocker, taken today
  )
  expect_equal(cycles1to2_beta_blockers(!!!test_data_4), 1)  # Should return 1 because of the beta-blocker
})

test_that("cycles1to2_ace_inhibitors works as expected", {
  # Test 1: Case when taking ACE inhibitors
  test_data_1 <- list(
    atc_101a = "C09", mhr_101b = 1,  # ACE inhibitor ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_ace_inhibitors(!!!test_data_1), 1)
  
  # Test 2: Case when not taking ACE inhibitors
  test_data_2 <- list(
    atc_101a = "C07", mhr_101b = 1,  # Non-ACE inhibitor ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_ace_inhibitors(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_ace_inhibitors(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed ACE inhibitors and other drugs
  test_data_4 <- list(
    atc_101a = "C09", mhr_101b = 1,  # ACE inhibitor, taken today
    atc_102a = "C07", mhr_102b = 2   # Non-ACE inhibitor, taken yesterday
  )
  expect_equal(cycles1to2_ace_inhibitors(!!!test_data_4), 1)  # Should return 1 because of the ACE inhibitor
})

test_that("cycles1to2_diuretics works as expected", {
  # Test 1: Case when taking diuretics
  test_data_1 <- list(
    atc_101a = "C03", mhr_101b = 1,  # Diuretic ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_diuretics(!!!test_data_1), 1)
  
  # Test 2: Case when not taking diuretics
  test_data_2 <- list(
    atc_101a = "C09", mhr_101b = 1,  # Non-diuretic ATC code, taken today
    atc_102a = NULL, mhr_102b = NULL
  )
  expect_equal(cycles1to2_diuretics(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_diuretics(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed diuretics and other drugs
  test_data_4 <- list(
    atc_101a = "C03", mhr_101b = 1,  # Diuretic, taken today
    atc_102a = "C07", mhr_102b = 2   # Non-diuretic, taken yesterday
  )
  expect_equal(cycles1to2_diuretics(!!!test_data_4), 1)  # Should return 1 because of the diuretic
})

test_that("cycles1to2_calcium_channel_blockers works correctly", {
  # Test 1: Case when taking calcium channel blockers
  test_data_1 <- list(
    atc_101a = "C08CA01", mhr_101b = 1  # Calcium channel blocker, taken today
  )
  expect_equal(cycles1to2_calcium_channel_blockers(!!!test_data_1), 1)
  
  # Test 2: Case when not taking calcium channel blockers
  test_data_2 <- list(
    atc_101a = "C09AA01", mhr_101b = 1  # Non-calcium channel blocker, taken today
  )
  expect_equal(cycles1to2_calcium_channel_blockers(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_calcium_channel_blockers(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed medications
  test_data_4 <- list(
    atc_101a = "C08CA01", mhr_101b = 1,  # Calcium channel blocker, taken today
    atc_102a = "C09AA01", mhr_102b = 2   # Non-calcium channel blocker, taken yesterday
  )
  expect_equal(cycles1to2_calcium_channel_blockers(!!!test_data_4), 1)  # Should return 1 because of the calcium channel blocker
})

test_that("cycles1to2_other_antiHTN_meds works correctly", {
  # Test 1: Case when taking other anti-hypertensive medications
  test_data_1 <- list(
    atc_101a = "C09AA01", mhr_101b = 1  # Other anti-hypertensive, taken today
  )
  expect_equal(cycles1to2_other_antiHTN_meds(!!!test_data_1), 1)
  
  # Test 2: Case when not taking other anti-hypertensive medications
  test_data_2 <- list(
    atc_101a = "C08CA01", mhr_101b = 1  # Calcium channel blocker, taken today
  )
  expect_equal(cycles1to2_other_antiHTN_meds(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_other_antiHTN_meds(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed medications
  test_data_4 <- list(
    atc_101a = "C02AA01", mhr_101b = 1,  # Other anti-hypertensive, taken today
    atc_102a = "C08CA01", mhr_102b = 2   # Calcium channel blocker, taken yesterday
  )
  expect_equal(cycles1to2_other_antiHTN_meds(!!!test_data_4), 1)  # Should return 1 because of the other anti-hypertensive
})

test_that("cycles1to2_any_antiHTN_meds works correctly", {
  # Test 1: Case when taking any anti-hypertensive medication
  test_data_1 <- list(
    atc_101a = "C08CA01", mhr_101b = 1  # Calcium channel blocker, taken today
  )
  expect_equal(cycles1to2_any_antiHTN_meds(!!!test_data_1), 1)
  
  # Test 2: Case when taking another anti-hypertensive medication
  test_data_2 <- list(
    atc_101a = "C09AA01", mhr_101b = 1  # Other anti-hypertensive, taken today
  )
  expect_equal(cycles1to2_any_antiHTN_meds(!!!test_data_2), 1)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_any_antiHTN_meds(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed medications
  test_data_4 <- list(
    atc_101a = "C08CA01", mhr_101b = 1,  # Calcium channel blocker, taken today
    atc_102a = "C09AA01", mhr_102b = 2   # Other anti-hypertensive, taken yesterday
  )
  expect_equal(cycles1to2_any_antiHTN_meds(!!!test_data_4), 1)  # Should return 1 because of any anti-hypertensive
})

test_that("cycles1to2_nsaid works correctly", {
  # Test 1: Case when taking NSAIDs
  test_data_1 <- list(
    atc_101a = "M01AE01", mhr_101b = 1  # NSAID, taken today
  )
  expect_equal(cycles1to2_nsaid(!!!test_data_1), 1)
  
  # Test 2: Case when not taking NSAIDs
  test_data_2 <- list(
    atc_101a = "C09AA01", mhr_101b = 1  # Non-NSAID, taken today
  )
  expect_equal(cycles1to2_nsaid(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_nsaid(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed medications
  test_data_4 <- list(
    atc_101a = "M01AE01", mhr_101b = 1,  # NSAID, taken today
    atc_102a = "C09AA01", mhr_102b = 2   # Non-NSAID, taken yesterday
  )
  expect_equal(cycles1to2_nsaid(!!!test_data_4), 1)  # Should return 1 because of the NSAID
})

test_that("cycles1to2_diabetes_drugs works correctly", {
  # Test 1: Case when taking diabetes drugs
  test_data_1 <- list(
    atc_101a = "A10BA02", mhr_101b = 1  # Diabetes drug, taken today
  )
  expect_equal(cycles1to2_diabetes_drugs(!!!test_data_1), 1)
  
  # Test 2: Case when not taking diabetes drugs
  test_data_2 <- list(
    atc_101a = "C09AA01", mhr_101b = 1  # Non-diabetes drug, taken today
  )
  expect_equal(cycles1to2_diabetes_drugs(!!!test_data_2), 0)
  
  # Test 3: Case with missing data (NA)
  test_data_3 <- list(
    atc_101a = NULL, mhr_101b = NULL  # No data
  )
  expect_equal(cycles1to2_diabetes_drugs(!!!test_data_3), haven::tagged_na("b"))
  
  # Test 4: Case with mixed medications
  test_data_4 <- list(
    atc_101a = "A10BA02", mhr_101b = 1,  # Diabetes drug, taken today
    atc_102a = "C09AA01", mhr_102b = 2   # Non-diabetes drug, taken yesterday
  )
  expect_equal(cycles1to2_diabetes_drugs(!!!test_data_4), 1)  # Should return 1 because of the diabetes drug
})