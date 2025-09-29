# test-exercise.R

# Test for find_week_accelerometer_average
test_that("find_week_accelerometer_average returns correct weekly accelerometer average", {
  expect_equal(find_week_accelerometer_average(30, 30, 30, 30, 30, 30, 30), 30)
  expect_true(is.na(find_week_accelerometer_average(9996, 30, 30, 30, 30, 30, 30)))
  expect_true(is.na(find_week_accelerometer_average(9997, 30, 30, 30, 30, 30, 30)))
  expect_true(haven::is_tagged_na(find_week_accelerometer_average(-1, 30, 30, 30, 30, 30, 30), "b"))
  expect_true(is.na(find_week_accelerometer_average(NA, 30, 30, 30, 30, 30, 30)))
  expect_equal(find_week_accelerometer_average(c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0)), c(30, 0))
})

# Test for minperday_to_minperweek
test_that("minperday_to_minperweek returns correct minutes per week", {
  expect_equal(minperday_to_minperweek(30), 210)
  expect_true(haven::is_tagged_na(minperday_to_minperweek(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(minperday_to_minperweek(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(minperday_to_minperweek(-1), "b"))
  expect_true(is.na(minperday_to_minperweek(NA)))
  expect_equal(minperday_to_minperweek(c(30, 0, haven::tagged_na("a"))), c(210, 0, haven::tagged_na("a")))
})

# Test for categorize_minperweek
test_that("categorize_minperweek returns correct physical activity category", {
  expect_equal(categorize_minperweek(150), 1)
  expect_equal(categorize_minperweek(149), 2)
  expect_true(haven::is_tagged_na(categorize_minperweek(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_minperweek(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_minperweek(-1), "b"))
  expect_true(is.na(categorize_minperweek(NA)))
  expect_equal(categorize_minperweek(c(150, 149, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
