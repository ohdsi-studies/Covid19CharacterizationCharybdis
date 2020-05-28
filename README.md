Characterizing Health Associated Risks, and Your Baseline Disease In SARS-COV-2 (CHARYBDIS)
=============

 <img src="https://img.shields.io/badge/Study%20Status-Design%20Finalized-brightgreen.svg" alt="Study Status: Design Finalized"> 

- Analytics use case(s): **Characterization**
- Study type: **Clinical Application**
- Tags: **OHDSI, Study-a-thon, COVID-19**
- Study lead: **Talita Duarte-Salles, Kristin Kostka, Albert Prats-Uribe**
- Study lead forums tag: **[tduarte](https://forums.ohdsi.org/u/tduarte)**, **[krfeeney](https://forums.ohdsi.org/u/krfeeney)**, **[Albert_Prats](https://forums.ohdsi.org/u/Albert_Prats)**
- Study start date: **April 21, 2020**
- Study end date: **Mid-June 2020**
- Protocol: **[Word Doc](https://github.com/ohdsi-studies/Covid19Characterization/blob/master/documents/Protocol_COVID-19%20Characterisation_V3.docx)**
- Publications: **-**
- Results explorer: **-**

**Objectives:**<br>
1) Describe the baseline demographic, clinical characteristics, treatments and outcomes of interest among individuals tested for SARS-CoV-2 and/or diagnosed with COVID-19 overall and stratified by sex, age and specific comorbidities;<br>
2) Describe characteristics and outcomes of patients diagnosed/tested positive for influenza as well as patients hospitalized with influenza between September 2017 and April 2018 compared to the COVID-19 population.<br>


