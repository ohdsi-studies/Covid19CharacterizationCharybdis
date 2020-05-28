createBulkStrata <- function(connection,
                             cdmDatabaseSchema,
                             cohortDatabaseSchema,
                             cohortStagingTable,
                             targetIds, 
                             oracleTempSchema,
                             incremental,
                             incrementalFolder) {
  
  if (incremental) {
    recordKeepingFile <- file.path(incrementalFolder, "StratifiedCohorts.csv")
  }
  
  # Create the bulk strata from the CSV
  createBulkStrataFromFile(connection,
                           cdmDatabaseSchema,
                           cohortDatabaseSchema,
                           cohortStagingTable,
                           targetIds, 
                           oracleTempSchema,
                           incremental,
                           recordKeepingFile)
  
  # Create the bulk strata from the cohorts of interest
  createBulkStrataFromCohorts(connection,
                               cdmDatabaseSchema,
                               cohortDatabaseSchema,
                               cohortStagingTable,
                               targetIds, 
                               oracleTempSchema,
                               incremental,
                               recordKeepingFile)
  
}

createBulkStrataFromFile <- function(connection,
                                     cdmDatabaseSchema,
                                     cohortDatabaseSchema,
                                     cohortStagingTable,
                                     targetIds, 
                                     oracleTempSchema,
                                     incremental,
                                     recordKeepingFile) {
  packageName <- getThisPackageName()
  bulkStrataToCreate <- getBulkStrata()
  targetStrataXref <- getTargetStrataXref()
  
  if (incremental) {
    bulkStrataToCreate$checksum <- computeChecksum(serializeBulkStrataName(bulkStrataToCreate))
  }
  
  for (i in 1:nrow(bulkStrataToCreate)) {
    strataId <- bulkStrataToCreate$cohortId[i]
    if (!incremental || isTaskRequired(cohortId = strataId,
                                       checksum = bulkStrataToCreate$checksum[i],
                                       recordKeepingFile = recordKeepingFile)) {
      # Get the strata to create for the targets selected
      tsXrefSubset <- targetStrataXref[targetStrataXref$targetId %in% targetIds & targetStrataXref$strataId == strataId, ]
      # Create the SQL for the temp table to hold the cohorts to be stratified
      tsXrefTempTableSql <- cohortStrataXrefTempTableSql(connection, tsXrefSubset, oracleTempSchema)
      # Execute the SQL to create the stratified cohorts
      ParallelLogger::logInfo(paste0("Stratify by ", bulkStrataToCreate$name[i]))
      sql <- SqlRender::loadRenderTranslateSql(dbms = attr(connection, "dbms"),
                                               sqlFilename = bulkStrataToCreate$generationScript[i], 
                                               packageName = packageName,
                                               warnOnMissingParameters = FALSE,
                                               oracleTempSchema = oracleTempSchema,
                                               cdm_database_schema = cdmDatabaseSchema,
                                               cohort_database_schema = cohortDatabaseSchema,
                                               cohort_staging_table = cohortStagingTable,
                                               strata_value = bulkStrataToCreate$parameterValue[i],
                                               target_strata_xref_table_create = tsXrefTempTableSql$create,
                                               target_strata_xref_table_drop = tsXrefTempTableSql$drop)
      DatabaseConnector::executeSql(connection, sql)
      
      if (incremental) {
        recordTasksDone(cohortId = strataId, checksum = bulkStrataToCreate$checksum[i], recordKeepingFile = recordKeepingFile)
      }
    }
  }
}

createBulkStrataFromCohorts <- function(connection,
                                        cdmDatabaseSchema,
                                        cohortDatabaseSchema,
                                        cohortStagingTable,
                                        targetIds, 
                                        oracleTempSchema,
                                        incremental,
                                        recordKeepingFile) {
  packageName <- getThisPackageName()
  strataCohorts <- getCohortBasedStrata()
  targetStrataXref <- getTargetStrataXref()
  
  # Get the strata to create for the targets selected
  tsXrefSubset <- targetStrataXref[targetStrataXref$targetId %in% targetIds & targetStrataXref$strataId %in% strataCohorts$cohortId, ]
  # Create the SQL for the temp table to hold the cohorts to be stratified
  tsXrefTempTableSql <- cohortStrataXrefTempTableSql(connection, tsXrefSubset, oracleTempSchema)
  
  
  sql <- SqlRender::loadRenderTranslateSql(dbms = attr(connection, "dbms"),
                                           sqlFilename = "StratifyByCohort.sql",
                                           packageName = packageName,
                                           oracleTempSchema = oracleTempSchema,
                                           warnOnMissingParameters = TRUE,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_staging_table = cohortStagingTable,
                                           target_strata_xref_table_create = tsXrefTempTableSql$create,
                                           target_strata_xref_table_drop = tsXrefTempTableSql$drop)
  
  cohortId <- 200 # Represents the range of stratified cohorts created in this process
  if (!incremental || isTaskRequired(cohortId = cohortId,
                                     checksum = computeChecksum(sql),
                                     recordKeepingFile = recordKeepingFile)) {
    
    ParallelLogger::logInfo("Stratify by cohorts")
    DatabaseConnector::executeSql(connection, sql)
    if (incremental) {
      recordTasksDone(cohortId = cohortId, checksum = computeChecksum(sql), recordKeepingFile = recordKeepingFile)
    }
  }
}

cohortStrataXrefTempTableSql <- function(connection, targetStrataXref, oracleTempSchema) {
  sql <- "WITH data AS (
            @unions
          ) 
          SELECT target_id,strata_id,cohort_id,cohort_type
          INTO #TARGET_STRATA_XREF 
          FROM data;"
  unions <- "";
  for(i in 1:nrow(targetStrataXref)) {
    stmt <- paste0("SELECT ", targetStrataXref$targetId[i], " target_id, ", 
                   targetStrataXref$strataId[i], " strata_id, ", 
                   targetStrataXref$cohortId[i], " cohort_id, ",
                   "'", targetStrataXref$cohortType[i], "' cohort_type")
    unions <- paste(unions, stmt, sep="\n")
    if (i < nrow(targetStrataXref)) {
      unions <- paste(unions, "UNION ALL", sep="\n")
    }
  }
  
  sql <- SqlRender::render(sql, unions = unions)
  sql <- SqlRender::translate(sql = sql, 
                              targetDialect = attr(connection, "dbms"),
                              oracleTempSchema = oracleTempSchema)
  
  dropSql <- "TRUNCATE TABLE #TARGET_STRATA_XREF;\nDROP TABLE #TARGET_STRATA_XREF;\n\n"
  return(list(create = sql, drop = dropSql))
}

serializeBulkStrataName <- function(bulkStrataToCreate) {
  return(paste(bulkStrataToCreate$generationScript, bulkStrataToCreate$name, bulkStrataToCreate$parameterValue, sep = "|"))
}

getAllStrata <- function() {
  colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
  bulkStrata <- getBulkStrata()
  bulkStrata <- bulkStrata[, match(colNames, names(bulkStrata))]
  atlasCohortStrata <- getCohortBasedStrata()
  atlasCohortStrata <- atlasCohortStrata[, match(colNames, names(atlasCohortStrata))]
  strata <- rbind(bulkStrata, atlasCohortStrata)
  return(strata)  
}
