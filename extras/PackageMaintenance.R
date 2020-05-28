# Copyright 2020 Observational Health Data Sciences and Informatics
#
# This file is part of Covid19CharacterizationCharybdis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::checkUsagePackage("Covid19CharacterizationCharybdis")
OhdsiRTools::updateCopyrightYearFolder()

# Create manual -----------------------------------------------------------
unlink("extras/Covid19CharacterizationCharybdis.pdf")
shell("R CMD Rd2pdf ./ --output=extras/Covid19CharacterizationCharybdis.pdf")

pkgdown::build_site()


# Insert cohort definitions from ATLAS into package -----------------------
cohortGroups <- read.csv("inst/settings/CohortGroups.csv")
for (i in 1:nrow(cohortGroups)) {
  ParallelLogger::logInfo("* Importing cohorts in group: ", cohortGroups$cohortGroup[i], " *")
  ROhdsiWebApi::insertCohortDefinitionSetInPackage(fileName = file.path("inst/", cohortGroups$fileName[i]),
                                                   baseUrl = Sys.getenv("baseUrl"),
                                                   insertTableSql = TRUE,
                                                   insertCohortCreationR = FALSE,
                                                   generateStats = FALSE,
                                                   packageName = "Covid19CharacterizationCharybdis")
}
unlink("inst/cohorts/InclusionRules.csv")

# Create the list of combinations of T, TwS, TwoS for the combinations of strata ----------------------------
settingsPath <- "inst/settings"
useSubset <- as.logical(Sys.getenv("USE_SUBSET"))
if (useSubset) {
  settingsPath <- file.path(settingsPath, "subset/")
}
covidCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateCovid.csv"))
influenzaCohorts <- read.csv(file.path(settingsPath, "CohortsToCreateInfluenza.csv"))
bulkStrata <- read.csv(file.path(settingsPath, "BulkStrata.csv"))
atlasCohortStrata <- read.csv(file.path(settingsPath, "CohortsToCreateStrata.csv"))


# Ensure all of the IDs are unique
allCohortIds <- c(covidCohorts[,match("cohortId", names(covidCohorts))], 
                  influenzaCohorts[,match("cohortId", names(influenzaCohorts))],
                  bulkStrata[,match("cohortId", names(bulkStrata))],
                  atlasCohortStrata[,match("cohortId", names(atlasCohortStrata))])

totalRows <- nrow(covidCohorts) + nrow(influenzaCohorts) + nrow(bulkStrata) + nrow(atlasCohortStrata)
if (length(unique(allCohortIds)) != totalRows) {
  warning("There are duplicate cohort IDs in the settings files!")
}

# Target cohorts
colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
targetCohorts <- rbind(covidCohorts, influenzaCohorts)
targetCohorts <- targetCohorts[, match(colNames, names(targetCohorts))]
names(targetCohorts) <- c("targetName", "targetId")
# Strata cohorts
bulkStrataColNames <- c("inverseName", "name", "cohortId") # Use this to subset to the columns of interest
bulkStrata <- bulkStrata[, match(bulkStrataColNames, names(bulkStrata))]
bulkStrata$name <- paste("with", bulkStrata$name)
bulkStrata$inverseName <- paste("with", bulkStrata$inverseName)
atlasCohortStrata <- atlasCohortStrata[, match(colNames, names(atlasCohortStrata))]
atlasCohortStrata$inverseName <- paste0("without ", atlasCohortStrata$name) 
atlasCohortStrata$name <- paste0("with ", atlasCohortStrata$name) 
strata <- rbind(bulkStrata, atlasCohortStrata)
names(strata) <- c("strataInverseName", "strataName", "strataId")
# Get all of the unique combinations of target + strata
targetStrataCP <- do.call(expand.grid, lapply(list(targetCohorts$targetId, strata$strataId), unique))
names(targetStrataCP) <- c("targetId", "strataId")
targetStrataCP <- merge(targetStrataCP, targetCohorts)
targetStrataCP <- merge(targetStrataCP, strata)
targetStrataCP$cohortId <- (targetStrataCP$targetId * 1000000) + (targetStrataCP$strataId*10)
tWithS <- targetStrataCP
tWithoutS <- targetStrataCP
tWithS$cohortId <- tWithS$cohortId + 1
tWithS$cohortType <- "TwS"
tWithS$name <- paste(tWithS$targetName, tWithS$strataName)
tWithoutS$cohortId <- tWithoutS$cohortId + 2
tWithoutS$cohortType <- "TwoS"
tWithoutS$name <- paste(tWithS$targetName, tWithS$strataInverseName)
targetStrataXRef <- rbind(tWithS, tWithoutS)
targetStrataXRef <- targetStrataXRef[,c("targetId","strataId","cohortId","cohortType","name")]

# Write out the final targetStrataXRef
readr::write_csv(targetStrataXRef, file.path(settingsPath, "targetStrataXref.csv"))


# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("Covid19CharacterizationCharybdis")