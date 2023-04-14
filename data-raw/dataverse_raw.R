## code to prepare `dataverse_raw` dataset goes here
pars <- read_config(conf = "local")

pk_path <- system.file("data-raw", package = "aquadata.data.mapping")
csv_files <- list.files(pk_path)
metadata_files <- csv_files[c(which(grepl("dataset_metadata", csv_files)))]
org_names <- stringr::word(metadata_files, 1, sep = "\\_")

dataverse_metadata <-
  purrr::map(metadata_files, clean_metadata_files, folder_path = pk_path) %>%
  rlang::set_names(org_names) %>%
  dplyr::bind_rows(.id = "organization") %>%
  janitor::remove_empty(c("rows", "cols")) %>%
  dplyr::distinct()

anonymize <- function(x, algo="xxhash32", seed = pars$seed){
  unq_hashes <- vapply(unique(x), function(object) digest::digest(object, algo=algo, seed = seed), FUN.VALUE="", USE.NAMES=TRUE)
  unname(unq_hashes[x])
}

worldfish_guestbook_responses <-
  readr::read_csv(paste0(pk_path, "/all_worldfish_guestbook_responses_2022.12.27.csv"), show_col_types = FALSE) %>%
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
  ) %>%
  dplyr::mutate(
    file_id = as.integer(file_id),
    publication_date = as.Date(publication_date, "%m/%d/%Y"),
    dplyr::across(c(title, user_name, Institution, Position, answer_1, answer_2), tolower),
    user_name = anonymize(.data$user_name),
    Email = anonymize(.data$Email)
  ) %>%
  janitor::clean_names() %>%
  janitor::remove_empty(c("rows", "cols"))

usethis::use_data(dataverse_metadata, overwrite = TRUE)
usethis::use_data(worldfish_guestbook_responses, overwrite = TRUE)