### FAQ
#### *I'm a data owner. How do I know if this study is right for my data?*
The study is designed to run on any OMOP CDM V5 or higher that has populated the [PERSON](https://ohdsi.github.io/CommonDataModel/cdm531.html#person), [OBSERVATION_PERIOD](https://ohdsi.github.io/CommonDataModel/cdm531.html#observation_period), [VISIT_OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#visit_occurrence), [CONDITION_OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#condition_occurrence), [DRUG_EXPOSURE](https://ohdsi.github.io/CommonDataModel/cdm531.html#drug_exposure), [PROCEDURE-OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#procedure_occurrence), [MEASUREMENT](https://ohdsi.github.io/CommonDataModel/cdm531.html#measurement), [OBSERVATION](https://ohdsi.github.io/CommonDataModel/cdm531.html#observation), [DRUG_ERA](https://ohdsi.github.io/CommonDataModel/cdm531.html#drug_era) and [CONDITION_ERA](https://ohdsi.github.io/CommonDataModel/cdm531.html#condition_era) tables. 

##### I've never used the ERA Tables. Why do I need to populate these?
The OMOP CDM stores verbatim data from the source across various clinical domains, such as records for conditions, drugs, procedures, and measurements. In addition, to assist the analyst, the CDM also provides some derived tables, based on commonly used analytic procedures. For example, the [Condition_era](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_ERA) table is derived from the [Condition_occurrence](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_OCCURRENCE) table and both the [Drug_era](https://github.com/OHDSI/CommonDataModel/wiki/DRUG_ERA) and [Dose_era](https://github.com/OHDSI/CommonDataModel/wiki/DOSE_ERA) tables are derived from the [Drug_exposure](https://github.com/OHDSI/CommonDataModel/wiki/DRUG_EXPOSURE) table. An era is defined as a span of time when a patient is assumed to have a given condition or exposure to a particular active ingredient. For network research, it is essential to populate ERA tables so that downstream analytical methods/tools can utilize this information (e.g. ERA tables are required for using [FeatureExtraction](https://github.com/OHDSI/FeatureExtraction) which is the backbone to this package). It is suggested to run ERA scripts at the time of your latest ETL. If processing time is limited, you may choose to omit the Dose_era tables as these are not commonly used in network research. There are [scripts available from the OHDSI community](https://github.com/OHDSI/CommonDataModel/tree/master/CodeExcerpts/DerivedTables).

### *What if I don't have COVID-19 patients in my data?*
The package is segmented to allow a user to choose between running the Influenza cohorts and the COVID-19 cohorts. If you do not have COVID-19 data, you are invited to run this on your historical flu data. Characterizing prior flu seasons is a unique piece of our overall analysis to better understand how historical analogs apply to COVID-19. This information is very valuable for the community.

### Do I have to get IRB approval to run this study?
Generally, yes. We encourage sites to file the protocol/study results with their local governance committee (e.g. Institutional Review Boards, Publication Review Committees, etc). It is at your discretion whether you choose to file a master protocol for all COVID-19 related work or if you wish to file individual protocols for each subsequent OHDSI network study. In the [Documents](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/tree/master/documents) folder, we will keep an up to date copy of the Protocol (inclusive of any iterative revisions that may arise as we test and validate the overall study package). Please use the documents in this folder in your IRB submissions. If you need additional input, please reach out to the study leads.

### What do I need to do to run the package?
OHDSI study  repos are designed to have information in the README.md (where you are now) to provide you with instructions on how to navigate the repo. The study package has the following major pieces:
- `R` folder = the folder which will provide the R library the scripts it needs to execute this study
- Documents folder = the folder where you will find study documents (protocols, 1-sliders to explain the study, etc)
- extras folder = the folder where we store a copy of the instructions (called `CodeToRun.R`) below and other files that the study needs to do things like package maintenance or talk with the Shiny app. Aside from `CodeToRun.R`, you can largely ignore the rest of these files.
- inst folder = This is the "install" folder. It contains the most important parts of the study: the study cohort JSONs (analogous to what ATLAS shows you in the Export tab), the study settings, a sub-folder that contains information to the Shiny app, and the study cohort SQL scripts that [SqlRender](https://cran.r-project.org/web/packages/SqlRender/index.html) will use to translate these into your RDBMS.

Below you will find instructions for how to bring this package into your `R`/ `RStudio` environment. Note that if you are not able to connect to the internet in `R`/ `RStudio` to download pacakges, you will have to adjust this process accordingly.

## Requirements
- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- Suggested: 25 GB of free disk space

See [this video](https://youtu.be/K9_0s2Rchbo) for instructions on how to set up the R environment on Windows.

## How to Run
1. In `R`, you will need to build an .renv file.
````
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
````

2. To install the package (which will build a new R library for you that is specifically for Covid19CharacterizationCharybdis), type the following into a new `R` script and run:

````
# Prevents errors due to packages being built for other R versions: 
Sys.setenv("R_REMOTES_NO_ERRORS_FROM_WARNINGS" = TRUE)

# First, it probably is best to make sure you are up-to-date on all existing packages. 
# Important: This code is best run in R, not RStudio, as RStudio may have some libraries 
# (like 'rlang') in use.
update.packages(ask = "graphics")

# When asked to update packages, select '1' ('update all') (could be multiple times)
# When asked whether to install from source, select 'No' (could be multiple times)
install.packages("devtools")
devtools::install_github("ohdsi-studies/Covid19CharacterizationCharybdis")
````
(You can also retrieve this code from `extras/CodeToRun.R`).

*Note: When using this installation method it can be difficult to 'retrace' because you will not see the same folders that you see in the GitHub Repo. You may alternatively download the TAR file for this repo and bring this into your `R`/`RStudio` environment. Instructions for how to call ZIP files into your environment can be found in the [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/PopulationLevelEstimation.html#running-the-study-package).*

3. Great work! Now you need to execute the study, below is the code you will use:
````
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
# 
# Also worth noting: The runStudy function below allows for the input of cohort groups (covid and/or influenza)
# in the event that you would like to characterize a subset of these 2 target groups. To run the analysis
# on a single group, uncomment the parameter "cohortGroups = c("covid", "influenza")" and change the list
# to reflect the cohort group(s) you'd like to use. By default, the package will use both sets of cohorts
#-----------------------------------------------------------------------------------------------

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

# Details specific to the database:
databaseId <- "DOD_S0"
databaseName <- "DOD_S0"
databaseDescription <- "DOD_S0"

# Details for connecting to the CDM and storing the results
outputFolder <- file.path("E:/Covid19Characterization", databaseId)
cdmDatabaseSchema <- "CDM_OPTUM_EXTENDED_DOD_V1194.dbo"
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- paste0("AS_S0_full_", databaseId)
cohortStagingTable <- paste0(cohortTable, "_stg")
featureSummaryTable <- paste0(cohortTable, "_smry")
minCellCount <- 5

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
         incremental = TRUE,
         minCellCount = minCellCount) 

#CohortDiagnostics::preMergeDiagnosticsFiles(outputFolder)
#CohortDiagnostics::launchDiagnosticsExplorer(outputFolder)
````
4. If the study code runs to completion, your outputFolder will have the following contents:
- RecordKeeping = a folder designed to store incremental information such that if the study code dies, it will restart where it left off
- cohort.csv
- cohort_count.csv
- cohort_staging_count.csv
- covariate.csv
- covariate_value.csv
- covid19characterizationcharybdis.txt
- database.csv
- feature_proportions.csv
- Results_[CONVENTION YOU INPUT IN SCRIPT].zip

As a data owner, you will want to inspect these files for adherence to the minCellCount you input. You may find that only some files are generated. If this happens, please reach out to the study leads to debug. 

5. To utilize the `OhdsiSharing` library to connect and upload results to the OHDSI STFP server, you will need a site key. Reach out to the study leads to get a key. 

Once you have checked results, you can use the following code to send:
````
# Upload results to OHDSI SFTP server:
#uploadResults(outputFolder, keyFileName, userName)
````
