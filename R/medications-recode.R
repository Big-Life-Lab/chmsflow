#' Identify variable_details rows whose databaseStart entries are all `_meds` databases
#'
#' Internal helper for [recode_after_meds()]. The previous `grepl("_meds", ...)` was an
#' unanchored substring match: a future databaseStart like `non_meds_cohort` or
#' `_medstudy` would be silently dropped. This helper splits databaseStart by comma and
#' returns TRUE only when every token ends in `_meds`, so mixed rows (e.g. a `copy` row
#' covering `cycle1, cycle2_meds`) are kept.
#'
#' @param database_start Character vector of databaseStart entries, e.g.
#'   `c("cycle1_meds, cycle2_meds", "cycle1, cycle2")`.
#' @return Logical vector, same length as `database_start`.
#' @noRd
is_meds_only_database <- function(database_start) {
  vapply(
    strsplit(as.character(database_start), ",\\s*"),
    function(tokens) length(tokens) > 0 && all(grepl("_meds$", trimws(tokens))),
    logical(1)
  )
}

#' Stop if a database name does not appear in any variable_details databaseStart entry
#'
#' Internal helper. When wrapper functions derive `database_name` /
#' `meds_database_name` via `deparse(substitute())`, an unrecognised name causes
#' `rec_with_table()` to return silent NAs. This helper raises an actionable error
#' pointing the user to the explicit-override argument.
#'
#' @noRd
validate_database_name <- function(database_name, variable_details, override_arg) {
  db_starts <- strsplit(as.character(variable_details$databaseStart), ",\\s*")
  matches <- vapply(db_starts, function(x) database_name %in% trimws(x), logical(1))
  if (!any(matches)) {
    stop(sprintf(
      "No rows in `variable_details` have `databaseStart` matching '%s'. The name was inferred from the calling argument; pass `%s = '<name>'` explicitly to override (e.g. `%s = 'cycle1_meds'`).",
      database_name, override_arg, override_arg
    ), call. = FALSE)
  }
  invisible(NULL)
}

#' Validate join keys between main cycle data and recoded medication data
#'
#' Internal helper for [recode_meds_cycles1to2()] and [recode_meds_cycles3to6()].
#' `dplyr::left_join` silently fans out duplicate keys, silently leaves untagged NA
#' for missing keys, and silently drops keys present only on the right. This helper
#' makes all three audible: stop on duplicate keys (never valid in CHMS), warn with
#' counts on asymmetric coverage.
#'
#' @noRd
check_join_keys <- function(data, target, by, target_label) {
  target_keys <- target[[by]]
  if (any(duplicated(target_keys))) {
    stop(sprintf(
      "%d duplicate `%s` value(s) in %s; refusing to left_join to prevent silent row fan-out into `data`.",
      sum(duplicated(target_keys)), by, target_label
    ), call. = FALSE)
  }
  missing_in_target <- setdiff(data[[by]], target_keys)
  if (length(missing_in_target) > 0) {
    warning(sprintf(
      "%d respondent(s) in `data` not found in %s; medication columns will be NA.",
      length(missing_in_target), target_label
    ), call. = FALSE)
  }
  missing_in_data <- setdiff(target_keys, data[[by]])
  if (length(missing_in_data) > 0) {
    warning(sprintf(
      "%d respondent(s) in %s not found in `data`; rows will be dropped from result.",
      length(missing_in_data), target_label
    ), call. = FALSE)
  }
  invisible(NULL)
}

#' Convert a recoded factor or character to numeric while preserving tagged NAs
#'
#' Internal helper used by [recode_meds_cycles1to2()] and [aggregate_meds_by_person()].
#' `as.numeric(as.character(.x))` strips `haven::tagged_na()` information, collapsing
#' valid skips (`NA::a`) and missing/refused (`NA::b`) into plain `NA_real_`. This
#' helper restores those tags so downstream consumers (e.g. `derive_hypertension()`
#' checking `is_tagged_na(any_htn_med, "b")`) behave correctly.
#'
#' @param x A factor, character, or numeric vector. Tagged-NA inputs are preserved.
#' @return Numeric vector with `tagged_na("a")` / `tagged_na("b")` restored where present.
#' @noRd
factor_to_tagged_numeric <- function(x) {
  was_a <- if (is.numeric(x)) haven::is_tagged_na(x, "a") else rep(FALSE, length(x))
  was_b <- if (is.numeric(x)) haven::is_tagged_na(x, "b") else rep(FALSE, length(x))

  s <- as.character(x)
  out <- suppressWarnings(as.numeric(s))

  not_na_s <- !is.na(s)
  out[not_na_s & s == "NA::a"] <- haven::tagged_na("a")
  out[not_na_s & s == "NA::b"] <- haven::tagged_na("b")

  out[was_a] <- haven::tagged_na("a")
  out[was_b] <- haven::tagged_na("b")

  out
}

