# test-alcohol.R

# Test for low_drink_score_fun
test_that("low_drink_score_fun returns correct scores", {
  # General tests
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 3), 1)
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 3), 1)
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 12), 1)
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 12), 2)
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 18), 2)
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 18), 3)
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 25), 3)
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 25), 3)
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 2, ALCDWKY = NA), 1)

  # Edge case tests - StatsCan missing data codes
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 6, 5), "a"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 7, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 8, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 9, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 1, NA), "b"))

  # Edge case tests - boundary values at thresholds
  expect_equal(low_drink_score_fun(1, 1, 10), 1)
  expect_equal(low_drink_score_fun(1, 1, 15), 1)
  expect_equal(low_drink_score_fun(2, 1, 15), 2)
  expect_equal(low_drink_score_fun(1, 1, 20), 2)
  expect_equal(low_drink_score_fun(2, 1, 20), 3)

  # Edge case tests - invalid sex codes
  expect_true(haven::is_tagged_na(low_drink_score_fun(0, 1, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(3, 1, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(-1, 1, 5), "b"))

  # Edge case tests - invalid ALC_11 codes
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 0, 5), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 3, 5), "b"))
  # Edge case tests - very large ALCDWKY
  expect_equal(low_drink_score_fun(1, 1, 500), 3)

  # Vector tests
  expect_equal(low_drink_score_fun(CLC_SEX = c(1, 2, 1), ALC_11 = c(1, 1, 2), ALCDWKY = c(3, 12, NA)), c(1, 2, 1))

  # Database tests
  df_alc <- data.frame(
    CLC_SEX = c(1, 2, 1, 2),
    ALC_11 = c(1, 1, 2, 1),
    ALCDWKY = c(3, 12, NA, 25)
  )
  expected_output_alc <- c(1, 2, 1, 3)
  expect_equal(df_alc %>% dplyr::mutate(low_drink_score = low_drink_score_fun(CLC_SEX, ALC_11, ALCDWKY)) %>% dplyr::pull(low_drink_score), expected_output_alc)
})

# Test for low_drink_score_fun1
test_that("low_drink_score_fun1 returns correct scores", {
  # General tests
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 2, ALC_11 = 2, ALC_18 = 2), 1)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 2), 1)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 1), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 3)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 3)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(is.na(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 996, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1)))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 6, 5, 1, 2), "a"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 7, 5, 1, 2), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 1, NA, 8, 2), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 1, 5, 1, 9), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(6, 7, 5, 1, 2), "a")) # mixed missing codes ("not applicable" takes precedence)
  # Boundary values at thresholds
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 10, ALC_17 = 1, ALC_18 = 2), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 15, ALC_17 = 1, ALC_18 = 2), 2)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 15, ALC_17 = 1, ALC_18 = 2), 3)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 20, ALC_17 = 1, ALC_18 = 2), 3)
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 20, ALC_17 = 1, ALC_18 = 2), 4)
  # Invalid sex codes
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = 0, ALC_11 = 1, ALCDWKY = 5, ALC_17 = 1, ALC_18 = 2), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = 3, ALC_11 = 1, ALCDWKY = 5, ALC_17 = 1, ALC_18 = 2), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = -1, ALC_11 = 1, ALCDWKY = 5, ALC_17 = 1, ALC_18 = 2), "b"))
  # Invalid ALC_11 codes
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 0, ALCDWKY = 5, ALC_17 = 1, ALC_18 = 2), "b"))
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 3, ALCDWKY = 5, ALC_17 = 1, ALC_18 = 2), "b"))
  # Very large ALCDWKY
  expect_true(haven::is_tagged_na(low_drink_score_fun1(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 500, ALC_17 = 1, ALC_18 = 2), "b"))

  # Vector tests
  expect_equal(low_drink_score_fun1(CLC_SEX = c(1, 2, 1), ALC_11 = c(1, 1, 2), ALCDWKY = c(3, 12, NA), ALC_17 = c(1, 1, 1), ALC_18 = c(2, 2, 1)), c(2, 3, 2))

  # Database tests
  df_alc1 <- data.frame(
    CLC_SEX = c(1, 2, 1, 2),
    ALC_11 = c(1, 1, 2, 1),
    ALCDWKY = c(3, 12, NA, 25),
    ALC_17 = c(1, 1, 1, 1),
    ALC_18 = c(2, 2, 1, 1)
  )
  expected_output_alc1 <- c(2, 3, 2, 4)
  expect_equal(df_alc1 %>% dplyr::mutate(low_drink_score1 = low_drink_score_fun1(CLC_SEX, ALC_11, ALCDWKY, ALC_17, ALC_18)) %>% dplyr::pull(low_drink_score1), expected_output_alc1)
})
