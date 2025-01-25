# test-smoking.R
test_that("Correct calculation for SMKDSTY 1", {
  expect_equal(
    pack_years_fun(SMKDSTY = 1, CLC_AGE = 30, SMK_52 = 20, SMK_31 = 20),
    10
  )
})

test_that("pack_years calculation is correct for valid inputs", {
  # SMKDSTY = 1 Daily smoker: one pack/day), 20 years smoking (from age 20 to age 30)
  expect_equal(pack_years_fun(SMKDSTY = 1, CLC_AGE = 30, SMK_52 = 20, SMK_31 = 20), 10)

  # SMKDSTY = 2 Occasional smoker (former daily): 5 cigarettes a day, 5 days per month, started smoking age 15 and stopped age 40 years
  expect_equal(pack_years_fun(SMKDSTY = 5, CLC_AGE = 50, SMKDSTP = 20, SMK_52 = 10, SMK_41 = 5, SMK_23 = 4, SMK_21 = 25, SMK_11 = 1), 0.0137)
})
