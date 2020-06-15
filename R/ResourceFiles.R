getBulkStrata <- function() {
  resourceFile <- file.path(getPathToResource(), "BulkStrata.csv")
  return(readCsv(resourceFile))
}

getCohortGroupNamesForDiagnostics <- function() {
  cohortGroupNames <- getCohortGroupsForDiagnostics()$cohortGroup
}

getCohortGroupsForDiagnostics <- function () {
  resourceFile <- file.path(getPathToResource(), "CohortGroupsDiagnostics.csv")
  return(readCsv(resourceFile))
}

getCohortGroups <- function () {
  resourceFile <- file.path(getPathToResource(), "CohortGroups.csv")
  return(readCsv(resourceFile))
}

getCohortBasedStrata <- function() {
  resourceFile <- file.path(getPathToResource(), "CohortsToCreateStrata.csv")
  return(readCsv(resourceFile))
}

getFeatures <- function() {
  resourceFile <- file.path(getPathToResource(), "CohortsToCreateFeature.csv")
  return(readCsv(resourceFile))
}

getFeatureTimeWindows <- function() {
  resourceFile <- file.path(getPathToResource(), "featureTimeWindows.csv")
  return(readCsv(resourceFile))
}

getTargetStrataXref <- function() {
  resourceFile <- file.path(getPathToResource(), "targetStrataXref.csv")
  return(readCsv(resourceFile))
}

getCohortsToCreate <- function(cohortGroups = getCohortGroups()) {
  packageName <- getThisPackageName()
  cohorts <- data.frame()
  for(i in 1:nrow(cohortGroups)) {
    c <- readr::read_csv(system.file(cohortGroups$fileName[i], package = packageName, mustWork = TRUE), col_types = readr::cols())
    c$cohortType <- cohortGroups$cohortGroup[i]
    cohorts <- rbind(cohorts, c)
  }
  return(cohorts)  
}

getAllStrata <- function() {
  colNames <- c("name", "cohortId", "generationScript") # Use this to subset to the columns of interest
  bulkStrata <- getBulkStrata()
  bulkStrata <- bulkStrata[, match(colNames, names(bulkStrata))]
  atlasCohortStrata <- getCohortBasedStrata()
  atlasCohortStrata$generationScript <- paste0(atlasCohortStrata$cohortId, ".sql")
  atlasCohortStrata <- atlasCohortStrata[, match(colNames, names(atlasCohortStrata))]
  strata <- rbind(bulkStrata, atlasCohortStrata)
  return(strata)  
}

getAllStudyCohorts <- function() {
  cohortsToCreate <- getCohortsToCreate()
  targetStrataXref <- getTargetStrataXref()
  colNames <- c("name", "cohortId")
  cohortsToCreate <- cohortsToCreate[, match(colNames, names(cohortsToCreate))]
  targetStrataXref <- targetStrataXref[, match(colNames, names(targetStrataXref))]
  allCohorts <- rbind(cohortsToCreate, targetStrataXref)
}

getThisPackageName <- function() {
  return("Covid19CharacterizationCharybdis")
}

readCsv <- function(resourceFile) {
  packageName <- getThisPackageName()
  pathToCsv <- system.file(resourceFile, package = packageName, mustWork = TRUE)
  fileContents <- readr::read_csv(pathToCsv, col_types = readr::cols())
  return(fileContents)
}

getPathToResource <- function(useSubset = Sys.getenv("USE_SUBSET")) {
  path <- "settings"
  useSubset <- as.logical(useSubset)
  if (is.na(useSubset)) {
    useSubset = FALSE
  }
  if (useSubset) {
    path <- file.path(path, "subset/")
  }
  return(path)
}