#test-exercise.R
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
})

# Test minperday_to_minperweek
test_that("minperday_to_minperweek handles various inputs", {
  # Case 1: Valid input
  expect_equal(minperday_to_minperweek(35), 245)
  
  # Case 2: NA input
  expect_equal(minperday_to_minperweek(NA), haven::tagged_na("b"))
  
  # Case 3: Zero input
  expect_equal(minperday_to_minperweek(0), 0)
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
})