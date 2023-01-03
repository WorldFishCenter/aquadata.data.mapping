#' Tidy raw dataverse metadata
#'
#' Read and tidy Dataverse raw metadata files.
#'
#' @param folder_path Path of folder where raw metadata are located.
#' @param file_path Path of raw metadata file.
#'
#' @return A dataframe.
#' @export
#' @importFrom rlang .data
#'
clean_metadata_files <- function(folder_path = NULL, file_path = NULL) {
  readr::read_csv(paste0(folder_path, "/", file_path), show_col_types = FALSE) |>
    dplyr::rename(
      dataset_doi = .data$persistentUrl,
      publication_date = .data$publicationdate
    ) |>
    dplyr::mutate(
      dataset_doi = stringr::str_replace(.data$dataset_doi, "https://doi.org/", "doi:"),
      dataset_id = as.integer(.data$dataset_id),
      dplyr::across(c(.data$keywordValue, .data$title), tolower)
    ) |>
    janitor::clean_names()
}
