# test-income.R
# Test for find_totalFV_cycles1and2
test_that("find_totalFV_cycles1and2 calculates average daily FV consumption correctly", {
  # Normal cases
  expect_equal(
    find_totalFV_cycles1and2(50, 150, 200, 100, 80, 120, 90),
    (50 + 150 + 200 + 100 + 80 + 120 + 90) / 365
  )

  expect_equal(
    find_totalFV_cycles1and2(0, 0, 0, 0, 0, 0, 0),
    0
  )

  # Cases with missing values
  expect_equal(
    find_totalFV_cycles1and2(50, NA, 200, 100, 80, NA, 90),
    (50 + 200 + 100 + 80 + 90) / 365
  )

  expect_equal(
    find_totalFV_cycles1and2(NA, NA, NA, NA, NA, NA, NA),
    haven::tagged_na("b")
  )
})

# Test for find_totalFV_cycles3to6
test_that("find_totalFV_cycles3to6 calculates average daily FV consumption correctly", {
  # Normal cases
  expect_equal(
    find_totalFV_cycles3to6(50, 100, 150, 80, 40, 200, 100, 80, 60, 120, 90),
    (50 + 100 + 150 + 80 + 40 + 200 + 100 + 80 + 60 + 120 + 90) / 365
  )

  expect_equal(
    find_totalFV_cycles3to6(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
    0
  )

  # Cases with missing values
  expect_equal(
    find_totalFV_cycles3to6(50, 100, NA, 80, 40, 200, 100, NA, 60, NA, 90),
    (50 + 100 + 80 + 40 + 200 + 100 + 60 + 90) / 365
  )

  expect_equal(
    find_totalFV_cycles3to6(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA),
    haven::tagged_na("b")
  )
})

# Test for determine_gooddiet
test_that("determine_gooddiet categorizes diet correctly", {
  # Good diet
  expect_equal(determine_gooddiet(5), 1)
  expect_equal(determine_gooddiet(7), 1)
  expect_equal(determine_gooddiet(10), 1)

  # Poor diet
  expect_equal(determine_gooddiet(4.99), 2)
  expect_equal(determine_gooddiet(3), 2)
  expect_equal(determine_gooddiet(0), 2)

  # Missing input
  expect_equal(determine_gooddiet(NA), haven::tagged_na("b"))
})