#' @title Recode medication variables for cycles 1-2 (wide format)
#'
#' @description Recodes medication variables from cycles 1-2 wide-format data (one row per
#' respondent, up to 80 ATC/MHR columns), and merges into the main cycle dataset. Wraps
#' `recodeflow::rec_with_table()` and converts factor outputs to numeric.
#'
#' @param data [data.frame] Main cycle data to merge medication variables into.
#' @param meds_data [data.frame] Wide-format medication data (cycles 1-2). Must contain
#'   `clinicid`, ATC code columns `atc_101a`-`atc_115a`, `atc_131a`-`atc_135a`,
#'   `atc_201a`-`atc_215a`, `atc_231a`-`atc_235a`, and matching time-last-taken columns
#'   `mhr_101b`-`mhr_115b`, `mhr_131b`-`mhr_135b`, `mhr_201b`-`mhr_215b`,
#'   `mhr_231b`-`mhr_235b`. Column names are normalized to lowercase before recoding,
#'   so uppercase variants (e.g., `CLINICID`, `ATC_101A`) are accepted.
#' @param variables [character] Medication variable names to derive (e.g., `"any_htn_med"`).
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param meds_database_name [character] Name of the meds database in `variable_details`.
#'   Defaults to the name of the `meds_data` argument. Override when passing a transformed
#'   object (e.g., `head()`).
#' @param variable_details [data.frame] Variable details table. Defaults to `chmsflow::variable_details`.
#'
#' @return [data.frame] `data` with derived medication variables merged in as numeric columns.
#'
#' @examples
#' result <- recode_meds_cycles1to2(
#'   cycle1,
#'   cycle1_meds,
#'   c("any_htn_med", "diab_med")
#' )
#' head(result[, c("clinicid", "any_htn_med", "diab_med")])
#'
#' @seealso [recode_meds_cycles3to6()], [aggregate_meds_by_person()]
#' @export
recode_meds_cycles1to2 <- function(data, meds_data, variables, by = "clinicid",
                                   meds_database_name = NULL,
                                   variable_details = chmsflow::variable_details) {
  if (is.null(meds_database_name)) meds_database_name <- deparse(substitute(meds_data))
  validate_database_name(meds_database_name, variable_details, "meds_database_name")
  meds_data <- dplyr::rename_with(meds_data, tolower)
  atc_mhr_cols <- c(
    paste0("atc_", c(101:115, 131:135, 201:215, 231:235), "a"),
    paste0("mhr_", c(101:115, 131:135, 201:215, 231:235), "b")
  )
  meds_recoded <- recodeflow::rec_with_table(
    meds_data,
    c(by, atc_mhr_cols, variables),
    database_name = meds_database_name,
    variable_details = variable_details
  ) |>
    dplyr::select(dplyr::all_of(c(by, variables))) |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(variables),
      ~ factor_to_tagged_numeric(.x)
    ))
  check_join_keys(data, meds_recoded, by, "meds_data")
  dplyr::left_join(data, meds_recoded, by = by)
}

#' @title Aggregate medication variables to one row per person
#'
#' @description Collapses long-format medication data (cycles 3-6) to one row per respondent
#' by taking the maximum value of each medication variable across all rows. A result of 1
#' (taking the medication) takes precedence over 0. Tagged NAs are propagated only when
#' all rows for a respondent are missing.
#'
#' @param data [data.frame] Long-format medication data with multiple rows per respondent.
#' @param variables [character] Variable names to aggregate.
#' @param by [character] The respondent identifier column. Default is `"clinicid"`.
#'
#' @return [data.frame] One row per respondent with aggregated medication variables as numeric.
#'
#' @examples
#' df <- data.frame(
#'   clinicid    = c(1, 1, 2, 2),
#'   any_htn_med = c(0, 1, 0, 0),
#'   diab_med    = c(1, 0, 0, 0)
#' )
#' aggregate_meds_by_person(df, variables = c("any_htn_med", "diab_med"))
#'
#' @seealso [recode_meds_cycles3to6()], [recode_meds_cycles1to2()]
#' @export
aggregate_meds_by_person <- function(data, variables, by = "clinicid") {
  data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(by))) |>
    dplyr::summarize(
      dplyr::across(
        dplyr::all_of(variables),
        ~ {
          vals <- factor_to_tagged_numeric(.x)
          if (all(haven::is_tagged_na(vals, "a"))) {
            haven::tagged_na("a")
          } else if (all(is.na(vals))) {
            haven::tagged_na("b")
          } else {
            max(vals, na.rm = TRUE)
          }
        }
      ),
      .groups = "drop"
    )
}

