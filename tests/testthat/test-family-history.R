#test-family-history.R
# Test determine_CVD_Personal_History
test_that("determine_CVD_Personal_History works correctly", {
  
  # Example case: Heart disease present
  expect_equal(determine_CVD_Personal_History(CCC_61 = 1, CCC_63 = 2, CCC_81 = 2), 1)
  
  # Heart attack present
  expect_equal(determine_CVD_Personal_History(CCC_61 = 2, CCC_63 = 1, CCC_81 = 2), 1)
  
  # Stroke present
  expect_equal(determine_CVD_Personal_History(CCC_61 = 2, CCC_63 = 2, CCC_81 = 1), 1)
  
  # All conditions absent
  expect_equal(determine_CVD_Personal_History(CCC_61 = 2, CCC_63 = 2, CCC_81 = 2), 2)
  
  # Non-response: All inputs are missing
  expect_equal(determine_CVD_Personal_History(CCC_61 = NA, CCC_63 = NA, CCC_81 = NA), haven::tagged_na("b"))
  
  # Mixed responses: One missing, others valid
  expect_equal(determine_CVD_Personal_History(CCC_61 = 1, CCC_63 = NA, CCC_81 = 2), 1)
  expect_equal(determine_CVD_Personal_History(CCC_61 = 2, CCC_63 = 2, CCC_81 = NA), 2)
  
  # Edge cases: Invalid inputs
  expect_equal(determine_CVD_Personal_History(CCC_61 = NA, CCC_63 = 1, CCC_81 = 1), 1)
  expect_equal(determine_CVD_Personal_History(CCC_61 = NA, CCC_63 = NA, CCC_81 = 1), 1)
})