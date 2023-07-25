#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
run_app <- function(
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...) {
  logger::log_info("Running app in run_app()")
  golem::with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(...)
  )
}

#' Shiny Application starting function
#'
#' @param global_pars Set global parameters
#'
#' @export
start_fun <- function(global_pars = TRUE) {
  logger::log_info("Running start_fun")
  if (isTRUE(global_pars)) {
    logger::log_info("Setting up pars as a global variable")
    pars <<- read_config("local")
    Quandl::Quandl.api_key(pars$quantl$key)
  }
  logger::log_info("Finished instructions in start_fun")
}
