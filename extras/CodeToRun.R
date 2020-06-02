# *******************************************************
# -----------------INSTRUCTIONS -------------------------
# *******************************************************
#
#-----------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------
# This CodeToRun.R is provided as an example of how to run this study package.
# Below you will find 2 sections: the 1st is for installing the dependencies 
# required to run the study and the 2nd for running the package.
#
# The code below makes use of R environment variables (denoted by "Sys.getenv(<setting>)") to 
# allow for protection of sensitive information. If you'd like to use R environment variables stored
# in an external file, this can be done by creating an .Renviron file in the root of the folder
# where you have cloned this code. For more information on setting environment variables please refer to: 
# https://stat.ethz.ch/R-manual/R-devel/library/base/html/readRenviron.html
#
#
# Below is an example .Renviron file's contents: (please remove)
# the "#" below as these too are interprted as comments in the .Renviron file:
#
#    DBMS = "postgresql"
#    DB_SERVER = "database.server.com"
#    DB_PORT = 17001
#    DB_USER = "database_user_name_goes_here"
#    DB_PASSWORD = "your_secret_password"
#    FFTEMP_DIR = "E:/fftemp"
#    USE_SUBSET = FALSE
#
# The following describes the settings
#    DBMS, DB_SERVER, DB_PORT, DB_USER, DB_PASSWORD := These are the details used to connect
#    to your database server. For more information on how these are set, please refer to:
#    http://ohdsi.github.io/DatabaseConnector/
#
#    FFTEMP_DIR = A directory where temporary files used by the FF package are stored while running.
#
#    USE_SUBSET = TRUE/FALSE. When set to TRUE, this will allow for runnning this package with a 
#    subset of the cohorts/features. This is used for testing. PLEASE NOTE: This is only enabled
#    by setting this environment variable.
#
# Once you have established an .Renviron file, you must restart your R session for R to pick up these new
# variables. 
#
# In section 2 below, you will also need to update the code to use your site specific values. Please scroll
# down for specific instructions.
#-----------------------------------------------------------------------------------------------
#
# 
# *******************************************************
# SECTION 1: Make sure to install all dependencies (not needed if already done) -------------------------------
# *******************************************************
# 
# Prevents errors due to packages being built for other R versions: 
Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)
# 
# First, it probably is best to make sure you are up-to-date on all existing packages.
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries
# (like 'rlang') in use.
#update.packages(ask = "graphics")

# When asked to update packages, select '1' ('update all') (could be multiple times)
# When asked whether to install from source, select 'No' (could be multiple times)
#install.packages("devtools")
#devtools::install_github("ohdsi-studies/Covid19CharacterizationCharybdis")

# *******************************************************
# SECTION 2: Running the package -------------------------------------------------------------------------------
# *******************************************************
library(Covid19CharacterizationCharybdis)

# Optional: specify where the temporary files (used by the ff package) will be created:
fftempdir <- if (Sys.getenv("FFTEMP_DIR") == "") "~/fftemp" else Sys.getenv("FFTEMP_DIR")
options(fftempdir = fftempdir)

# Details for connecting to the server:
dbms = Sys.getenv("DBMS")
user <- if (Sys.getenv("DB_USER") == "") NULL else Sys.getenv("DB_USER")
password <- if (Sys.getenv("DB_PASSWORD") == "") NULL else Sys.getenv("DB_PASSWORD")
server = Sys.getenv("DB_SERVER")
port = Sys.getenv("DB_PORT")
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = dbms,
                                                                server = server,
                                                                user = user,
                                                                password = password,
                                                                port = port)


