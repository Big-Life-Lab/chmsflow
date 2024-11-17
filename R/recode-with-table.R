#' @file
#' Load packages
library(haven)
library(stringr)
library(dplyr)
library(magrittr)

#' @title
#' Recode with Table
#'
#' Recode with Table is responsible for recoding values of a dataset based on
#' the specifications in variable_details.
#'
#' The variable_details dataframe needs the following variables to function:
#'  \describe{
#'   \item{variable}{name of new (mutated) variable that is recoded}
#'   \item{toType}{type the variable is being recoded to
#'   \emph{cat = categorical, cont = continuous}}
#'   \item{databaseStart}{name of dataframe with original variables to be
#'   recoded}
#'   \item{variableStart}{name of variable to be recoded}
#'   \item{fromType}{variable type of start variable.
#'   \emph{cat = categorical or factor variable}
#'   \emph{cont = continuous variable (real number or integer)}}
#'   \item{recTo}{Value to recode to}
#'   \item{recFrom}{Value/range being recoded from}
#'  }
#'  Each row in \emph{variable_details} comprises one category in a
#'  newly transformed variable. The rules for each category the new variable
#'  are a string in \emph{recFrom} and value in \emph{recTo}.
#'  These recode pairs are the same syntax as \emph{sjmisc::rec()},
#'  except in \emph{sjmisc::rec()} the pairs are a string for the function
#'  attribute \emph{rec =}, separated by '\emph{=}'.
#'  For example in \emph{rec_w_table}
#'  \emph{variable_details$recFrom = 2; variable_details$recTo = 4}
#'  is the same as \emph{sjmisc::rec(rec = "2=4")}.
#'  the pairs are obtained from the RecFrom and RecTo columns
#'   \describe{
#'     \item{recode pairs}{each recode pair is row. see above example
#'     or \emph{PBC-variableDetails.csv}}
#'     \item{multiple values}{multiple old values that should be recoded into
#'     a new single value may be separated with comma, e.g.
#'     \emph{recFrom = "1,2"; recTo = 1}}
#'     \item{value range}{a value range is indicated by a colon, e.g.
#'     \emph{recFrom= "1:4"; recTo = 1} (recodes all values from 1 to 4 into 1)}
#'     \item{value range for doubles}{for double vectors (with fractional part),
#'      all values within the specified range are recoded; e.g.
#'      \emph{recFrom = "1:2.5'; recTo = 1} recodes 1 to 2.5 into 1,
#'      but 2.55 would not be recoded
#'      (since it's not included in the specified range)}
#'     \item{\emph{"min"} and \emph{"max"}}{minimum and maximum values
#'     are indicates by \emph{min} (or \emph{lo}) and \emph{max} (or \emph{hi}),
#'      e.g. \emph{recFrom = "min:4"; recTo = 1} (recodes all values from
#'      minimum values of \emph{x} to 4 into 1)}
#'     \item{\emph{"else"}}{all other values, which have not been specified yet,
#'      are indicated by \emph{else}, e.g. \emph{recFrom = "else"; recTo = NA}
#'      (recode all other values (not specified in other rows) to "NA")}
#'     \item{\emph{"copy"}}{the \emph{"else"}-token can be combined with
#'     \emph{copy}, indicating that all remaining, not yet recoded values should
#'      stay the same (are copied from the original value), e.g.
#'      \emph{recFrom = "else"; recTo = "copy"}}
#'     \item{\emph{NA}'s}{\emph{NA} values are allowed both as old and
#'     new value, e.g.
#'     \emph{recFrom "NA"; recTo = 1. or "recFrom = "3:5"; recTo = "NA"}
#'     (recodes all NA into 1,
#'     and all values from 3 to 5 into NA in the new variable)}
#' }
#'
#' @param data A dataframe containing the variables to be recoded. Can also be a list of dataframes
#' @param variables character vector containing variable names to recode or
#' a variables csv containing additional variable info
#' @param database_name String, the name of the dataset containing the variables
#' to be recoded. Can also be a vector of strings if data is a list
#' @param variable_details A dataframe containing the specifications (rules)
#' for recoding.
#' @param else_value Value (string, number, integer, logical or NA) that is used
#' to replace any values that are outside the specified ranges
#' (no rules for recoding).
#' @param append_to_data Logical, if \code{TRUE} (default), recoded variables
#' will be appended to the data.
#' @param log Logical, if \code{FALSE} (default), a log of recoding will
#' not be printed.
#' @param notes Logical, if \code{FALSE} (default), will not print the
#' content inside the `Note`` column of the variable being recoded.
#' @param var_labels labels vector to attach to variables in variables
#' @param custom_function_path path to location of the function to load
#' @param attach_data_name to attach name of database to end table
#'
#' @return a dataframe that is recoded according to rules in variable_details.
#' 
#' @examples
#' cycle1_ages_and_sexes <- rec_with_table(
#'   data = cycle1, 
#'   variables = c("clc_age", "clc_sex"),
#'   variable_details = my_variable_details
#' )
#' 
#' @export
rec_with_table <-
  function(data,
           variables,
           database_name = NULL,
           variable_details,
           else_value = NA,
           append_to_data = FALSE,
           log = FALSE,
           notes = TRUE,
           var_labels = NULL,
           custom_function_path = NULL,
           attach_data_name = FALSE) {
    # If custom Functions are passed create new environment and source
    if (!is.null(custom_function_path)) {
      source(custom_function_path)
    }
    if (is.null(variable_details)) {
      message("No variable_details detected.
              Loading cchsflow variable_details")
      data(variable_details, package = "cchsflow", envir = environment())
    }
    if (is.null(variables)) {
      message("No variables detected.
              Loading cchsflow variables")
      data(variables, package = "cchsflow", envir = environment())
    }
    if (is.null(database_name)) {
      message("Using the passed data variable name as database_name")
      database_name <- deparse(substitute(data))
    }
    # ---- Step 1: Detemine if the passed data is a list or single database
    append_non_db_columns <- FALSE
    if (is.list(data) &&
        length(database_name) == length(data)) {
      for (data_name in database_name) {
        # ---- Step 2A: Verify that the passed name exists in the passed data
        
        if (!is.null(data[[data_name]])) {
          data[[data_name]] <- recode_call(
            variables = variables,
            data = data[[data_name]],
            database_name = database_name,
            print_note = notes,
            else_value = else_value,
            variable_details = variable_details,
            append_to_data = append_to_data,
            append_non_db_columns = append_non_db_columns,
            log = log,
            var_labels = var_labels
          )
        } else {
          stop(
            paste(
              "The data",
              data_name,
              "is missing from the passed list please verify the names are
              correct in the data list and the database_name list"
            )
          )
        }
      }
    } else if ("data.frame" %in% class(data) &&
               length(database_name) == 1) {
      data <- recode_call(
        variables = variables,
        data = data,
        database_name = database_name,
        print_note = notes,
        else_value = else_value,
        variable_details = variable_details,
        append_to_data = append_to_data,
        append_non_db_columns = append_non_db_columns,
        log = log,
        var_labels = var_labels
      )
      if (attach_data_name) {
        data[["data_name"]] <- database_name
      }
    } else {
      stop(
        paste(
          "The passed number of data does not match the passed number of
          data_names. Please verify that the number of databases matches the number
          of passed names.
          Aborting operation!"
        ),
        call. = FALSE
      )
    }
    
    return(data)
  }