#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::fluidPage(
    theme = shinythemes::shinytheme("yeti"),
    shiny::absolutePanel(
      top = 0, right = 0,
      width = 100, height = 30
      # htmltools::img(src = "/Users/lore/Desktop/worldfish-vector-logo.png", height = 50, width = 50)
    ),
    # App title and logo
    shiny::headerPanel(
      title = "CGIAR metadata",
      windowTitle = "My App"
    ),

    # Define the two tabs
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
        )
      ),
      # Second tab - Text Processing
      shiny::tabPanel(
        "Text Processing",
        shiny::fluidRow(
          shiny::column(
            width = 12,
            shiny::h2("Upload Text File"),
            shiny::p("Upload a text file for processing")
          )
        ),
        shiny::fluidRow(
          shiny::column(width = 12, shiny::fileInput("file_upload", "Choose a file"))
        ),
        shiny::fluidRow(
          shiny::column(width = 12, shiny::textAreaInput("processed_text",
            label = "Output",
            rows = 20,
            width = "1000px",
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
            shiny::h2("Welcome to aquadata.data.mapping"),
            shiny::markdown(pars$about$text)
          )
        )
      )
    )
  )
}
