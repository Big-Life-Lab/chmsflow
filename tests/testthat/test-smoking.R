# test-smoking.R

test_that("SMKDSTY = 1: Daily smoker", {
  # Should equal 0.05
  expect_equal(pack_years_fun(SMKDSTY = 1, CLC_AGE = 21, SMK_52 = 20, SMK_31 = 1, SMK_54 = 0, SMK_41 = 0, SMK_53 = 0, SMK_42 = 0, SMK_21 = 0, SMK_11 = 0), 0.05)
})

test_that("SMKDSTY = 2: Occasional smoker (former daily)", {
  # daily 1 pack/day for 10 years, then occasional 5 cigs/day, 4 days/month for 5 years
  result <- pack_years_fun(
    SMKDSTY = 2, CLC_AGE = 50, SMK_52 = 30, SMK_31 = NA, SMK_54 = 45, SMK_53 = 20,
    SMK_41 = 5, SMK_42 = 4, SMK_21 = 0, SMK_11 = 1
  )

  expected <- 15.25
  expect_equal(result, expected)
})

test_that("SMKDSTY = 3: Occasional smoker (never daily)", {
  result <- pack_years_fun(
    SMKDSTY = 3, CLC_AGE = 40, SMK_41 = 10, SMK_42 = 6, SMK_21 = 30,
    SMK_52 = 0, SMK_53 = 0, SMK_31 = 0, SMK_54 = 0, SMK_11 = 0
  )
  expected <- (pmax((10 * 6 / 30), 1) / 20) * (40 - 30)
  expect_equal(result, expected)
})

test_that("SMKDSTY = 4: Former daily smoker", {
  result <- pack_years_fun(
    SMKDSTY = 4, CLC_AGE = 60, SMK_52 = 20, SMK_54 = 50, SMK_53 = 30,
    SMK_31 = 0, SMK_41 = 0, SMK_42 = 0, SMK_21 = 0, SMK_11 = 0
  )
  expected <- pmax(((50 - 20) * (30 / 20)), 0.0137)
  expect_equal(result, expected)
})

test_that("SMKDSTY = 5: Former occasional smoker, smoked ≥100 cigarettes", {
  expect_equal(
    pack_years_fun(
      SMKDSTY = 5, CLC_AGE = 50, SMK_11 = 1,
      SMK_54 = 0, SMK_52 = 0, SMK_31 = 0,
      SMK_41 = 0, SMK_42 = 0, SMK_21 = 0, SMK_53 = 0
    ),
    0.0137
  )
})

test_that("SMKDSTY = 5: Former occasional smoker, smoked <100 cigarettes", {
  expect_equal(
    pack_years_fun(
      SMKDSTY = 5, CLC_AGE = 50, SMK_11 = 2,
      SMK_54 = 0, SMK_52 = 0, SMK_31 = 0,
      SMK_41 = 0, SMK_42 = 0, SMK_21 = 0, SMK_53 = 0
    ),
    0.007
  )
})

test_that("SMKDSTY = 6: Non-smoker", {
  expect_equal(
    pack_years_fun(
      SMKDSTY = 6, CLC_AGE = 40, SMK_11 = 2,
      SMK_54 = 0, SMK_52 = 0, SMK_31 = 0,
      SMK_41 = 0, SMK_42 = 0, SMK_21 = 0, SMK_53 = 0
    ),
    0
  )
})


test_that("Returns tagged NA when CLC_AGE is NA or invalid", {
  expect_equal(pack_years_fun(SMKDSTY = 1, CLC_AGE = NA, SMK_52 = 20, SMK_31 = 20, SMK_54 = 0, SMK_41 = 0, SMK_53 = 0, SMK_42 = 0, SMK_21 = 0, SMK_11 = 0), haven::tagged_na("b"))
  expect_equal(pack_years_fun(SMKDSTY = 1, CLC_AGE = -5, SMK_52 = 20, SMK_31 = 20, SMK_54 = 0, SMK_41 = 0, SMK_53 = 0, SMK_42 = 0, SMK_21 = 0, SMK_11 = 0), haven::tagged_na("b"))
})

test_that("pack_years_fun handles NA inputs for smoking variables", {
  # Daily smoker with NA for SMK_52
  expect_true(is.na(pack_years_fun(SMKDSTY = 1, CLC_AGE = 40, SMK_52 = NA, SMK_31 = 10, SMK_54 = 0, SMK_41 = 0, SMK_53 = 0, SMK_42 = 0, SMK_21 = 0, SMK_11 = 0)))

  # Occasional smoker (former daily) with NA for SMK_54
  expect_true(is.na(pack_years_fun(SMKDSTY = 2, CLC_AGE = 50, SMK_52 = 30, SMK_31 = 0, SMK_54 = NA, SMK_53 = 20, SMK_41 = 5, SMK_42 = 4, SMK_21 = 0, SMK_11 = 1)))

  # Vector usage
  expect_equal(
    pack_years_fun(
      SMKDSTY = c(1, 5, 6, 1, NA),
      CLC_AGE = c(40, 50, 60, NA, 40),
      SMK_52 = c(20, 18, 0, 20, 0),
      SMK_31 = c(30, 0, 0, 30, 0),
      SMK_54 = c(0, 40, 0, 0, 0),
      SMK_41 = c(0, 15, 0, 0, 0),
      SMK_53 = c(0, 0, 0, 0, 0),
      SMK_42 = c(0, 3, 0, 0, 0),
      SMK_21 = c(0, 25, 0, 0, 0),
      SMK_11 = c(0, 1, 0, 0, 0)
    ),
    c(30, 0.0137, 0, haven::tagged_na("b"), haven::tagged_na("b"))
  )

  # Database usage (simulated)
  df_smoking <- data.frame(
    SMKDSTY = c(1, 5, 6, 1, NA),
    CLC_AGE = c(40, 50, 60, NA, 40),
    SMK_52 = c(20, 18, 0, 20, 0),
    SMK_31 = c(30, 0, 0, 30, 0),
    SMK_54 = c(0, 40, 0, 0, 0),
    SMK_41 = c(0, 15, 0, 0, 0),
    SMK_53 = c(0, 0, 0, 0, 0),
    SMK_42 = c(0, 3, 0, 0, 0),
    SMK_21 = c(0, 25, 0, 0, 0),
    SMK_11 = c(0, 1, 2, 0, 0)
  )
  expected_output_smoking <- c(30, 0.0137, 0, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_smoking %>% dplyr::mutate(pack_years = pack_years_fun(SMKDSTY, CLC_AGE, SMK_54, SMK_52, SMK_31, SMK_41, SMK_53, SMK_42, SMK_21, SMK_11)) %>% dplyr::pull(pack_years), expected_output_smoking)
})
