# test-diabetes.R

# Test for derive_diabetes_status
test_that("derive_diabetes_status returns correct diabetes status", {
  # All inputs present
  expect_equal(derive_diabetes_status(1, 1, 1), 1)
  expect_equal(derive_diabetes_status(1, 1, 0), 1)
  expect_equal(derive_diabetes_status(1, 2, 1), 1)
  expect_equal(derive_diabetes_status(1, 2, 0), 1)
  expect_equal(derive_diabetes_status(2, 1, 1), 1)
  expect_equal(derive_diabetes_status(2, 1, 0), 1)
  expect_equal(derive_diabetes_status(2, 2, 1), 1)
  expect_equal(derive_diabetes_status(2, 2, 0), 2)

  # One input missing
  expect_equal(derive_diabetes_status(NA, 1, 1), 1)
  expect_equal(derive_diabetes_status(1, NA, 1), 1)
  expect_equal(derive_diabetes_status(1, 1, NA), 1)
  expect_equal(derive_diabetes_status(NA, 2, 0), 2)
  expect_equal(derive_diabetes_status(2, NA, 0), 2)
  expect_equal(derive_diabetes_status(2, 2, NA), 2)

  # Two inputs missing
  expect_equal(derive_diabetes_status(NA, NA, 1), 1)
  expect_equal(derive_diabetes_status(NA, 1, NA), 1)
  expect_equal(derive_diabetes_status(1, NA, NA), 1)
  expect_equal(derive_diabetes_status(NA, NA, 0), 2)
  expect_equal(derive_diabetes_status(NA, 2, NA), 2)
  expect_equal(derive_diabetes_status(2, NA, NA), 2)

  # All inputs missing
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 8, haven::tagged_na("b")), "b"))

  # Missing data codes
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("a"), 6, 0), "a"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("a"), 6, haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 7, 0), "b"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 7, haven::tagged_na("b")), "b"))

  # Vector usage
  expect_equal(derive_diabetes_status(c(1, 2, 2, NA), c(2, 1, 2, NA), c(0, 0, 1, 1)), c(1, 1, 1, 1))
})
