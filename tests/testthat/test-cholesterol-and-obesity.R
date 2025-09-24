# test-cholesterol-and-obesity.R
test_that("calculate_nonHDL works correctly", {
  # Valid inputs within new thresholds
  expect_equal(calculate_nonHDL(5, 1), 4)
  expect_equal(calculate_nonHDL(10, 2), 8)

  # LAB_CHOL below lower threshold
  expect_equal(calculate_nonHDL(1.87, 1), haven::tagged_na("b"))
  # LAB_CHOL above upper threshold
  expect_equal(calculate_nonHDL(13.59, 1), haven::tagged_na("b"))

  # LAB_HDL below lower threshold
  expect_equal(calculate_nonHDL(5, 0.48), haven::tagged_na("b"))
  # LAB_HDL above upper threshold
  expect_equal(calculate_nonHDL(5, 3.75), haven::tagged_na("b"))

  # Both LAB_CHOL and LAB_HDL are missing
  expect_equal(calculate_nonHDL(NA, NA), haven::tagged_na("b"))

  # Valid inputs with zero HDL cholesterol (should be NA(b) due to new lower bound)
  expect_equal(calculate_nonHDL(5, 0), haven::tagged_na("b"))

  # Non-response values
  expect_true(is.na(calculate_nonHDL(99.98, 9.98)))

  # Vector usage
  expect_equal(calculate_nonHDL(LAB_CHOL = c(5, 10, 1.87, 13.59, NA), LAB_HDL = c(1, 2, 1, 1, NA)), c(4, 8, haven::tagged_na("b"), haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_nonhdl <- data.frame(
    LAB_CHOL = c(5, 10, 1.87, 13.59, NA),
    LAB_HDL = c(1, 2, 1, 1, NA)
  )
  expected_output_nonhdl <- c(4, 8, NA, NA, NA)
  expect_equal(df_nonhdl %>% dplyr::mutate(non_hdl = calculate_nonHDL(LAB_CHOL, LAB_HDL)) %>% dplyr::pull(non_hdl), expected_output_nonhdl)
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

  # Vector usage
  expect_equal(categorize_nonHDL(c(5.0, 3.8, 4.3, NA, -1)), c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_cat_nonhdl <- data.frame(
    nonHDL = c(5.0, 3.8, 4.3, NA, -1)
  )
  expected_output_cat_nonhdl <- c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_cat_nonhdl %>% dplyr::mutate(non_hdl_category = categorize_nonHDL(nonHDL)) %>% dplyr::pull(non_hdl_category), expected_output_cat_nonhdl)
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

  # Non-response values
  expect_true(is.na(calculate_WHR(999.98, 999.8)))

  # Vector usage
  expect_equal(calculate_WHR(HWM_11CM = c(170, 180, 160, NA, 170, 0), HWM_14CX = c(85, 90, 80, 85, NA, 85)), c(0.5, 0.5, 0.5, haven::tagged_na("b"), haven::tagged_na("b"), Inf))

  # Database usage (simulated)
  df_whr <- data.frame(
    HWM_11CM = c(170, 180, 160, NA, 170, 0),
    HWM_14CX = c(85, 90, 80, 85, NA, 85)
  )
  expected_output_whr <- c(0.5, 0.5, 0.5, haven::tagged_na("b"), haven::tagged_na("b"), Inf)
  expect_equal(df_whr %>% dplyr::mutate(whr = calculate_WHR(HWM_11CM, HWM_14CX)) %>% dplyr::pull(whr), expected_output_whr)
  expect_equal(df_whr %>% dplyr::mutate(whr = calculate_WHR(HWM_11CM, HWM_14CX)) %>% dplyr::pull(whr), expected_output_whr)
})
