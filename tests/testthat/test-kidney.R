# test-kidney.R

# Test for calculate_GFR
test_that("calculate_GFR returns correct GFR", {
  expect_equal(calculate_GFR(80, 1, 2, 45), 67.27905, tolerance = 1e-5)
  expect_equal(calculate_GFR(70, 2, 2, 35), 99.94114, tolerance = 1e-5)
  expect_equal(calculate_GFR(90, 1, 1, 50), 77.47422, tolerance = 1e-5)
  expect_true(haven::is_tagged_na(calculate_GFR(9996, 1, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 96, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 6, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 2, 996), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(9997, 1, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 97, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 7, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 2, 997), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(13, 1, 2, 45), "b"))
  expect_true(is.na(calculate_GFR(NA, 1, 2, 45)))
  expect_equal(calculate_GFR(c(80, 70), c(1, 2), c(2, 2), c(45, 35)), c(67.27905, 99.94114), tolerance = 1e-5)
})

# Test for categorize_GFR_to_CKD
test_that("categorize_GFR_to_CKD returns correct CKD category", {
  expect_equal(categorize_GFR_to_CKD(60), 1)
  expect_equal(categorize_GFR_to_CKD(61), 2)
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(-1), "b"))
  expect_true(is.na(categorize_GFR_to_CKD(NA)))
  expect_equal(categorize_GFR_to_CKD(c(60, 61, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
