# test-cholesterol-and-obesity.R

# Test for calculate_nonhdl
test_that("calculate_nonhdl returns correct non-HDL cholesterol level", {
  expect_equal(calculate_nonhdl(5, 1.5), 3.5)
  expect_true(haven::is_tagged_na(calculate_nonhdl(99.96, 1.5), "a"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 9.96), "a"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(99.97, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 9.97), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(1.87, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 0.48), "b"))
  expect_true(is.na(calculate_nonhdl(NA, 1.5)))
  expect_equal(calculate_nonhdl(c(5, 99.96), c(1.5, 1.5)), c(3.5, haven::tagged_na("a")))
})

# Test for categorize_nonhdl
test_that("categorize_nonhdl returns correct non-HDL cholesterol category", {
  expect_equal(categorize_nonhdl(4.3), 1)
  expect_equal(categorize_nonhdl(4.29), 2)
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("b")), "b"))
  expect_true(is.na(categorize_nonhdl(NA)))
  expect_equal(categorize_nonhdl(c(4.3, 4.29, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})

# Test for calculate_waist_height_ratio
test_that("calculate_waist_height_ratio returns correct waist-to-height ratio", {
  expect_equal(calculate_waist_height_ratio(170, 85), 0.5)
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(999.96, 85), "a"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, 999.6), "a"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(999.97, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, 999.7), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(-1, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, -1), "b"))
  expect_true(is.na(calculate_waist_height_ratio(NA, 85)))
  expect_equal(calculate_waist_height_ratio(c(170, 999.96), c(85, 85)), c(0.5, haven::tagged_na("a")))
})
