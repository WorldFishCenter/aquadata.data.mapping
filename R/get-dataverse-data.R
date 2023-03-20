get_dataset <- function(parsed_doi = NULL, dataverse_key = NULL) {
  dataverse::get_dataset(
    dataset = parsed_doi,
    key = dataverse_key,
    server = "dataverse.harvard.edu"
  ) %>%
    magrittr::extract2("files") %>%
    dplyr::as_tibble(.name_repair = "unique")
}

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
