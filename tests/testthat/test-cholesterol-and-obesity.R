# test-cholesterol-and-obesity.R

# Test for calculate_nonHDL
test_that("calculate_nonHDL returns correct non-HDL cholesterol level", {
  # General tests
  expect_equal(calculate_nonHDL(5, 1.5), 3.5)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_nonHDL(99.96, 1.5), "a"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 9.96), "a"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(99.97, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 9.97), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(1.87, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 0.48), "b"))
  expect_true(is.na(calculate_nonHDL(NA, 1.5)))
  # Edge case tests - boundary values for valid ranges
  expect_true(!is.na(calculate_nonHDL(1.88, 0.49))) # Min valid
  expect_true(!is.na(calculate_nonHDL(13.58, 3.74))) # Max valid
  expect_true(haven::is_tagged_na(calculate_nonHDL(13.59, 1.5), "b")) # Above max CHOL
  expect_true(haven::is_tagged_na(calculate_nonHDL(5, 3.75), "b")) # Above max HDL
  expect_equal(calculate_nonHDL(2, 1), 1) # Low but valid values

  # Vector tests
  expect_equal(calculate_nonHDL(c(5, 99.96), c(1.5, 1.5)), c(3.5, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(CHOL = c(5, 6), HDL = c(1.5, 2))
  expect_equal(df %>% dplyr::mutate(nonHDL = calculate_nonHDL(CHOL, HDL)) %>% dplyr::pull(nonHDL), c(3.5, 4))
})

# Test for categorize_nonHDL
test_that("categorize_nonHDL returns correct non-HDL cholesterol category", {
  # General tests
  expect_equal(categorize_nonHDL(4.3), 1)
  expect_equal(categorize_nonHDL(4.29), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(categorize_nonHDL(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_nonHDL(haven::tagged_na("b")), "b"))
  expect_true(is.na(categorize_nonHDL(NA)))
  # Edge case tests - boundary values
  expect_equal(categorize_nonHDL(4.30), 1) # Exactly at threshold
  expect_equal(categorize_nonHDL(0), 2) # Zero value

  # Vector tests
  expect_equal(categorize_nonHDL(c(4.3, 4.29, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(nonHDL = c(4.3, 4.29, 5))
  expect_equal(df %>% dplyr::mutate(cat = categorize_nonHDL(nonHDL)) %>% dplyr::pull(cat), c(1, 2, 1))
})

# Test for calculate_WHR
test_that("calculate_WHR returns correct waist-to-height ratio", {
  # General tests
  expect_equal(calculate_WHR(170, 85), 0.5)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_WHR(999.96, 85), "a"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, 999.6), "a"))
  expect_true(haven::is_tagged_na(calculate_WHR(999.97, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, 999.7), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(-1, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_WHR(170, -1), "b"))
  expect_true(is.na(calculate_WHR(NA, 85)))
  # Edge case tests - boundary values
  expect_equal(calculate_WHR(100, 50), 0.5) # Different valid values
  expect_equal(calculate_WHR(200, 100), 0.5) # Large valid values

  # Vector tests
  expect_equal(calculate_WHR(c(170, 999.96), c(85, 85)), c(0.5, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(HT = c(170, 180), WAIST = c(85, 90))
  expect_equal(df %>% dplyr::mutate(whr = calculate_WHR(HT, WAIST)) %>% dplyr::pull(whr), c(0.5, 0.5))
})
