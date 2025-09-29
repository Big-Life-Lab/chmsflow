# test-diet.R

# Test for find_totalFV_cycles1and2
test_that("find_totalFV_cycles1and2 returns correct daily fruit and vegetable consumption", {
  expect_equal(find_totalFV_cycles1and2(365, 365, 365, 365, 365, 365, 365), 7)
  expect_equal(find_totalFV_cycles1and2(9996, 365, 365, 365, 365, 365, 365), 6)
  expect_equal(find_totalFV_cycles1and2(9997, 365, 365, 365, 365, 365, 365), 6)
  expect_true(haven::is_tagged_na(find_totalFV_cycles1and2(-1, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(find_totalFV_cycles1and2(NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_equal(find_totalFV_cycles1and2(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(7, 0))
})

# Test for find_totalFV_cycles3to6
test_that("find_totalFV_cycles3to6 returns correct daily fruit and vegetable consumption", {
  expect_equal(find_totalFV_cycles3to6(365, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 11)
  expect_equal(find_totalFV_cycles3to6(9996, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)
  expect_equal(find_totalFV_cycles3to6(9997, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)
  expect_true(haven::is_tagged_na(find_totalFV_cycles3to6(-1, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(find_totalFV_cycles3to6(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_equal(find_totalFV_cycles3to6(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(11, 0))
})

# Test for determine_gooddiet
test_that("determine_gooddiet returns correct diet category", {
  expect_equal(determine_gooddiet(5), 1)
  expect_equal(determine_gooddiet(4.9), 2)
  expect_true(haven::is_tagged_na(determine_gooddiet(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(determine_gooddiet(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(determine_gooddiet(-1), "b"))
  expect_true(is.na(determine_gooddiet(NA)))
  expect_equal(determine_gooddiet(c(5, 4.9, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))
})
