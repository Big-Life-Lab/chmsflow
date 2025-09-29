# test-income.R

# Test for calculate_hhld_income
test_that("calculate_hhld_income returns correct adjusted household income", {
  expect_equal(calculate_hhld_income(50000, 1), 50000)
  expect_equal(calculate_hhld_income(50000, 2), 35714.29, tolerance = 1e-2)
  expect_equal(calculate_hhld_income(50000, 3), 29411.76, tolerance = 1e-2)
  expect_true(haven::is_tagged_na(calculate_hhld_income(99999996, 1), "a"))
  expect_true(haven::is_tagged_na(calculate_hhld_income(50000, 96), "a"))
  expect_true(haven::is_tagged_na(calculate_hhld_income(99999997, 1), "b"))
  expect_true(haven::is_tagged_na(calculate_hhld_income(50000, 97), "b"))
  expect_true(haven::is_tagged_na(calculate_hhld_income(-1, 1), "b"))
  expect_true(haven::is_tagged_na(calculate_hhld_income(50000, 0), "b"))
  expect_true(is.na(calculate_hhld_income(NA, 1)))
  expect_equal(calculate_hhld_income(c(50000, 50000), c(1, 2)), c(50000, 35714.29), tolerance = 1e-2)
})

# Test for categorize_income
test_that("categorize_income returns correct income category", {
  expect_equal(categorize_income(21500), 1)
  expect_equal(categorize_income(21501), 2)
  expect_equal(categorize_income(35000), 2)
  expect_equal(categorize_income(35001), 3)
  expect_equal(categorize_income(50000), 3)
  expect_equal(categorize_income(50001), 4)
  expect_equal(categorize_income(70000), 4)
  expect_equal(categorize_income(70001), 5)
  expect_true(haven::is_tagged_na(categorize_income(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_income(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_income(-1), "b"))
  expect_true(is.na(categorize_income(NA)))
  expect_equal(categorize_income(c(21500, 35000, 50000, 70000, 70001)), c(1, 2, 3, 4, 5))
})

# Test for in_lowest_income_quintile
test_that("in_lowest_income_quintile returns correct lowest income quintile status", {
  expect_equal(in_lowest_income_quintile(1), 1)
  expect_equal(in_lowest_income_quintile(2), 2)
  expect_equal(in_lowest_income_quintile(3), 2)
  expect_equal(in_lowest_income_quintile(4), 2)
  expect_equal(in_lowest_income_quintile(5), 2)
  expect_true(haven::is_tagged_na(in_lowest_income_quintile(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(in_lowest_income_quintile(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(in_lowest_income_quintile(0), "b"))
  expect_true(haven::is_tagged_na(in_lowest_income_quintile(6), "b"))
  expect_true(is.na(in_lowest_income_quintile(NA)))
  expect_equal(in_lowest_income_quintile(c(1, 2, 3, 4, 5)), c(1, 2, 2, 2, 2))
})
