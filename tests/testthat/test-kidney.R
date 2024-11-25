# test-kidney.R
# Test calculate_GFR
test_that("calculate_GFR works correctly", {
  
  # Example cases
  expect_equal(calculate_GFR(LAB_BCRE = 80, PGDCGT = 1, CLC_SEX = 2, CLC_AGE = 45), 67.27905, tolerance = 1e-5)
  expect_equal(calculate_GFR(LAB_BCRE = 70, PGDCGT = 2, CLC_SEX = 2, CLC_AGE = 35), 99.94114, tolerance = 1e-5)
  
  # Non-response values
  expect_equal(calculate_GFR(LAB_BCRE = 996, PGDCGT = 1, CLC_SEX = 1, CLC_AGE = 30), haven::tagged_na("b"))
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
})