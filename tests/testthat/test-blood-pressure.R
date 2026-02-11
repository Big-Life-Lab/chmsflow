# test-blood-pressure.R

# Test for adjust_sbp
test_that("adjust_sbp returns correct adjusted systolic blood pressure", {
  expect_equal(adjust_sbp(120), 123)
  expect_true(haven::is_tagged_na(adjust_sbp(996), "a"))
  expect_true(haven::is_tagged_na(adjust_sbp(997), "b"))
  expect_true(haven::is_tagged_na(adjust_sbp(-5), "b"))
  expect_true(is.na(adjust_sbp(NA)))
  expect_equal(adjust_sbp(c(120, 996, -5, NA)), c(123, haven::tagged_na("a"), haven::tagged_na("b"), NA))
})

# Test for adjust_dbp
test_that("adjust_dbp returns correct adjusted diastolic blood pressure", {
  expect_equal(adjust_dbp(80), 82)
  expect_true(haven::is_tagged_na(adjust_dbp(996), "a"))
  expect_true(haven::is_tagged_na(adjust_dbp(997), "b"))
  expect_true(haven::is_tagged_na(adjust_dbp(-5), "b"))
  expect_true(is.na(adjust_dbp(NA)))
  expect_equal(adjust_dbp(c(80, 996, -5, NA)), c(82, haven::tagged_na("a"), haven::tagged_na("b"), NA))
})

# Test for derive_hypertension
test_that("derive_hypertension returns correct hypertension status", {
  expect_equal(derive_hypertension(140, 80, 0), 1)
  expect_equal(derive_hypertension(120, 90, 0), 1)
  expect_equal(derive_hypertension(120, 80, 1), 1)
  expect_equal(derive_hypertension(130, 80, 0, diab_status = 1), 1)
  expect_equal(derive_hypertension(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(derive_hypertension(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension(120, 997, 0), "b"))
  expect_true(is.na(derive_hypertension(NA, NA, 0)))
})

# Test for derive_hypertension_adj
test_that("derive_hypertension_adj returns correct adjusted hypertension status", {
  expect_equal(derive_hypertension_adj(140, 80, 0), 1)
  expect_equal(derive_hypertension_adj(120, 90, 0), 1)
  expect_equal(derive_hypertension_adj(120, 80, 1), 1)
  expect_equal(derive_hypertension_adj(130, 80, 0, diab_status = 1), 1)
  expect_equal(derive_hypertension_adj(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(derive_hypertension_adj(996, 80, 0), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_adj(120, 997, 0), "b"))
  expect_true(is.na(derive_hypertension_adj(NA, NA, 0)))
})

# Test for derive_hypertension_control
test_that("derive_hypertension_control returns correct controlled hypertension status", {
  expect_equal(derive_hypertension_control(139, 89, 1), 1)
  expect_equal(derive_hypertension_control(140, 89, 1), 2)
  expect_equal(derive_hypertension_control(139, 90, 1), 2)
  expect_equal(derive_hypertension_control(129, 79, 1, ccc_32 = 1, diab_status = 1), 1)
  expect_equal(derive_hypertension_control(130, 79, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control(129, 80, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(derive_hypertension_control(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_control(120, 997, 1), "b"))
  expect_true(is.na(derive_hypertension_control(NA, NA, 1)))
})

# Test for derive_hypertension_control_adj
test_that("derive_hypertension_control_adj returns correct controlled adjusted hypertension status", {
  expect_equal(derive_hypertension_control_adj(139, 89, 1), 1)
  expect_equal(derive_hypertension_control_adj(140, 89, 1), 2)
  expect_equal(derive_hypertension_control_adj(139, 90, 1), 2)
  expect_equal(derive_hypertension_control_adj(129, 79, 1, ccc_32 = 1, diab_status = 1), 1)
  expect_equal(derive_hypertension_control_adj(130, 79, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control_adj(129, 80, 1, diab_status = 1), 2)
  expect_equal(derive_hypertension_control_adj(120, 80, 0), 2)
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(996, 80, 1), "a"))
  expect_true(haven::is_tagged_na(derive_hypertension_control_adj(120, 997, 1), "b"))
  expect_true(is.na(derive_hypertension_control_adj(NA, NA, 1)))
})
