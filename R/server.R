#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Render the plot in the "Explore metadata" tab
  palette <- c("#440154", "#30678D", "#35B778", "#FDE725", "#FCA35D", "#D32F2F", "#67001F")
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
  # Render the table
  output$t <- reactable::renderReactable({
    # Render table
    reactable::reactable(
      data = organize_metatab(),
      theme = reactablefmtr::espn(),
      striped = TRUE,
      fullWidth = TRUE,
      sortable = TRUE,
      filterable = TRUE,
      searchable = TRUE,
      highlight = TRUE,
      selection = "single", # Allow selecting only one row
      onClick = "select"
      # detail = function(index) {
      #  dataset <- get_dataset_insights(tab_dat, index)
      #  tbl <- reactable(dataset, outlined = TRUE, highlight = TRUE, fullWidth = TRUE)
      #  htmltools::div(style = list(margin = "12px 45px"), tbl)
      # }
    )
  })

  output$selected_row_details <- renderUI({
    selected <- reactable::getReactableState("t", "selected")
    req(selected)

    output$insights <- reactable::renderReactable(
      reactable::reactable(
        data = get_dataset_insights(parent_table = organize_metatab(), index = selected),
        theme = reactablefmtr::espn(),
        selection = "single", # Allow selecting only one row
        onClick = "select"
      )
    )

    shiny::fluidRow(
      h2("Selected row details"),
      shiny::column(width = 12, reactable::reactableOutput(("insights")))
    )
  })
  # Render the plots and table in the "Country indicators" tab
  wb_dat <- reactive({
    countries <- aquadata.data.mapping::wb_country_codes %>%
      dplyr::filter(.data$country_name %in% c(input$country)) %>%
      magrittr::extract2("country_code")
    indicator <- aquadata.data.mapping::wb_indicators %>%
      dplyr::filter(.data$indicator_name %in% input$indicator) %>%
      magrittr::extract2("series_id")

    Quandl::Quandl.datatable("WB/DATA",
      series_id = indicator,
      country_code = countries
    ) %>%
      dplyr::arrange(.data$year)
  })

  output$c1 <- apexcharter::renderApexchart({
    apexcharter::apex(wb_dat(),
      type = "area",
      mapping = apexcharter::aes(x = .data$year, y = .data$value, group = .data$country_name)
    ) %>%
      apexcharter::ax_chart(
        toolbar = list(show = FALSE),
        animations = list(
          enabled = TRUE,
          speed = 800,
          animateGradually = list(enabled = TRUE)
        ),
        selection = list(enabled = FALSE),
        zoom = list(enabled = FALSE)
      ) %>%
      apexcharter::ax_xaxis(tickAmount = 15)
  })


  wb_dat2 <- reactive({
    indicator <- aquadata.data.mapping::wb_indicators %>%
      dplyr::filter(.data$indicator_name == input$indicator) %>%
      magrittr::extract2("series_id")

    dat <-
      Quandl::Quandl.datatable("WB/DATA",
        series_id = indicator,
        country_code = pars$quantl$countries
      ) %>%
      dplyr::rename(name_long = country_name)

    dat %>% dplyr::filter(.data$year == input$year)
  })

  output$map <- leaflet::renderLeaflet({
    # Filter data based on inputs
    data <- wb_dat2()

    leafdat <-
      rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
      merge(data, by = "name_long") %>%
      dplyr::select(name_long, year, value, geometry)

    Popup <- paste0(
      "<strong>Country: </strong>",
      leafdat$name_long,
      "<br><strong> Indicator value: </strong>",
      round(leafdat$value, 2)
    )

    # color
    mypalette <- leaflet::colorNumeric(
      palette = "viridis",
      domain = dat$value,
      na.color = "transparent",
      reverse = F
    )

    # Create leaflet map
    leaflet::leaflet(leafdat) %>%
      leaflet::setView(lng = 80, lat = 8, zoom = 2) %>%
      leaflet::addProviderTiles("CartoDB.Positron") %>%
      leaflet::addPolygons(
        fillColor = ~ mypalette(value),
        fillOpacity = 0.7,
        color = "black",
        weight = 2.5,
        popup = Popup
      ) %>%
      leaflet::addLegend(
        pal = mypalette,
        # labFormat = label_format,
        bins = 5,
        values = ~value,
        className = "panel panel-default",
        # title = leg_title,
        position = "bottomright"
      )
  })
  # Observer to update the processed_text input value
  shiny::observeEvent(input$process_text, {
    prompt <-
      if (input$prompt == "Story") {
        pars$openai$refine_prompts$story
      } else if (input$prompt == "Summary") {
        pars$openai$refine_prompts$summary
      }

    if (is.null(input$file_upload)) {
      shiny::showModal(
        shiny::modalDialog(
          title = "Error",
          "Please upload a file.",
          easyClose = TRUE
        )
      )
      return() # Exit the observeEvent early if no file is uploaded
    }

    shiny::withProgress(
      message = "Processing text...",
      value = 0,
      {
        file <- input$file_upload$datapath # Get the path of the uploaded file
        text <- read_file(file) # Read the text file
        # Perform your text processing on the 'text' variable
        utils::write.table(text, "text.txt")
        processed_text <-
          chatgpt_wrapper(
            document_path = "text.txt",
            openaikey = pars$openai$token,
            engine = input$engine,
            temperature = input$temperature,
            refine_text = prompt
          )
        shiny::updateTextAreaInput(session, "processed_text", value = processed_text$output_text)
        shiny::setProgress(1) # Set progress to 100% to make it disappear
      }
    )
  })
}
