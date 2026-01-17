# test-blood-pressure.R

# Test for adjust_SBP
test_that("adjust_SBP returns correct adjusted systolic blood pressure", {
  # General tests
  expect_equal(adjust_SBP(120), 123)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(adjust_SBP(996), "a"))
  expect_true(haven::is_tagged_na(adjust_SBP(997), "b"))
  expect_true(haven::is_tagged_na(adjust_SBP(-5), "b"))
  expect_true(is.na(adjust_SBP(NA)))
  # Edge case tests - boundary values
  expect_true(!is.na(adjust_SBP(0))) # Zero BP still valid

  # Vector tests
  expect_equal(adjust_SBP(c(120, 996, -5, NA)), c(123, haven::tagged_na("a"), haven::tagged_na("b"), NA))

  # Database tests
  df <- data.frame(SBP = c(120, 140, 996))
  result <- df %>%
    dplyr::mutate(adj = adjust_SBP(SBP)) %>%
    dplyr::pull(adj)
  expect_equal(length(result), 3)
  expect_true(haven::is_tagged_na(result[3], "a"))
})

# Test for adjust_DBP
test_that("adjust_DBP returns correct adjusted diastolic blood pressure", {
  # General tests
  expect_equal(adjust_DBP(80), 82)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(adjust_DBP(996), "a"))
  expect_true(haven::is_tagged_na(adjust_DBP(997), "b"))
  expect_true(haven::is_tagged_na(adjust_DBP(-5), "b"))
  expect_true(is.na(adjust_DBP(NA)))

  # Edge case tests - boundary values
  expect_true(!is.na(adjust_DBP(0))) # Zero BP still valid

  # Vector tests
  expect_equal(adjust_DBP(c(80, 996, -5, NA)), c(82, haven::tagged_na("a"), haven::tagged_na("b"), NA))

  # Database tests
  df <- data.frame(DBP = c(80, 90, 996))
  result <- df %>%
    dplyr::mutate(adj = adjust_DBP(DBP)) %>%
    dplyr::pull(adj)
  expect_equal(length(result), 3)
  expect_true(haven::is_tagged_na(result[3], "a"))
})

