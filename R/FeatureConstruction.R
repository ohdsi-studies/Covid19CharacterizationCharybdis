createFeatureProportions <- function(connection,
                                     cohortDatabaseSchema,
                                     cohortStagingTable,
                                     cohortTable,
                                     featureSummaryTable,
                                     oracleTempSchema,
                                     incremental,
                                     incrementalFolder) {
  packageName <- getThisPackageName()
  featureIds <- getAllFeatures()$cohortId
  featureTimeWindows <- getFeatureTimeWindows()
  featureTimeWindowTempTableSql <- featureWindowsTempTableSql(connection, featureTimeWindows, oracleTempSchema)
  sql <- SqlRender::loadRenderTranslateSql(dbms = attr(connection, "dbms"),
                                           sqlFilename = "CreateFeatureProportions.sql",
                                           packageName = packageName,
                                           oracleTempSchema = oracleTempSchema,
                                           warnOnMissingParameters = TRUE,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_staging_table = cohortStagingTable,
                                           cohort_table = cohortTable,
                                           feature_summary_table = featureSummaryTable,
                                           feature_ids = featureIds,
                                           feature_time_window_table_create = featureTimeWindowTempTableSql$create,
                                           feature_time_window_table_drop = featureTimeWindowTempTableSql$drop)
  
  ParallelLogger::logInfo("Compute feature proportions for all target and strata")
  DatabaseConnector::executeSql(connection, sql)
}

exportFeatureProportions <- function(connection,
                                     cohortDatabaseSchema,
                                     cohortTable,
                                     featureSummaryTable) {
  packageName <- getThisPackageName()
  sql <- SqlRender::loadRenderTranslateSql(dbms = attr(connection, "dbms"),
                                           sqlFilename = "GetFeatureProportions.sql",
                                           packageName = packageName,
                                           warnOnMissingParameters = TRUE,
                                           cohort_database_schema = cohortDatabaseSchema,
                                           cohort_table = cohortTable,
                                           feature_summary_table = featureSummaryTable)
  data <- DatabaseConnector::querySql(connection, sql) 
  names(data) <- SqlRender::snakeCaseToCamelCase(names(data))
  data <- formatFeatureProportions(data)
  return(data)
}

formatFeatureProportions <- function(data) {
  featureTimeWindows <- getFeatureTimeWindows()
  featureCohorts <- getAllFeatures()
  data <- merge(data, featureTimeWindows, by="windowId")
  data <- merge(data, featureCohorts, by.x="featureCohortDefinitionId", by.y="cohortId")
  names(data)[names(data) == 'name'] <- 'featureName'
  names(data)[names(data) == 'cohortDefinitionId'] <- 'cohortId'
  
  data$covariateId <- data$featureCohortDefinitionId * 1000 + data$windowId
  data$covariateName <- createFeatureCovariateName(data$windowStart, 
                                                             data$windowEnd,
                                                             data$windowType,
                                                             data$featureName)
  data$analysisId <- data$featureCohortDefinitionId
  return(data)
}

createFeatureCovariateName <- function(windowStart, windowEnd, windowType, featureName) {
  return(paste0("Cohort during day ", windowStart, " through ", windowEnd, " days ", windowType, " the index: ", featureName))  
}

featureWindowsTempTableSql <- function(connection, featureWindows, oracleTempSchema) {
  sql <- "WITH data AS (
            @unions
          ) 
          SELECT window_id, window_start, window_end, window_type
          INTO #feature_windows
          FROM data;"
  unions <- "";
  for(i in 1:nrow(featureWindows)) {
    stmt <- paste0("SELECT ", featureWindows$windowId[i], " window_id, ", 
                   featureWindows$windowStart[i], " window_start, ", 
                   featureWindows$windowEnd[i], " window_end, ", 
                   "'", featureWindows$windowType[i], "' window_type")
    unions <- paste(unions, stmt, sep="\n")
    if (i < nrow(featureWindows)) {
      unions <- paste(unions, "UNION ALL", sep="\n")
    }
  }
  
  sql <- SqlRender::render(sql, unions = unions)
  sql <- SqlRender::translate(sql = sql, 
                              targetDialect = attr(connection, "dbms"),
                              oracleTempSchema = oracleTempSchema)
  
  dropSql <- "TRUNCATE TABLE #feature_windows;\nDROP TABLE #feature_windows;\n\n"
  return(list(create = sql, drop = dropSql))
}


getAllFeatures <- function() {
  colNames <- c("name", "cohortId") # Use this to subset to the columns of interest
  cohortBasedStrata <- getCohortBasedStrata()
  cohortBasedStrata <- cohortBasedStrata[, match(colNames, names(cohortBasedStrata))]
  cohortBasedFeatures <- getFeatures()
  cohortBasedFeatures <- cohortBasedFeatures[, match(colNames, names(cohortBasedFeatures))]
  features <- rbind(cohortBasedStrata, cohortBasedFeatures)
  return(features)  
}
