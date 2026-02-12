# test-exercise.R

# Test for calculate_exercise_daily_avg
test_that("calculate_exercise_daily_avg returns correct weekly accelerometer average", {
  expect_equal(calculate_exercise_daily_avg(30, 30, 30, 30, 30, 30, 30), 30)
  expect_true(is.na(calculate_exercise_daily_avg(9996, 30, 30, 30, 30, 30, 30)))
  expect_true(is.na(calculate_exercise_daily_avg(9997, 30, 30, 30, 30, 30, 30)))
  expect_true(haven::is_tagged_na(calculate_exercise_daily_avg(-1, 30, 30, 30, 30, 30, 30), "b"))
  expect_true(is.na(calculate_exercise_daily_avg(NA, 30, 30, 30, 30, 30, 30)))
  expect_equal(calculate_exercise_daily_avg(c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0)), c(30, 0))
})

# Test for calculate_exercise_weekly
test_that("calculate_exercise_weekly returns correct minutes per week", {
  expect_equal(calculate_exercise_weekly(30), 210)
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(-1), "b"))
  expect_true(is.na(calculate_exercise_weekly(NA)))
  expect_equal(calculate_exercise_weekly(c(30, 0, haven::tagged_na("a"))), c(210, 0, haven::tagged_na("a")))
})

# Test for categorize_exercise
test_that("categorize_exercise returns correct physical activity category", {
  expect_equal(categorize_exercise(150), 1)
  expect_equal(categorize_exercise(149), 2)
  expect_true(haven::is_tagged_na(categorize_exercise(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_exercise(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_exercise(-1), "b"))
  expect_true(is.na(categorize_exercise(NA)))
  expect_equal(categorize_exercise(c(150, 149, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
