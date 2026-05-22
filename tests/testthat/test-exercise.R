# test-exercise.R

# Test for calculate_exercise_daily_avg
test_that("calculate_exercise_daily_avg returns correct weekly accelerometer average", {
  # General tests
  expect_equal(calculate_exercise_daily_avg(30, 30, 30, 30, 30, 30, 30), 30)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(is.na(calculate_exercise_daily_avg(9996, 30, 30, 30, 30, 30, 30)))
  expect_true(is.na(calculate_exercise_daily_avg(9997, 30, 30, 30, 30, 30, 30)))
  expect_true(haven::is_tagged_na(calculate_exercise_daily_avg(-1, 30, 30, 30, 30, 30, 30), "b"))
  expect_true(is.na(calculate_exercise_daily_avg(NA, 30, 30, 30, 30, 30, 30)))
  expect_equal(calculate_exercise_daily_avg(0, 0, 0, 0, 0, 0, 0), 0) # All zeros
  expect_equal(calculate_exercise_daily_avg(10, 20, 30, 40, 50, 60, 70), 40) # Variable activity

  # Vector tests
  expect_equal(calculate_exercise_daily_avg(c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0)), c(30, 0))

  # Database tests
  df <- data.frame(D1 = c(30, 0), D2 = c(30, 0), D3 = c(30, 0), D4 = c(30, 0), D5 = c(30, 0), D6 = c(30, 0), D7 = c(30, 0))
  expect_equal(df |> dplyr::mutate(avg = calculate_exercise_daily_avg(D1, D2, D3, D4, D5, D6, D7)) |> dplyr::pull(avg), c(30, 0))
})

# Test for calculate_exercise_weekly
test_that("calculate_exercise_weekly returns correct minutes per week", {
  # General tests
  expect_equal(calculate_exercise_weekly(30), 210)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(calculate_exercise_weekly(-1), "b"))
  expect_true(is.na(calculate_exercise_weekly(NA)))
  expect_equal(calculate_exercise_weekly(0), 0) # Zero minutes
  expect_equal(calculate_exercise_weekly(60), 420) # One hour per day

  # Vector tests
  expect_equal(calculate_exercise_weekly(c(30, 0, haven::tagged_na("a"))), c(210, 0, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(minday = c(30, 0, 60))
  expect_equal(df |> dplyr::mutate(minweek = calculate_exercise_weekly(minday)) |> dplyr::pull(minweek), c(210, 0, 420))
})

# Test for categorize_exercise
test_that("categorize_exercise returns correct physical activity category", {
  # General tests
  expect_equal(categorize_exercise(150), 1)
  expect_equal(categorize_exercise(149), 2)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(categorize_exercise(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_exercise(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_exercise(-1), "b"))
  expect_true(is.na(categorize_exercise(NA)))
  expect_equal(categorize_exercise(150.0), 1) # Exactly at threshold
  expect_equal(categorize_exercise(0), 2) # Zero minutes

  # Vector tests
  expect_equal(categorize_exercise(c(150, 149, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(minweek = c(150, 149, 200))
  expect_equal(df |> dplyr::mutate(cat = categorize_exercise(minweek)) |> dplyr::pull(cat), c(1, 2, 1))
})

# Mixed-length / empty-vector tests
test_that("calculate_exercise_daily_avg handles empty input", {
  empty <- numeric(0)
  expect_length(
    calculate_exercise_daily_avg(empty, empty, empty, empty, empty, empty, empty),
    0
  )
})
