# test-blood-pressure.R

# Test for adjust_SBP
test_that("adjust_SBP returns correct adjusted systolic blood pressure", {
  expect_equal(adjust_SBP(120), 123)
  expect_true(haven::is_tagged_na(adjust_SBP(996), "a"))
  expect_true(haven::is_tagged_na(adjust_SBP(997), "b"))
  expect_true(haven::is_tagged_na(adjust_SBP(-5), "b"))
  expect_true(is.na(adjust_SBP(NA)))
  expect_equal(adjust_SBP(c(120, 996, -5, NA)), c(123, haven::tagged_na("a"), haven::tagged_na("b"), NA))
})

# Test for adjust_DBP
test_that("adjust_DBP returns correct adjusted diastolic blood pressure", {
  expect_equal(adjust_DBP(80), 82)
  expect_true(haven::is_tagged_na(adjust_DBP(996), "a"))
  expect_true(haven::is_tagged_na(adjust_DBP(997), "b"))
  expect_true(haven::is_tagged_na(adjust_DBP(-5), "b"))
  expect_true(is.na(adjust_DBP(NA)))
  expect_equal(adjust_DBP(c(80, 996, -5, NA)), c(82, haven::tagged_na("a"), haven::tagged_na("b"), NA))
})

# Test for determine_hypertension
test_that("determine_hypertension returns correct hypertension status", {
  expect_equal(determine_hypertension(140, 80, 0), 1)
  expect_equal(determine_hypertension(120, 90, 0), 1)
  expect_equal(determine_hypertension(120, 80, 1), 1)
  expect_equal(determine_hypertension(130, 80, 0, DIABX = 1), 1)
  expect_equal(determine_hypertension(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(determine_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(determine_hypertension(120, 997, 0), "b"))
  expect_true(is.na(determine_hypertension(NA, NA, 0)))
})

# Test for determine_adjusted_hypertension
test_that("determine_adjusted_hypertension returns correct adjusted hypertension status", {
  expect_equal(determine_adjusted_hypertension(140, 80, 0), 1)
  expect_equal(determine_adjusted_hypertension(120, 90, 0), 1)
  expect_equal(determine_adjusted_hypertension(120, 80, 1), 1)
  expect_equal(determine_adjusted_hypertension(130, 80, 0, DIABX = 1), 1)
  expect_equal(determine_adjusted_hypertension(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(determine_adjusted_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(determine_adjusted_hypertension(120, 997, 0), "b"))
  expect_true(is.na(determine_adjusted_hypertension(NA, NA, 0)))
})

# Test for determine_controlled_hypertension
test_that("determine_controlled_hypertension returns correct controlled hypertension status", {
  expect_equal(determine_controlled_hypertension(139, 89, 1), 1)
  expect_equal(determine_controlled_hypertension(140, 89, 1), 2)
  expect_equal(determine_controlled_hypertension(139, 90, 1), 2)
  expect_equal(determine_controlled_hypertension(129, 79, 1, CCC_32 = 1, DIABX = 1), 1)
  expect_equal(determine_controlled_hypertension(130, 79, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_hypertension(129, 80, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_hypertension(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(determine_controlled_hypertension(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(determine_controlled_hypertension(120, 997, 1), "b"))
  expect_true(is.na(determine_controlled_hypertension(NA, NA, 1)))
})

# Test for determine_controlled_adjusted_hypertension
test_that("determine_controlled_adjusted_hypertension returns correct controlled adjusted hypertension status", {
  expect_equal(determine_controlled_adjusted_hypertension(139, 89, 1), 1)
  expect_equal(determine_controlled_adjusted_hypertension(140, 89, 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(139, 90, 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(129, 79, 1, CCC_32 = 1, DIABX = 1), 1)
  expect_equal(determine_controlled_adjusted_hypertension(130, 79, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(129, 80, 1, DIABX = 1), 2)
  expect_equal(determine_controlled_adjusted_hypertension(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(determine_controlled_adjusted_hypertension(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(determine_controlled_adjusted_hypertension(120, 997, 1), "b"))
  expect_true(is.na(determine_controlled_adjusted_hypertension(NA, NA, 1)))
})
