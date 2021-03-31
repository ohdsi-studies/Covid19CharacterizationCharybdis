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



# Download the JSON for the Charybdis cohorts into to the package
library(httr)
token <- "" # Copy from ATLAS
bearer <- paste0("Bearer ", token)
# Get the list of cohorts from the package
cohortList <- readr::read_csv("inst/shiny/CharybdisResultsExplorer/cohorts.csv", col_types = readr::cols())
cohortList <- cohortList[order(cohortList$cohortId),]
# Iterate over each item and pull down the cohort json from ATLAS
atlasUrl <- "https://atlas.ohdsi.org/WebAPI/cohortdefinition/"
for(i in 1:nrow(cohortList)) {
  print(paste0("Name: ", cohortList$name[i], "; CohortId: ", cohortList$cohortId[i], "; AtlasId: ", cohortList$atlasId[i], "; CirceDef: ", cohortList$circeDef[i]))
  if (cohortList$circeDef[i]) {
    r <- httr::GET(paste0(atlasUrl, cohortList$atlasId[i]), add_headers(Authorization = bearer))
    json <- httr::content(r)
    write(json$expression, paste0("inst/cohorts/", cohortList$cohortId[i], ".json"))
  }
}