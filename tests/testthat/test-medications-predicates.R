# test-medications-predicates.R

# Test for is_beta_blocker
test_that("is_beta_blocker returns correct values", {
  # General tests
  expect_equal(is_beta_blocker("C07AA05", 1), 1)
  expect_equal(is_beta_blocker("C07AA07", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_beta_blocker("", 1), 0) # missing inputs
  expect_true(haven::is_tagged_na(is_beta_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 6), "a"))
  expect_true(haven::is_tagged_na(is_beta_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_beta_blocker("C07AA05", 7), "b"))

  # Vector tests
  expect_equal(is_beta_blocker(c("C07AA05", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C07AA05", "C07AA07"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(bb = is_beta_blocker(med, last)) |> dplyr::pull(bb), c(1, 0))
})

# Test for is_ace_inhibitor
test_that("is_ace_inhibitor returns correct values", {
  # General tests
  expect_equal(is_ace_inhibitor("C09AA02", 1), 1)
  expect_equal(is_ace_inhibitor("C08AA02", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_ace_inhibitor("", 1), 0)
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_ace_inhibitor("C09AA02", 7), "b"))

  # Vector tests
  expect_equal(is_ace_inhibitor(c("C09AA02", "C08AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C09AA02", "C08AA02"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(ace = is_ace_inhibitor(med, last)) |> dplyr::pull(ace), c(1, 0))
})

# Test for is_diuretic
test_that("is_diuretic returns correct values", {
  # General tests
  expect_equal(is_diuretic("C03AA03", 1), 1)
  expect_equal(is_diuretic("C03BA08", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_diuretic("", 1), 0)
  expect_true(haven::is_tagged_na(is_diuretic("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 6), "a"))
  expect_true(haven::is_tagged_na(is_diuretic("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diuretic("C03AA03", 7), "b"))

  # Vector tests
  expect_equal(is_diuretic(c("C03AA03", "C03BA08"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C03AA03", "C03BA08"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(diur = is_diuretic(med, last)) |> dplyr::pull(diur), c(1, 0))
})

# Test for is_calcium_channel_blocker
test_that("is_calcium_channel_blocker returns correct values", {
  # General tests
  expect_equal(is_calcium_channel_blocker("C08CA01", 1), 1)
  expect_equal(is_calcium_channel_blocker("C07CA01", 1), 0)

  # Edge case tests - missing data
  expect_equal(is_calcium_channel_blocker("", 1), 0)
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 6), "a"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_calcium_channel_blocker("C08CA01", 7), "b"))

  # Vector tests
  expect_equal(is_calcium_channel_blocker(c("C08CA01", "C07CA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C08CA01", "C07CA01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(ccb = is_calcium_channel_blocker(med, last)) |> dplyr::pull(ccb), c(1, 0))
})

# Test for is_other_antihtn_med
test_that("is_other_antihtn_med returns correct values", {
  # General tests
  expect_equal(is_other_antihtn_med("C02AB01", 1), 1)
  expect_equal(is_other_antihtn_med("C02KX01", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_other_antihtn_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_other_antihtn_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_other_antihtn_med(c("C02AB01", "C02KX01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C02KX01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(other_antihtn = is_other_antihtn_med(med, last)) |> dplyr::pull(other_antihtn), c(1, 0))
})

# Test for is_any_antihtn_med
test_that("is_any_antihtn_med returns correct values", {
  # General tests
  expect_equal(is_any_antihtn_med("C02AB01", 1), 1)
  expect_equal(is_any_antihtn_med("C03AA03", 1), 1)
  expect_equal(is_any_antihtn_med("C07AA05", 1), 1)
  expect_equal(is_any_antihtn_med("C08CA01", 1), 1)
  expect_equal(is_any_antihtn_med("C09AA02", 1), 1)
  expect_equal(is_any_antihtn_med("C07AA07", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_any_antihtn_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("C02AB01", 6), "a"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_any_antihtn_med("C02AB01", 7), "b"))

  # Vector tests
  expect_equal(is_any_antihtn_med(c("C02AB01", "C07AA07"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("C02AB01", "C07AA07"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(any_antihtn = is_any_antihtn_med(med, last)) |> dplyr::pull(any_antihtn), c(1, 0))
})

# Test for is_nsaid
test_that("is_nsaid returns correct values", {
  # General tests
  expect_equal(is_nsaid("M01AE01", 1), 1)
  expect_equal(is_nsaid("M02AA01", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_nsaid("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_nsaid("M01AE01", 6), "a"))
  expect_true(haven::is_tagged_na(is_nsaid("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_nsaid("M01AE01", 7), "b"))

  # Vector tests
  expect_equal(is_nsaid(c("M01AE01", "M02AA01"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("M01AE01", "M02AA01"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(nsaid = is_nsaid(med, last)) |> dplyr::pull(nsaid), c(1, 0))
})

# Test for is_diabetes_med
test_that("is_diabetes_med returns correct values", {
  # General tests
  expect_equal(is_diabetes_med("A10BA02", 1), 1)
  expect_equal(is_diabetes_med("A09AA02", 1), 0)

  # Edge case tests - missing data
  expect_true(haven::is_tagged_na(is_diabetes_med("9999996", 1), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_med("A10BA02", 6), "a"))
  expect_true(haven::is_tagged_na(is_diabetes_med("9999997", 1), "b"))
  expect_true(haven::is_tagged_na(is_diabetes_med("A10BA02", 7), "b"))

  # Vector tests
  expect_equal(is_diabetes_med(c("A10BA02", "A09AA02"), c(1, 1)), c(1, 0))

  # Database tests
  df <- data.frame(med = c("A10BA02", "A09AA02"), last = c(1, 1))
  expect_equal(df |> dplyr::mutate(diabetes_med = is_diabetes_med(med, last)) |> dplyr::pull(diabetes_med), c(1, 0))
})

