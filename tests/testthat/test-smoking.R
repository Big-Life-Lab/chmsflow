# test-smoking.R

# Test for calculate_pack_years
test_that("calculate_pack_years returns correct pack years", {
  # General tests - Daily smoker
  expect_equal(calculate_pack_years(1, 40, NA, 20, 20, NA, NA, NA, NA, NA), 20)

  # General tests - Occasional smoker (former daily)
  expect_equal(calculate_pack_years(2, 50, 45, 30, NA, 5, 20, 4, NA, 1), 15.25)

  # General tests - Occasional smoker (never daily)
  expect_equal(calculate_pack_years(3, 40, NA, NA, NA, 10, NA, 6, 30, NA), 1)

  # General tests - Former daily smoker
  expect_equal(calculate_pack_years(4, 60, 50, 20, NA, NA, 30, NA, NA, NA), 45)

  # General tests - Former occasional smoker
  expect_equal(calculate_pack_years(5, 50, NA, NA, NA, NA, NA, NA, NA, 1), 0.0137)
  expect_equal(calculate_pack_years(5, 50, NA, NA, NA, NA, NA, NA, NA, 2), 0.007)

  # General tests - Non-smoker
  expect_equal(calculate_pack_years(6, 40, NA, NA, NA, NA, NA, NA, NA, 2), 0)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(calculate_pack_years(96, 40, NA, 20, 20, NA, NA, NA, NA, NA), "a"))
  expect_true(haven::is_tagged_na(calculate_pack_years(1, 96, NA, 20, 20, NA, NA, NA, NA, NA), "a"))
  expect_true(haven::is_tagged_na(calculate_pack_years(97, 40, NA, 20, 20, NA, NA, NA, NA, NA), "b"))
  expect_true(haven::is_tagged_na(calculate_pack_years(1, 97, NA, 20, 20, NA, NA, NA, NA, NA), "b"))

  # Vector tests
  expect_equal(
    calculate_pack_years(
      smkdsty = c(1, 2, 3, 4, 5, 5, 6),
      clc_age = c(40, 50, 40, 60, 50, 50, 40),
      smk_54 = c(NA, 45, NA, 50, NA, NA, NA),
      smk_52 = c(20, 30, NA, 20, NA, NA, NA),
      smk_31 = c(20, NA, NA, NA, NA, NA, NA),
      smk_41 = c(NA, 5, 10, NA, NA, NA, NA),
      smk_53 = c(NA, 20, NA, 30, NA, NA, NA),
      smk_42 = c(NA, 4, 6, NA, NA, NA, NA),
      smk_21 = c(NA, NA, 30, NA, NA, NA, NA),
      smk_11 = c(NA, 1, NA, NA, 1, 2, 2)
    ),
    c(20, 15.25, 1, 45, 0.0137, 0.007, 0)
  )

  # Database tests
  df <- data.frame(
    SMKDSTY = c(1, 6),
    CLC_AGE = c(40, 40),
    SMK_54 = c(NA, NA),
    SMK_52 = c(20, NA),
    SMK_31 = c(20, NA),
    SMK_41 = c(NA, NA),
    SMK_53 = c(NA, NA),
    SMK_42 = c(NA, NA),
    SMK_21 = c(NA, NA),
    SMK_11 = c(NA, 2)
  )
  expect_equal(
    df |> dplyr::mutate(py = calculate_pack_years(SMKDSTY, CLC_AGE, SMK_54, SMK_52, SMK_31, SMK_41, SMK_53, SMK_42, SMK_21, SMK_11)) |> dplyr::pull(py),
    c(20, 0)
  )
})
