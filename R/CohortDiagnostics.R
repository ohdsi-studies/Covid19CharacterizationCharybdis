#' @export
runCohortDiagnostics <- function(connectionDetails = NULL,
                                 connection = NULL,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortStagingTable = "cohort_stg",
                                 oracleTempSchema = cohortDatabaseSchema,
                                 cohortGroups = getCohortGroups(),
                                 exportFolder,
                                 databaseId = "Unknown",
                                 databaseName = "Unknown",
                                 databaseDescription = "Unknown",
                                 incrementalFolder = file.path(exportFolder, "RecordKeeping"),
                                 minCellCount = 5) {
  # NOTE: The exportFolder is the root folder where the 
  # study results will live. The diagnostics will be written
  # to a subfolder called "diagnostics". Both the diagnostics
  # and main study code (RunStudy.R) will share the same
  # RecordKeeping folder so that we can ensure that cohorts
  # are only created one time.
  diagnosticOutputFolder <- file.path(exportFolder, "diagnostics")
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
  cohorts <- getCohortsToCreate()
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
                                            inclusionStatisticsFolder = diagnosticOutputFolder,
                                            exportFolder = diagnosticOutputFolder,
                                            databaseId = databaseId,
                                            databaseName = databaseName,
                                            databaseDescription = databaseDescription,
                                            runInclusionStatistics = FALSE,
                                            runIncludedSourceConcepts = FALSE,
                                            runOrphanConcepts = FALSE,
                                            runTimeDistributions = FALSE,
                                            runBreakdownIndexEvents = FALSE,
                                            runIncidenceRate = TRUE,
                                            runCohortOverlap = FALSE,
                                            runCohortCharacterization = FALSE,
                                            minCellCount = minCellCount,
                                            incremental = TRUE,
                                            incrementalFolder = incrementalFolder)  
  }
}