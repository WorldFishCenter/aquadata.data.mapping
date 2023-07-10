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
          # uiOutput("selected_row_open")
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
            shiny::column(width = 4, shiny::selectInput("engine", "Select the AI engine", choices = c(pars$openai$engines))),
            shiny::column(width = 4, shiny::selectInput("prompt", "Output aim", choices = c("Impact Story", "Baseline Story", "Summary"))),
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
              rows = 10,
              width = "100%",
              height = "100%"
            ))
          ),
          shiny::fluidRow(
            shiny::h2("Chat with the document")
          ),
          shiny::fluidRow(
            shiny::column(width = 12, shiny::uiOutput("chatbot"))
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
