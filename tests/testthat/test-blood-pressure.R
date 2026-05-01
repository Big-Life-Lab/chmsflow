# test-blood-pressure.R

# Test for adjust_sbp
test_that("adjust_sbp returns correct adjusted systolic blood pressure", {
  # General tests
  expect_equal(adjust_sbp(120), 123)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(adjust_sbp(996), "a"))
  expect_true(haven::is_tagged_na(adjust_sbp(997), "b"))
  expect_true(haven::is_tagged_na(adjust_sbp(-5), "b"))
  expect_true(is.na(adjust_sbp(NA)))
  # Edge case tests - boundary values
  expect_true(!is.na(adjust_sbp(0))) # Zero BP still valid

  # Vector tests
  expect_equal(adjust_sbp(c(120, 996, -5, NA)), c(123, haven::tagged_na("a"), haven::tagged_na("b"), NA))

  # Database tests
  df <- data.frame(SBP = c(120, 140, 996))
  result <- df |>
    dplyr::mutate(adj = adjust_sbp(SBP)) |>
    dplyr::pull(adj)
  expect_equal(length(result), 3)
  expect_true(haven::is_tagged_na(result[3], "a"))
})

# Test for adjust_dbp
test_that("adjust_dbp returns correct adjusted diastolic blood pressure", {
  # General tests
  expect_equal(adjust_dbp(80), 82)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(adjust_dbp(996), "a"))
  expect_true(haven::is_tagged_na(adjust_dbp(997), "b"))
  expect_true(haven::is_tagged_na(adjust_dbp(-5), "b"))
  expect_true(is.na(adjust_dbp(NA)))

  # Edge case tests - boundary values
  expect_true(!is.na(adjust_dbp(0))) # Zero BP still valid

  # Vector tests
  expect_equal(adjust_dbp(c(80, 996, -5, NA)), c(82, haven::tagged_na("a"), haven::tagged_na("b"), NA))

  # Database tests
  df <- data.frame(DBP = c(80, 90, 996))
  result <- df |>
    dplyr::mutate(adj = adjust_dbp(DBP)) |>
    dplyr::pull(adj)
  expect_equal(length(result), 3)
  expect_true(haven::is_tagged_na(result[3], "a"))
})

