#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    shiny::fluidPage(
      theme = bslib::bs_theme(
        version = 5,
        bg = "#ffffff",
        fg = "#333333",
        primary = "#669bbc",
        secondary = "#dda15e",
        base_font = bslib::font_google("Montserrat")
      ),
      # App title and logo
      shiny::headerPanel(
        title = "CGIAR metadata explorer",
        windowTitle = "CGIAR metadata explorer"
      ),
      # Define the tabs
      shiny::tabsetPanel(
        # First tab - Plot and table
        shiny::tabPanel(
          "Explore metadata",
          shiny::fluidRow(
            shiny::column(
              width = 12,
              shiny::h2("Data Distribution Treemap"),
              shiny::p("Visualize the distribution of data for each CGIAR Organization")
            )
          ),
          shiny::fluidRow(
            shiny::column(width = 12, apexcharter::apexchartOutput("p", height = "80vh"))
          ),
          shiny::fluidRow(
            shiny::column(
              width = 12,
              shiny::h2("Interactive Metadata Table"),
              shiny::p("Browse and Explore metadata from CGIAR Organizations")
            )
          ),
          shiny::fluidRow(
            shiny::column(width = 12, reactable::reactableOutput(("t")))
          ),
          uiOutput("selected_row_details")
        ),
        shiny::tabPanel(
          "Country indicators",
          shiny::fluidRow(
            shiny::column(
              width = 12,
              shiny::h2("Explore country indicators"),
              shiny::p("Explore and compare coutry development indicators")
            )
          ),
          shiny::fluidRow(
            shiny::selectInput("indicator",
              label = tags$div(style = c("font-weight: bolder"), "Select indicator"),
              choices = aquadata.data.mapping::wb_indicators$indicator_name,
              width = "40%"
            )
          ),
          shiny::fluidRow(
            shiny::selectInput("country",
              label = tags$div(style = c("font-weight: bolder"), "Select country"),
              choices = dplyr::filter(aquadata.data.mapping::wb_country_codes, .data$country_code %in% pars$quantl$countries) %>% magrittr::extract2("country_name"),
              multiple = T,
              selected = "India"
            ),
            shiny::sliderInput(inputId = "year", "Year:", min = 1970, max = 2021, step = 1, value = 2021, sep = "")
          ),
          shiny::fluidRow(
            shiny::column(width = 6, apexcharter::apexchartOutput("c1", height = "60vh")),
            shiny::column(width = 6, leaflet::leafletOutput("map"), height = "60vh"),
          )
        ),
        # Second tab - Text Processing
        shiny::tabPanel(
          "Text Processing Engine",
          shiny::fluidRow(
            shiny::column(
              width = 12,
              shiny::h2("Upload a File"),
              shiny::p("Upload a text file to generate stories or summaries")
            )
          ),
          shiny::fluidRow(
            shiny::column(width = 12, shiny::fileInput("file_upload", "Choose a file"))
          ),
          shiny::fluidRow(
            shiny::column(width = 4, shiny::selectInput("engine", "Select the AI engine", choices = pars$openai$engines)),
            shiny::column(width = 4, shiny::selectInput("prompt", "Output aim", choices = c("Story", "Summary"))),
            shiny::column(width = 4, shiny::sliderInput("temperature", "Select the temperature (creativity)",
              value = 0.5,
              min = 0.1,
              max = 1,
              step = 0.1
            ))
          ),
          shiny::fluidRow(
            shiny::column(width = 3, shiny::actionButton("process_text", "Process Text"))
          ),
          shiny::fluidRow(
            shiny::column(width = 12, shiny::textAreaInput("processed_text",
              label = "",
              rows = 20,
              width = "100%",
              height = "100%"
            ))
          )
        ),
        # Third tab - App information
        shiny::tabPanel(
          "About",
          shiny::fluidRow(
            shiny::column(
              width = 12,
              shiny::markdown(pars$about$text)
            )
          )
        )
      )
    )
  )
}
