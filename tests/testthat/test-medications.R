# test-medications.R

# Test for is_beta_blocker
test_that("is_beta_blocker returns correct values", {
  expect_equal(is_beta_blocker("C07AA05", 1), 1)
  expect_equal(is_beta_blocker("C07AA07", 1), 0)
  expect_true(haven::is_tagged_na(is_beta_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 6), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 7), "b"))
  expect_equal(is_beta_blocker(c("C07AA05", "C07AA07"), c(1, 1)), c(1, 0))
})

# Test for is_ace_inhibitor
test_that("is_ace_inhibitor returns correct values", {
  expect_equal(is_ace_inhibitor("C09AA02", 1), 1)
  expect_equal(is_ace_inhibitor("C08AA02", 1), 0)
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 7), "b"))
  expect_equal(is_ace_inhibitor(c("C09AA02", "C08AA02"), c(1, 1)), c(1, 0))
})

# Test for is_diuretic
test_that("is_diuretic returns correct values", {
  expect_equal(is_diuretic("C03AA03", 1), 1)
  expect_equal(is_diuretic("C03BA08", 1), 0)
  expect_true(haven::is_tagged_na(is_diuretic("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 6), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 7), "b"))
  expect_equal(is_diuretic(c("C03AA03", "C03BA08"), c(1, 1)), c(1, 0))
})

# Test for is_calcium_channel_blocker
test_that("is_calcium_channel_blocker returns correct values", {
  expect_equal(is_calcium_channel_blocker("C08CA01", 1), 1)
  expect_equal(is_calcium_channel_blocker("C07CA01", 1), 0)
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 6), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 7), "b"))
  expect_equal(is_calcium_channel_blocker(c("C08CA01", "C07CA01"), c(1, 1)), c(1, 0))
})

# Test for is_other_antiHTN_med
test_that("is_other_antiHTN_med returns correct values", {
  expect_equal(is_other_antiHTN_med("C02AB01", 1), 1)
  expect_equal(is_other_antiHTN_med("C02KX01", 1), 0)
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_other_antiHTN_med("C02AB01", 7), "b"))
  expect_equal(is_other_antiHTN_med(c("C02AB01", "C02KX01"), c(1, 1)), c(1, 0))
})

# Test for is_any_antiHTN_med
test_that("is_any_antiHTN_med returns correct values", {
  expect_equal(is_any_antiHTN_med("C02AB01", 1), 1)
  expect_equal(is_any_antiHTN_med("C03AA03", 1), 1)
  expect_equal(is_any_antiHTN_med("C07AA05", 1), 1)
  expect_equal(is_any_antiHTN_med("C08CA01", 1), 1)
  expect_equal(is_any_antiHTN_med("C09AA02", 1), 1)
  expect_equal(is_any_antiHTN_med("C07AA07", 1), 0)
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_any_antiHTN_med("C02AB01", 7), "b"))
  expect_equal(is_any_antiHTN_med(c("C02AB01", "C07AA07"), c(1, 1)), c(1, 0))
})

# Test for is_NSAID
test_that("is_NSAID returns correct values", {
  expect_equal(is_NSAID("M01AE01", 1), 1)
  expect_equal(is_NSAID("M02AA01", 1), 0)
  expect_true(haven::is_tagged_na(is_NSAID("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_NSAID("M01AE01", 6), "a"))
  expect_true(haven::is_tagged_na(is_NSAID("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_NSAID("M01AE01", 7), "b"))
  expect_equal(is_NSAID(c("M01AE01", "M02AA01"), c(1, 1)), c(1, 0))
})

# Test for is_diabetes_drug
test_that("is_diabetes_drug returns correct values", {
  expect_equal(is_diabetes_drug("A10BA02", 1), 1)
  expect_equal(is_diabetes_drug("A09AA02", 1), 0)
  expect_true(haven::is_tagged_na(is_diabetes_drug("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("A10BA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diabetes_drug("A10BA02", 7), "b"))
  expect_equal(is_diabetes_drug(c("A10BA02", "A09AA02"), c(1, 1)), c(1, 0))
})