#' @title Recode medication variables for cycles 3-6 (long format)
#'
#' @description Recodes medication variables from cycles 3-6 long-format data (one row per
#' medication per respondent), aggregates to one row per respondent, and merges into the
#' main cycle dataset. Wraps `recodeflow::rec_with_table()` and [aggregate_meds_by_person()].
#'
#' @param data [data.frame] Main cycle data to merge medication variables into.
#' @param meds_data [data.frame] Long-format medication data (cycles 3-6) with columns
#'   `clinicid`, `meucatc`, and `npi_25b`.
#' @param variables [character] Medication variable names to derive (e.g., `"any_htn_med"`).
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param meds_database_name [character] Name of the meds database in `variable_details`.
#'   Defaults to the name of the `meds_data` argument. Override when passing a transformed
#'   object (e.g., `head()`).
#' @param variable_details [data.frame] Variable details table. Defaults to `chmsflow::variable_details`.
#'
#' @return [data.frame] `data` with derived medication variables merged in as numeric columns.
#'
#' @examples
#' result <- recode_meds_cycles3to6(
#'   cycle3,
#'   cycle3_meds,
#'   c("any_htn_med", "diab_med")
#' )
#' head(result[, c("clinicid", "any_htn_med", "diab_med")])
#'
#' @seealso [recode_meds_cycles1to2()], [aggregate_meds_by_person()]
#' @export
recode_meds_cycles3to6 <- function(data, meds_data, variables, by = "clinicid",
                                   meds_database_name = NULL,
                                   variable_details = chmsflow::variable_details) {
  if (is.null(meds_database_name)) meds_database_name <- deparse(substitute(meds_data))
  validate_database_name(meds_database_name, variable_details, "meds_database_name")
  meds_recoded <- recodeflow::rec_with_table(
    meds_data,
    c(by, "meucatc", "npi_25b", variables),
    database_name = meds_database_name,
    variable_details = variable_details
  ) |>
    aggregate_meds_by_person(variables = variables, by = by)
  check_join_keys(data, meds_recoded, by, "aggregated meds_data")
  dplyr::left_join(data, meds_recoded, by = by)
}

#' @title Recode variables that depend on derived medication variable inputs
#'
#' @description Wraps `recodeflow::rec_with_table()` for use after derived medication
#' variables (e.g., `any_htn_med`, `diab_med`) have been recoded and merged into the
#' main cycle dataset. Use this instead of `rec_with_table()` when deriving variables
#' whose inputs include derived medication variables: it automatically excludes
#' medication-specific rows from `variable_details` so that pre-computed medication
#' columns are passed through via the `copy` entries rather than re-derived from raw
#' ATC/MHR columns.
#'
#' @param data [data.frame] Main cycle data with derived medication variables already merged.
#' @param variables [character] Variable names to recode.
#' @param by [character] Respondent identifier column. Default is `"clinicid"`.
#' @param database_name [character] Name of the database in `variable_details`.
#'   Defaults to the name of the `data` argument.
#' @param variable_details [data.frame] Variable details table. Defaults to
#'   `chmsflow::variable_details`.
#'
#' @return [data.frame] Recoded data frame returned by `recodeflow::rec_with_table()`.
#'
#' @examples
#' cycle3 <- recode_meds_cycles3to6(cycle3, cycle3_meds, c("any_htn_med", "diab_med"))
#' cycle3_diab <- recode_after_meds(
#'   cycle3,
#'   c("lab_hba1", "diab_a1c", "diab_med", "ccc_51", "diab_status")
#' )
#' head(cycle3_diab[, c("clinicid", "diab_status")])
#'
#' @seealso [recode_meds_cycles3to6()], [recode_meds_cycles1to2()]
#' @export
recode_after_meds <- function(data, variables, by = "clinicid",
                              database_name = NULL,
                              variable_details = chmsflow::variable_details) {
  if (is.null(database_name)) database_name <- deparse(substitute(data))
  variable_details <- variable_details[!is_meds_only_database(variable_details$databaseStart), ]
  validate_database_name(database_name, variable_details, "database_name")
  recoded <- recodeflow::rec_with_table(
    data,
    variables,
    database_name = database_name,
    variable_details = variable_details
  )
  stopifnot(
    "rec_with_table() returned a different number of rows than `data`; row alignment cannot be trusted" =
      nrow(recoded) == nrow(data)
  )
  if (!(by %in% names(recoded))) {
    # rec_with_table() preserves input row order; the row-shuffle test in
    # test-medications.R guards against any future regression of that contract.
    recoded <- dplyr::bind_cols(dplyr::select(data, dplyr::all_of(by)), recoded)
  }
  recoded
}
