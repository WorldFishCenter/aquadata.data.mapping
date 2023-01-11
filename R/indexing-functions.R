#' Filter metadata by word
#'
#' Filter metadata by a specific word in dataset title and/or dataset keyword list.
#'
#' @param word Character string to be be filtered.
#'
#' @return A dataframe
#' @export
#' @importFrom rlang .data
#'
filterby_word <- function(word = NULL) {
  tol_word <- tolower(word)

  aquadata.data.mapping::dataverse_metadata %>%
    dplyr::filter(grepl(tol_word, .data$title) | .data$keyword_value == tol_word)
}
