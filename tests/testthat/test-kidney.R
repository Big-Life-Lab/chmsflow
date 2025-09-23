# test-kidney.R
# Test calculate_GFR
test_that("calculate_GFR works correctly", {
  # Example cases
  expect_equal(calculate_GFR(LAB_BCRE = 80, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 45), 67.27905, tolerance = 1e-5)
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 2, CLC_SEX = 2, CLC_AGE = 35), 99.94114, tolerance = 1e-5)

  # Non-response values
  expect_equal(calculate_GFR(LAB_BCRE = 9996, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 96, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 6, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 996), haven::tagged_na("b"))

  # Invalid inputs
  expect_equal(calculate_GFR(LAB_BCRE = NA, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = NA, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = NA, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = NA), haven::tagged_na("b"))

  # Boundary cases
  expect_equal(calculate_GFR(LAB_BCRE = 0, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))

  # Vector usage
  expect_equal(calculate_GFR(LAB_BCRE = c(80, 70, 90, NA, 14, 785), PGDCGT = c(1, 2, 1, 1, 1, 1), CLC_SEX = c(2, 2, 1, 1, 1, 1), CLC_AGE = c(45, 35, 50, 30, 3, 79)), c(67.27905, 99.94114, 77.474217, haven::tagged_na("b"), 175 * ((14 / 88.4)^(-1.154)) * ((3)^(-0.203)), 175 * ((785 / 88.4)^(-1.154)) * ((79)^(-0.203))), tolerance = 1e-5)

  # Database usage (simulated)
  df_gfr <- data.frame(
    LAB_BCRE = c(80, 70, 90, NA, 14, 785),
    PGDCGT = c(1, 2, 1, 1, 1, 1),
    CLC_SEX = c(2, 2, 1, 1, 1, 1),
    CLC_AGE = c(45, 35, 50, 30, 3, 79)
  )
  expected_output_gfr <- c(67.27905, 99.94114, 77.47422, haven::tagged_na("b"), 175 * ((14 / 88.4)^(-1.154)) * ((3)^(-0.203)), 175 * ((785 / 88.4)^(-1.154)) * ((79)^(-0.203)))
  expect_equal(df_gfr %>% dplyr::mutate(gfr = calculate_GFR(LAB_BCRE, PGDCGT, CLC_SEX, CLC_AGE)) %>% dplyr::pull(gfr), expected_output_gfr, tolerance = 1e-5)
})

# Test categorize_GFR_to_CKD
test_that("categorize_GFR_to_CKD works correctly", {
  # CKD stage 1 (GFR <= 60)
  expect_equal(categorize_GFR_to_CKD(45), 1)
  expect_equal(categorize_GFR_to_CKD(60), 1)

  # CKD stage 2 (GFR > 60)
  expect_equal(categorize_GFR_to_CKD(75), 2)

  # Missing or invalid inputs
  expect_equal(categorize_GFR_to_CKD(NA), haven::tagged_na("b"))
  expect_equal(categorize_GFR_to_CKD(haven::tagged_na("b")), haven::tagged_na("b"))

  # Boundary cases
  expect_equal(categorize_GFR_to_CKD(0), 1)
  expect_equal(categorize_GFR_to_CKD(61), 2)

  # Vector usage
  expect_equal(categorize_GFR_to_CKD(c(45, 75, 60, NA, -1)), c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_ckd <- data.frame(
    GFR = c(45, 75, 60, NA, -1)
  )
  expected_output_ckd <- c(1, 2, 1, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_ckd %>% dplyr::mutate(ckd = categorize_GFR_to_CKD(GFR)) %>% dplyr::pull(ckd), expected_output_ckd)
})

test_that("calculate_GFR input boundaries are tested", {
  # LAB_BCRE boundaries
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 14, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30)))
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 785, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30)))
  expect_equal(calculate_GFR(LAB_BCRE = 13, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 786, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))

  # CLC_SEX boundaries
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30)))
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 30)))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 0, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 3, CLC_AGE = 30), haven::tagged_na("b"))

  # PGDCGT boundaries
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30)))
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 13, CLC_SEX = 1, CLC_AGE = 30)))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 0, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 14, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))

  # CLC_AGE boundaries
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 3)))
  expect_true(is.numeric(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 79)))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 2), haven::tagged_na("b"))
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 80), haven::tagged_na("b"))
})

test_that("categorize_GFR_to_CKD handles more boundary cases", {
  expect_equal(categorize_GFR_to_CKD(60.0001), 2)
  expect_equal(categorize_GFR_to_CKD(59.9999), 1)
  expect_equal(categorize_GFR_to_CKD(-1), haven::tagged_na("b"))
})
