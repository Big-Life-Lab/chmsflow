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
  expect_equal(determine_CVD_family_history(FMH_11 = 3, FMH_12 = NA, FMH_13 = 1, FMH_14 = 50), haven::tagged_na("b"))
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 4, FMH_14 = NA), haven::tagged_na("b"))

  # Multiple conditions: Premature heart disease and late stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 1, FMH_14 = 70), 1)

  # Multiple conditions: Late heart disease and premature stroke
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 65, FMH_13 = 1, FMH_14 = 55), 1)

  # Non-response combined with valid input
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = NA, FMH_13 = 1, FMH_14 = 55), 1)
  expect_equal(determine_CVD_family_history(FMH_11 = 1, FMH_12 = 50, FMH_13 = 1, FMH_14 = NA), 1)
})
