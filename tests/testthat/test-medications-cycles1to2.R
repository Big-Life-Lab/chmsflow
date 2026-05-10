# test-medications-cycles1to2.R

# Test for is_bb_med_cycles1to2
test_that("is_bb_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 1), 1)

  # Non-match (excluded beta blocker)
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA07", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_bb_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_bb_med_cycles1to2(atc_201a = "C07AB02", mhr_201b = 2), 1)

  # Not taken recently (last_taken > 4) - returns 0 because other NULL slots pad to valid non-matches
  expect_equal(is_bb_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_bb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AB02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_bb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_ace_med_cycles1to2
test_that("is_ace_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C08AA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_ace_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_ace_med_cycles1to2(atc_201a = "C09BB05", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_ace_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_ace_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09BB05", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_ace_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_diur_med_cycles1to2
test_that("is_diur_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 1), 1)

  # Non-match (excluded diuretic)
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03BA08", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_diur_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_diur_med_cycles1to2(atc_201a = "C03DA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_diur_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_diur_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C03AA03", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_diur_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_ccb_med_cycles1to2
test_that("is_ccb_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C07CA01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_ccb_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_ccb_med_cycles1to2(atc_201a = "C08DA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_ccb_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_ccb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C08CA01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_ccb_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_misc_htn_med_cycles1to2
test_that("is_misc_htn_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 1), 1)

  # Non-match (excluded misc antihypertensive)
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02KX01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_misc_htn_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_misc_htn_med_cycles1to2(atc_201a = "C02CA01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_misc_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_misc_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C02AB01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_misc_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_any_htn_med_cycles1to2
test_that("is_any_htn_med_cycles1to2 returns correct values", {
  # Matches each antihypertensive class
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C09AA02", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C03AA03", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C08CA01", mhr_101b = 1), 1)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C02AB01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_any_htn_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_any_htn_med_cycles1to2(atc_201a = "C07AB02", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_any_htn_med_cycles1to2(atc_101a = "C07AA05", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_any_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_any_htn_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "M01AE01", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_nsaid_med_cycles1to2
test_that("is_nsaid_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M01AE01", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M02AA01", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_nsaid_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_nsaid_med_cycles1to2(atc_201a = "M01AB05", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_nsaid_med_cycles1to2(atc_101a = "M01AE01", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_nsaid_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "M01AE01", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_nsaid_med_cycles1to2(atc_101a = "A10BA02", atc_102a = "C07AA05", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

# Test for is_diab_med_cycles1to2
test_that("is_diab_med_cycles1to2 returns correct values", {
  # Match in first prescription slot
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 1), 1)

  # Non-match
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A09AA02", mhr_101b = 1), 0)

  # All NULL returns tagged NA "b"
  expect_true(haven::is_tagged_na(is_diab_med_cycles1to2(), "b"))

  # Match in OTC slot
  expect_equal(is_diab_med_cycles1to2(atc_201a = "A10BB01", mhr_201b = 1), 1)

  # Not taken recently (last_taken > 4)
  expect_equal(is_diab_med_cycles1to2(atc_101a = "A10BA02", mhr_101b = 6), 0)

  # Multiple slots, one match
  expect_equal(
    is_diab_med_cycles1to2(atc_101a = "C07AA05", atc_102a = "A10BA02", mhr_101b = 1, mhr_102b = 1),
    1
  )

  # Multiple slots, no match
  expect_equal(
    is_diab_med_cycles1to2(atc_101a = "C07AA05", atc_102a = "C09AA02", mhr_101b = 1, mhr_102b = 1),
    0
  )
})

