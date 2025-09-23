# test-family-history.R
# Test determine_CVD_personal_history
test_that("determine_CVD_personal_history works correctly", {
  # Example case: Heart disease present
  expect_equal(determine_CVD_personal_history(CCC_61 = 1, CCC_63 = 2, CCC_81 = 2), 1)

  # Heart attack present
  expect_equal(determine_CVD_personal_history(CCC_61 = 2, CCC_63 = 1, CCC_81 = 2), 1)

  # Stroke present
  expect_equal(determine_CVD_personal_history(CCC_61 = 2, CCC_63 = 2, CCC_81 = 1), 1)

  # All conditions absent
  expect_equal(determine_CVD_personal_history(CCC_61 = 2, CCC_63 = 2, CCC_81 = 2), 2)

  # Non-response: All inputs are missing
  expect_equal(determine_CVD_personal_history(CCC_61 = NA, CCC_63 = NA, CCC_81 = NA), haven::tagged_na("b"))

  # Mixed responses: One missing, others valid
  expect_equal(determine_CVD_personal_history(CCC_61 = 1, CCC_63 = NA, CCC_81 = 2), 1)
  expect_equal(determine_CVD_personal_history(CCC_61 = 2, CCC_63 = 2, CCC_81 = NA), 2)

  # Edge cases: Invalid inputs
  expect_equal(determine_CVD_personal_history(CCC_61 = NA, CCC_63 = 1, CCC_81 = 1), 1)
  expect_equal(determine_CVD_personal_history(CCC_61 = NA, CCC_63 = NA, CCC_81 = 1), 1)

  # Vector usage
  expect_equal(determine_CVD_personal_history(CCC_61 = c(1, 2, 2, NA, 2), CCC_63 = c(2, 1, 2, NA, 2), CCC_81 = c(2, 2, 1, NA, 2)), c(1, 1, 1, haven::tagged_na("b"), 2))

  # Database usage (simulated)
  df_cvd_personal <- data.frame(
    CCC_61 = c(1, 2, 2, NA, 2),
    CCC_63 = c(2, 1, 2, NA, 2),
    CCC_81 = c(2, 2, 1, NA, 2)
  )
  expected_output_cvd_personal <- c(1, 1, 1, haven::tagged_na("b"), 2)
  expect_equal(df_cvd_personal %>% dplyr::mutate(cvd_personal_history = determine_CVD_personal_history(CCC_61, CCC_63, CCC_81)) %>% dplyr::pull(cvd_personal_history), expected_output_cvd_personal)
})

# Test determine_CVD_family_history
test_that("determine_CVD_family_history works correctly", {
  # Example case: Heart disease at age 50 (premature)
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 2, FMH_14 = NA), 1)

  # Stroke at age 55 (premature)
  expect_equal(determine_CVD_family_history(FMH_11 = 2, FMH_12 = NA, FMH_13 = 1, FMH_14 = 55), 1)

  # Late diagnosis of heart disease at age 65
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 65, FMH_13 = 2, FMH_14 = NA), 2)

  # Late diagnosis of stroke at age 75
  expect_equal(determine_CVD_family_history(FMH_11 = 2, FMH_12 = NA, FMH_13 = 1, FMH_14 = 75), 2)

  # No family history of heart disease or stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 2, FMH_12 = NA, FMH_13 = 2, FMH_14 = NA), 2)

  # Non-response for all inputs
  expect_equal(determine_CVD_family_history(FMH_11 = NA, FMH_12 = NA, FMH_13 = NA, FMH_14 = NA), haven::tagged_na("b"))

  # Mixed responses: Heart disease missing, stroke present
  expect_equal(determine_CVD_family_history(FMH_11 = NA, FMH_12 = NA, FMH_13 = 1, FMH_14 = 55), 1)

  # Invalid age inputs for heart disease
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 997, FMH_13 = 2, FMH_14 = NA), haven::tagged_na("b"))
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = -1, FMH_13 = 2, FMH_14 = NA), haven::tagged_na("b"))

  # Invalid age inputs for stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 2, FMH_12 = NA, FMH_13 = 1, FMH_14 = 999), haven::tagged_na("b"))
  expect_equal(determine_CVD_family_history(FMH_11 = 2, FMH_12 = NA, FMH_13 = 1, FMH_14 = -10), haven::tagged_na("b"))

  # Invalid FMH_11 and FMH_13 values
  expect_equal(determine_CVD_family_history(FMH_11 = 3, FMH_12 = NA, FMH_13 = 3, FMH_14 = 50), haven::tagged_na("b"))
  expect_equal(determine_CVD_family_history(FMH_11 = 4, FMH_12 = 50, FMH_13 = 4, FMH_14 = NA), haven::tagged_na("b"))

  # Multiple conditions: Premature heart disease and late stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 1, FMH_14 = 70), 1)

  # Multiple conditions: Late heart disease and premature stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 65, FMH_13 = 1, FMH_14 = 55), 1)

  # Non-response combined with valid input
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = NA, FMH_13 = 1, FMH_14 = 55), 1)
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 1, FMH_14 = NA), 1)

  # Vector usage
  expect_equal(determine_CVD_family_history(FMH_11 = c(1, 2, 1, NA, 2), FMH_12 = c(50, NA, 70, NA, NA), FMH_13 = c(2, 1, 2, NA, 2), FMH_14 = c(NA, 55, NA, NA, NA)), c(1, 1, 2, haven::tagged_na("b"), 2))

  # Database usage (simulated)
  df_cvd_family <- data.frame(
    FMH_11 = c(1, 2, 1, NA, 2),
    FMH_12 = c(50, NA, 70, NA, NA),
    FMH_13 = c(2, 1, 2, NA, 2),
    FMH_14 = c(NA, 55, NA, NA, NA)
  )
  expected_output_cvd_family <- c(1, 1, 2, haven::tagged_na("b"), 2)
  expect_equal(df_cvd_family %>% dplyr::mutate(cvd_family_history = determine_CVD_family_history(FMH_11, FMH_12, FMH_13, FMH_14)) %>% dplyr::pull(cvd_family_history), expected_output_cvd_family)
})
