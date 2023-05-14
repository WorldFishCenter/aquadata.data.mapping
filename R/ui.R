
#' The Shiny App UI.
#' @importFrom shinythemes shinytheme
#' @export
shiny_ui <- shiny::fluidPage(
  theme = shinythemes::shinytheme("yeti"),
  shiny::absolutePanel(
    top = 0, right = 0,
    width = 100, height = 30
    #htmltools::img(src = "/Users/lore/Desktop/worldfish-vector-logo.png", height = 50, width = 50)
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
          shiny::h2("Treemap"),
          shiny::p("This interactive plot provides visual insights into the data.")
        )
      ),
      shiny::fluidRow(
        shiny::column(width = 12, apexcharter::apexchartOutput("p", height = "80vh"))
      ),
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::h2("Table"),
          shiny::p("This table displays the underlying data in a tabular format.")
        )
      ),
      shiny::fluidRow(
        shiny::column(width = 12, reactable::reactableOutput(("t")))
      )
    ),

    # Second tab - App information
    shiny::tabPanel(
      "About",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::h2("Welcome to My Shiny App!"),
          shiny::p("This app provides an interactive visualization and data table."),
          shiny::p("You can explore and analyze the data using the Plot and Table tabs.")
        )
      )
    )
  )
)
