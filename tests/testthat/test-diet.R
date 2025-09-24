# test-diet.R
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

  # Non-response values
  expect_true(is.na(find_totalFV_cycles1and2(9998, 9998, 9998, 9998, 9998, 9998, 9998)))

  # Vector usage
  expect_equal(
    find_totalFV_cycles1and2(
      WSDD14Y = c(50, 60, NA),
      GFVD17Y = c(150, 160, NA),
      GFVD18Y = c(200, 210, NA),
      GFVD19Y = c(100, 110, NA),
      GFVD20Y = c(80, 90, NA),
      GFVD22Y = c(120, 130, NA),
      GFVD23Y = c(90, 100, NA)
    ),
    c(2.16438356164384, 2.35616438356164, haven::tagged_na("b"))
  )

  # Database usage (simulated)
  df_fv12 <- data.frame(
    WSDD14Y = c(50, 60, NA),
    GFVD17Y = c(150, 160, NA),
    GFVD18Y = c(200, 210, NA),
    GFVD19Y = c(100, 110, NA),
    GFVD20Y = c(80, 90, NA),
    GFVD22Y = c(120, 130, NA),
    GFVD23Y = c(90, 100, NA)
  )
  expected_output_fv12 <- c(2.16438356164384, 2.35616438356164, haven::tagged_na("b"))
  expect_equal(df_fv12 %>% dplyr::mutate(total_fv = find_totalFV_cycles1and2(WSDD14Y, GFVD17Y, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y)) %>% dplyr::pull(total_fv), expected_output_fv12)
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

  # Non-response values
  expect_true(is.na(find_totalFV_cycles3to6(9998, 9998, 9998, 9998, 9998, 9998, 9998, 9998, 9998, 9998, 9998)))

  # Vector usage
  expect_equal(
    find_totalFV_cycles3to6(
      WSDD34Y = c(50, 60, NA),
      WSDD35Y = c(100, 110, NA),
      GFVD17AY = c(150, 160, NA),
      GFVD17BY = c(80, 90, NA),
      GFVD17CY = c(40, 50, NA),
      GFVD17DY = c(200, 210, NA),
      GFVD18Y = c(100, 110, NA),
      GFVD19Y = c(80, 90, NA),
      GFVD20Y = c(60, 70, NA),
      GFVD22Y = c(120, 130, NA),
      GFVD23Y = c(90, 100, NA)
    ),
    c(2.93150684931507, 3.23287671232877, haven::tagged_na("b"))
  )

  # Database usage (simulated)
  df_fv36 <- data.frame(
    WSDD34Y = c(50, 60, NA),
    WSDD35Y = c(100, 110, NA),
    GFVD17AY = c(150, 160, NA),
    GFVD17BY = c(80, 90, NA),
    GFVD17CY = c(40, 50, NA),
    GFVD17DY = c(200, 210, NA),
    GFVD18Y = c(100, 110, NA),
    GFVD19Y = c(80, 90, NA),
    GFVD20Y = c(60, 70, NA),
    GFVD22Y = c(120, 130, NA),
    GFVD23Y = c(90, 100, NA)
  )
  expected_output_fv36 <- c(2.93150684931507, 3.23287671232877, haven::tagged_na("b"))
  expect_equal(df_fv36 %>% dplyr::mutate(total_fv = find_totalFV_cycles3to6(WSDD34Y, WSDD35Y, GFVD17AY, GFVD17BY, GFVD17CY, GFVD17DY, GFVD18Y, GFVD19Y, GFVD20Y, GFVD22Y, GFVD23Y)) %>% dplyr::pull(total_fv), expected_output_fv36)
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

  # Vector usage
  expect_equal(determine_gooddiet(c(3, 7, 5, NA, -1)), c(2, 1, 1, haven::tagged_na("b"), haven::tagged_na("b")))

  # Database usage (simulated)
  df_diet <- data.frame(
    totalFV = c(3, 7, 5, NA, -1)
  )
  expected_output_diet <- c(2, 1, 1, haven::tagged_na("b"), haven::tagged_na("b"))
  expect_equal(df_diet %>% dplyr::mutate(diet_quality = determine_gooddiet(totalFV)) %>% dplyr::pull(diet_quality), expected_output_diet)
})

test_that("find_totalFV_cycles1and2 handles negative inputs", {
  expect_equal(find_totalFV_cycles1and2(-10, 150, 200, 100, 80, 120, 90), haven::tagged_na("b"))
})

test_that("find_totalFV_cycles3to6 handles negative inputs", {
  expect_equal(find_totalFV_cycles3to6(-10, 100, 150, 80, 40, 200, 100, 80, 60, 120, 90), haven::tagged_na("b"))
})

test_that("determine_gooddiet handles negative inputs", {
  expect_equal(determine_gooddiet(-1), haven::tagged_na("b"))
})
