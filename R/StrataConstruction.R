createBulkStrata <- function(connection,
                             cdmDatabaseSchema,
                             cohortDatabaseSchema,
                             cohortStagingTable,
                             targetIds, 
                             oracleTempSchema) {
  
  # Create the bulk strata from the CSV
  createBulkStrataFromFile(connection,
                           cdmDatabaseSchema,
                           cohortDatabaseSchema,
                           cohortStagingTable,
                           targetIds, 
                           oracleTempSchema)
  
  # Create the bulk strata from the cohorts of interest
  createBulkStrataFromCohorts(connection,
                               cdmDatabaseSchema,
                               cohortDatabaseSchema,
                               cohortStagingTable,
                               targetIds, 
                               oracleTempSchema)
  
}

createBulkStrataFromFile <- function(connection,
                                     cdmDatabaseSchema,
                                     cohortDatabaseSchema,
                                     cohortStagingTable,
                                     targetIds, 
                                     oracleTempSchema) {
  packageName <- getThisPackageName()
  bulkStrataToCreate <- getBulkStrata()
  targetStrataXref <- getTargetStrataXref()
  
  for (i in 1:nrow(bulkStrataToCreate)) {
    strataId <- bulkStrataToCreate$cohortId[i]
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
    #write(sql,paste0(i, ".sql"))
  }
}

createBulkStrataFromCohorts <- function(connection,
                                        cdmDatabaseSchema,
                                        cohortDatabaseSchema,
                                        cohortStagingTable,
                                        targetIds, 
                                        oracleTempSchema) {
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
  
  ParallelLogger::logInfo("Stratify by cohorts")
  #write(sql,"stratify.sql")
  DatabaseConnector::executeSql(connection, sql)
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
  dropSql <- SqlRender::translate(sql = dropSql, 
                                  targetDialect = attr(connection, "dbms"),
                                  oracleTempSchema = oracleTempSchema)
  return(list(create = sql, drop = dropSql))
}

serializeBulkStrataName <- function(bulkStrataToCreate) {
  return(paste(bulkStrataToCreate$generationScript, bulkStrataToCreate$name, bulkStrataToCreate$parameterValue, sep = "|"))
}

