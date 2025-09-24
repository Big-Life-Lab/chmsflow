#' @title Adjusted total household income
#'
#' @description This function calculates the adjusted total household income based on the respondent's income amount
#'              and actual household size, taking into account the weighted household size.
#'
#' @param THI_01 [numeric] A numeric representing the respondent's household income amount in dollars.
#' @param DHHDHSZ [integer] An integer representing the respondent's actual household size in persons.
#'
#' @return [numeric] The calculated adjusted total household income as a numeric. If any of the input parameters (THI_01,
#'         DHHDHSZ) are non-response values (THI_01 >= 996, DHHDHSZ >= 996), the adjusted household income will be
#'         NA(b) (Not Available).
#'
#' @details This function applies equivalence scales to adjust household income for household size,
#'          allowing for meaningful income comparisons across different household compositions.
#'
#'          **Equivalence Scale Logic:**
#'          - First adult: Weight = 1.0 (full weight)
#'          - Second adult: Weight = 0.4 (economies of scale)
#'          - Additional members: Weight = 0.3 each (further economies)
#'
#'          **Examples:**
#'          - Single person: weight = 1.0
#'          - Two adults: weight = 1.4 (1.0 + 0.4)
#'          - Family of four: weight = 2.0 (1.0 + 0.4 + 0.3 + 0.3)
#'
#'          **Non-response Handling:**
#'          Income values >= 996 or household size <= 0 indicate survey non-response and result in tagged NA ("b").
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Respondent with $50,000 income and a household size of 3.
#' calculate_hhld_income(THI_01 = 50000, DHHDHSZ = 3)
#' # Output: 29411.76
#'
#' # Example 2: Respondent with $75000 income and a household size of 2.
#' calculate_hhld_income(THI_01 = 75000, DHHDHSZ = 2)
#' # Output: 53571.43
#'
#' # Example 3: Respondent with $90000 income and a household size of 1.
#' calculate_hhld_income(THI_01 = 90000, DHHDHSZ = 1)
#' # Output: 90000
#'
#' # Example 4: Respondent has non-response values for all inputs.
#' calculate_hhld_income(THI_01 = 99999998, DHHDHSZ = 98)
#' # Output: NA
#'
#' # Multiple respondents
#' calculate_hhld_income(THI_01 = c(50000, 75000, 90000), DHHDHSZ = c(3, 2, 1))
#' # Returns: c(29411.76, 53571.43, 90000)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(adj_hh_income = calculate_hhld_income(THI_01, DHHDHSZ))
#'
#' @seealso [categorize_income()] for income classification, [in_lowest_income_quintile()] for poverty indicators
#' @references OECD equivalence scales for income adjustment
#' @keywords survey socioeconomic income household demographics
#' @export
calculate_hhld_income <- function(THI_01, DHHDHSZ) {
  hh_size_wt <- sapply(DHHDHSZ, function(size) {
    if (is.na(size) || size <= 0) {
      return(NA)
    } else if (size == 1) {
      return(1)
    } else if (size == 2) {
      return(1 + 0.4)
    } else {
      return(1 + 0.4 + (size - 2) * 0.3)
    }
  })

  adj_hh_inc <- THI_01 / hh_size_wt

  dplyr::case_when(
    (THI_01 >= 99999996) | (DHHDHSZ >= 96) ~ haven::tagged_na("b"),
    is.na(adj_hh_inc) | adj_hh_inc < 0 ~ haven::tagged_na("b"),
    TRUE ~ adj_hh_inc
  )
}

#' @title Categorical adjusted household income
#'
#' @description This function categorizes individuals' adjusted household income based on specified income ranges.
#'
#' @param adj_hh_inc [numeric] A numeric representing the adjusted household income.
#'
#' @return [integer] The income category:
#'   - 1: Below or equal to $21,500
#'   - 2: Above $21,500 and up to $35,000
#'   - 3: Above $35,000 and up to $50,000
#'   - 4: Above $50,000 and up to $70,000
#'   - 5: Above $70,000
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Categorize a household income of $25,000
#' categorize_income(25000)
#' # Output: 2
#'
#' # Example 2: Categorize a household income of $45,000
#' categorize_income(45000)
#' # Output: 3
#'
#' # Multiple respondents
#' categorize_income(c(25000, 45000, 80000))
#' # Returns: c(2, 3, 5)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(income_category = categorize_income(adj_hh_income))
#'
#' @export
categorize_income <- function(adj_hh_inc) {
  dplyr::case_when(
    is.na(adj_hh_inc) | adj_hh_inc < 0 ~ haven::tagged_na("b"),
    adj_hh_inc <= 21500 ~ 1,
    adj_hh_inc > 21500 & adj_hh_inc <= 35000 ~ 2,
    adj_hh_inc > 35000 & adj_hh_inc <= 50000 ~ 3,
    adj_hh_inc > 50000 & adj_hh_inc <= 70000 ~ 4,
    adj_hh_inc > 70000 ~ 5,
    .default = haven::tagged_na("b")
  )
}

#' @title Lowest income quintile indicator
#'
#' @description This function checks if an individual's income category corresponds to the lowest income quintile.
#'
#' @param incq [integer] A categorical vector indicating the income category as defined by the categorize_income function.
#'
#' @return [integer] Whether the individual is in the lowest income quintile:
#'   - 1: In the lowest income quntile
#'   - 2: Not in the lowest income quntile
#'   - NA(b): Missing or invalid input
#'
#' @examples
#' # Scalar usage: Single respondent
#' # Example 1: Check if an income category of 3 (between $35,000-50,000) is in the lowest quintile
#' in_lowest_income_quintile(3)
#' # Output: 2
#'
#' # Example 2: Check if an income category of 1 (below or equal to $21,500) is in the lowest quintile
#' in_lowest_income_quintile(1)
#' # Output: 1
#'
#' # Multiple respondents
#' in_lowest_income_quintile(c(3, 1, 5))
#' # Returns: c(2, 1, 2)
#'
#' # Database usage: Applied to survey datasets
#' library(dplyr)
#' # dataset %>%
#' #   mutate(in_lowest_quintile = in_lowest_income_quintile(income_category))
#'
#' @export
in_lowest_income_quintile <- function(incq) {
  dplyr::case_when(
    is.na(incq) | incq < 0 | incq == "NA(b)" ~ haven::tagged_na("b"),
    incq == 1 ~ 1,
    TRUE ~ 2
  )
}
