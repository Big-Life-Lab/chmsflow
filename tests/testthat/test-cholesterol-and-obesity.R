# test-cholesterol-and-obesity.R
test_that("calculate_nonHDL works correctly", {
  # Valid inputs within threshold
  expect_equal(calculate_nonHDL(50, 5), 45)

  # LAB_CHOL exceeds threshold
  expect_equal(calculate_nonHDL(100, 5), haven::tagged_na("b"))

  # LAB_HDL exceeds threshold
  expect_equal(calculate_nonHDL(50, 10), haven::tagged_na("b"))

  # Both LAB_CHOL and LAB_HDL are missing
  expect_equal(calculate_nonHDL(NA, NA), haven::tagged_na("b"))

  # Valid inputs with zero HDL cholesterol
  expect_equal(calculate_nonHDL(50, 0), 50)
})


test_that("categorize_nonHDL works correctly", {
  # High non-HDL cholesterol (nonHDL >= 4.3)
  expect_equal(categorize_nonHDL(5.0), 1)

  # Normal non-HDL cholesterol (nonHDL < 4.3)
  expect_equal(categorize_nonHDL(3.8), 2)

  # Missing nonHDL input
  expect_equal(categorize_nonHDL(NA), haven::tagged_na("b"))

  # Edge case: nonHDL exactly 4.3
  expect_equal(categorize_nonHDL(4.3), 1)
})


test_that("calculate_WHR works correctly", {
  # Valid inputs
  expect_equal(calculate_WHR(170, 85), 0.5)

  # Missing height
  expect_equal(calculate_WHR(NA, 85), haven::tagged_na("b"))

  # Missing waist circumference
  expect_equal(calculate_WHR(170, NA), haven::tagged_na("b"))

  # Both height and waist circumference missing
  expect_equal(calculate_WHR(NA, NA), haven::tagged_na("b"))

  # Valid inputs with zero waist circumference
  expect_equal(calculate_WHR(170, 0), 0)

  # Edge case: Zero height (should handle division by zero)
  expect_equal(calculate_WHR(0, 85), Inf)
})
