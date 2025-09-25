# test-alcohol.R
# Test for low_drink_score_fun
test_that("low_drink_score_fun returns correct scores", {
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 3), 1) # Low risk for male
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 3), 1) # Low risk for female
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 12), 1) # Low risk for male
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 12), 2) # Marginal risk for female
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 18), 2) # Marginal risk for male
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 18), 3) # Medium risk for female
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = 25), 3) # Medium risk for male
  expect_equal(low_drink_score_fun(CLC_SEX = 2, ALC_11 = 1, ALCDWKY = 25), 3) # Medium risk for female
  expect_equal(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 2, ALCDWKY = NA), 1) # Never drinker - low risk
  # StatsCan missing data codes
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 6, 5), "a"))   # Code 6 -> tagged NA(a) 
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 7, 5), "b"))   # Code 7 -> tagged NA(b)
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 8, 5), "b"))   # Code 8 -> tagged NA(b) 
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 9, 5), "b"))   # Code 9 -> tagged NA(b)
  expect_true(haven::is_tagged_na(low_drink_score_fun(1, 1, NA), "b"))  # Missing ALCDWKY -> tagged NA(b)

  # Vector usage
  expect_equal(low_drink_score_fun(CLC_SEX = c(1, 2, 1), ALC_11 = c(1, 1, 2), ALCDWKY = c(3, 12, NA)), c(1, 2, 1))

  # Database usage (simulated)
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
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 2, ALC_11 = 2, ALC_18 = 2), 1) # Never drinker (male)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 2), 1) # Former drinker, no heavy (similar risk as never drinking)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 1), 2) # Former drinker, heavy
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2) # Light drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2) # Light drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 2) # Light drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 3) # Moderate drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 3) # Moderate drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4) # Heavy drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4) # Heavy drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 2), 4) # Heavy drinker, female
  expect_true(is.na(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 996, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1))) # Invalid input

  # StatsCan missing data codes
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 6, 5, 1, 2), "a"))     # Code 6 -> tagged NA(a)
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 7, 5, 1, 2), "b"))     # Code 7 -> tagged NA(b) 
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 1, NA, 8, 2), "b"))    # Code 8 -> tagged NA(b)
  expect_true(haven::is_tagged_na(low_drink_score_fun1(1, 1, 5, 1, 9), "b"))     # Code 9 -> tagged NA(b)
  
  # Mixed missing codes - "not applicable" takes precedence over "missing"
  expect_true(haven::is_tagged_na(low_drink_score_fun1(6, 7, 5, 1, 2), "a"))     # 6 + 7 -> tagged NA(a)

  # Vector usage
  expect_equal(low_drink_score_fun1(CLC_SEX = c(1, 2, 1), ALC_11 = c(1, 1, 2), ALCDWKY = c(3, 12, NA), ALC_17 = c(1, 1, 1), ALC_18 = c(2, 2, 1)), c(2, 3, 2))

  # Database usage (simulated)
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
