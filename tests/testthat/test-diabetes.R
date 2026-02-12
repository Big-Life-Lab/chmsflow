# test-diabetes.R

# Test for derive_diabetes_status
test_that("derive_diabetes_status returns correct diabetes status", {
  # General tests - all inputs present
  expect_equal(derive_diabetes_status(1, 1, 1), 1)
  expect_equal(derive_diabetes_status(1, 1, 0), 1)
  expect_equal(derive_diabetes_status(1, 2, 1), 1)
  expect_equal(derive_diabetes_status(1, 2, 0), 1)
  expect_equal(derive_diabetes_status(2, 1, 1), 1)
  expect_equal(derive_diabetes_status(2, 1, 0), 1)
  expect_equal(derive_diabetes_status(2, 2, 1), 1)
  expect_equal(derive_diabetes_status(2, 2, 0), 2)

  # Edge case tests - one input missing
  expect_equal(derive_diabetes_status(NA, 1, 1), 1) # CCC_32 missing, others positive
  expect_equal(derive_diabetes_status(1, NA, 1), 1) # DIABX missing, others positive
  expect_equal(derive_diabetes_status(1, 1, NA), 1) # DIAB_MED missing, others positive
  expect_equal(derive_diabetes_status(NA, 2, 0), 2) # CCC_32 missing, others negative
  expect_equal(derive_diabetes_status(2, NA, 0), 2) # DIABX missing, others negative
  expect_equal(derive_diabetes_status(2, 2, NA), 2) # DIAB_MED missing, others negative

  # Edge case tests - two inputs missing
  expect_equal(derive_diabetes_status(NA, NA, 1), 1) # Only DIAB_MED positive
  expect_equal(derive_diabetes_status(NA, 1, NA), 1) # Only DIABX positive
  expect_equal(derive_diabetes_status(1, NA, NA), 1) # Only CCC_32 positive
  expect_equal(derive_diabetes_status(NA, NA, 0), 2) # Only DIAB_MED negative
  expect_equal(derive_diabetes_status(NA, 2, NA), 2) # Only DIABX negative
  expect_equal(derive_diabetes_status(2, NA, NA), 2) # Only CCC_32 negative

  # Edge case tests - all inputs missing
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 8, haven::tagged_na("b")), "b"))

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("a"), 6, 0), "a"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("a"), 6, haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 7, 0), "b"))
  expect_true(haven::is_tagged_na(derive_diabetes_status(haven::tagged_na("b"), 7, haven::tagged_na("b")), "b"))

  # Vector tests
  expect_equal(derive_diabetes_status(c(1, 2, 2, NA), c(2, 1, 2, NA), c(0, 0, 1, 1)), c(1, 1, 1, 1))

  # Database tests
  df <- data.frame(CCC_32 = c(1, 2, 2), DIABX = c(2, 1, 2), DIAB_MED = c(0, 0, 1))
  expect_equal(df |> dplyr::mutate(diab = derive_diabetes_status(CCC_32, DIABX, DIAB_MED)) |> dplyr::pull(diab), c(1, 1, 1))
})
