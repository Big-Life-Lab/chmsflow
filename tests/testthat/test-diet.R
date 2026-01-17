# test-diet.R

# Test for find_totalFV_cycles1and2
test_that("find_totalFV_cycles1and2 returns correct daily fruit and vegetable consumption", {
  # General tests
  expect_equal(find_totalFV_cycles1and2(365, 365, 365, 365, 365, 365, 365), 7)
  expect_equal(find_totalFV_cycles1and2(9996, 365, 365, 365, 365, 365, 365), 6)
  expect_equal(find_totalFV_cycles1and2(9997, 365, 365, 365, 365, 365, 365), 6)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(find_totalFV_cycles1and2(-1, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(find_totalFV_cycles1and2(NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_true(!is.na(find_totalFV_cycles1and2(365, 9996, 365, 365, 365, 365, 365))) # One missing
  expect_true(!is.na(find_totalFV_cycles1and2(365, 365, 9997, 365, 365, 365, 365))) # Different missing code
  expect_true(haven::is_tagged_na(find_totalFV_cycles1and2(9996, 9996, 9996, 9996, 9996, 9996, 9996), "b")) # All missing
  expect_equal(find_totalFV_cycles1and2(0, 0, 0, 0, 0, 0, 0), 0) # All zeros

  # Vector tests
  expect_equal(find_totalFV_cycles1and2(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(7, 0))

  # Database tests
  df <- data.frame(V1 = c(365, 0), V2 = c(365, 0), V3 = c(365, 0), V4 = c(365, 0), V5 = c(365, 0), V6 = c(365, 0), V7 = c(365, 0))
  expect_equal(df %>% dplyr::mutate(fv = find_totalFV_cycles1and2(V1, V2, V3, V4, V5, V6, V7)) %>% dplyr::pull(fv), c(7, 0))
})

# Test for find_totalFV_cycles3to6
test_that("find_totalFV_cycles3to6 returns correct daily fruit and vegetable consumption", {
  # General tests
  expect_equal(find_totalFV_cycles3to6(365, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 11)
  expect_equal(find_totalFV_cycles3to6(9996, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)
  expect_equal(find_totalFV_cycles3to6(9997, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), 10)

  # Edge case tests - missing data, invalid inputs, and boundary values
  expect_true(haven::is_tagged_na(find_totalFV_cycles3to6(-1, 365, 365, 365, 365, 365, 365, 365, 365, 365, 365), "b"))
  expect_true(haven::is_tagged_na(find_totalFV_cycles3to6(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA), "b"))
  expect_equal(find_totalFV_cycles3to6(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 0) # All zeros
  expect_true(!is.na(find_totalFV_cycles3to6(365, 9996, 365, 365, 365, 365, 365, 365, 365, 365, 365))) # One missing

  # Vector tests
  expect_equal(find_totalFV_cycles3to6(c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0), c(365, 0)), c(11, 0))

  # Database tests
  df <- data.frame(V1 = c(365), V2 = c(365), V3 = c(365), V4 = c(365), V5 = c(365), V6 = c(365), V7 = c(365), V8 = c(365), V9 = c(365), V10 = c(365), V11 = c(365))
  expect_equal(df %>% dplyr::mutate(fv = find_totalFV_cycles3to6(V1, V2, V3, V4, V5, V6, V7, V8, V9, V10, V11)) %>% dplyr::pull(fv), 11)
})

# Test for determine_gooddiet
test_that("determine_gooddiet returns correct diet category", {
  # General tests
  expect_equal(determine_gooddiet(5), 1)
  expect_equal(determine_gooddiet(4.9), 2)

  # Edge case tests - missing data codes
  expect_true(haven::is_tagged_na(determine_gooddiet(haven::tagged_na("a")), "a"))
  expect_true(haven::is_tagged_na(determine_gooddiet(haven::tagged_na("b")), "b"))
  expect_true(haven::is_tagged_na(determine_gooddiet(-1), "b"))
  expect_true(is.na(determine_gooddiet(NA)))

  # Edge case tests - boundary values
  expect_equal(determine_gooddiet(5.0), 1) # Exactly at threshold
  expect_equal(determine_gooddiet(0), 2) # Zero servings

  # Vector tests
  expect_equal(determine_gooddiet(c(5, 4.9, haven::tagged_na("a"))), c(1, 2, haven::tagged_na("a")))

  # Database tests
  df <- data.frame(fv = c(5, 4.9, 6))
  expect_equal(df %>% dplyr::mutate(diet = determine_gooddiet(fv)) %>% dplyr::pull(diet), c(1, 2, 1))
})
