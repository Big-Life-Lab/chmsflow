# test-income.R

# Test for calculate_household_income
test_that("calculate_household_income returns correct adjusted household income", {
  # General tests
  expect_equal(calculate_household_income(50000, 1), 50000)
  expect_equal(calculate_household_income(50000, 2), 35714.29, tolerance = 1e-2)
  expect_equal(calculate_household_income(50000, 3), 29411.76, tolerance = 1e-2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_household_income(99999996, 1), "a"))
  expect_true(haven::is_tagged_na(calculate_household_income(50000, 96), "a"))
  expect_true(haven::is_tagged_na(calculate_household_income(99999997, 1), "b"))
  expect_true(haven::is_tagged_na(calculate_household_income(50000, 97), "b"))
  expect_true(haven::is_tagged_na(calculate_household_income(-1, 1), "b"))
  expect_true(haven::is_tagged_na(calculate_household_income(50000, 0), "b"))
  expect_true(is.na(calculate_household_income(NA, 1)))

  # Edge case tests - boundary values
  expect_equal(calculate_household_income(100000, 10), 100000 / (1 + 0.4 + 8 * 0.3), tolerance = 1e-2) # Large household
  expect_equal(calculate_household_income(0, 1), 0) # Zero income single
  expect_equal(calculate_household_income(0, 3), 0) # Zero income family

  # Vector tests
  expect_equal(calculate_household_income(c(50000, 50000), c(1, 2)), c(50000, 35714.29), tolerance = 1e-2)

  # Database tests
  df <- data.frame(income = c(50000, 100000), hhld = c(1, 2))
  expect_equal(df |> dplyr::mutate(adj = calculate_household_income(income, hhld)) |> dplyr::pull(adj), c(50000, 71428.57), tolerance = 1e-2)
})

# Test for categorize_income_quintile
test_that("categorize_income_quintile returns correct income category", {
  # General tests
  expect_equal(categorize_income_quintile(21500), 1)
  expect_equal(categorize_income_quintile(21501), 2)
  expect_equal(categorize_income_quintile(35000), 2)
  expect_equal(categorize_income_quintile(35001), 3)
  expect_equal(categorize_income_quintile(50000), 3)
  expect_equal(categorize_income_quintile(50001), 4)
  expect_equal(categorize_income_quintile(70000), 4)
  expect_equal(categorize_income_quintile(70001), 5)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(categorize_income_quintile(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_income_quintile(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_income_quintile(-1), "b"))
  expect_true(is.na(categorize_income_quintile(NA)))

  # Edge case tests - boundary values at thresholds
  expect_equal(categorize_income_quintile(0), 1) # Zero income

  # Vector tests
  expect_equal(categorize_income_quintile(c(21500, 35000, 50000, 70000, 70001)), c(1, 2, 3, 4, 5))

  # Database tests
  df <- data.frame(income = c(21500, 35001, 70001))
  expect_equal(df |> dplyr::mutate(cat = categorize_income_quintile(income)) |> dplyr::pull(cat), c(1, 3, 5))
})

# Test for is_lowest_income_quintile
test_that("is_lowest_income_quintile returns correct lowest income quintile status", {
  # General tests
  expect_equal(is_lowest_income_quintile(1), 1)
  expect_equal(is_lowest_income_quintile(2), 2)
  expect_equal(is_lowest_income_quintile(3), 2)
  expect_equal(is_lowest_income_quintile(4), 2)
  expect_equal(is_lowest_income_quintile(5), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(is_lowest_income_quintile(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(is_lowest_income_quintile(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(is_lowest_income_quintile(0), "b"))
  expect_true(haven::is_tagged_na(is_lowest_income_quintile(6), "b"))
  expect_true(is.na(is_lowest_income_quintile(NA)))

  # Edge case tests - boundary quintile values
  expect_true(haven::is_tagged_na(is_lowest_income_quintile(-1), "b")) # Negative quintile

  # Vector tests
  expect_equal(is_lowest_income_quintile(c(1, 2, 3, 4, 5)), c(1, 2, 2, 2, 2))

  # Database tests
  df <- data.frame(quintile = c(1, 2, 5))
  expect_equal(df |> dplyr::mutate(low = is_lowest_income_quintile(quintile)) |> dplyr::pull(low), c(1, 2, 2))
})

# Mixed-length / empty-vector tests
test_that("calculate_household_income handles empty and mismatched-length input", {
  expect_length(calculate_household_income(numeric(0), numeric(0)), 0)
  # Documents current behavior: arithmetic recycles silently on mismatch
  expect_no_error(calculate_household_income(c(50000, 60000), c(2)))
})
