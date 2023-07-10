#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  options(shiny.maxRequestSize = 30 * 1024^2)
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

  # output$selected_row_open <- renderUI({

  # output$content <- renderText(
  #  get_dataset_file(insights_tab, insights_tab$ID)
  # )

  # shiny::fluidRow(
  #  h2("File content"),
  #  shiny::column(width = 12, textOutput(("content")))
  # )
  # })


  # Observer to update the processed_text input value
  shiny::observeEvent(input$process_text, {
    prompt <-
      if (input$prompt == "Summary") {
        pars$openai$refine_prompts$summary
      } else if (input$prompt == "Impact Story") {
        pars$openai$refine_prompts$impact_story
      } else if (input$prompt == "Baseline Story") {
        pars$openai$refine_prompts$baseline_story
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

  # Define a reactive value to store chat messages
  chat_messages <- shiny::reactiveValues(messages = character(0))

  # Render the chat interface
  output$chatbot <- shiny::renderUI({
    shiny::tagList(
      shiny::textInput(inputId = "chat_input", label = NULL, value = "", placeholder = "Type your message..."),
      shiny::div(shiny::verbatimTextOutput("chat_output")),
      shiny::actionButton(inputId = "send_button", label = "Send")
    )
  })

  # Render the chat messages
  output$chat_output <- shiny::renderText({
    paste(chat_messages$messages, collapse = "\n")
  })

  # Observer to handle chatbot messages
  shiny::observeEvent(input$send_button, {
    user_input <- input$chat_input

    if (user_input != "") {
      # User message received, process it
      chat_messages$messages <- c(chat_messages$messages, paste("You:", user_input))

      # Perform document querying based on user input
      # Update the chatbot messages accordingly

      # Example implementation
      if (grepl("documents", user_input, ignore.case = TRUE)) {
        # Query documents and update chatbot messages
        documents <- query_documents(user_input)
        reply <- paste("Bot: Here are the matching documents:", documents)
        chat_messages$messages <- c(chat_messages$messages, reply)
      } else {
        # If the user input doesn't match any known query, provide a default response
        reply <- "Bot: I'm sorry, but I couldn't understand your request."
        chat_messages$messages <- c(chat_messages$messages, reply)
      }

      # Clear the input field
      shiny::updateTextInput(session, "chat_input", value = "")
    }
  })

}
