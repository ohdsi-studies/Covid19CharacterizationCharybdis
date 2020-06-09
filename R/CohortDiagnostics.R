#' @export
runCohortDiagnostics <- function(connectionDetails = NULL,
                                 connection = NULL,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortStagingTable = "cohort_stg",
                                 oracleTempSchema = cohortDatabaseSchema,
                                 cohortGroupNames = getCohortGroupNamesForDiagnostics(),
                                 cohortIdsToExcludeFromExecution = c(),
                                 exportFolder,
                                 databaseId = "Unknown",
                                 databaseName = "Unknown",
                                 databaseDescription = "Unknown",
                                 incrementalFolder = file.path(exportFolder, "RecordKeeping"),
                                 minCellCount = 5) {
  # Verify that the cohortGroups are the ones that are specified in the 
  # CohortGroupsDiagnostics.csv
  cohortGroups <- getCohortGroupsForDiagnostics()
  cohortGroupsExist <- cohortGroupNames %in% cohortGroups$cohortGroup
  if (!all(cohortGroupsExist)) {
    ParallelLogger::logError(paste("Invalid cohort group name. Must be one of:", paste(getCohortGroupNamesForDiagnostics(), collapse = ', ')))
    stop()
  }
  cohortGroups <- cohortGroups[cohortGroups$cohortGroup %in% cohortGroupNames, ]
  ParallelLogger::logDebug(paste("CohortGroups: ", cohortGroups))
  
  # NOTE: The exportFolder is the root folder where the
  # study results will live. The diagnostics will be written
  # to a subfolder called "diagnostics". Both the diagnostics
  # and main study code (RunStudy.R) will share the same
  # RecordKeeping folder so that we can ensure that cohorts
  # are only created one time.
  diagnosticOutputFolder <- file.path(exportFolder, "diagnostics")
  cohortGroups$outputFolder <- file.path(diagnosticOutputFolder, cohortGroups$cohortGroup)
  if (!file.exists(diagnosticOutputFolder)) {
    dir.create(diagnosticOutputFolder, recursive = TRUE)
  }

  if (!is.null(getOption("fftempdir")) && !file.exists(getOption("fftempdir"))) {
    warning("fftempdir '", getOption("fftempdir"), "' not found. Attempting to create folder")
    dir.create(getOption("fftempdir"), recursive = TRUE)
  }
  ParallelLogger::addDefaultFileLogger(file.path(diagnosticOutputFolder, "cohortDiagnosticsLog.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT"))

  if (is.null(connection)) {
    connection <- DatabaseConnector::connect(connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection))
  }

  # Create cohorts -----------------------------
  cohorts <- getCohortsToCreate(cohortGroups = cohortGroups)
  cohorts <- cohorts[!(cohorts$cohortId %in% cohortIdsToExcludeFromExecution) & cohorts$atlasId > 0, ] # cohorts$atlasId > 0 is used to avoid those cohorts that use custom SQL identified with an atlasId == -1
  ParallelLogger::logInfo("Creating cohorts in incremental mode")
  instantiateCohortSet(connectionDetails = connectionDetails,
                       connection = connection,
                       cdmDatabaseSchema = cdmDatabaseSchema,
                       oracleTempSchema = oracleTempSchema,
                       cohortDatabaseSchema = cohortDatabaseSchema,
                       cohortTable = cohortStagingTable,
                       cohortIds = cohorts$cohortId,
                       minCellCount = minCellCount,
                       createCohortTable = TRUE,
                       generateInclusionStats = FALSE,
                       incremental = TRUE,
                       incrementalFolder = incrementalFolder,
                       inclusionStatisticsFolder = diagnosticOutputFolder)

  # Run diagnostics -----------------------------
  ParallelLogger::logInfo("Running cohort diagnostics")
  for (i in 1:nrow(cohortGroups)) {
    CohortDiagnostics::runCohortDiagnostics(packageName = getThisPackageName(),
                                            connection = connection,
                                            cohortToCreateFile = cohortGroups$fileName[i],
                                            connectionDetails = connectionDetails,
                                            cdmDatabaseSchema = cdmDatabaseSchema,
                                            oracleTempSchema = oracleTempSchema,
                                            cohortDatabaseSchema = cohortDatabaseSchema,
                                            cohortTable = cohortStagingTable,
                                            cohortIds = cohorts$cohortId,
                                            inclusionStatisticsFolder = diagnosticOutputFolder,
                                            exportFolder = cohortGroups$outputFolder[i],
                                            databaseId = databaseId,
                                            databaseName = databaseName,
                                            databaseDescription = databaseDescription,
                                            runInclusionStatistics = FALSE,
                                            runIncludedSourceConcepts = TRUE,
                                            runOrphanConcepts = TRUE,
                                            runTimeDistributions = TRUE,
                                            runBreakdownIndexEvents = TRUE,
                                            runIncidenceRate = TRUE,
                                            runCohortOverlap = TRUE,
                                            runCohortCharacterization = FALSE,
                                            minCellCount = minCellCount,
                                            incremental = TRUE,
                                            incrementalFolder = incrementalFolder)
  }
}