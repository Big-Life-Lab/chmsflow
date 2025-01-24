# test-income.R
# Test for calculate_Hhld_Income
test_that("calculate_Hhld_Income works correctly", {
  expect_equal(calculate_Hhld_Income(50000, 3), 29411.76, tolerance = 1e-2)
  expect_equal(calculate_Hhld_Income(75000, 2), 53571.43, tolerance = 1e-2)
  expect_equal(calculate_Hhld_Income(90000, 1), 90000)
  expect_equal(calculate_Hhld_Income(NA, 3), haven::tagged_na("b")) # Non-response income
  expect_equal(calculate_Hhld_Income(50000, NA), haven::tagged_na("b")) # Non-response household size
  expect_equal(calculate_Hhld_Income(NA, 3), haven::tagged_na("b"))
  expect_equal(calculate_Hhld_Income(50000, NA), haven::tagged_na("b"))
})

# Test for categorize_income
test_that("categorize_income works correctly", {
  expect_equal(categorize_income(15000), 1)
  expect_equal(categorize_income(25000), 2)
  expect_equal(categorize_income(45000), 3)
  expect_equal(categorize_income(65000), 4)
  expect_equal(categorize_income(75000), 5)
  expect_equal(categorize_income(NA), haven::tagged_na("b"))
})

# Test for in_lowest_income_qunitle
test_that("in_lowest_income_qunitle works correctly", {
  expect_equal(in_lowest_income_qunitle(1), 1) # In the lowest income quintile
  expect_equal(in_lowest_income_qunitle(3), 2) # Not in the lowest income quintile
  expect_equal(in_lowest_income_qunitle(NA), haven::tagged_na("b")) # Missing input
})
