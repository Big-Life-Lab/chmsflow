#' @title Tests for medication functions (restored parameters)
#' @description This file contains tests for all medication functions with restored parameters.

library(testthat)
library(dplyr)

# 1. Test is_taking_drug_class
# ----------------------------------------------------------------------------
test_that("is_taking_drug_class works correctly", {
  # Create a sample data frame
  df <- data.frame(
    med1 = c("C07AA13", "C09AA02", "C07AG02"),
    last1 = c(3, 5, 1),
    med2 = c("C03AA03", NA, "C07AA12"),
    last2 = c(2, NA, 4)
  )

  # Define a condition function (e.g., for beta blockers)
  is_beta_blocker_condition <- function(med_code, last_taken) {
    dplyr::case_when(
      is.na(med_code) | is.na(last_taken) ~ 0,
      startsWith(med_code, "C07") & !(med_code %in% c("C07AA07", "C07AA12", "C07AG02")) & last_taken <= 4 ~ 1,
      .default = 0
    )
  }

  # Scalar usage:
  result_df <- is_taking_drug_class(
    df,
    "beta_blocker_count",
    c("med1", "med2"),
    c("last1", "last2"),
    is_beta_blocker_condition,
    overwrite = TRUE
  )

  expect_equal(result_df$beta_blocker_count, c(1, 0, 0))

  # Vector usage
  df_vector <- data.frame(
    med1 = c("C07AA13", "C09AA02", "C07AG02", "C03AA03"),
    last1 = c(3, 5, 1, 2),
    med2 = c("C03AA03", NA, "C07AA12", "C08CA05"),
    last2 = c(2, NA, 4, 1)
  )

  result_df_vector <- is_taking_drug_class(
    df_vector,
    "beta_blocker_count",
    c("med1", "med2"),
    c("last1", "last2"),
    is_beta_blocker_condition,
    overwrite = TRUE
  )

  expect_equal(result_df_vector$beta_blocker_count, c(1, 0, 0, 0))

  # Database usage
  library(dplyr)

  survey_data <- data.frame(
    med1 = c("C07AA13", "C09AA02", "C07AG02", "C03AA03"),
    last1 = c(3, 5, 1, 2),
    med2 = c("C03AA03", NA, "C07AA12", "C08CA05"),
    last2 = c(2, NA, 4, 1)
  )

  db_result <- survey_data %>%
    is_taking_drug_class(
      "beta_blocker_count",
      c("med1", "med2"),
      c("last1", "last2"),
      is_beta_blocker_condition,
      overwrite = TRUE
    ) %>%
    mutate(has_beta_blocker = ifelse(beta_blocker_count > 0, 1, 0)) %>%
    select(has_beta_blocker)

  expect_equal(db_result$has_beta_blocker, c(1, 0, 0, 0))
})

