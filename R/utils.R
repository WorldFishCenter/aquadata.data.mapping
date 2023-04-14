#' Read configuration file
#'
#' Reads configuration file in `conf.yml` and adds some logging lines. Wrapped
#' for convenience
#'
#' @param conf The configuration (default or local).
#' @return the environment parameters
#' @export
#'
read_config <- function(conf = "default") {
  logger::log_info("Loading configuration file...")

  pars <- config::get(
    config = Sys.getenv("R_CONFIG_ACTIVE", conf),
    file = system.file("conf.yml", package = "aquadata.data.mapping")
  )

  logger::log_info("Using configutation: {attr(pars, 'config')}")
  logger::log_debug("Running with parameters {pars}")

  pars
}
