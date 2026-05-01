# test-cholesterol-and-obesity.R

# Test for calculate_nonhdl
test_that("calculate_nonhdl returns correct non-HDL cholesterol level", {
  # General tests
  expect_equal(calculate_nonhdl(5, 1.5), 3.5)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_nonhdl(99.96, 1.5), "a"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 9.96), "a"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(99.97, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 9.97), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(1.87, 1.5), "b"))
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 0.48), "b"))
  expect_true(is.na(calculate_nonhdl(NA, 1.5)))
  # Edge case tests - boundary values for valid ranges
  expect_true(!is.na(calculate_nonhdl(1.88, 0.49))) # Min valid
  expect_true(!is.na(calculate_nonhdl(13.58, 3.74))) # Max valid
  expect_true(haven::is_tagged_na(calculate_nonhdl(13.59, 1.5), "b")) # Above max CHOL
  expect_true(haven::is_tagged_na(calculate_nonhdl(5, 3.75), "b")) # Above max HDL
  expect_equal(calculate_nonhdl(2, 1), 1) # Low but valid values

  # Vector tests
  expect_equal(calculate_nonhdl(c(5, 99.96), c(1.5, 1.5)), c(3.5, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(CHOL = c(5, 6), HDL = c(1.5, 2))
  expect_equal(df |> dplyr::mutate(nonHDL = calculate_nonhdl(CHOL, HDL)) |> dplyr::pull(nonHDL), c(3.5, 4))
})

# Test for categorize_nonhdl
test_that("categorize_nonhdl returns correct non-HDL cholesterol category", {
  # General tests
  expect_equal(categorize_nonhdl(4.3), 1)
  expect_equal(categorize_nonhdl(4.29), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("b")), "b"))
  expect_true(is.na(categorize_nonhdl(NA)))
  # Edge case tests - boundary values
  expect_equal(categorize_nonhdl(4.30), 1) # Exactly at threshold
  expect_equal(categorize_nonhdl(0), 2) # Zero value

  # Vector tests
  expect_equal(categorize_nonhdl(c(4.3, 4.29, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(nonHDL = c(4.3, 4.29, 5))
  expect_equal(df |> dplyr::mutate(cat = categorize_nonhdl(nonHDL)) |> dplyr::pull(cat), c(1, 2, 1))
})

# Test for calculate_waist_height_ratio
test_that("calculate_waist_height_ratio returns correct waist-to-height ratio", {
  # General tests
  expect_equal(calculate_waist_height_ratio(170, 85), 0.5)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(999.96, 85), "a"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, 999.6), "a"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(999.97, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, 999.7), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(-1, 85), "b"))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(170, -1), "b"))
  expect_true(is.na(calculate_waist_height_ratio(NA, 85)))
  # Edge case tests - boundary values
  expect_equal(calculate_waist_height_ratio(100, 50), 0.5) # Different valid values
  expect_equal(calculate_waist_height_ratio(200, 100), 0.5) # Large valid values

  # Vector tests
  expect_equal(calculate_waist_height_ratio(c(170, 999.96), c(85, 85)), c(0.5, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(HT = c(170, 180), WAIST = c(85, 90))
  expect_equal(df |> dplyr::mutate(whr = calculate_waist_height_ratio(HT, WAIST)) |> dplyr::pull(whr), c(0.5, 0.5))
})

# Tagged-NA input propagation tests
# These verify the chained-derivation contract: a tagged NA input from a prior
# step must produce a tagged NA output, not a plain NA or a numeric class.

test_that("calculate_nonhdl propagates tagged NA input on lab_chol", {
  expect_true(haven::is_tagged_na(calculate_nonhdl(haven::tagged_na("a"), 1.5)))
  expect_true(haven::is_tagged_na(calculate_nonhdl(haven::tagged_na("b"), 1.5)))
})

test_that("categorize_nonhdl propagates tagged NA input on nonhdl", {
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("a"))))
  expect_true(haven::is_tagged_na(categorize_nonhdl(haven::tagged_na("b"))))
})

test_that("calculate_waist_height_ratio propagates tagged NA input on hwm_11cm", {
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(haven::tagged_na("a"), 85)))
  expect_true(haven::is_tagged_na(calculate_waist_height_ratio(haven::tagged_na("b"), 85)))
})
