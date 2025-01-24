# test-blood-pressure.R
# Test suite for the adjust_SBP function
test_that("adjust_SBP calculates adjusted systolic blood pressure correctly", {
  # Case: Valid blood pressure input
  expect_equal(adjust_SBP(120), 11.4 + (0.93 * 120))

  # Case: Non-response value
  expect_equal(adjust_SBP(996), haven::tagged_na("b"))

  # Case: Invalid input (negative value)
  expect_equal(adjust_SBP(-5), haven::tagged_na("b"))

  # Case: NA input
  expect_equal(adjust_SBP(NA), haven::tagged_na("b"))
})

# Test suite for the adjust_DBP function
test_that("adjust_DBP calculates adjusted diastolic blood pressure correctly", {
  # Case: Valid blood pressure input
  expect_equal(adjust_DBP(80), 15.6 + (0.83 * 80))

  # Case: Non-response value
  expect_equal(adjust_DBP(996), haven::tagged_na("b"))

  # Case: Invalid input (negative value)
  expect_equal(adjust_DBP(-5), haven::tagged_na("b"))

  # Case: NA input
  expect_equal(adjust_DBP(NA), haven::tagged_na("b"))
})

# Test suite for the determine_hypertension function
test_that("determine_hypertension identifies hypertension status correctly", {
  # Case: High systolic and diastolic BP
  expect_equal(determine_hypertension(150, 95, 1), 1)

  # Case: Normal BP and not on medication
  expect_equal(determine_hypertension(120, 80, 0), 2)

  # Case: Missing BP but on medication
  expect_equal(determine_hypertension(NA, NA, 1), 1)

  # Case: Missing BP and not on medication
  expect_equal(determine_hypertension(NA, NA, 0), haven::tagged_na("b"))

  # Case: Adjusted ANYMED2 due to conditions
  expect_equal(determine_hypertension(120, 80, 1, CCC_32 = 2, CARDIOV = 1), 2)
})

# Test suite for the determine_adjusted_hypertension function
test_that("determine_adjusted_hypertension identifies adjusted hypertension status correctly", {
  # Case: High adjusted systolic and diastolic BP
  expect_equal(determine_adjusted_hypertension(150, 95, 1), 1)

  # Case: Normal adjusted BP and not on medication
  expect_equal(determine_adjusted_hypertension(120, 80, 0), 2)

  # Case: Missing adjusted BP but on medication
  expect_equal(determine_adjusted_hypertension(NA, NA, 1), 1)

  # Case: Missing adjusted BP and not on medication
  expect_equal(determine_adjusted_hypertension(NA, NA, 0), haven::tagged_na("b"))

  # Case: Adjusted ANYMED2 due to conditions
  expect_equal(determine_adjusted_hypertension(120, 80, 1, CCC_32 = 2, CARDIOV = 1), 2)
})

# Test suite for the determine_controlled_hypertension function
test_that("determine_controlled_hypertension works correctly", {
  # Case 1: Controlled Hypertension
  expect_equal(determine_controlled_hypertension(130, 85, 1), 1)

  # Case 2: Uncontrolled Hypertension
  expect_equal(determine_controlled_hypertension(145, 95, 1), 2)

  # Case 3: Controlled for Special Cases
  expect_equal(determine_controlled_hypertension(128, 78, 1, CCC_32 = 1, DIABX = 1), 1)

  # Case 4: Invalid Input
  expect_equal(determine_controlled_hypertension(999, 999, 1), haven::tagged_na("b"))

  # Case 5: No Hypertension
  expect_equal(determine_controlled_hypertension(120, 80, 0), 2)
})

# Test suite for the determine_controlled_adjusted_hypertension function
test_that("determine_controlled_adjusted_hypertension works correctly", {
  # Case 1: Controlled Hypertension
  expect_equal(determine_controlled_adjusted_hypertension(135, 88, 1), 1)

  # Case 2: Uncontrolled Hypertension
  expect_equal(determine_controlled_adjusted_hypertension(142, 92, 1), 2)

  # Case 3: Controlled for Special Cases
  expect_equal(determine_controlled_adjusted_hypertension(129, 79, 1, CCC_32 = 1, CKD = 1), 1)

  # Case 4: Invalid Input
  expect_equal(determine_controlled_adjusted_hypertension(999, 999, 1), haven::tagged_na("b"))

  # Case 5: No Hypertension
  expect_equal(determine_controlled_adjusted_hypertension(122, 80, 0), 2)
})
