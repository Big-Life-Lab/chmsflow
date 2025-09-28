#' @title Smoking pack-years
#'
#' @description This function calculates an individual's smoking pack-years based on various CHMS smoking variables. Pack years is a measure used by researchers to quantify lifetime exposure to cigarette use.
#'
#' @param SMKDSTY [integer] An integer representing the smoking status of the respondent:
#'   - 1: Daily smoker
#'   - 2: Occasional smoker (former daily)
#'   - 3: Occasional smoker (never daily)
#'   - 4: Former daily smoker (non-smoker now)
#'   - 5: Former occasional smoker (non-smoker now) who smoked at least 100 cigarettes in their lifetime
#'   - 6: Non-smoker (never smoked more than 100 cigarettes)
#' @param CLC_AGE [numeric] A numeric representing the respondent's age.
#' @param SMK_54 [numeric] A numeric representing the respondent's age when they stopped smoking daily.
#' @param SMK_52 [numeric] A numeric representing the respondent's age when they first started smoking daily.
#' @param SMK_31 [integer] An integer representing the number of cigarettes smoked per day for daily smokers.
#' @param SMK_41 [numeric] A numeric representing the number of cigarettes smoked per day for occasional smokers.
#' @param SMK_53 [numeric] A numeric representing the number of cigarettes smoked per day for former daily smokers.
#' @param SMK_42 [numeric] A numeric representing the number of days in past month the respondent smoked at least 1 cigarette (for occasional smokers).
#' @param SMK_21 [numeric] A numeric representing the respondent's age when they first started smoking occasionally.
#' @param SMK_11 [integer] An integer representing whether the respondent has smoked at least 100 cigarettes in their lifetime:
#'   - 1: Yes
#'   - 2: No
#'
#' @return [numeric] A numeric representing the pack years for the respondent's smoking history.
#'   - If `CLC_AGE` is missing or negative, returns `tagged_na("b")`.
#'   - For different smoking statuses (`SMKDSTY`), the function calculates pack years as follows:
#'       - **Daily smoker (1):** `pmax(((CLC_AGE - SMK_52) * (SMK_31 / 20)), 0.0137)`
#'       - **Occasional smoker (former daily) (2):**
#'         `pmax(((CLC_AGE - SMK_52 - (CLC_AGE - SMK_54)) * (SMK_53 / 20)), 0.0137) + ((pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_54))`
#'       - **Occasional smoker (never daily) (3):**
#'         `(pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_21)`
#'       - **Former daily smoker (4):**
#'         `pmax(((SMK_54 - SMK_52) * (SMK_53 / 20)), 0.0137)`
#'       - **Former occasional smoker (5)**:
#'           - If `SMK_11 == 1` (>=100 cigarettes): `0.0137`
#'           - If `SMK_11 == 2` (<100 cigarettes): `0.007`
#'       - **Non-smoker (6):** `0`
#'       - If `SMKDSTY` is `NA(a)`, returns `tagged_na("a")`.
#'       - For all other unexpected inputs, returns `tagged_na("b")`.
#'
#' @examples
#' # Scalar usage: Single respondent
#' # A former occasional smoker who smoked at least 100 cigarettes in their lifetime.
#' pack_years_fun(
#'   SMKDSTY = 5, CLC_AGE = 50, SMK_54 = 40, SMK_52 = 18, SMK_31 = NA,
#'   SMK_41 = 15, SMK_53 = NA, SMK_42 = 3, SMK_21 = 25, SMK_11 = 1
#' )
#' # Output: 0.0137 (pack years)
#'
#' # Example: Respondent has non-response values for all inputs.
#' pack_years_fun(
#'   SMKDSTY = 98, CLC_AGE = 998, SMK_54 = 98, SMK_52 = 98, SMK_31 = 98,
#'   SMK_41 = 98, SMK_53 = 98, SMK_42 = 98, SMK_21 = 98, SMK_11 = 8
#' )
#' # Output: NA
#'
#' # Multiple respondents
#' pack_years_fun(
#'   SMKDSTY = c(1, 5, 6),
#'   CLC_AGE = c(40, 50, 60),
#'   SMK_52 = c(20, 18, NA),
#'   SMK_31 = c(30, NA, NA),
#'   SMK_54 = c(NA, 40, NA),
#'   SMK_41 = c(NA, 15, NA),
#'   SMK_53 = c(NA, NA, NA),
#'   SMK_42 = c(NA, 3, NA),
#'   SMK_21 = c(NA, 25, NA),
#'   SMK_11 = c(NA, 1, NA)
#' )
#' # Returns: c(30, 0.0137, 0)
#'
#' @export
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
#'          **Clinical Significance:**
#'          Pack-years data is crucial for lung cancer screening guidelines, COPD risk
#'          assessment, and cardiovascular disease evaluation.
#'
#' @seealso https://big-life-lab.github.io/cchsflow/reference/pack_years_fun.html
#' @references Guidelines for lung cancer screening and smoking cessation programs
#' @keywords survey health smoking tobacco substance-use epidemiology
pack_years_fun <- function(SMKDSTY, CLC_AGE, SMK_54, SMK_52, SMK_31, SMK_41, SMK_53, SMK_42, SMK_21, SMK_11) {
  pack_years <- dplyr::case_when(
    CLC_AGE == 96 ~ haven::tagged_na("a"),
    CLC_AGE < 0 | CLC_AGE %in% 97:99 ~ haven::tagged_na("b"),
    SMKDSTY == 1 ~ pmax(((CLC_AGE - SMK_52) * (SMK_31 / 20)), 0.0137),
    SMKDSTY == 2 ~ pmax(((CLC_AGE - SMK_52 - (CLC_AGE - SMK_54)) * (SMK_53 / 20)), 0.0137) +
      ((pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_54)),
    SMKDSTY == 3 ~ (pmax((SMK_41 * SMK_42 / 30), 1) / 20) * (CLC_AGE - SMK_21),
    SMKDSTY == 4 ~ pmax(((SMK_54 - SMK_52) * (SMK_53 / 20)), 0.0137),
    SMKDSTY == 5 & SMK_11 == 1 ~ 0.0137,
    SMKDSTY == 5 & SMK_11 == 2 ~ 0.007,
    SMKDSTY == 6 ~ 0,
    SMKDSTY == 96 ~ haven::tagged_na("a"),
    SMKDSTY %in% 97:99 ~ haven::tagged_na("b"),
    .default = haven::tagged_na("b")
  )
  return(pack_years)
}
