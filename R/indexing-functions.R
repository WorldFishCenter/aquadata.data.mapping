#' Filter metadata by word
#'
#' Filter metadata by a specific word in dataset title and/or dataset keyword list.
#'
#' @param data Metadata dataframe.
#' @param word Character string to be be filtered.
#'
#' @return A dataframe
#' @export
#' @importFrom rlang .data
#'
filterby_word <- function(data = NULL, word = NULL){
  data |>
    dplyr::filter(grepl(word, .data$title) | .data$keyword_value == word)
}
