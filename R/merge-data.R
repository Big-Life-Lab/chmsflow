#' @file
#' Load file
source("R/label-utils.R")

#' @title Merge recoded data
#' 
#' @description This function allows users to merge CHMS data transformed by the
#'  \code{\link{rec_with_table}} function. This function generates a labelled
#'  merged data frame with multiple transformed CHMS cycles.
#'
#' @details When merging recoded CHMS data, there are variables that are missing
#'  in certain CHMS cycles. This function tags missing variable observations as
#'  NA(c), indicating that the variable was not asked or included in the CHMS
#'  cycle of the respondent. 
#'  
#'  Click \href{https://big-life-lab.github.io/cchsflow/articles/tagged_na_usage.html}{here}
#'  for more details on how NA's are treated in chmsflow.
#' 
#' @param ... recoded data frames to be merged.
#' 
#' @return a merged data frame consisting of multiple recoded CHMS cycles with
#'  labels for variable names and tags for variables not included in particular
#'  CHMS cycles.
#' 
#' @examples 
#' # Merging two CHMS cycles with variables missing in each cycle.
#' 
#' # phc_11 is a CHMS variable available in CHMS cycle 1, while
#' # prs_11 is a CHMS variable available in CHMS cycle 6. 
#' # Using merge_rec_data(), datasets containing phc_11 & prc_11 can be
#' # merged and tagged.
#' 
#' library(chmsflow)
#' cycle1_pregnancies <- rec_with_table(cycle1, "phc_11")
#' cycle6_pregnancies <- rec_with_table(cycle6, "prs_11")
#' 
#' cycles1and6_pregnancies <- merge_rec_data(cycle1_pregnancies, cycle3_pregnancies)
#' head(cycles1and6_pregnancies)
#' tail(cycles1and6_pregnancies)
#' 
#' @export
merge_rec_data <- function(...) {
  # Step 1: bind datasets
  new_data <- dplyr::bind_rows(...)
  
  # Step 2: apply NA(c) to untagged NA's
  for (i in names(new_data)) {
    NA_index <- is.na(new_data[[i]])
    tagged_NA_index <- haven::is_tagged_na(new_data[[i]])
    true_NA_index <- !(NA_index == tagged_NA_index)
    if (is.numeric(new_data[[i]])) {
      new_data[true_NA_index, i] <-
        haven::tagged_na("c")
    } else {
      if (!"NA(c)" %in% levels(new_data[[i]])) {
        levels(new_data[[i]]) <-
          c(levels(new_data[[i]]),
            "NA(c)")
      }
      new_data[true_NA_index, i] <-
        "NA(c)"
    }
  }
  # Step 3: apply labels to combined dataset
  labelled_data <- set_data_labels(new_data, cchsflow::variable_details,
                                   cchsflow::variables)
  return(labelled_data)
}