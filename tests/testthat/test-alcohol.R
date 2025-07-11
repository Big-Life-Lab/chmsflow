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
  expect_true(is.na(low_drink_score_fun(CLC_SEX = 1, ALC_11 = 1, ALCDWKY = NA))) # Check for NA
})

# Test for low_drink_score_fun1
test_that("low_drink_score_fun1 returns correct scores", {
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 2, ALC_11 = 2), 1) # Never drinker (male)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 2), 1) # Former drinker, no heavy (similar risk as never drinking)
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = NA, ALC_17 = 1, ALC_11 = 2, ALC_18 = 1), 2) # Former drinker, heavy
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 2) # Light drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 3, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 2) # Light drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 2) # Light drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 12, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 3) # Moderate drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 3) # Moderate drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 18, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 4) # Heavy drinker, female
  expect_equal(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 4) # Heavy drinker, male
  expect_equal(low_drink_score_fun1(CLC_SEX = 2, ALCDWKY = 25, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1), 4) # Heavy drinker, female
  expect_true(is.na(low_drink_score_fun1(CLC_SEX = 1, ALCDWKY = 996, ALC_17 = 1, ALC_11 = 1, ALC_18 = 1))) # Invalid input
})
