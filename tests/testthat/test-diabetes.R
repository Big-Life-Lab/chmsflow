# test-diabetes.R

# Test for determine_inclusive_diabetes
test_that("determine_inclusive_diabetes returns correct diabetes status", {
  # All inputs present
  expect_equal(determine_inclusive_diabetes(1, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(1, 2, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, 2, 0), 1)
  expect_equal(determine_inclusive_diabetes(2, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(2, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(2, 2, 1), 1)
  expect_equal(determine_inclusive_diabetes(2, 2, 0), 2)

  # One input missing
  expect_equal(determine_inclusive_diabetes(NA, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(NA, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, 2, NA), 2)

  # Two inputs missing
  expect_equal(determine_inclusive_diabetes(NA, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(NA, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(1, NA, NA), 1)
  expect_equal(determine_inclusive_diabetes(NA, NA, 0), 2)
  expect_equal(determine_inclusive_diabetes(NA, 2, NA), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, NA), 2)

  # All inputs missing
  expect_true(haven::is_tagged_na(determine_inclusive_diabetes(haven::tagged_na("b"), 8, haven::tagged_na("b")), "b"))

  # Missing data codes
  expect_true(haven::is_tagged_na(determine_inclusive_diabetes(haven::tagged_na("a"), 6, 0), "a"))
  expect_true(haven::is_tagged_na(determine_inclusive_diabetes(haven::tagged_na("a"), 6, haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(determine_inclusive_diabetes(haven::tagged_na("b"), 7, 0), "b"))
  expect_true(haven::is_tagged_na(determine_inclusive_diabetes(haven::tagged_na("b"), 7, haven::tagged_na("b")), "b"))

  # Vector usage
  expect_equal(determine_inclusive_diabetes(c(1, 2, 2, NA), c(2, 1, 2, NA), c(0, 0, 1, 1)), c(1, 1, 1, 1))
})
