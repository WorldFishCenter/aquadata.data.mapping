## code to prepare `dataverse_raw` dataset goes here

pk_path <- system.file(package = "aquadata.data.mapping")
csv_files <- list.files(pk_path)
metadata_files <- csv_files[c(which(grepl("dataset_metadata", csv_files)))]
org_names <- stringr::word(metadata_files, 1, sep = "\\_")

dataverse_metadata <-
  purrr::map(metadata_files, clean_metadata_files, folder_path = pk_path) |>
  rlang::set_names(org_names) |>
  dplyr::bind_rows(.id = "organization") |>
  janitor::remove_empty(c("rows", "cols")) |>
  dplyr::distinct()

worldfish_guestbook_responses <-
  readr::read_csv(paste0(pk_path, "/all_worldfish_guestbook_responses_2022.12.27.csv"), show_col_types = FALSE) |>
  dplyr::rename(
    title = Dataset,
    dataset_doi = `Dataset PID`,
    publication_date = Date,
    type = Type,
    file_name = `File Name`,
    file_id = `File Id`,
    file_doi = `File PID`,
    user_name = `User Name`,
    question_1 = `Custom Question 1`,
    answer_1 = `Custom Answer 1`,
    question_2 = `Custom Question 2`,
    answer_2 = `Custom Answer 2`
  ) |>
  dplyr::mutate(
    file_id = as.integer(file_id),
    publication_date = as.Date(publication_date, "%m/%d/%Y"),
    dplyr::across(c(title, user_name, Institution, Position, answer_1, answer_2), tolower)
  ) |>
  janitor::clean_names() |>
  janitor::remove_empty(c("rows", "cols"))

usethis::use_data(dataverse_metadata, overwrite = TRUE)
usethis::use_data(worldfish_guestbook_responses, overwrite = TRUE)
