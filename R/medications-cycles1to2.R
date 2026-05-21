#' Reduce 80 wide-format ATC/MHR slots into a single tagged-NA aware indicator
#'
#' Internal helper that consolidates the shared body of the eight
#' `is_*_med_cycles1to2()` wrappers. Each wrapper accepts up to 80 named
#' `atc_*`/`mhr_*` arguments (load-bearing for the `DerivedVar::` metadata
#' contract) and reduces them via a scalar predicate (`is_beta_blocker()`,
#' etc.) to produce a per-respondent indicator.
#'
#' Tagged-NA semantics: returns `tagged_na("a")` only when all 80 slots are
#' tagged "a"; returns `tagged_na("b")` when all slots are NA but at least
#' one is tagged "b" or untagged-NA; otherwise the max of valid 0/1 results
#' wins (1 takes precedence over 0).
#'
#' @param predicate [function] A scalar predicate accepting `(meucatc, npi_25b)`
#'   and returning 0/1 or `haven::tagged_na()`.
#' @param atc_args [list] List of ATC code arguments (one per slot, length up to 40).
#' @param mhr_args [list] List of time-last-taken arguments (one per slot, length up to 40).
#' @return [numeric] 1, 0, or `haven::tagged_na()`. Length matches the longest
#'   non-`NULL` input vector (typically 1).
#' @noRd
is_atc_class_cycles1to2 <- function(predicate, atc_args, mhr_args) {
  max_len <- max(lengths(c(atc_args, mhr_args)), 0)
  if (max_len == 0) {
    return(haven::tagged_na("b"))
  }

  atc <- purrr::map(
    atc_args,
    \(x) if (is.null(x)) rep(NA_character_, max_len) else rep(x, length.out = max_len)
  )
  mhr <- purrr::map(
    mhr_args,
    \(x) if (is.null(x)) rep(NA_real_, max_len) else rep(x, length.out = max_len)
  )

  results <- predicate(unlist(atc), unlist(mhr)) |>
    matrix(nrow = max_len)

  has_one <- rowSums(results == 1, na.rm = TRUE) > 0
  has_zero <- rowSums(results == 0, na.rm = TRUE) > 0
  has_na_a <- apply(results, 1, \(r) all(is.na(r)) && any(haven::is_tagged_na(r, "a")))
  has_na_b <- apply(
    results, 1,
    \(r) all(is.na(r)) && (any(haven::is_tagged_na(r, "b")) || any(is.na(r) & !haven::is_tagged_na(r)))
  )

  dplyr::case_when(
    has_one ~ 1,
    has_zero ~ 0,
    has_na_a ~ haven::tagged_na("a"),
    has_na_b ~ haven::tagged_na("b"),
    .default = 0
  )
}

#' @title Beta blockers - cycles 1-2
#'
#' @description This function checks if a person is taking beta blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the respondent is taking beta blockers, 0 otherwise. If all medication information is missing, returns a tagged NA.
#'
#' @details The function identifies beta blockers based on ATC codes starting with "C07", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_beta_blocker` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_beta_blocker` for usage examples.
#' @seealso `is_beta_blocker`
#' @export
is_bb_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_beta_blocker,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title ACE inhibitors - cycles 1-2
#'
#' @description This function checks if a person is taking ACE inhibitors based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking ACE inhibitors, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies ACE inhibitors based on ATC codes starting with "C09". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_ace_inhibitor` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_ace_inhibitor` for usage examples.
#' @seealso `is_ace_inhibitor`
#' @export
is_ace_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_ace_inhibitor,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Diuretics - cycles 1-2
#'
#' @description This function checks if a person is taking diuretics based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking diuretics, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies diuretics based on ATC codes starting with "C03", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_diuretic` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_diuretic` for usage examples.
#' @seealso `is_diuretic`
#' @export
is_diur_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_diuretic,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Calcium channel blockers - cycles 1-2
#'
#' @description This function checks if a person is taking calcium channel blockers based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking calcium channel blockers, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies calcium channel blockers based on ATC codes starting with "C08". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_calcium_channel_blocker` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_calcium_channel_blocker` for usage examples.
#' @seealso `is_calcium_channel_blocker`
#' @export
is_ccb_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_calcium_channel_blocker,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Other anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking another type of anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking another type of anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies other anti-hypertensive drugs based on ATC codes starting with "C02", excluding a specific sub-code. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_other_antihtn_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_other_antihtn_med` for usage examples.
#' @seealso `is_other_antihtn_med`
#' @export
is_misc_htn_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_other_antihtn_med,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Any anti-hypertensive medications - cycles 1-2
#'
#' @description This function checks if a person is taking any anti-hypertensive medication based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking any anti-hypertensive medication, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies anti-hypertensive drugs based on ATC codes starting with "C02", "C03", "C07", "C08", or "C09", excluding specific sub-codes. It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_any_antihtn_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_any_antihtn_med` for usage examples.
#' @seealso `is_any_antihtn_med`
#' @export
is_any_htn_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_any_antihtn_med,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Non-steroidal anti-inflammatory drugs (NSAIDs) - cycles 1-2
#'
#' @description This function checks if a person is taking any NSAIDs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking any NSAIDs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies NSAIDs based on ATC codes starting with "M01A". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_nsaid` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_nsaid` for usage examples.
#' @seealso `is_nsaid`
#' @export
is_nsaid_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_nsaid,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}