# Test for determine_hypertension
test_that("determine_hypertension returns correct hypertension status", {
  # General tests
  expect_equal(determine_hypertension(140, 80, 0), 1)
  expect_equal(determine_hypertension(120, 90, 0), 1)
  expect_equal(determine_hypertension(120, 80, 1), 1)
  expect_equal(determine_hypertension(130, 80, 0, DIABX = 1), 1)
  expect_equal(determine_hypertension(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(determine_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(determine_hypertension(120, 997, 0), "b"))
  expect_true(is.na(determine_hypertension(NA, NA, 0)))
  # Edge case tests - boundary values
  expect_equal(determine_hypertension(139, 89, 0), 2)
  expect_equal(determine_hypertension(140, 89, 0), 1)
  expect_equal(determine_hypertension(139, 90, 0), 1)
  expect_equal(determine_hypertension(129, 79, 0, DIABX = 1), 2)
  expect_equal(determine_hypertension(130, 79, 0, DIABX = 1), 1)
  expect_equal(determine_hypertension(129, 80, 0, DIABX = 1), 1)

  # Edge case tests - combined comorbidities
  expect_equal(determine_hypertension(130, 80, 0, DIABX = 1, CKD = 1), 1)
  expect_equal(determine_hypertension(129, 79, 0, DIABX = 1, CKD = 1), 2)

  # Edge case tests - very high BP values
  expect_equal(determine_hypertension(200, 120, 0), 1)
  expect_equal(determine_hypertension(250, 150, 0), 1)

  # Vector tests
  expect_equal(determine_hypertension(c(140, 120), c(80, 80), c(0, 0)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(140, 120), DBP = c(80, 80), ANYMED2 = c(0, 0))
  expect_equal(df %>% dplyr::mutate(htn = determine_hypertension(SBP, DBP, ANYMED2)) %>% dplyr::pull(htn), c(1, 2))
})

# Test for determine_adjusted_hypertension
test_that("determine_adjusted_hypertension returns correct adjusted hypertension status", {
  # General tests
  expect_equal(determine_adjusted_hypertension(140, 80, 0), 1)
  expect_equal(determine_adjusted_hypertension(120, 90, 0), 1)
  expect_equal(determine_adjusted_hypertension(120, 80, 1), 1)
  expect_equal(determine_adjusted_hypertension(130, 80, 0, DIABX = 1), 1)
  expect_equal(determine_adjusted_hypertension(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(determine_adjusted_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(determine_adjusted_hypertension(120, 997, 0), "b"))
  expect_true(is.na(determine_adjusted_hypertension(NA, NA, 0)))
  # Edge case tests - boundary values
  expect_equal(determine_adjusted_hypertension(139, 89, 0), 2)
  expect_equal(determine_adjusted_hypertension(140, 89, 0), 1)
  expect_equal(determine_adjusted_hypertension(139, 90, 0), 1)

  # Edge case tests - combined comorbidities
  expect_equal(determine_adjusted_hypertension(130, 80, 0, DIABX = 1, CKD = 1), 1)
  expect_equal(determine_adjusted_hypertension(129, 79, 0, DIABX = 1, CKD = 1), 2)

  # Vector tests
  expect_equal(determine_adjusted_hypertension(c(140, 120), c(80, 80), c(0, 0)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(140, 120), DBP = c(80, 80), ANYMED2 = c(0, 0))
  expect_equal(df %>% dplyr::mutate(htn = determine_adjusted_hypertension(SBP, DBP, ANYMED2)) %>% dplyr::pull(htn), c(1, 2))
})

# Test for determine_controlled_hypertension
test_that("determine_controlled_hypertension returns correct controlled hypertension status", {
  # General tests
  expect_equal(determine_controlled_hypertension(139, 89, 1), 1)
  expect_equal(determine_controlled_hypertension(140, 89, 1), 2)
  expect_equal(determine_controlled_hypertension(139, 90, 1), 2)
  expect_equal(determine_controlled_hypertension(129, 79, 1, CCC_32 = 1, DIABX = 1), 1)
  expect_equal(determine_controlled_hypertension(130, 79, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_hypertension(129, 80, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_hypertension(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(determine_controlled_hypertension(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(determine_controlled_hypertension(120, 997, 1), "b"))
  expect_true(is.na(determine_controlled_hypertension(NA, NA, 1)))
  # Edge case tests - boundary with comorbidities
  expect_equal(determine_controlled_hypertension(139, 89, 1, DIABX = 0), 1)

  # Vector tests
  expect_equal(determine_controlled_hypertension(c(139, 140), c(89, 89), c(1, 1)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(139, 140), DBP = c(89, 89), ANYMED2 = c(1, 1))
  expect_equal(df %>% dplyr::mutate(ctrl = determine_controlled_hypertension(SBP, DBP, ANYMED2)) %>% dplyr::pull(ctrl), c(1, 2))
})

# Test for determine_controlled_adjusted_hypertension
test_that("determine_controlled_adjusted_hypertension returns correct controlled adjusted hypertension status", {
  # General tests
  expect_equal(determine_controlled_adjusted_hypertension(139, 89, 1), 1)
  expect_equal(determine_controlled_adjusted_hypertension(140, 89, 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(139, 90, 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(129, 79, 1, CCC_32 = 1, DIABX = 1), 1)
  expect_equal(determine_controlled_adjusted_hypertension(130, 79, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(129, 80, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(determine_controlled_adjusted_hypertension(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(determine_controlled_adjusted_hypertension(120, 997, 1), "b"))
  expect_true(is.na(determine_controlled_adjusted_hypertension(NA, NA, 1)))
  # Edge case tests - boundary with comorbidities
  expect_equal(determine_controlled_adjusted_hypertension(139, 89, 1, DIABX = 0), 1)

  # Vector tests
  expect_equal(determine_controlled_adjusted_hypertension(c(139, 140), c(89, 89), c(1, 1)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(139, 140), DBP = c(89, 89), ANYMED2 = c(1, 1))
  expect_equal(df %>% dplyr::mutate(ctrl = determine_controlled_adjusted_hypertension(SBP, DBP, ANYMED2)) %>% dplyr::pull(ctrl), c(1, 2))
})
