#' @export
runCohortDiagnostics <- function(connectionDetails = NULL,
                                 connection = NULL,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortStagingTable = "cohort_stg",
                                 oracleTempSchema = cohortDatabaseSchema,
                                 cohortGroups = getUserSelectableCohortGroups(),
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
  outputFolder <- file.path(outputFolder, "diagnostics")
  if (!file.exists(outputFolder)) {
    dir.create(outputFolder, recursive = TRUE)
  }
  if (!is.null(getOption("fftempdir")) && !file.exists(getOption("fftempdir"))) {
    warning("fftempdir '", getOption("fftempdir"), "' not found. Attempting to create folder")
    dir.create(getOption("fftempdir"), recursive = TRUE)
  }
  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "cohortDiagnosticsLog.txt"))
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
                       inclusionStatisticsFolder = outputFolder)
  
  # Run diagnostics -----------------------------
  ParallelLogger::logInfo("Running cohort diagnostics")
  CohortDiagnostics::runCohortDiagnostics(packageName = getThisPackageName(),
                                          connection = connection,
                                          connectionDetails = connectionDetails,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = oracleTempSchema,
                                          cohortDatabaseSchema = cohortDatabaseSchema,
                                          cohortTable = cohortStagingTable,
                                          inclusionStatisticsFolder = outputFolder,
                                          exportFolder = ouputFolder,
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