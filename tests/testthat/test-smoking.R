# test-smoking.R

# Test for pack_years_fun
test_that("pack_years_fun returns correct pack years", {
  # Daily smoker
  expect_equal(pack_years_fun(1, 40, NA, 20, 20, NA, NA, NA, NA, NA), 20)

  # Occasional smoker (former daily)
  expect_equal(pack_years_fun(2, 50, 45, 30, NA, 5, 20, 4, NA, 1), 15.25)

  # Occasional smoker (never daily)
  expect_equal(pack_years_fun(3, 40, NA, NA, NA, 10, NA, 6, 30, NA), 1)

  # Former daily smoker
  expect_equal(pack_years_fun(4, 60, 50, 20, NA, NA, 30, NA, NA, NA), 45)

  # Former occasional smoker
  expect_equal(pack_years_fun(5, 50, NA, NA, NA, NA, NA, NA, NA, 1), 0.0137)
  expect_equal(pack_years_fun(5, 50, NA, NA, NA, NA, NA, NA, NA, 2), 0.007)

  # Non-smoker
  expect_equal(pack_years_fun(6, 40, NA, NA, NA, NA, NA, NA, NA, 2), 0)

  # Missing data codes
  expect_true(haven::is_tagged_na(pack_years_fun(96, 40, NA, 20, 20, NA, NA, NA, NA, NA), "a"))
  expect_true(haven::is_tagged_na(pack_years_fun(1, 96, NA, 20, 20, NA, NA, NA, NA, NA), "a"))
  expect_true(haven::is_tagged_na(pack_years_fun(97, 40, NA, 20, 20, NA, NA, NA, NA, NA), "b"))
  expect_true(haven::is_tagged_na(pack_years_fun(1, 97, NA, 20, 20, NA, NA, NA, NA, NA), "b"))

  # Vector usage
  expect_equal(
    pack_years_fun(
      SMKDSTY = c(1, 2, 3, 4, 5, 5, 6),
      CLC_AGE = c(40, 50, 40, 60, 50, 50, 40),
      SMK_54 = c(NA, 45, NA, 50, NA, NA, NA),
      SMK_52 = c(20, 30, NA, 20, NA, NA, NA),
      SMK_31 = c(20, NA, NA, NA, NA, NA, NA),
      SMK_41 = c(NA, 5, 10, NA, NA, NA, NA),
      SMK_53 = c(NA, 20, NA, 30, NA, NA, NA),
      SMK_42 = c(NA, 4, 6, NA, NA, NA, NA),
      SMK_21 = c(NA, NA, 30, NA, NA, NA, NA),
      SMK_11 = c(NA, 1, NA, NA, 1, 2, 2)
    ),
    c(20, 15.25, 1, 45, 0.0137, 0.007, 0)
  )
})
