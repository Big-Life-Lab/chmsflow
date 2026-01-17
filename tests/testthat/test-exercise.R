# test-exercise.R

# Test for find_week_accelerometer_average
test_that("find_week_accelerometer_average returns correct weekly accelerometer average", {
  # General tests
  expect_equal(find_week_accelerometer_average(30, 30, 30, 30, 30, 30, 30), 30)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(is.na(find_week_accelerometer_average(9996, 30, 30, 30, 30, 30, 30)))
  expect_true(is.na(find_week_accelerometer_average(9997, 30, 30, 30, 30, 30, 30)))
  expect_true(haven::is_tagged_na(find_week_accelerometer_average(-1, 30, 30, 30, 30, 30, 30), "b"))
  expect_true(is.na(find_week_accelerometer_average(NA, 30, 30, 30, 30, 30, 30)))
  expect_equal(find_week_accelerometer_average(0, 0, 0, 0, 0, 0, 0), 0) # All zeros
  expect_equal(find_week_accelerometer_average(10, 20, 30, 40, 50, 60, 70), 40) # Variable activity

  # Vector tests
  expect_equal(find_week_accelerometer_average(c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0), c(30, 0)), c(30, 0))

  # Database tests
  df <- data.frame(D1 = c(30, 0), D2 = c(30, 0), D3 = c(30, 0), D4 = c(30, 0), D5 = c(30, 0), D6 = c(30, 0), D7 = c(30, 0))
  expect_equal(df %>% dplyr::mutate(avg = find_week_accelerometer_average(D1, D2, D3, D4, D5, D6, D7)) %>% dplyr::pull(avg), c(30, 0))
})

# Test for minperday_to_minperweek
test_that("minperday_to_minperweek returns correct minutes per week", {
  # General tests
  expect_equal(minperday_to_minperweek(30), 210)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(minperday_to_minperweek(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(minperday_to_minperweek(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(minperday_to_minperweek(-1), "b"))
  expect_true(is.na(minperday_to_minperweek(NA)))
  expect_equal(minperday_to_minperweek(0), 0) # Zero minutes
  expect_equal(minperday_to_minperweek(60), 420) # One hour per day

  # Vector tests
  expect_equal(minperday_to_minperweek(c(30, 0, haven::tagged_na("a"))), c(210, 0, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(minday = c(30, 0, 60))
  expect_equal(df %>% dplyr::mutate(minweek = minperday_to_minperweek(minday)) %>% dplyr::pull(minweek), c(210, 0, 420))
})

# Test for categorize_minperweek
test_that("categorize_minperweek returns correct physical activity category", {
  # General tests
  expect_equal(categorize_minperweek(150), 1)
  expect_equal(categorize_minperweek(149), 2)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(categorize_minperweek(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_minperweek(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_minperweek(-1), "b"))
  expect_true(is.na(categorize_minperweek(NA)))
  expect_equal(categorize_minperweek(150.0), 1) # Exactly at threshold
  expect_equal(categorize_minperweek(0), 2) # Zero minutes

  # Vector tests
  expect_equal(categorize_minperweek(c(150, 149, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(minweek = c(150, 149, 200))
  expect_equal(df %>% dplyr::mutate(cat = categorize_minperweek(minweek)) %>% dplyr::pull(cat), c(1, 2, 1))
})
