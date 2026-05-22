#' @title Smoking pack-years
#'
#' @description This function calculates an individual's smoking pack-years based on various CHMS smoking variables. Pack years is a measure used by researchers to quantify lifetime exposure to cigarette use.
#'
#' @param smkdsty [integer] An integer representing the smoking status of the respondent.
#' @param clc_age [numeric] A numeric representing the respondent's age.
#' @param smk_54 [numeric] A numeric representing the respondent's age when they stopped smoking daily.
#' @param smk_52 [numeric] A numeric representing the respondent's age when they first started smoking daily.
#' @param smk_31 [integer] An integer representing the number of cigarettes smoked per day for daily smokers.
#' @param smk_41 [numeric] A numeric representing the number of cigarettes smoked per day for occasional smokers.
#' @param smk_53 [numeric] A numeric representing the number of cigarettes smoked per day for former daily smokers.
#' @param smk_42 [numeric] A numeric representing the number of days in past month the respondent smoked at least 1 cigarette (for occasional smokers).
#' @param smk_21 [numeric] A numeric representing the respondent's age when they first started smoking occasionally.
#' @param smk_11 [integer] An integer representing whether the respondent has smoked at least 100 cigarettes in their lifetime.
#'
#' @return [numeric] A numeric representing the pack years for the respondent's smoking history. If inputs are invalid or out of bounds, the function returns a tagged NA.
#'
#' @details Pack-years is a standardized measure of lifetime cigarette exposure used in epidemiological
#'          research and clinical practice. The calculation varies by smoking pattern:
#'
#'          **Smoking Patterns:**
#'          - Daily smokers: Consistent daily consumption over time period
#'          - Occasional smokers: Variable consumption adjusted for frequency
#'          - Former smokers: Historical consumption during smoking periods
#'
#'          **Minimum Values:**
#'          The function applies minimum pack-year values (0.0137 or 0.007) to prevent
#'          underestimation of health risks for light smokers.
#'
#'          **Missing Data Codes:**
#'          - `smkdsty`: `96` (Not applicable), `97-99` (Missing)
#'          - `clc_age`: `96` (Not applicable), `97-99` (Missing)
#'          - Other variables: Handled within the formula logic.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # A former occasional smoker who smoked at least 100 cigarettes in their lifetime.
#' calculate_pack_years(
#'   smkdsty = 5, clc_age = 50, smk_54 = 40, smk_52 = 18, smk_31 = NA,
#'   smk_41 = 15, smk_53 = NA, smk_42 = 3, smk_21 = 25, smk_11 = 1
#' )
#' # Output: 0.0137
#'
#' # Example: Respondent has non-response values for all inputs.
#' result <- calculate_pack_years(
#'   smkdsty = 98, clc_age = 998, smk_54 = 98, smk_52 = 98, smk_31 = 98,
#'   smk_41 = 98, smk_53 = 98, smk_42 = 98, smk_21 = 98, smk_11 = 8
#' )
#' result # Shows: NA
#' haven::is_tagged_na(result, "b") # Shows: TRUE (confirms it's tagged NA(b))
#' format(result, tag = TRUE) # Shows: "NA(b)" (displays the tag)
#'
#' # Multiple respondents
#' calculate_pack_years(
#'   smkdsty = c(1, 5, 6),
#'   clc_age = c(40, 50, 60),
#'   smk_52 = c(20, 18, NA),
#'   smk_31 = c(30, NA, NA),
#'   smk_54 = c(NA, 40, NA),
#'   smk_41 = c(NA, 15, NA),
#'   smk_53 = c(NA, NA, NA),
#'   smk_42 = c(NA, 3, NA),
#'   smk_21 = c(NA, 25, NA),
#'   smk_11 = c(NA, 1, NA)
#' )
#' # Returns: c(30, 0.0137, 0)
#'
#' # Database usage: Applied to survey datasets
#' # library(dplyr)
#' # dataset |>
#' #   mutate(pack_years = calculate_pack_years(smkdsty, clc_age, smk_54, smk_52,
#' #     smk_31, smk_41, smk_53, smk_42, smk_21, smk_11))
#'
#' @seealso https://big-life-lab.github.io/cchsflow/reference/calculate_pack_years.html
#' @export
calculate_pack_years <- function(smkdsty, clc_age, smk_54, smk_52, smk_31, smk_41, smk_53, smk_42, smk_21, smk_11) {
  # Calculate pack years based on smoking status
  pack_years <- dplyr::case_when(
    # Age
    # Valid skip
    clc_age == 96 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    clc_age < 0 | clc_age %in% 97:99 ~ haven::tagged_na("b"),

    # Calculate pack years for each smoking status
    smkdsty == 1 ~ pmax(((clc_age - smk_52) * (smk_31 / 20)), 0.0137),
    smkdsty == 2 ~ pmax(((clc_age - smk_52 - (clc_age - smk_54)) * (smk_53 / 20)), 0.0137) +
      ((pmax((smk_41 * smk_42 / 30), 1) / 20) * (clc_age - smk_54)),
    smkdsty == 3 ~ (pmax((smk_41 * smk_42 / 30), 1) / 20) * (clc_age - smk_21),
    smkdsty == 4 ~ pmax(((smk_54 - smk_52) * (smk_53 / 20)), 0.0137),
    smkdsty == 5 & smk_11 == 1 ~ 0.0137,
    smkdsty == 5 & smk_11 == 2 ~ 0.007,
    smkdsty == 6 ~ 0,

    # Smoking status
    # Valid skip
    smkdsty == 96 ~ haven::tagged_na("a"),
    # Don't know, refusal, not stated
    smkdsty %in% 97:99 ~ haven::tagged_na("b"),

    # Default to missing if no other condition is met
    .default = haven::tagged_na("b")
  )
  return(pack_years)
}
