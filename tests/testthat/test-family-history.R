# test-family-history.R

# Test for determine_CVD_personal_history
test_that("determine_CVD_personal_history returns correct CVD personal history", {
  # General tests
  expect_equal(determine_CVD_personal_history(1, 2, 2), 1)
  expect_equal(determine_CVD_personal_history(2, 1, 2), 1)
  expect_equal(determine_CVD_personal_history(2, 2, 1), 1)
  expect_equal(determine_CVD_personal_history(2, 2, 2), 2)

  # Edge case tests - missing data, invalid inputs, and multiple conditions
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(6, 6, 6), "a"))
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(7, 7, 7), "b"))
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(NA, NA, NA), "b"))
  expect_equal(determine_CVD_personal_history(1, 1, 1), 1)
  expect_equal(determine_CVD_personal_history(1, 1, 2), 1)
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(6, 2, 2), "a"))
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(2, 6, 2), "a"))
  expect_true(haven::is_tagged_na(determine_CVD_personal_history(2, 2, 6), "a"))

  # Vector tests
  expect_equal(determine_CVD_personal_history(c(1, 2, 2), c(2, 1, 2), c(2, 2, 1)), c(1, 1, 1))

  # Database tests
  df <- data.frame(CCC_81 = c(1, 2, 2), CCC_91 = c(2, 1, 2), CCC_92 = c(2, 2, 1))
  expect_equal(df %>% dplyr::mutate(cvd = determine_CVD_personal_history(CCC_81, CCC_91, CCC_92)) %>% dplyr::pull(cvd), c(1, 1, 1))
})

# Test for determine_CVD_family_history
test_that("determine_CVD_family_history returns correct CVD family history", {
  # General tests
  expect_equal(determine_CVD_family_history(1, 50, 2, NA), 1)
  expect_equal(determine_CVD_family_history(2, NA, 1, 55), 1)
  expect_equal(determine_CVD_family_history(1, 70, 2, NA), 2)
  expect_equal(determine_CVD_family_history(2, NA, 1, 70), 2)
  expect_equal(determine_CVD_family_history(2, NA, 2, NA), 2)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(determine_CVD_family_history(6, NA, 6, NA), "a"))
  expect_true(haven::is_tagged_na(determine_CVD_family_history(7, NA, 7, NA), "b"))
  expect_true(haven::is_tagged_na(determine_CVD_family_history(1, 996, 1, 996), "a"))
  expect_true(haven::is_tagged_na(determine_CVD_family_history(1, 997, 2, NA), "b"))
  expect_true(haven::is_tagged_na(determine_CVD_family_history(NA, NA, NA, NA), "b"))
  expect_equal(determine_CVD_family_history(1, 59, 2, NA), 1)
  expect_equal(determine_CVD_family_history(1, 60, 2, NA), 2)
  expect_equal(determine_CVD_family_history(2, NA, 1, 59), 1)
  expect_equal(determine_CVD_family_history(2, NA, 1, 60), 2)
  expect_equal(determine_CVD_family_history(1, 50, 1, 55), 1)
  expect_equal(determine_CVD_family_history(1, 65, 1, 70), 2)
  expect_equal(determine_CVD_family_history(1, 0, 2, NA), 1)
  expect_true(haven::is_tagged_na(determine_CVD_family_history(1, 80, 2, NA), "b"))
  expect_true(haven::is_tagged_na(determine_CVD_family_history(1, -1, 2, NA), "b"))

  # Vector tests
  expect_equal(determine_CVD_family_history(c(1, 2, 1), c(50, NA, 70), c(2, 1, 2), c(NA, 55, NA)), c(1, 1, 2))

  # Database tests
  df <- data.frame(CCC_280 = c(1, 2, 1), CCC_281 = c(50, NA, 70), CCC_290 = c(2, 1, 2), CCC_291 = c(NA, 55, NA))
  expect_equal(df %>% dplyr::mutate(fam = determine_CVD_family_history(CCC_280, CCC_281, CCC_290, CCC_291)) %>% dplyr::pull(fam), c(1, 1, 2))
})