#-----------------------------------------------------------------------------------------------
# Instructions for the remaining variables
#-----------------------------------------------------------------------------------------------
# 
# - oracleTempSchema := If using Oracle, what is the schema to use. Please see http://ohdsi.github.io/DatabaseConnector/ for more details.
# - databaseId := The database identifier to use for reporting results. Please review this list and use the one that matches your site:
# 
#   | Database_id |                               Database Name                                |
#   |-------------|----------------------------------------------------------------------------|
#   | AU_ePBRN    | Australian Electronic Practice Based Research Network                      |
#   | AUSOM       | Ajou University School of Medicine Database                                |
#   | CCAE        | IBM MarketScan® Commercial Database                                        |
#   | CUIMC       | Columbia University Irving Medical Center                                  |
#   | DCMC        | Daegu Catholic University Medical Center                                   |
#   | HIRA        | Health Insurance and Review Assessment                                     |
#   | HM          | HM Hospitales                                                              |
#   | IPCI        | Integrated Primary Care Information                                        |
#   | JMDC        | Japan Medical Data Center                                                  |
#   | MDCD        | IBM MarketScan® Multi-State Medicaid Database                              |
#   | MDCR        | IBM MarketScan® Medicare Supplemental Database                             |
#   | OptumDoD    | Optum® De-Identified Clinformatic Data Mart Database – Date of Death (DOD) |
#   | optumEhr    | Optum® de-identified Electronic Health Record Dataset                      |
#   | SIDIAP      | The Information System for Research in Primary Care (SIDIAP)               |
#   | STARR       | STAnford medicine Research data Repository                                 |
#   | TRDW        | Tufts Researrch Data Warehouse                                             |
#   | VA          | Department of Veterans Affairs                                             |
#   
#    *** If your database is not in this list, please specify the database_id yourself and report it back to the study lead ***
#
# - databaseName := The full name of your database
# - databaseDescription := A full description of your database.
# - outputFolder := The file path where the results of the study are placed.
# - cdmDatabaseSchema := The database schema where the OMOP CDM data exists. In the case of SQL Server, this should be the database + schema.
# - cohortDatabaseSchema := The database schema where the cohort data is created. The account specified as DB_USER must have full rights to that schema to create/drop tables
# - cohortTable := The name of the table to use the cohorts for the study
# - cohortStagingTable := The name of the table used to stage the cohorts used in this study
# - featureSummaryTable := The name of the table to hold the feature summary for this study
# - minCellCount := Aggregate stats that yield a value < minCellCount are censored in the output
# - cohortIdsToExclude := A vector of cohort IDs to exclude from the study. This is useful if a particular cohort is problematic in your environment
# - useBulkCharacterization := When set to TRUE, this will attempt to do all of the characterization operations for the whole 
#                              study via SQL vs sequentially per cohort and time window. This is recommended if your DB platform is 
#                              robust to perform this type of operation. Best to test this using the USE_SUBSET option to test.
# 
# Also worth noting: The runStudy function below allows for the input of cohort groups (covid and/or influenza)
# in the event that you would like to characterize a subset of these 2 target groups. To run the analysis
# on a single group, uncomment the parameter "cohortGroups = c("covid", "influenza")" and change the list
# to reflect the cohort group(s) you'd like to use. By default, the package will use both sets of cohorts
#-----------------------------------------------------------------------------------------------

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
databaseId <- "PREMIER_COVID_SUBSET_BULK"
databaseName <- "PREMIER_COVID_SUBSET_BULK"
databaseDescription <- "PREMIER_COVID_SUBSET_BULK"

# Details for connecting to the CDM and storing the results
outputFolder <- file.path("E:/Covid19Characterization/TestRuns", databaseId)
cdmDatabaseSchema <- "CDM_Premier_v1214.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- paste0("AS_S0_subset_", databaseId)
cohortStagingTable <- paste0(cohortTable, "_stg")
featureSummaryTable <- paste0(cohortTable, "_smry")
minCellCount <- 5
useBulkCharacterization <- FALSE
cohortIdsToExclude <- c()

# For uploading the results. You should have received the key file from the study coordinator:
keyFileName <- "c:/home/keyFiles/study-data-site-covid19.dat"
userName <- "study-data-site-covid19"

# Use this to run the study. The results will be stored in a zip file called 
# 'AllResults_<databaseId>.zip in the outputFolder. 
runStudy(connectionDetails = connectionDetails,
         cdmDatabaseSchema = cdmDatabaseSchema,
         cohortDatabaseSchema = cohortDatabaseSchema,
         cohortStagingTable = cohortStagingTable,
         cohortTable = cohortTable,
         featureSummaryTable = featureSummaryTable,
         oracleTempSchema = cohortDatabaseSchema,
         exportFolder = outputFolder,
         databaseId = databaseId,
         databaseName = databaseName,
         databaseDescription = databaseDescription,
         #cohortGroups = c("covid", "influenza"),
         cohortIdsToExclude = cohortIdsToExclude,
         incremental = TRUE,
         useBulkCharacterization = useBulkCharacterization,
         minCellCount = minCellCount) 

#CohortDiagnostics::preMergeDiagnosticsFiles(outputFolder)
#launchShinyApp(outputFolder)

# Upload results to OHDSI SFTP server:
#uploadResults(outputFolder, keyFileName, userName)
