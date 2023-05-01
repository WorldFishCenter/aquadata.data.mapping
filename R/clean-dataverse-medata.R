#' Clean metadata raw files
#'
#' Read and clean Dataverse raw metadata files.
#'
#' @param folder_path Path of folder where raw metadata are located.
#' @param file_path Path of raw metadata file.
#'
#' @return A dataframe.
#' @export
#' @importFrom rlang .data
#'
clean_metadata_files <- function(folder_path = NULL, file_path = NULL) {
  readr::read_csv(paste0(folder_path, "/", file_path), show_col_types = FALSE) %>%
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

  path <- system.file("data-raw", package = "aquadata.data.mapping")
  csv_files <- list.files(path)
  metadata_files <- csv_files[c(which(grepl("dataset_metadata", csv_files)))]
  org_names <- stringr::word(metadata_files, 1, sep = "\\_")

  logger::log_info("Cleaning metadata raw data")
  dataverse_metadata <-
    purrr::map(metadata_files, clean_metadata_files, folder_path = path) %>%
    rlang::set_names(org_names) %>%
    dplyr::bind_rows(.id = "organization") %>%
    janitor::remove_empty(c("rows", "cols")) %>%
    dplyr::distinct()

  logger::log_info("Saving tidy metadata")
  usethis::use_data(dataverse_metadata, overwrite = TRUE)
}
