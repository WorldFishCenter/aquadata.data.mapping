#' Rearrange metadata for apexcharter
#'
#' This function is strictly related to `apexcharter`, as it rearrange the
#' metadata dataframe in the shape of "list of lists" in order to be correctly
#' processed by `apex_treemap` function.
#'
#' @return A list.
#' @export
#'
#' @examples
#' \dontrun{
#' metadata_lists <- jsonify_metadata()
#' }
jsonify_metadata <- function() {
  df <-
    aquadata.data.mapping::dataverse_metadata %>%
    dplyr::select(.data$organization, .data$subject) %>%
    dplyr::group_by(.data$organization) %>%
    dplyr::count(.data$subject) %>%
    stats::na.omit() %>%
    dplyr::mutate(
      organization = as.factor(.data$organization),
      subject = as.factor(.data$subject)
    ) %>%
    dplyr::ungroup()

  df_ord <-
    df %>%
    dplyr::group_by(.data$organization) %>%
    dplyr::mutate(ntot = sum(.data$n)) %>%
    dplyr::arrange(-.data$ntot) %>%
    dplyr::ungroup()

  df_split <- df_ord %>% split(.$organization)
  df_split_ord <- df_split[unique(df_ord$organization)]

  dat <- lapply(names(df_split_ord), function(org_name) {
    org_data <- df_split_ord[[org_name]]
    list(
      name = org_name,
      data = lapply(1:nrow(org_data), function(i) {
        list(x = org_data$subject[i], y = org_data$n[i])
      })
    )
  })
  dat
}

#' Apexchart Treemap
#'
#' Generate a treemap using the `apexchart` library (see \url{https://dreamrs.github.io/apexcharter/index.html})
#'
#' @param series The series to plot. Generated from `jsonify_metadata`.
#' @param colors Treemap fill colors.
#' @param legend_size Legend font size.
#'
#' @return An apexchart interactive plot.
#' @export
#'
#' @examples
#' \dontrun{
#' palette <- c(
#'   "#440154", "#30678D", "#35B778",
#'   "#FDE725", "#FCA35D", "#D32F2F", "#67001F"
#' )
#' colors <- palette %>% strtrim(width = 7)
#' dat <- jsonify_metadata()
#' apex_treemap(series = dat, colors = colors, legend_size = 15)
#' }
apex_treemap <- function(series = NULL, colors = NULL, legend_size = 15) {
  apexcharter::apexchart() %>%
    apexcharter::ax_chart(
      type = "treemap",
      toolbar = list(show = FALSE),
      animations = list(
        enabled = TRUE,
        speed = 800,
        animateGradually = list(enabled = TRUE)
      ),
      selection = list(enabled = FALSE),
      zoom = list(enabled = FALSE)
    ) %>%
    apexcharter::ax_series2(series) %>%
    apexcharter::ax_legend(
      show = T,
      fontSize = legend_size,
      position = "top",
      onItemClick = F
    ) %>%
    apexcharter::ax_colors(colors) %>%
    apexcharter::ax_tooltip(
      shared = FALSE,
      followCursor = TRUE,
      intersect = TRUE,
      fillSeriesColor = FALSE
    )
}

#' Read uploaded file
#'
#' This function read uplaoded file from the user. It returns a object based
#' on the extension of the file. Allowed formats are docx, pdf, txt.
#'
#' @param file The uploaded file.
#'
#' @return A text.
#' @export
#'
#' @examples
#' \dontrun{
#' read_text("my_file.pdf")
#' }
read_file <- function(file = NULL) {
  extension <- tools::file_ext(file)

  if (extension == "docx") {
    f <- readtext::readtext(file = file)$text
  } else if (extension == "txt") {
    f <- base::readLines(file)
  } else if (extension == "pdf") {
    f <- readtext::readtext(file = file)$text
  }
  f
}
