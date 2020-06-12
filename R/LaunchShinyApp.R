# Borrowed from devtools: https://github.com/hadley/devtools/blob/ba7a5a4abd8258c52cb156e7b26bb4bf47a79f0b/R/utils.r#L44
.is_installed <- function (pkg, version = 0) {
  installed_version <- tryCatch(utils::packageVersion(pkg), 
                                error = function(e) NA)
  !is.na(installed_version) && installed_version >= version
}

.ensure_installed <- function(pkg) {
  if (!.is_installed(pkg)) {
    msg <- paste0(sQuote(pkg), " must be installed for this functionality.")
    if (interactive()) {
      message(msg, "/nWould you like to install it?")
      if (menu(c("Yes", "No")) == 1) {
        install.packages(pkg)
      } else {
        stop(msg, call. = FALSE)
      }
    } else {
      stop(msg, call. = FALSE)
    }
  }
}

#' @export
launchShinyApp <- function(outputFolder) {
  .ensure_installed("shiny")
  .ensure_installed("shinydashboard")
  .ensure_installed("shinyWidgets")
  .ensure_installed("DT")
  .ensure_installed("VennDiagram")
  .ensure_installed("htmltools")
  appDir <- system.file("shiny/CharybdisResultsExplorer", package = getThisPackageName())
  shinySettings <- list(dataFolder = outputFolder)
  .GlobalEnv$shinySettings <- shinySettings
  on.exit(rm(shinySettings, envir = .GlobalEnv))
  shiny::runApp(appDir)
}
