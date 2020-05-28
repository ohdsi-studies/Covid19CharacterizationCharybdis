getCohortDefinitionExpression <- function(definitionId, baseUrl) {
  url <- paste(baseUrl, "cohortdefinition", definitionId, sep = "/")
  json <- httr::GET(url)
  httr::content(json)
}

cohortPath <- "E:/Covid19Characterization/testCohorts"

cdT <- getCohortDefinitionExpression(definitionId = 5902, baseUrl = Sys.getenv("baseUrl"))
write(cdT$expression, file = file.path(cohortPath, "influenza.json"))

cdStrata <- getCohortDefinitionExpression(definitionId = 5903, baseUrl = Sys.getenv("baseUrl"))
write(cdStrata$expression, file = file.path(cohortPath, "strata.json"))

cdOutcomes <- getCohortDefinitionExpression(definitionId = 5900, baseUrl = Sys.getenv("baseUrl"))
write(cdOutcomes$expression, file = file.path(cohortPath, "outcomes.json"))