#' @title Diabetes medications - cycles 1-2
#'
#' @description This function checks if a person is taking diabetes drugs based on the provided Anatomical Therapeutic Chemical (ATC) codes for medications
#' and the Canadian Health Measures Survey (CHMS) response for the time when the medication was last taken.
#'
#' @param atc_101a [character] ATC code of respondent's first prescription medication.
#' @param atc_102a [character] ATC code of respondent's second prescription medication.
#' @param atc_103a [character] ATC code of respondent's third prescription medication.
#' @param atc_104a [character] ATC code of respondent's fourth prescription medication.
#' @param atc_105a [character] ATC code of respondent's fifth prescription medication.
#' @param atc_106a [character] ATC code of respondent's sixth prescription medication.
#' @param atc_107a [character] ATC code of respondent's seventh prescription medication.
#' @param atc_108a [character] ATC code of respondent's eighth prescription medication.
#' @param atc_109a [character] ATC code of respondent's ninth prescription medication.
#' @param atc_110a [character] ATC code of respondent's tenth prescription medication.
#' @param atc_111a [character] ATC code of respondent's eleventh prescription medication.
#' @param atc_112a [character] ATC code of respondent's twelfth prescription medication.
#' @param atc_113a [character] ATC code of respondent's thirteenth prescription medication.
#' @param atc_114a [character] ATC code of respondent's fourteenth prescription medication.
#' @param atc_115a [character] ATC code of respondent's fifteenth prescription medication.
#' @param atc_201a [character] ATC code of respondent's first over-the-counter medication.
#' @param atc_202a [character] ATC code of respondent's second over-the-counter medication.
#' @param atc_203a [character] ATC code of respondent's third over-the-counter medication.
#' @param atc_204a [character] ATC code of respondent's fourth over-the-counter medication.
#' @param atc_205a [character] ATC code of respondent's fifth over-the-counter medication.
#' @param atc_206a [character] ATC code of respondent's sixth over-the-counter medication.
#' @param atc_207a [character] ATC code of respondent's seventh over-the-counter medication.
#' @param atc_208a [character] ATC code of respondent's eighth over-the-counter medication.
#' @param atc_209a [character] ATC code of respondent's ninth over-the-counter medication.
#' @param atc_210a [character] ATC code of respondent's tenth over-the-counter medication.
#' @param atc_211a [character] ATC code of respondent's eleventh over-the-counter medication.
#' @param atc_212a [character] ATC code of respondent's twelfth over-the-counter medication.
#' @param atc_213a [character] ATC code of respondent's thirteenth over-the-counter medication.
#' @param atc_214a [character] ATC code of respondent's fourteenth over-the-counter medication.
#' @param atc_215a [character] ATC code of respondent's fifteenth over-the-counter medication.
#' @param atc_131a [character] ATC code of respondent's first new prescription medication.
#' @param atc_132a [character] ATC code of respondent's second new prescription medication.
#' @param atc_133a [character] ATC code of respondent's third new prescription medication.
#' @param atc_134a [character] ATC code of respondent's fourth new prescription medication.
#' @param atc_135a [character] ATC code of respondent's fifth new prescription medication.
#' @param atc_231a [character] ATC code of respondent's first new over-the-counter medication.
#' @param atc_232a [character] ATC code of respondent's second new over-the-counter medication.
#' @param atc_233a [character] ATC code of respondent's third new over-the-counter medication.
#' @param atc_234a [character] ATC code of respondent's fourth new over-the-counter medication.
#' @param atc_235a [character] ATC code of respondent's fifth new over-the-counter medication.
#' @param mhr_101b [integer] Response for when the first prescription medication was last taken (1 = Today, …, 6 = Never).
#' @param mhr_102b [integer] Response for when the second prescription medication was last taken (1-6).
#' @param mhr_103b [integer] Response for when the third prescription medication was last taken (1-6).
#' @param mhr_104b [integer] Response for when the fourth prescription medication was last taken (1-6).
#' @param mhr_105b [integer] Response for when the fifth prescription medication was last taken (1-6).
#' @param mhr_106b [integer] Response for when the sixth prescription medication was last taken (1-6).
#' @param mhr_107b [integer] Response for when the seventh prescription medication was last taken (1-6).
#' @param mhr_108b [integer] Response for when the eighth prescription medication was last taken (1-6).
#' @param mhr_109b [integer] Response for when the ninth prescription medication was last taken (1-6).
#' @param mhr_110b [integer] Response for when the tenth prescription medication was last taken (1-6).
#' @param mhr_111b [integer] Response for when the eleventh prescription medication was last taken (1-6).
#' @param mhr_112b [integer] Response for when the twelfth prescription medication was last taken (1-6).
#' @param mhr_113b [integer] Response for when the thirteenth prescription medication was last taken (1-6).
#' @param mhr_114b [integer] Response for when the fourteenth prescription medication was last taken (1-6).
#' @param mhr_115b [integer] Response for when the fifteenth prescription medication was last taken (1-6).
#' @param mhr_201b [integer] Response for when the first over-the-counter medication was last taken (1-6).
#' @param mhr_202b [integer] Response for when the second over-the-counter medication was last taken (1-6).
#' @param mhr_203b [integer] Response for when the third over-the-counter medication was last taken (1-6).
#' @param mhr_204b [integer] Response for when the fourth over-the-counter medication was last taken (1-6).
#' @param mhr_205b [integer] Response for when the fifth over-the-counter medication was last taken (1-6).
#' @param mhr_206b [integer] Response for when the sixth over-the-counter medication was last taken (1-6).
#' @param mhr_207b [integer] Response for when the seventh over-the-counter medication was last taken (1-6).
#' @param mhr_208b [integer] Response for when the eighth over-the-counter medication was last taken (1-6).
#' @param mhr_209b [integer] Response for when the ninth over-the-counter medication was last taken (1-6).
#' @param mhr_210b [integer] Response for when the tenth over-the-counter medication was last taken (1-6).
#' @param mhr_211b [integer] Response for when the eleventh over-the-counter medication was last taken (1-6).
#' @param mhr_212b [integer] Response for when the twelfth over-the-counter medication was last taken (1-6).
#' @param mhr_213b [integer] Response for when the thirteenth over-the-counter medication was last taken (1-6).
#' @param mhr_214b [integer] Response for when the fourteenth over-the-counter medication was last taken (1-6).
#' @param mhr_215b [integer] Response for when the fifteenth over-the-counter medication was last taken (1-6).
#' @param mhr_131b [integer] Response for when the first new prescription medication was last taken (1-6).
#' @param mhr_132b [integer] Response for when the second new prescription medication was last taken (1-6).
#' @param mhr_133b [integer] Response for when the third new prescription medication was last taken (1-6).
#' @param mhr_134b [integer] Response for when the fourth new prescription medication was last taken (1-6).
#' @param mhr_135b [integer] Response for when the fifth new prescription medication was last taken (1-6).
#' @param mhr_231b [integer] Response for when the first new over-the-counter medication was last taken (1-6).
#' @param mhr_232b [integer] Response for when the second new over-the-counter medication was last taken (1-6).
#' @param mhr_233b [integer] Response for when the third new over-the-counter medication was last taken (1-6).
#' @param mhr_234b [integer] Response for when the fourth new over-the-counter medication was last taken (1-6).
#' @param mhr_235b [integer] Response for when the fifth new over-the-counter medication was last taken (1-6).
#'
#' @return [numeric] Returns 1 if the person is taking any diabetes drugs, 0 otherwise. If all medication information is missing, it returns a tagged NA.
#'
#' @details The function identifies diabetes drugs based on ATC codes starting with "A10". It checks all medication variables provided in the input data frame.
#'
#'          **Missing Data Codes:**
#'          - The function handles tagged NAs from the `is_diabetes_med` function and propagates them.
#'
#' @examples
#' # This is a wrapper function and is not intended to be called directly by the user.
#' # See `is_diabetes_med` for usage examples.
#' @seealso `is_diabetes_med`
#' @export
is_diab_med_cycles1to2 <- function(
  atc_101a = NULL, atc_102a = NULL, atc_103a = NULL, atc_104a = NULL, atc_105a = NULL,
  atc_106a = NULL, atc_107a = NULL, atc_108a = NULL, atc_109a = NULL, atc_110a = NULL,
  atc_111a = NULL, atc_112a = NULL, atc_113a = NULL, atc_114a = NULL, atc_115a = NULL,
  atc_201a = NULL, atc_202a = NULL, atc_203a = NULL, atc_204a = NULL, atc_205a = NULL,
  atc_206a = NULL, atc_207a = NULL, atc_208a = NULL, atc_209a = NULL, atc_210a = NULL,
  atc_211a = NULL, atc_212a = NULL, atc_213a = NULL, atc_214a = NULL, atc_215a = NULL,
  atc_131a = NULL, atc_132a = NULL, atc_133a = NULL, atc_134a = NULL, atc_135a = NULL,
  atc_231a = NULL, atc_232a = NULL, atc_233a = NULL, atc_234a = NULL, atc_235a = NULL,
  mhr_101b = NULL, mhr_102b = NULL, mhr_103b = NULL, mhr_104b = NULL, mhr_105b = NULL,
  mhr_106b = NULL, mhr_107b = NULL, mhr_108b = NULL, mhr_109b = NULL, mhr_110b = NULL,
  mhr_111b = NULL, mhr_112b = NULL, mhr_113b = NULL, mhr_114b = NULL, mhr_115b = NULL,
  mhr_201b = NULL, mhr_202b = NULL, mhr_203b = NULL, mhr_204b = NULL, mhr_205b = NULL,
  mhr_206b = NULL, mhr_207b = NULL, mhr_208b = NULL, mhr_209b = NULL, mhr_210b = NULL,
  mhr_211b = NULL, mhr_212b = NULL, mhr_213b = NULL, mhr_214b = NULL, mhr_215b = NULL,
  mhr_131b = NULL, mhr_132b = NULL, mhr_133b = NULL, mhr_134b = NULL, mhr_135b = NULL,
  mhr_231b = NULL, mhr_232b = NULL, mhr_233b = NULL, mhr_234b = NULL, mhr_235b = NULL
) {
  is_atc_class_cycles1to2(
    predicate = is_diabetes_med,
    atc_args = list(
      atc_101a, atc_102a, atc_103a, atc_104a, atc_105a,
      atc_106a, atc_107a, atc_108a, atc_109a, atc_110a,
      atc_111a, atc_112a, atc_113a, atc_114a, atc_115a,
      atc_201a, atc_202a, atc_203a, atc_204a, atc_205a,
      atc_206a, atc_207a, atc_208a, atc_209a, atc_210a,
      atc_211a, atc_212a, atc_213a, atc_214a, atc_215a,
      atc_131a, atc_132a, atc_133a, atc_134a, atc_135a,
      atc_231a, atc_232a, atc_233a, atc_234a, atc_235a
    ),
    mhr_args = list(
      mhr_101b, mhr_102b, mhr_103b, mhr_104b, mhr_105b,
      mhr_106b, mhr_107b, mhr_108b, mhr_109b, mhr_110b,
      mhr_111b, mhr_112b, mhr_113b, mhr_114b, mhr_115b,
      mhr_201b, mhr_202b, mhr_203b, mhr_204b, mhr_205b,
      mhr_206b, mhr_207b, mhr_208b, mhr_209b, mhr_210b,
      mhr_211b, mhr_212b, mhr_213b, mhr_214b, mhr_215b,
      mhr_131b, mhr_132b, mhr_133b, mhr_134b, mhr_135b,
      mhr_231b, mhr_232b, mhr_233b, mhr_234b, mhr_235b
    )
  )
}
