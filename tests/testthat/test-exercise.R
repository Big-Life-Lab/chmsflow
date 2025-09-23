# test-exercise.R
# Test find_week_accelerometer_average
test_that("find_week_accelerometer_average handles various cases", {
  # Case 1: All days have valid exercise values
  expect_equal(find_week_accelerometer_average(30, 40, 25, 35, 20, 45, 50), 35)

  # Case 2: Some days are NA
  expect_equal(find_week_accelerometer_average(30, NA, 25, 35, NA, 45, 50), haven::tagged_na("b"))

  # Case 3: All days are 0 (no exercise)
  expect_equal(find_week_accelerometer_average(0, 0, 0, 0, 0, 0, 0), 0)

  # Case 4: All days are NA
  expect_equal(find_week_accelerometer_average(NA, NA, NA, NA, NA, NA, NA), haven::tagged_na("b"))

  # Vector usage
  expect_equal(find_week_accelerometer_average(c(30, 20), c(40, 30), c(25, 35), c(35, 45), c(20, 25), c(45, 55), c(50, 60)), c(35, 38.57142857142857), tolerance = 1e-7)

  # Database usage (simulated)
  df_accel <- data.frame(
    AMMDMVA1 = c(30, NA),
    AMMDMVA2 = c(40, NA),
    AMMDMVA3 = c(25, NA),
    AMMDMVA4 = c(35, NA),
    AMMDMVA5 = c(20, NA),
    AMMDMVA6 = c(45, NA),
    AMMDMVA7 = c(50, NA)
  )
  expected_output_accel <- c(35, haven::tagged_na("b"))
  expect_equal(df_accel %>% dplyr::mutate(avg_exercise = find_week_accelerometer_average(AMMDMVA1, AMMDMVA2, AMMDMVA3, AMMDMVA4, AMMDMVA5, AMMDMVA6, AMMDMVA7)) %>% dplyr::pull(avg_exercise), expected_output_accel)
})

# Test minperday_to_minperweek
test_that("minperday_to_minperweek handles various inputs", {
  # Case 1: Valid input
  expect_equal(minperday_to_minperweek(35), 245)

  # Case 2: NA input
  expect_equal(minperday_to_minperweek(NA), haven::tagged_na("b"))

  # Case 3: Zero input
  expect_equal(minperday_to_minperweek(0), 0)

  # Vector usage
  expect_equal(minperday_to_minperweek(c(35, 40, 20, NA, -10)), c(245, 280, 140, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_minperweek <- data.frame(
    MVPA_min = c(35, 40, 20, NA, -10)
  )
  expected_output_minperweek <- c(245, 280, 140, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_minperweek %>% dplyr::mutate(min_per_week = minperday_to_minperweek(MVPA_min)) %>% dplyr::pull(min_per_week), expected_output_minperweek)
})

# Test categorize_minperweek
test_that("categorize_minperweek handles various thresholds", {
  # Case 1: Meets or exceeds the recommendation
  expect_equal(categorize_minperweek(150), 1)
  expect_equal(categorize_minperweek(200), 1)

  # Case 2: Below the recommendation
  expect_equal(categorize_minperweek(149), 2)
  expect_equal(categorize_minperweek(0), 2)

  # Case 3: NA input
  expect_equal(categorize_minperweek(NA), haven::tagged_na("b"))

  # Vector usage
  expect_equal(categorize_minperweek(c(180, 120, 150, NA, -1)), c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_cat_minperweek <- data.frame(
    minperweek = c(180, 120, 150, NA, -1)
  )
  expected_output_cat_minperweek <- c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_cat_minperweek %>% dplyr::mutate(pa_category = categorize_minperweek(minperweek)) %>% dplyr::pull(pa_category), expected_output_cat_minperweek)
})

test_that("find_week_accelerometer_average handles single NA", {
  expect_equal(find_week_accelerometer_average(30, 40, 25, 35, 20, 45, NA), haven::tagged_na("b"))
})

test_that("find_week_accelerometer_average handles negative inputs", {
  expect_equal(find_week_accelerometer_average(30, 40, -25, 35, 20, 45, 50), haven::tagged_na("b"))
})

test_that("minperday_to_minperweek handles negative inputs", {
  expect_equal(minperday_to_minperweek(-10), haven::tagged_na("b"))
})

test_that("categorize_minperweek handles more boundary cases", {
  expect_equal(categorize_minperweek(150.0001), 1)
  expect_equal(categorize_minperweek(149.9999), 2)
  expect_equal(categorize_minperweek(-1), haven::tagged_na("b"))
})
