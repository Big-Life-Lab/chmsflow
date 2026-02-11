# test-diet.R

# Test for calculate_fv_daily_cycles1to2
test_that("calculate_fv_daily_cycles1to2 returns correct daily fruit and vegetable consumption", {
  expect_equal(calculate_fv_daily_cycles1to2(365, 365, 365, 365, 365, 365, 365), 7)
  expect_equal(calculate_fv_daily_cycles1to2(9996, 365, 365, 365, 365, 365, 365), 6)
  expect_equal(calculate_fv_daily_cycles1to2(9997, 365, 365, 365, 365, 365, 365), 6)
  expect_true(haven::is_tagged_na(calculate_fv_daily_cycles1to2(-1, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(calculate_fv_daily_cycles1to2(NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_equal(calculate_fv_daily_cycles1to2(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(7, 0))
})

# Test for calculate_fv_daily_cycles3to6
test_that("calculate_fv_daily_cycles3to6 returns correct daily fruit and vegetable consumption", {
  expect_equal(calculate_fv_daily_cycles3to6(365, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 11)
  expect_equal(calculate_fv_daily_cycles3to6(9996, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)
  expect_equal(calculate_fv_daily_cycles3to6(9997, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)
  expect_true(haven::is_tagged_na(calculate_fv_daily_cycles3to6(-1, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(calculate_fv_daily_cycles3to6(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_equal(calculate_fv_daily_cycles3to6(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(11, 0))
})

# Test for categorize_diet_quality
test_that("categorize_diet_quality returns correct diet category", {
  expect_equal(categorize_diet_quality(5), 1)
  expect_equal(categorize_diet_quality(4.9), 2)
  expect_true(haven::is_tagged_na(categorize_diet_quality(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_diet_quality(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_diet_quality(-1), "b"))
  expect_true(is.na(categorize_diet_quality(NA)))
  expect_equal(categorize_diet_quality(c(5, 4.9, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
