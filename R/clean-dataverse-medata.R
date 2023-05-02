#' Clean metadata raw files
#'
#' Read and clean Dataverse raw metadata files.
#'
#' @param file_path Path of raw metadata file.
#'
#' @return A dataframe.
#' @export
#' @importFrom rlang .data
#'
clean_metadata_files <- function(file_path = NULL) {
  readr::read_csv(file_path, show_col_types = FALSE) %>%
    dplyr::rename(
      dataset_doi = .data$persistentUrl,
      publication_date = .data$publicationdate
    ) %>%
    dplyr::mutate(
      dataset_doi = stringr::str_replace(.data$dataset_doi, "https://doi.org/", "doi:"),
      dataset_id = as.integer(.data$dataset_id),
      dplyr::across(c(.data$keywordValue, .data$title), tolower)
    ) %>%
    janitor::clean_names()
}


#' Clean raw metadata
#'
#' This function uses `clean_metadata_files` to clean metadata raw files into an
#' unique and structured .rda file.
#'
#' @param log_threshold The (standard Apache logj4) log level used as a
#'   threshold for the logging infrastructure. See [logger::log_levels] for more
#'   details
#'
#' @return Nothing, this function clean and store raw metadata into "data" folder.
#' @export
#' @examples
#' \dontrun{
#' update_metadata()
#' }
process_raw_metadata <- function(log_threshold = logger::DEBUG) {
  pars <- read_config()

  folder_path <- system.file("dataverse_raw", package = "aquadata.data.mapping", mustWork = TRUE)
  folder_files <- list.files(
    path = folder_path, full.names = TRUE,
    recursive = TRUE, include.dirs = TRUE
  )
  print(folder_files)
  system.file()
  list.files()
  org_names <- stringr::word(list.files(folder_path), 1, sep = "\\_")

  logger::log_info("Cleaning metadata raw data")
  dataverse_metadata <-
    purrr::map(metadata_files, clean_metadata_files) %>%
    rlang::set_names(org_names) %>%
    dplyr::bind_rows(.id = "organization") %>%
    janitor::remove_empty(c("rows", "cols")) %>%
    dplyr::distinct()

  logger::log_info("Saving tidy metadata")
  usethis::use_data(dataverse_metadata, overwrite = TRUE)
}
