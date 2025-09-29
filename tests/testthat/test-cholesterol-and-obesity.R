# test-cholesterol-and-obesity.R

# Test for calculate_nonHDL
test_that("calculate_nonHDL returns correct non-HDL cholesterol level", {
  expect_equal(calculate_nonHDL(5, 1.5), 3.5)
  expect_true(haven::is_tagged_na(calculate_nonHDL(99.96, 1.5), "a"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 9.96), "a"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(99.97, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 9.97), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(1.87, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 0.48), "b"))
  expect_true(is.na(calculate_nonHDL(NA, 1.5)))
  expect_equal(calculate_nonHDL(c(5, 99.96), c(1.5, 1.5)), c(3.5, haven::tagged_na("a")))
})

# Test for categorize_nonHDL
test_that("categorize_nonHDL returns correct non-HDL cholesterol category", {
  expect_equal(categorize_nonHDL(4.3), 1)
  expect_equal(categorize_nonHDL(4.29), 2)
  expect_true(haven::is_tagged_na(categorize_nonHDL(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_nonHDL(haven::tagged_na("b")), "b"))
  expect_true(is.na(categorize_nonHDL(NA)))
  expect_equal(categorize_nonHDL(c(4.3, 4.29, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})

# Test for calculate_WHR
test_that("calculate_WHR returns correct waist-to-height ratio", {
  expect_equal(calculate_WHR(170, 85), 0.5)
  expect_true(haven::is_tagged_na(calculate_WHR(999.96, 85), "a"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, 999.6), "a"))
  expect_true(haven::is_tagged_na(calculate_WHR(999.97, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, 999.7), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(-1, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, -1), "b"))
  expect_true(is.na(calculate_WHR(NA, 85)))
  expect_equal(calculate_WHR(c(170, 999.96), c(85, 85)), c(0.5, haven::tagged_na("a")))
})