# 2. Test is_beta_blocker
# ----------------------------------------------------------------------------
test_that("is_beta_blocker works correctly", {
  # Scalar usage
  expect_equal(is_beta_blocker("C07AA13", 3), 1)

  # Non-response values
  expect_true(is.na(is_beta_blocker("9999996", 6)))

  # Vector usage
  expect_equal(is_beta_blocker(c("C07AA13", "C07AA07"), c(3, 4)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C07AA13", "C07AA07", "C01AA05"),
    NPI_25B = c(3, 4, 2)
  )
  db_result <- survey_data %>%
    mutate(is_bb = is_beta_blocker(MEUCATC, NPI_25B)) %>%
    select(is_bb)

  expect_equal(db_result$is_bb, c(1, 0, 0))
})

# 3. Test is_ace_inhibitor
# ----------------------------------------------------------------------------
test_that("is_ace_inhibitor works correctly", {
  # Scalar usage
  expect_equal(is_ace_inhibitor("C09AB03", 2), 1)

  # Non-response values
  expect_true(is.na(is_ace_inhibitor("9999996", 6)))

  # Vector usage
  expect_equal(is_ace_inhibitor(c("C09AB03", "C01AA05"), c(2, 1)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C09AB03", "C01AA05", "C09AA02"),
    NPI_25B = c(2, 1, 3)
  )
  db_result <- survey_data %>%
    mutate(is_ace = is_ace_inhibitor(MEUCATC, NPI_25B)) %>%
    select(is_ace)

  expect_equal(db_result$is_ace, c(1, 0, 1))
})

# 4. Test is_diuretic
# ----------------------------------------------------------------------------
test_that("is_diuretic works correctly", {
  # Scalar usage
  expect_equal(is_diuretic("C03AA03", 3), 1)

  # Non-response values
  expect_true(is.na(is_diuretic("9999996", 6)))

  # Vector usage
  expect_equal(is_diuretic(c("C03AA03", "C03BA08"), c(3, 2)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C03AA03", "C03BA08", "C01AA05"),
    NPI_25B = c(3, 2, 1)
  )
  db_result <- survey_data %>%
    mutate(is_diuretic = is_diuretic(MEUCATC, NPI_25B)) %>%
    select(is_diuretic)

  expect_equal(db_result$is_diuretic, c(1, 0, 0))
})

# 5. Test is_calcium_channel_blocker
# ----------------------------------------------------------------------------
test_that("is_calcium_channel_blocker works correctly", {
  # Scalar usage
  expect_equal(is_calcium_channel_blocker("C08CA05", 1), 1)

  # Non-response values
  expect_true(is.na(is_calcium_channel_blocker("9999996", 6)))

  # Vector usage
  expect_equal(is_calcium_channel_blocker(c("C08CA05", "C01AA05"), c(1, 2)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C08CA05", "C01AA05", "C08DB01"),
    NPI_25B = c(1, 2, 4)
  )
  db_result <- survey_data %>%
    mutate(is_ccb = is_calcium_channel_blocker(MEUCATC, NPI_25B)) %>%
    select(is_ccb)

  expect_equal(db_result$is_ccb, c(1, 0, 1))
})

# 6. Test is_other_antiHTN_med
# ----------------------------------------------------------------------------
test_that("is_other_antiHTN_med works correctly", {
  # Scalar usage
  expect_equal(is_other_antiHTN_med("C02AC04", 3), 1)

  # Non-response values
  expect_true(is.na(is_other_antiHTN_med("9999996", 6)))

  # Vector usage
  expect_equal(is_other_antiHTN_med(c("C02AC04", "C02KX01"), c(3, 2)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C02AC04", "C02KX01", "C02AB01"),
    NPI_25B = c(3, 2, 1)
  )
  db_result <- survey_data %>%
    mutate(is_other_antihtn = is_other_antiHTN_med(MEUCATC, NPI_25B)) %>%
    select(is_other_antihtn)

  expect_equal(db_result$is_other_antihtn, c(1, 0, 1))
})

# 7. Test is_any_antiHTN_med
# ----------------------------------------------------------------------------
test_that("is_any_antiHTN_med works correctly", {
  # Scalar usage
  expect_equal(is_any_antiHTN_med("C07AB02", 4), 1)

  # Non-response values
  expect_true(is.na(is_any_antiHTN_med("9999996", 6)))

  # Vector usage
  expect_equal(is_any_antiHTN_med(c("C07AB02", "C07AA07"), c(4, 2)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("C07AB02", "C07AA07", "C09AA02"),
    NPI_25B = c(4, 2, 3)
  )
  db_result <- survey_data %>%
    mutate(is_any_antihtn = is_any_antiHTN_med(MEUCATC, NPI_25B)) %>%
    select(is_any_antihtn)

  expect_equal(db_result$is_any_antihtn, c(1, 0, 1))
})

# 8. Test is_NSAID
# ----------------------------------------------------------------------------
test_that("is_NSAID works correctly", {
  # Scalar usage
  expect_equal(is_NSAID("M01AB05", 1), 1)

  # Non-response values
  expect_true(is.na(is_NSAID("9999996", 6)))

  # Vector usage
  expect_equal(is_NSAID(c("M01AB05", "A10BB09"), c(1, 3)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("M01AB05", "A10BB09", "M01AE01"),
    NPI_25B = c(1, 3, 2)
  )
  db_result <- survey_data %>%
    mutate(is_nsaid = is_NSAID(MEUCATC, NPI_25B)) %>%
    select(is_nsaid)

  expect_equal(db_result$is_nsaid, c(1, 0, 1))
})

# 9. Test is_diabetes_drug
# ----------------------------------------------------------------------------
test_that("is_diabetes_drug works correctly", {
  # Scalar usage
  expect_equal(is_diabetes_drug("A10BB09", 3), 1)

  # Non-response values
  expect_true(is.na(is_diabetes_drug("9999996", 6)))

  # Vector usage
  expect_equal(is_diabetes_drug(c("A10BB09", "C09AA02"), c(3, 2)), c(1, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    MEUCATC = c("A10BB09", "C09AA02", "A10BA02"),
    NPI_25B = c(3, 2, 1)
  )
  db_result <- survey_data %>%
    mutate(is_diabetes = is_diabetes_drug(MEUCATC, NPI_25B)) %>%
    select(is_diabetes)

  expect_equal(db_result$is_diabetes, c(1, 0, 1))
})

# 10. Test cycles1to2_beta_blockers
# ----------------------------------------------------------------------------
test_that("cycles1to2_beta_blockers works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_beta_blockers(
    atc_101a = "C07AA13", mhr_101b = 3,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_beta_blockers(
    atc_101a = c("C07AA13", "C01AA05", "C07AB02"),
    mhr_101b = c(3, 1, 4),
    atc_102a = c("C08CA05", as.character(NA), "C09AA02"),
    mhr_102b = c(1, as.numeric(NA), 2)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C07AA13", "C01AA05", "C07AB02"),
    mhr_101b = c(3, 1, 4),
    atc_102a = c("C08CA05", as.character(NA), "C09AA02"),
    mhr_102b = c(1, as.numeric(NA), 2),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
    db_result <- survey_data %>%
      mutate(is_taking_bb = cycles1to2_beta_blockers(
        atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
        atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
        atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
        mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
        mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
        mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
      )) %>% 
      select(is_taking_bb)
  
    expect_equal(db_result$is_taking_bb, c(1, 0, 1))
  })

  # 11. Test cycles1to2_ace_inhibitors
# ----------------------------------------------------------------------------
test_that("cycles1to2_ace_inhibitors works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_ace_inhibitors(
    atc_101a = "C09AA02", mhr_101b = 3,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_ace_inhibitors(
    atc_101a = c("C09AA02", "C01AA05", "C09AB03"),
    mhr_101b = c(3, 1, 2),
    atc_102a = c("C08CA05", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C09AA02", "C01AA05", "C09AB03"),
    mhr_101b = c(3, 1, 2),
    atc_102a = c("C08CA05", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_ace = cycles1to2_ace_inhibitors(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_ace)

  expect_equal(db_result$is_taking_ace, c(1, 0, 1))
})

# 12. Test cycles1to2_diuretics
# ----------------------------------------------------------------------------
test_that("cycles1to2_diuretics works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_diuretics(
    atc_101a = "C03AA03", mhr_101b = 3,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_diuretics(
    atc_101a = c("C03AA03", "C03BA08", "C01AA05"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C03CA01", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3)
  ), c(1, 0, 0))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C03AA03", "C03BA08", "C01AA05"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C03CA01", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_diuretic = cycles1to2_diuretics(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_diuretic)

  expect_equal(db_result$is_taking_diuretic, c(1, 0, 0))
})

# 13. Test cycles1to2_calcium_channel_blockers
# ----------------------------------------------------------------------------
test_that("cycles1to2_calcium_channel_blockers works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_calcium_channel_blockers(
    atc_101a = "C08CA05", mhr_101b = 1,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_calcium_channel_blockers(
    atc_101a = c("C08CA05", "C01AA05", "C08DB01"),
    mhr_101b = c(1, 2, 4),
    atc_102a = c("C09AA02", as.character(NA), "C07AA13"),
    mhr_102b = c(2, as.numeric(NA), 3)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C08CA05", "C01AA05", "C08DB01"),
    mhr_101b = c(1, 2, 4),
    atc_102a = c("C09AA02", as.character(NA), "C07AA13"),
    mhr_102b = c(2, as.numeric(NA), 3),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_ccb = cycles1to2_calcium_channel_blockers(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_ccb)

  expect_equal(db_result$is_taking_ccb, c(1, 0, 1))
})

# 14. Test cycles1to2_other_antiHTN_meds
# ----------------------------------------------------------------------------
test_that("cycles1to2_other_antiHTN_meds works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_other_antiHTN_meds(
    atc_101a = "C02AC04", mhr_101b = 3,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_other_antiHTN_meds(
    atc_101a = c("C02AC04", "C02KX01", "C02AB01"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C09AA02", as.character(NA), "C07AA13"),
    mhr_102b = c(2, as.numeric(NA), 3)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C02AC04", "C02KX01", "C02AB01"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C09AA02", as.character(NA), "C07AA13"),
    mhr_102b = c(2, as.numeric(NA), 3),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_other_antihtn = cycles1to2_other_antiHTN_meds(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_other_antihtn)

  expect_equal(db_result$is_taking_other_antihtn, c(1, 0, 1))
})

# 15. Test cycles1to2_any_antiHTN_meds
# ----------------------------------------------------------------------------
test_that("cycles1to2_any_antiHTN_meds works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_any_antiHTN_meds(
    atc_101a = "C07AB02", mhr_101b = 4,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_any_antiHTN_meds(
    atc_101a = c("C07AB02", "C07AA07", "C09AA02"),
    mhr_101b = c(4, 2, 3),
    atc_102a = c("C08CA05", as.character(NA), "C02AB01"),
    mhr_102b = c(1, as.numeric(NA), 1)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("C07AB02", "C07AA07", "C09AA02"),
    mhr_101b = c(4, 2, 3),
    atc_102a = c("C08CA05", as.character(NA), "C02AB01"),
    mhr_102b = c(1, as.numeric(NA), 1),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_any_antihtn = cycles1to2_any_antiHTN_meds(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_any_antihtn)

  expect_equal(db_result$is_taking_any_antihtn, c(1, 0, 1))
})

# 16. Test cycles1to2_nsaid
# ----------------------------------------------------------------------------
test_that("cycles1to2_nsaid works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_nsaid(
    atc_101a = "M01AB05", mhr_101b = 1,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_nsaid(
    atc_101a = c("M01AB05", "A10BB09", "M01AE01"),
    mhr_101b = c(1, 3, 2),
    atc_102a = c("C08CA05", as.character(NA), "C09AA02"),
    mhr_102b = c(1, as.numeric(NA), 2)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("M01AB05", "A10BB09", "M01AE01"),
    mhr_101b = c(1, 3, 2),
    atc_102a = c("C08CA05", as.character(NA), "C09AA02"),
    mhr_102b = c(1, as.numeric(NA), 2),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_nsaid = cycles1to2_nsaid(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_nsaid)

  expect_equal(db_result$is_taking_nsaid, c(1, 0, 1))
})

# 17. Test cycles1to2_diabetes_drugs
# ----------------------------------------------------------------------------
test_that("cycles1to2_diabetes_drugs works correctly with restored parameters", {
  # Scalar usage
  expect_equal(cycles1to2_diabetes_drugs(
    atc_101a = "A10BB09", mhr_101b = 3,
    atc_102a = as.character(NA), mhr_102b = as.numeric(NA)
  ), 1)

  # Vector usage
  expect_equal(cycles1to2_diabetes_drugs(
    atc_101a = c("A10BB09", "C09AA02", "A10BA02"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C08CA05", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3)
  ), c(1, 0, 1))

  # Database usage
  library(dplyr)
  survey_data <- data.frame(
    atc_101a = c("A10BB09", "C09AA02", "A10BA02"),
    mhr_101b = c(3, 2, 1),
    atc_102a = c("C08CA05", as.character(NA), "C07AA13"),
    mhr_102b = c(1, as.numeric(NA), 3),
    atc_103a = as.character(NA), mhr_103b = as.numeric(NA),
    atc_104a = as.character(NA), mhr_104b = as.numeric(NA),
    atc_105a = as.character(NA), mhr_105b = as.numeric(NA),
    atc_106a = as.character(NA), mhr_106b = as.numeric(NA),
    atc_107a = as.character(NA), mhr_107b = as.numeric(NA),
    atc_108a = as.character(NA), mhr_108b = as.numeric(NA),
    atc_109a = as.character(NA), mhr_109b = as.numeric(NA),
    atc_110a = as.character(NA), mhr_110b = as.numeric(NA),
    atc_111a = as.character(NA), mhr_111b = as.numeric(NA),
    atc_112a = as.character(NA), mhr_112b = as.numeric(NA),
    atc_113a = as.character(NA), mhr_113b = as.numeric(NA),
    atc_114a = as.character(NA), mhr_114b = as.numeric(NA),
    atc_115a = as.character(NA), mhr_115b = as.numeric(NA),
    atc_201a = as.character(NA), mhr_201b = as.numeric(NA),
    atc_202a = as.character(NA), mhr_202b = as.numeric(NA),
    atc_203a = as.character(NA), mhr_203b = as.numeric(NA),
    atc_204a = as.character(NA), mhr_204b = as.numeric(NA),
    atc_205a = as.character(NA), mhr_205b = as.numeric(NA),
    atc_206a = as.character(NA), mhr_206b = as.numeric(NA),
    atc_207a = as.character(NA), mhr_207b = as.numeric(NA),
    atc_208a = as.character(NA), mhr_208b = as.numeric(NA),
    atc_209a = as.character(NA), mhr_209b = as.numeric(NA),
    atc_210a = as.character(NA), mhr_210b = as.numeric(NA),
    atc_211a = as.character(NA), mhr_211b = as.numeric(NA),
    atc_212a = as.character(NA), mhr_212b = as.numeric(NA),
    atc_213a = as.character(NA), mhr_213b = as.numeric(NA),
    atc_214a = as.character(NA), mhr_214b = as.numeric(NA),
    atc_215a = as.character(NA), mhr_215b = as.numeric(NA),
    atc_131a = as.character(NA), mhr_131b = as.numeric(NA),
    atc_132a = as.character(NA), mhr_132b = as.numeric(NA),
    atc_133a = as.character(NA), mhr_133b = as.numeric(NA),
    atc_134a = as.character(NA), mhr_134b = as.numeric(NA),
    atc_135a = as.character(NA), mhr_135b = as.numeric(NA),
    atc_231a = as.character(NA), mhr_231b = as.numeric(NA),
    atc_232a = as.character(NA), mhr_232b = as.numeric(NA),
    atc_233a = as.character(NA), mhr_233b = as.numeric(NA),
    atc_234a = as.character(NA), mhr_234b = as.numeric(NA),
    atc_235a = as.character(NA), mhr_235b = as.numeric(NA)
  )
  db_result <- survey_data %>%
    mutate(is_taking_diabetes_drug = cycles1to2_diabetes_drugs(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a, atc_106a, atc_107a, atc_108a, atc_109a, atc_110a, atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a, atc_206a, atc_207a, atc_208a, atc_209a, atc_210a, atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a, atc_231a, atc_232a, atc_233a, atc_234a, atc_235a,
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b, mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b, mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b, mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b, mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b, mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )) %>%
    select(is_taking_diabetes_drug)

  expect_equal(db_result$is_taking_diabetes_drug, c(1, 0, 1))
})
