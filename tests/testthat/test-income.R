# test-income.R
# Test for calculate_hhld_income
test_that("calculate_hhld_income works correctly", {
  expect_equal(calculate_hhld_income(50000, 3), 29411.76, tolerance = 1e-2)
  expect_equal(calculate_hhld_income(75000, 2), 53571.43, tolerance = 1e-2)
  expect_equal(calculate_hhld_income(90000, 1), 90000)
  expect_equal(calculate_hhld_income(NA, 3), haven::tagged_na("b")) # Non-response income
  expect_equal(calculate_hhld_income(50000, NA), haven::tagged_na("b")) # Non-response household size

  # Non-response values
  expect_true(is.na(calculate_hhld_income(99999998, 98)))
  expect_equal(calculate_hhld_income(NA, 3), haven::tagged_na("b"))
  expect_equal(calculate_hhld_income(50000, NA), haven::tagged_na("b"))

  # Vector usage
  expect_equal(calculate_hhld_income(THI_01 = c(50000, 75000, 90000, NA, 50000), DHHDHSZ = c(3, 2, 1, 3, NA)), c(29411.76, 53571.43, 90000, haven::tagged_na("b"), haven::tagged_na("b")), tolerance = 1e-2)

  # Database usage (simulated)
  df_income <- data.frame(
    THI_01 = c(50000, 75000, 90000, NA, 50000),
    DHHDHSZ = c(3, 2, 1, 3, NA)
  )
  expected_output_income <- c(29411.76, 53571.43, 90000, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_income %>% dplyr::mutate(adj_hh_income = calculate_hhld_income(THI_01, DHHDHSZ)) %>% dplyr::pull(adj_hh_income), expected_output_income, tolerance = 1e-2)
})

# Test for categorize_income
test_that("categorize_income works correctly", {
  expect_equal(categorize_income(15000), 1)
  expect_equal(categorize_income(25000), 2)
  expect_equal(categorize_income(45000), 3)
  expect_equal(categorize_income(65000), 4)
  expect_equal(categorize_income(75000), 5)
  expect_equal(categorize_income(NA), haven::tagged_na("b"))

  # Vector usage
  expect_equal(categorize_income(c(25000, 45000, 80000, NA, -100)), c(2, 3, 5, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_cat_income <- data.frame(
    adj_hh_inc = c(25000, 45000, 80000, NA, -100)
  )
  expected_output_cat_income <- c(2, 3, 5, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_cat_income %>% dplyr::mutate(income_category = categorize_income(adj_hh_inc)) %>% dplyr::pull(income_category), expected_output_cat_income)
})

# Test suite for boundary cases in categorize_income
test_that("categorize_income handles boundary cases correctly", {
  expect_equal(categorize_income(21500), 1)
  expect_equal(categorize_income(21500.01), 2)
  expect_equal(categorize_income(35000), 2)
  expect_equal(categorize_income(35000.01), 3)
  expect_equal(categorize_income(50000), 3)
  expect_equal(categorize_income(50000.01), 4)
  expect_equal(categorize_income(70000), 4)
  expect_equal(categorize_income(70000.01), 5)
})

# Test for in_lowest_income_quintile
test_that("in_lowest_income_quintile works correctly", {
  expect_equal(in_lowest_income_quintile(1), 1) # In the lowest income quintile
  expect_equal(in_lowest_income_quintile(3), 2) # Not in the lowest income quintile
  expect_equal(in_lowest_income_quintile(NA), haven::tagged_na("b")) # Missing input

  # Vector usage
  expect_equal(in_lowest_income_quintile(c(3, 1, 5, NA, haven::tagged_na("b"))), c(2, 1, 2, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_lowest_quintile <- data.frame(
    incq = c(3, 1, 5, NA, haven::tagged_na("b"))
  )
  expected_output_lowest_quintile <- c(2, 1, 2, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_lowest_quintile %>% dplyr::mutate(in_lowest_quintile = in_lowest_income_quintile(incq)) %>% dplyr::pull(in_lowest_quintile), expected_output_lowest_quintile)
})

test_that("calculate_hhld_income handles invalid inputs", {
  expect_equal(calculate_hhld_income(-100, 3), haven::tagged_na("b"))
  expect_equal(calculate_hhld_income(50000, -1), haven::tagged_na("b"))
  expect_equal(calculate_hhld_income(50000, 0), haven::tagged_na("b"))
})

test_that("categorize_income handles invalid inputs", {
  expect_equal(categorize_income(-100), haven::tagged_na("b"))
})

test_that("in_lowest_income_quintile covers all categories", {
  expect_equal(in_lowest_income_quintile(1), 1)
  expect_equal(in_lowest_income_quintile(2), 2)
  expect_equal(in_lowest_income_quintile(3), 2)
  expect_equal(in_lowest_income_quintile(4), 2)
  expect_equal(in_lowest_income_quintile(5), 2)
  expect_equal(in_lowest_income_quintile(haven::tagged_na("b")), haven::tagged_na("b"))
})
