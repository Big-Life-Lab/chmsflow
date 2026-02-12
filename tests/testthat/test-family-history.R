# test-family-history.R

# Test for derive_cvd_personal_history
test_that("derive_cvd_personal_history returns correct CVD personal history", {
  expect_equal(derive_cvd_personal_history(1, 2, 2), 1)
  expect_equal(derive_cvd_personal_history(2, 1, 2), 1)
  expect_equal(derive_cvd_personal_history(2, 2, 1), 1)
  expect_equal(derive_cvd_personal_history(2, 2, 2), 2)
  expect_true(haven::is_tagged_na(derive_cvd_personal_history(6, 6, 6), "a"))
  expect_true(haven::is_tagged_na(derive_cvd_personal_history(7, 7, 7), "b"))
  expect_true(haven::is_tagged_na(derive_cvd_personal_history(NA, NA, NA), "b"))
  expect_equal(derive_cvd_personal_history(c(1, 2, 2), c(2, 1, 2), c(2, 2, 1)), c(1, 1, 1))
})

# Test for derive_cvd_family_history
test_that("derive_cvd_family_history returns correct CVD family history", {
  expect_equal(derive_cvd_family_history(1, 50, 2, NA), 1)
  expect_equal(derive_cvd_family_history(2, NA, 1, 55), 1)
  expect_equal(derive_cvd_family_history(1, 70, 2, NA), 2)
  expect_equal(derive_cvd_family_history(2, NA, 1, 70), 2)
  expect_equal(derive_cvd_family_history(2, NA, 2, NA), 2)
  expect_true(haven::is_tagged_na(derive_cvd_family_history(6, NA, 6, NA), "a"))
  expect_true(haven::is_tagged_na(derive_cvd_family_history(7, NA, 7, NA), "b"))
  expect_true(haven::is_tagged_na(derive_cvd_family_history(1, 996, 1, 996), "a"))
  expect_true(haven::is_tagged_na(derive_cvd_family_history(1, 997, 2, NA), "b"))
  expect_true(haven::is_tagged_na(derive_cvd_family_history(NA, NA, NA, NA), "b"))
  expect_equal(derive_cvd_family_history(c(1, 2, 1), c(50, NA, 70), c(2, 1, 2), c(NA, 55, NA)), c(1, 1, 2))
})
