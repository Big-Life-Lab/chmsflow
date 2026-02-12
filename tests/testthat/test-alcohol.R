# test-alcohol.R
# Test for derive_alcohol_risk
test_that("derive_alcohol_risk returns correct scores", {
  expect_equal(derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = 3), 1) # Low risk for male
  expect_equal(derive_alcohol_risk(clc_sex = 2, alc_11 = 1, alcdwky = 3), 1) # Low risk for female
  expect_equal(derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = 12), 1) # Low risk for male
  expect_equal(derive_alcohol_risk(clc_sex = 2, alc_11 = 1, alcdwky = 12), 2) # Marginal risk for female
  expect_equal(derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = 18), 2) # Marginal risk for male
  expect_equal(derive_alcohol_risk(clc_sex = 2, alc_11 = 1, alcdwky = 18), 3) # Medium risk for female
  expect_equal(derive_alcohol_risk(clc_sex = 1, alc_11 = 1, alcdwky = 25), 3) # Medium risk for male
  expect_equal(derive_alcohol_risk(clc_sex = 2, alc_11 = 1, alcdwky = 25), 3) # Medium risk for female
  expect_equal(derive_alcohol_risk(clc_sex = 1, alc_11 = 2, alcdwky = NA), 1) # Never drinker - low risk
  # StatsCan missing data codes
  expect_true(haven::is_tagged_na(derive_alcohol_risk(1, 6, 5), "a")) # Code 6 -> tagged NA(a)
  expect_true(haven::is_tagged_na(derive_alcohol_risk(1, 7, 5), "b")) # Code 7 -> tagged NA(b)
  expect_true(haven::is_tagged_na(derive_alcohol_risk(1, 8, 5), "b")) # Code 8 -> tagged NA(b)
  expect_true(haven::is_tagged_na(derive_alcohol_risk(1, 9, 5), "b")) # Code 9 -> tagged NA(b)
  expect_true(haven::is_tagged_na(derive_alcohol_risk(1, 1, NA), "b")) # Missing alcdwky -> tagged NA(b)

  # Vector usage
  expect_equal(derive_alcohol_risk(clc_sex = c(1, 2, 1), alc_11 = c(1, 1, 2), alcdwky = c(3, 12, NA)), c(1, 2, 1))

  # Database usage (simulated)
  df_alc <- data.frame(
    clc_sex = c(1, 2, 1, 2),
    alc_11 = c(1, 1, 2, 1),
    alcdwky = c(3, 12, NA, 25)
  )
  expected_output_alc <- c(1, 2, 1, 3)
  expect_equal(df_alc |> dplyr::mutate(alc_risk_score = derive_alcohol_risk(clc_sex, alc_11, alcdwky)) |> dplyr::pull(alc_risk_score), expected_output_alc)
})

# Test for derive_alcohol_risk_detailed
test_that("derive_alcohol_risk_detailed returns correct scores", {
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = NA, alc_17 = 2, alc_11 = 2, alc_18 = 2), 1) # Never drinker (male)
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = NA, alc_17 = 1, alc_11 = 2, alc_18 = 2), 1) # Former drinker, no heavy (similar risk as never drinking)
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = NA, alc_17 = 1, alc_11 = 2, alc_18 = 1), 2) # Former drinker, heavy
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = 3, alc_17 = 1, alc_11 = 1, alc_18 = 2), 2) # Light drinker, male
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 2, alcdwky = 3, alc_17 = 1, alc_11 = 1, alc_18 = 2), 2) # Light drinker, female
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = 12, alc_17 = 1, alc_11 = 1, alc_18 = 2), 2) # Light drinker, male
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 2, alcdwky = 12, alc_17 = 1, alc_11 = 1, alc_18 = 2), 3) # Moderate drinker, female
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = 18, alc_17 = 1, alc_11 = 1, alc_18 = 2), 3) # Moderate drinker, male
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 2, alcdwky = 18, alc_17 = 1, alc_11 = 1, alc_18 = 2), 4) # Heavy drinker, female
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = 25, alc_17 = 1, alc_11 = 1, alc_18 = 2), 4) # Heavy drinker, male
  expect_equal(derive_alcohol_risk_detailed(clc_sex = 2, alcdwky = 25, alc_17 = 1, alc_11 = 1, alc_18 = 2), 4) # Heavy drinker, female
  expect_true(is.na(derive_alcohol_risk_detailed(clc_sex = 1, alcdwky = 996, alc_17 = 1, alc_11 = 1, alc_18 = 1))) # Invalid input

  # StatsCan missing data codes
  expect_true(haven::is_tagged_na(derive_alcohol_risk_detailed(1, 6, 5, 1, 2), "a")) # Code 6 -> tagged NA(a)
  expect_true(haven::is_tagged_na(derive_alcohol_risk_detailed(1, 7, 5, 1, 2), "b")) # Code 7 -> tagged NA(b)
  expect_true(haven::is_tagged_na(derive_alcohol_risk_detailed(1, 1, NA, 8, 2), "b")) # Code 8 -> tagged NA(b)
  expect_true(haven::is_tagged_na(derive_alcohol_risk_detailed(1, 1, 5, 1, 9), "b")) # Code 9 -> tagged NA(b)

  # Mixed missing codes - "not applicable" takes precedence over "missing"
  expect_true(haven::is_tagged_na(derive_alcohol_risk_detailed(6, 7, 5, 1, 2), "a")) # 6 + 7 -> tagged NA(a)

  # Vector usage
  expect_equal(derive_alcohol_risk_detailed(clc_sex = c(1, 2, 1), alc_11 = c(1, 1, 2), alcdwky = c(3, 12, NA), alc_17 = c(1, 1, 1), alc_18 = c(2, 2, 1)), c(2, 3, 2))

  # Database usage (simulated)
  df_alc1 <- data.frame(
    clc_sex = c(1, 2, 1, 2),
    alc_11 = c(1, 1, 2, 1),
    alcdwky = c(3, 12, NA, 25),
    alc_17 = c(1, 1, 1, 1),
    alc_18 = c(2, 2, 1, 1)
  )
  expected_output_alc1 <- c(2, 3, 2, 4)
  expect_equal(df_alc1 |> dplyr::mutate(alc_detailed_risk_score = derive_alcohol_risk_detailed(clc_sex, alc_11, alcdwky, alc_17, alc_18)) |> dplyr::pull(alc_detailed_risk_score), expected_output_alc1)
})
