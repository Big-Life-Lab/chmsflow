# test-diabetes.R
test_that("determine_inclusive_diabetes handles all inputs present", {
  # Case 1: All inputs are present and indicate diabetes
  expect_equal(determine_inclusive_diabetes(1, 2, 0), 1) # HbA1c positive
  expect_equal(determine_inclusive_diabetes(2, 1, 0), 1) # Self-reported positive
  expect_equal(determine_inclusive_diabetes(2, 2, 1), 1) # Diabetes medication positive

  # Case 2: All inputs are present and indicate no diabetes
  expect_equal(determine_inclusive_diabetes(2, 2, 0), 2)
})

test_that("determine_inclusive_diabetes handles all inputs NA", {
  # Case 3: All inputs are NA
  expect_equal(determine_inclusive_diabetes(NA, NA, NA), haven::tagged_na("b"))
})

test_that("determine_inclusive_diabetes handles two inputs NA", {
  # Case 4: diab_m and CCC_51 are NA, decision based on diab_drug2
  expect_equal(determine_inclusive_diabetes(NA, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(NA, NA, 0), haven::tagged_na("b"))

  # Case 5: diab_m and diab_drug2 are NA, decision based on CCC_51
  expect_equal(determine_inclusive_diabetes(NA, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(NA, 2, NA), 2)

  # Case 6: CCC_51 and diab_drug2 are NA, decision based on diab_m
  expect_equal(determine_inclusive_diabetes(1, NA, NA), 1)
  expect_equal(determine_inclusive_diabetes(2, NA, NA), 2)
})

test_that("determine_inclusive_diabetes handles one input NA", {
  # Case 7: diab_m is NA, decision based on CCC_51 and diab_drug2
  expect_equal(determine_inclusive_diabetes(NA, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(NA, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(NA, 2, 1), 1)

  # Case 8: CCC_51 is NA, decision based on diab_m and diab_drug2
  expect_equal(determine_inclusive_diabetes(1, NA, 0), 1)
  expect_equal(determine_inclusive_diabetes(2, NA, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, 1), 1)

  # Case 9: diab_drug2 is NA, decision based on diab_m and CCC_51
  expect_equal(determine_inclusive_diabetes(1, 2, NA), 1)
  expect_equal(determine_inclusive_diabetes(2, 2, NA), 2)
  expect_equal(determine_inclusive_diabetes(1, 1, NA), 1)
})

test_that("determine_inclusive_diabetes handles edge cases", {
  # Mixed valid and invalid inputs
  expect_equal(determine_inclusive_diabetes(NA, NA, 1), 1) # Decision based on diab_drug2
  expect_equal(determine_inclusive_diabetes(1, NA, NA), 1) # Decision based on diab_m
  expect_equal(determine_inclusive_diabetes(2, 1, NA), 1) # Decision based on CCC_51

  # All parameters explicitly "No" or invalid
  expect_equal(determine_inclusive_diabetes(2, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, 0), 2)
  expect_equal(determine_inclusive_diabetes(NA, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, 2, NA), 2)
})

test_that("determine_inclusive_diabetes covers all combinations", {
  combinations <- expand.grid(diab_m = c(1, 2, NA), CCC_51 = c(1, 2, NA), diab_drug2 = c(0, 1, NA))

  expected_results <- c(
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 2, 2, 1, 1, 1, 1, 2, 2, 1, haven::tagged_na("b"), haven::tagged_na("b")
  )

  for (i in seq_len(nrow(combinations))) {
    diab_m_val <- combinations$diab_m[i]
    ccc_51_val <- combinations$CCC_51[i]
    diab_drug2_val <- combinations$diab_drug2[i]

    # The expected_results vector needs to be manually created based on the logic.
    # This is a placeholder for the actual expected result for each combination.
    # The logic is complex, so I will test the combinations I derived manually.
  }

  # Manually derived combinations
  expect_equal(determine_inclusive_diabetes(1, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(1, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(1, 2, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, 2, 0), 1)
  expect_equal(determine_inclusive_diabetes(1, 2, NA), 1)
  expect_equal(determine_inclusive_diabetes(1, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(1, NA, 0), 1)
  expect_equal(determine_inclusive_diabetes(1, NA, NA), 1)
  expect_equal(determine_inclusive_diabetes(2, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(2, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(2, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(2, 2, 1), 1)
  expect_equal(determine_inclusive_diabetes(2, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, 2, NA), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(2, NA, 0), 2)
  expect_equal(determine_inclusive_diabetes(2, NA, NA), 2)
  expect_equal(determine_inclusive_diabetes(NA, 1, 1), 1)
  expect_equal(determine_inclusive_diabetes(NA, 1, 0), 1)
  expect_equal(determine_inclusive_diabetes(NA, 1, NA), 1)
  expect_equal(determine_inclusive_diabetes(NA, 2, 1), 1)
  expect_equal(determine_inclusive_diabetes(NA, 2, 0), 2)
  expect_equal(determine_inclusive_diabetes(NA, 2, NA), 2)
  expect_equal(determine_inclusive_diabetes(NA, NA, 1), 1)
  expect_equal(determine_inclusive_diabetes(NA, NA, 0), haven::tagged_na("b"))
  expect_equal(determine_inclusive_diabetes(NA, NA, NA), haven::tagged_na("b"))

  # Vector usage
  expect_equal(determine_inclusive_diabetes(diab_m = c(1, 2, 2, NA, 2), CCC_51 = c(2, 1, 2, NA, 2), diab_drug2 = c(0, 0, 1, 1, NA)), c(1, 1, 1, 1, 2))

  # Database usage (simulated)
  df_diabetes <- data.frame(
    diab_m = c(1, 2, 2, NA, 2),
    CCC_51 = c(2, 1, 2, NA, 2),
    diab_drug2 = c(0, 0, 1, 1, NA)
  )
  expected_output_diabetes <- c(1, 1, 1, 1, 2)
  expect_equal(df_diabetes %>% dplyr::mutate(diabetes_status = determine_inclusive_diabetes(diab_m, CCC_51, diab_drug2)) %>% dplyr::pull(diabetes_status), expected_output_diabetes)
})
