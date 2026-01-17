# test-kidney.R

# Test for calculate_GFR
test_that("calculate_GFR returns correct GFR", {
  # General tests
  expect_equal(calculate_GFR(80, 1, 2, 45), 67.27905, tolerance = 1e-5)
  expect_equal(calculate_GFR(70, 2, 2, 35), 99.94114, tolerance = 1e-5)
  expect_equal(calculate_GFR(90, 1, 1, 50), 77.47422, tolerance = 1e-5)
  expect_true(!is.na(calculate_GFR(80, 1, 1, 45))) # Non-Black male
  expect_true(!is.na(calculate_GFR(80, 1, 2, 45))) # Non-Black female
  expect_true(!is.na(calculate_GFR(80, 2, 1, 45))) # Black male
  expect_true(!is.na(calculate_GFR(80, 2, 2, 45))) # Black female

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_GFR(9996, 1, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 96, 2, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 6, 45), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 2, 996), "a"))
  expect_true(haven::is_tagged_na(calculate_GFR(9997, 1, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 97, 2, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 7, 45), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 2, 997), "b"))
  expect_true(haven::is_tagged_na(calculate_GFR(13, 1, 2, 45), "b"))
  expect_true(is.na(calculate_GFR(NA, 1, 2, 45)))

  # Edge case tests - boundary values for valid ranges
  expect_true(!is.na(calculate_GFR(14, 1, 1, 3))) # Min creatinine and age
  expect_true(!is.na(calculate_GFR(785, 13, 2, 79))) # Max creatinine, ethnicity, age
  expect_true(haven::is_tagged_na(calculate_GFR(786, 1, 1, 40), "b")) # Above max creatinine
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 1, 2), "b")) # Below min age
  expect_true(haven::is_tagged_na(calculate_GFR(80, 1, 1, 80), "b")) # Above max age
  expect_true(haven::is_tagged_na(calculate_GFR(80, 14, 1, 40), "b")) # Invalid ethnicity high
  expect_true(haven::is_tagged_na(calculate_GFR(80, 0, 1, 40), "b")) # Invalid ethnicity low

  # Vector tests
  expect_equal(calculate_GFR(c(80, 70), c(1, 2), c(2, 2), c(45, 35)), c(67.27905, 99.94114), tolerance = 1e-5)

  # Database tests
  df <- data.frame(CREAT = c(80, 70), ETHN = c(1, 2), SEX = c(2, 2), AGE = c(45, 35))
  result <- df %>%
    dplyr::mutate(gfr = calculate_GFR(CREAT, ETHN, SEX, AGE)) %>%
    dplyr::pull(gfr)
  expect_equal(result, c(67.27905, 99.94114), tolerance = 1e-5)
})

# Test for categorize_GFR_to_CKD
test_that("categorize_GFR_to_CKD returns correct CKD category", {
  # General tests
  expect_equal(categorize_GFR_to_CKD(60), 1)
  expect_equal(categorize_GFR_to_CKD(61), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(categorize_GFR_to_CKD(-1), "b"))
  expect_true(is.na(categorize_GFR_to_CKD(NA)))

  # Edge case tests - boundary values
  expect_equal(categorize_GFR_to_CKD(60.0), 1) # Exactly at threshold
  expect_equal(categorize_GFR_to_CKD(0), 1) # Zero GFR (severe CKD)

  # Vector tests
  expect_equal(categorize_GFR_to_CKD(c(60, 61, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(gfr = c(60, 61, 90))
  expect_equal(df %>% dplyr::mutate(ckd = categorize_GFR_to_CKD(gfr)) %>% dplyr::pull(ckd), c(1, 2, 2))
})
