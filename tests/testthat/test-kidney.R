# test-kidney.R

# Test for calculate_gfr
test_that("calculate_gfr returns correct GFR", {
  expect_equal(calculate_gfr(80, 1, 2, 45), 67.27905, tolerance = 1e-5)
  expect_equal(calculate_gfr(70, 2, 2, 35), 99.94114, tolerance = 1e-5)
  expect_equal(calculate_gfr(90, 1, 1, 50), 77.47422, tolerance = 1e-5)
  expect_true(haven::is_tagged_na(calculate_gfr(9996, 1, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 96, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 1, 6, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 1, 2, 996), "a"))
  expect_true(haven::is_tagged_na(calculate_gfr(9997, 1, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 97, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 1, 7, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_gfr(80, 1, 2, 997), "b"))
  expect_true(haven::is_tagged_na(calculate_gfr(13, 1, 2, 45), "b"))
  expect_true(is.na(calculate_gfr(NA, 1, 2, 45)))
  expect_equal(calculate_gfr(c(80, 70), c(1, 2), c(2, 2), c(45, 35)), c(67.27905, 99.94114), tolerance = 1e-5)
})

# Test for categorize_ckd
test_that("categorize_ckd returns correct CKD category", {
  expect_equal(categorize_ckd(60), 1)
  expect_equal(categorize_ckd(61), 2)
  expect_true(haven::is_tagged_na(categorize_ckd(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_ckd(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_ckd(-1), "b"))
  expect_true(is.na(categorize_ckd(NA)))
  expect_equal(categorize_ckd(c(60, 61, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
