getBulkStrata <- function() {
  resourceFile <- file.path(getPathToResource(), "BulkStrata.csv")
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

getCohortsToCreate <- function() {
  packageName <- getThisPackageName()
  cohortGroups <- getCohortGroups()
  cohorts <- data.frame()
  for(i in 1:nrow(cohortGroups)) {
    c <- readr::read_csv(system.file(cohortGroups$fileName[i], package = packageName), col_types = readr::cols())
    c$cohortType <- cohortGroups$cohortGroup[i]
    cohorts <- rbind(cohorts, c)
  }
  return(cohorts)  
}

getThisPackageName <- function() {
  return("Covid19CharacterizationCharybdis")
}

readCsv <- function(resourceFile) {
  packageName <- getThisPackageName()
  pathToCsv <- system.file(resourceFile, package = packageName)
  fileContents <- readr::read_csv(pathToCsv, col_types = readr::cols())
  return(fileContents)
}

getPathToResource <- function(useSubset = Sys.getenv("USE_SUBSET")) {
  path <- "settings/"
  useSubset <- as.logical(useSubset)
  if (useSubset) {
    path <- file.path(path, "subset/")
  }
  return(path)
}