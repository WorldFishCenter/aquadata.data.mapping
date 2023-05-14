#' The Shiny App Server.
#' @param input input set by Shiny.
#' @param output output set by Shiny.
#' @export
shiny_server <- function(input, output) {
  # Render the plot
  palette <- c(
    "#440154", "#30678D", "#35B778",
    "#FDE725", "#FCA35D", "#D32F2F", "#67001F"
  )
  colors <- palette %>% strtrim(width = 7)
  dat <- jsonify_metadata()
  output$p <- apexcharter::renderApexchart({
    apex_treemap(
      series = dat,
      colors = colors,
      legend_size = 20
    )
  })

  # Render the table
  output$t <- reactable::renderReactable({

    # Organize metadata
    tab_dat <-
      aquadata.data.mapping::dataverse_metadata %>%
      dplyr::select(
        Organization = .data$organization,
        Title = .data$title,
        Subject = .data$subject,
        Keyword = .data$keyword_value,
        doi = .data$dataset_doi
      ) %>%
      dplyr::group_by(.data$Title) %>%
      dplyr::summarise(
        Organization = dplyr::first(.data$Organization),
        Subject = dplyr::first(.data$Subject),
        Keyword = dplyr::first(.data$Keyword),
        doi = dplyr::first(.data$doi)
      ) %>%
      dplyr::select(.data$Organization, dplyr::everything())

    # Render table
    reactable::reactable(
      tab_dat,
      # pagination = FALSE,
      # compact = FALSE,
      # borderless = FALSE,
      striped = TRUE,
      fullWidth = TRUE,
      sortable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      highlight = TRUE
    )
  })
}