# Test for derive_hypertension
test_that("derive_hypertension returns correct hypertension status", {
  # General tests
  expect_equal(derive_hypertension(140, 80, 0), 1)
  expect_equal(derive_hypertension(120, 90, 0), 1)
  expect_equal(derive_hypertension(120, 80, 1), 1)
  expect_equal(derive_hypertension(130, 80, 0, diab_status = 1), 1)
  expect_equal(derive_hypertension(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(derive_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension(120, 997, 0), "b"))
  expect_true(is.na(derive_hypertension(NA, NA, 0)))
  # Edge case tests - boundary values
  expect_equal(derive_hypertension(139, 89, 0), 2)
  expect_equal(derive_hypertension(140, 89, 0), 1)
  expect_equal(derive_hypertension(139, 90, 0), 1)
  expect_equal(derive_hypertension(129, 79, 0, diab_status = 1), 2)
  expect_equal(derive_hypertension(130, 79, 0, diab_status = 1), 1)
  expect_equal(derive_hypertension(129, 80, 0, diab_status = 1), 1)

  # Edge case tests - combined comorbidities
  expect_equal(derive_hypertension(130, 80, 0, diab_status = 1, ckd_status = 1), 1)
  expect_equal(derive_hypertension(129, 79, 0, diab_status = 1, ckd_status = 1), 2)

  # Edge case tests - very high BP values
  expect_equal(derive_hypertension(200, 120, 0), 1)
  expect_equal(derive_hypertension(250, 150, 0), 1)

  # Vector tests
  expect_equal(derive_hypertension(c(140, 120), c(80, 80), c(0, 0)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(140, 120), DBP = c(80, 80), ANYMED2 = c(0, 0))
  expect_equal(df |> dplyr::mutate(htn = derive_hypertension(SBP, DBP, ANYMED2)) |> dplyr::pull(htn), c(1, 2))
})

# Test for derive_hypertension_adj
test_that("derive_hypertension_adj returns correct adjusted hypertension status", {
  # General tests
  expect_equal(derive_hypertension_adj(140, 80, 0), 1)
  expect_equal(derive_hypertension_adj(120, 90, 0), 1)
  expect_equal(derive_hypertension_adj(120, 80, 1), 1)
  expect_equal(derive_hypertension_adj(130, 80, 0, diab_status = 1), 1)
  expect_equal(derive_hypertension_adj(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(derive_hypertension_adj(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_adj(120, 997, 0), "b"))
  expect_true(is.na(derive_hypertension_adj(NA, NA, 0)))
  # Edge case tests - boundary values
  expect_equal(derive_hypertension_adj(139, 89, 0), 2)
  expect_equal(derive_hypertension_adj(140, 89, 0), 1)
  expect_equal(derive_hypertension_adj(139, 90, 0), 1)

  # Edge case tests - combined comorbidities
  expect_equal(derive_hypertension_adj(130, 80, 0, diab_status = 1, ckd_status = 1), 1)
  expect_equal(derive_hypertension_adj(129, 79, 0, diab_status = 1, ckd_status = 1), 2)

  # Vector tests
  expect_equal(derive_hypertension_adj(c(140, 120), c(80, 80), c(0, 0)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(140, 120), DBP = c(80, 80), ANYMED2 = c(0, 0))
  expect_equal(df |> dplyr::mutate(htn = derive_hypertension_adj(SBP, DBP, ANYMED2)) |> dplyr::pull(htn), c(1, 2))
})

# Test for derive_hypertension_control
test_that("derive_hypertension_control returns correct controlled hypertension status", {
  # General tests
  expect_equal(derive_hypertension_control(139, 89, 1), 1)
  expect_equal(derive_hypertension_control(140, 89, 1), 2)
  expect_equal(derive_hypertension_control(139, 90, 1), 2)
  expect_equal(derive_hypertension_control(129, 79, 1, ccc_32 = 1, diab_status = 1), 1)
  expect_equal(derive_hypertension_control(130, 79, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control(129, 80, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(derive_hypertension_control(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_control(120, 997, 1), "b"))
  expect_true(is.na(derive_hypertension_control(NA, NA, 1)))
  # Edge case tests - boundary with comorbidities
  expect_equal(derive_hypertension_control(139, 89, 1, diab_status = 0), 1)

  # Vector tests
  expect_equal(derive_hypertension_control(c(139, 140), c(89, 89), c(1, 1)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(139, 140), DBP = c(89, 89), ANYMED2 = c(1, 1))
  expect_equal(df |> dplyr::mutate(ctrl = derive_hypertension_control(SBP, DBP, ANYMED2)) |> dplyr::pull(ctrl), c(1, 2))
})

# Test for derive_hypertension_control_adj
test_that("derive_hypertension_control_adj returns correct controlled adjusted hypertension status", {
  # General tests
  expect_equal(derive_hypertension_control_adj(139, 89, 1), 1)
  expect_equal(derive_hypertension_control_adj(140, 89, 1), 2)
  expect_equal(derive_hypertension_control_adj(139, 90, 1), 2)
  expect_equal(derive_hypertension_control_adj(129, 79, 1, ccc_32 = 1, diab_status = 1), 1)
  expect_equal(derive_hypertension_control_adj(130, 79, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control_adj(129, 80, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control_adj(120, 80, 0), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(120, 997, 1), "b"))
  expect_true(is.na(derive_hypertension_control_adj(NA, NA, 1)))
  # Edge case tests - boundary with comorbidities
  expect_equal(derive_hypertension_control_adj(139, 89, 1, diab_status = 0), 1)

  # Vector tests
  expect_equal(derive_hypertension_control_adj(c(139, 140), c(89, 89), c(1, 1)), c(1, 2))

  # Database tests
  df <- data.frame(SBP = c(139, 140), DBP = c(89, 89), ANYMED2 = c(1, 1))
  expect_equal(df |> dplyr::mutate(ctrl = derive_hypertension_control_adj(SBP, DBP, ANYMED2)) |> dplyr::pull(ctrl), c(1, 2))
})

# Tagged-NA input propagation tests
# These verify the chained-derivation contract: a tagged NA input from a prior
# step (e.g., adjust_sbp() returning haven::tagged_na("a") for sentinel 996)
# must produce a tagged NA output, not a plain NA or a numeric class.

test_that("derive_hypertension propagates tagged NA input on bpmdpbps", {
  expect_true(haven::is_tagged_na(derive_hypertension(haven::tagged_na("a"), 80, 0)))
  expect_true(haven::is_tagged_na(derive_hypertension(haven::tagged_na("b"), 80, 0)))
})

test_that("derive_hypertension_adj propagates tagged NA input on sbp_adj_mmhg", {
  expect_true(haven::is_tagged_na(derive_hypertension_adj(haven::tagged_na("a"), 80, 0)))
  expect_true(haven::is_tagged_na(derive_hypertension_adj(haven::tagged_na("b"), 80, 0)))
})

test_that("derive_hypertension_control propagates tagged NA input on bpmdpbps", {
  expect_true(haven::is_tagged_na(derive_hypertension_control(haven::tagged_na("a"), 80, 1)))
  expect_true(haven::is_tagged_na(derive_hypertension_control(haven::tagged_na("b"), 80, 1)))
})

test_that("derive_hypertension_control_adj propagates tagged NA input on sbp_adj_mmhg", {
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(haven::tagged_na("a"), 80, 1)))
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(haven::tagged_na("b"), 80, 1)))
})
