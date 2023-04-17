#' Get dataset metadata
#'
#' A wrapper function of [dataverse::get_dataset].
#'
#' This function returns dataset' metadata information.
#'
#' @param doi The dataset DOI (eg. "10.7910/DVN/EXSAJ7").
#' @param dataverse_key Dataverse token.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' \dontrun{
#' get_dataset(doi = "10.7910/DVN/WMLQ3D", token = DATAVERSE_TOKEN)
#' }
get_dataset <- function(doi = NULL, dataverse_key = NULL) {
  dataverse::get_dataset(
    dataset = doi,
    key = dataverse_key,
    server = "dataverse.harvard.edu"
  ) %>%
    magrittr::extract2("files") %>%
    dplyr::as_tibble(.name_repair = "unique")
}

#' Get file from dataverse dataset
#'
#' A wrapper function of [dataverse::get_dataframe_by_id].
#'
#' This function returns a specific file associated to a dataverse dataset.
#' It returns an object based on the extension of the file. A dataframe in case of
#' .csv or .xlsx, a text for .pdf and .docx files.
#'
#' @param dataset A dataverse dataset returned from [aquadata.data.mappind::get_dataset].
#' @param file_id The dataverse file id.
#'
#' @return An object based on the file extension. A dataframe in case of .csv or .xlsx,
#'  a text for .pdf and .docx files.
#' @export
#'
#' @examples
#' \dontrun{
#' dataverse_dataset <- get_dataset(doi = "10.7910/DVN/WMLQ3D", token = DATAVERSE_TOKEN)
#' get_dataset_file(dataset = dataverse_dataset, id = 4570239)
#' }
get_dataset_file <- function(dataset = NULL, file_id = NULL) {
  datafile <- dataset %>% dplyr::filter(.data$id == file_id)
  extension <- magrittr::extract2(datafile, "extension")

  read_fun <- function(extension) {
    if (extension %in% c("xlsx")) {
      f <- readxl::read_xlsx
    } else if (extension == "csv") {
      f <- readr::read_csv
    } else if (extension == "docx") {
      f <- officer::read_docx
    } else if (extension == "pdf") {
      f <- pdftools::pdf_text
    }
    f
  }

  output <-
    dataverse::get_dataframe_by_id(
      file = file_id,
      server = "dataverse.harvard.edu",
      .f = read_fun(extension),
      original = F
    )
}

#' Download metadata
#'
#' This function is a wrapper of a python script `get_dataverse_metadata.py` udeful
#' to download metadata from a defined Dataverse.
#'
#' @param organization The Dataverse alias of the entity posting the data.
#'
#' @return A csv with metadata information.
#' @export
#'
#' @examples
#' \dontrun{
#' get_organization_metadata(organization = "CIAT")
#' }
get_organization_metadata <- function(organization) {
  python_path <- system.file("python", package = "aquadata.data.mapping")
  foo_import <- reticulate::import_from_path(module = "get_dataverse_metadata",
                                             path = python_path)
  py_function <- foo_import$get_dataverse_metadata
  py_function(organization)

  # Drop intermediate folders
  files <- list.files(full.names = TRUE)
  json_drop <- files[c(which(grepl("dataset_JSON", files)))]
  csv_drop <- files[c(which(grepl("csv_files", files)))]
  unlink(c(json_drop, csv_drop), force = TRUE, recursive = TRUE)
}
