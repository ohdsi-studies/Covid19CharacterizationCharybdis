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
- Protocol: **[Word Doc](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/blob/master/documents/Protocol_COVID-19%20Charybdis%20Characterisation_V5.docx)**
- Publications: **-**
- Results explorer: **[Shiny App](https://data.ohdsi.org/Covid19CharacterizationCharybdis/)**

**Objectives:**<br>
1) Describe the baseline demographic, clinical characteristics, treatments and outcomes of interest among individuals tested for SARS-CoV-2 and/or diagnosed with COVID-19 overall and stratified by sex, age, race and specific comorbidities;<br>
2) Describe characteristics and outcomes of patients diagnosed/tested positive for influenza as well as patients hospitalized with influenza between September 2017 and April 2018 compared to the COVID-19 population.<br>


### FAQ
#### *I'm a data owner. How do I know if this study is right for my data?*
The study is designed to run on any OMOP CDM V5 or higher that has populated the [PERSON](https://ohdsi.github.io/CommonDataModel/cdm531.html#person), [OBSERVATION_PERIOD](https://ohdsi.github.io/CommonDataModel/cdm531.html#observation_period), [VISIT_OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#visit_occurrence), [CONDITION_OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#condition_occurrence), [DRUG_EXPOSURE](https://ohdsi.github.io/CommonDataModel/cdm531.html#drug_exposure), [PROCEDURE-OCCURRENCE](https://ohdsi.github.io/CommonDataModel/cdm531.html#procedure_occurrence), [MEASUREMENT](https://ohdsi.github.io/CommonDataModel/cdm531.html#measurement), [OBSERVATION](https://ohdsi.github.io/CommonDataModel/cdm531.html#observation), [DRUG_ERA](https://ohdsi.github.io/CommonDataModel/cdm531.html#drug_era) and [CONDITION_ERA](https://ohdsi.github.io/CommonDataModel/cdm531.html#condition_era) tables.

##### *I've never used the ERA Tables. Why do I need to populate these?*
The OMOP CDM stores verbatim data from the source across various clinical domains, such as records for conditions, drugs, procedures, and measurements. In addition, to assist the analyst, the CDM also provides some derived tables, based on commonly used analytic procedures. For example, the [Condition_era](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_ERA) table is derived from the [Condition_occurrence](https://github.com/OHDSI/CommonDataModel/wiki/CONDITION_OCCURRENCE) table and both the [Drug_era](https://github.com/OHDSI/CommonDataModel/wiki/DRUG_ERA) and [Dose_era](https://github.com/OHDSI/CommonDataModel/wiki/DOSE_ERA) tables are derived from the [Drug_exposure](https://github.com/OHDSI/CommonDataModel/wiki/DRUG_EXPOSURE) table. An era is defined as a span of time when a patient is assumed to have a given condition or exposure to a particular active ingredient. For network research, it is essential to populate ERA tables so that downstream analytical methods/tools can utilize this information (e.g. ERA tables are required for using [FeatureExtraction](https://github.com/OHDSI/FeatureExtraction) which is the backbone to this package). It is suggested to run ERA scripts at the time of your latest ETL. If processing time is limited, you may choose to omit the Dose_era tables as these are not commonly used in network research. There are [scripts available from the OHDSI community](https://github.com/OHDSI/CommonDataModel/tree/master/CodeExcerpts/DerivedTables).

#### *What if I only have one of the Target cohorts (e.g. COVID-19 only, Influenza only) in my data?*
The package is designed to collect both Influenza cohorts and the COVID-19 cohorts. Unlike other OHDSI Studies where you may expect to have a `CreateCohorts = True`, this study is a little different. In the [`CodeToRun.R`](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/blob/master/extras/CodeToRun.R#L189) you will see a line of code commented out `#cohortGroups = c("covid", "influenza"), # Optional - will use all groups by default`. You can modify this line to run only COVID or Influenza patients. We welcome all sites who have Influenza data between 2017-2018, COVID-19 data or both to participate. If you do not have COVID-19 data, you are invited to run this on your historical flu data. Characterizing prior flu seasons is a unique piece of our overall analysis to better understand how historical analogs apply to COVID-19. This information is very valuable for the community.

#### *Do I have to get IRB approval to run this study?*
Generally, yes. We encourage sites to file the protocol/study results with their local governance committee (e.g. Institutional Review Boards, Publication Review Committees, etc). It is at your discretion whether you choose to file a master protocol for all COVID-19 related work or if you wish to file individual protocols for each subsequent OHDSI network study. In the [Documents](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/tree/master/documents) folder, we will keep an up to date copy of the Protocol (inclusive of any iterative revisions that may arise as we test and validate the overall study package). Please use the documents in this folder in your IRB submissions. If you need additional input, please reach out to the study leads.

#### *What do I need to do to run the package?*
OHDSI study  repos are designed to have information in the README.md (where you are now) to provide you with instructions on how to navigate the repo. This package has two major components:
1. [CohortDiagnostics](http://www.github.com/ohdsi/cohortDiagnostics) - an OHDSI R package used to perform diagnostics around the fitness of use of the study phenotypes on ouyr CDM. By running this package you will allow study leads to understand: cohort inclusion rule attrition, inspect source code lists for a phenotype, find orphan codes that should be in a particular concept set but are not, compute incidnece across calendar years, age and gender, break down index events into specific concepts that triggered then, compute overlap of two cohorts and compute basic characteristics of selected cohorts. This package will be requested of all sites. It is run on all available data not just your COVID-19 or Influenza populations. This allows us to understand how the study phenotypes perform in your database and identify any potentail gaps in the phenotype definitions.
2. RunStudy - the characterization package to evaluate Target-Stratum-Outcome pairings computing cohort characteristics and creating tables/visualizations to summarize differences between groups.

#### *I don't understand the organization of this Github Repo.*
The study repo has the following major pieces:
- `R` folder = the folder which will provide the R library the scripts it needs to execute this study
- `documents` folder = the folder where you will find study documents (protocols, 1-sliders to explain the study, etc)
- `extras` folder = the folder where we store a copy of the instructions (called `CodeToRun.R`) below and other files that the study needs to do things like package maintenance or talk with the Shiny app. Aside from `CodeToRun.R`, you can largely ignore the rest of these files.
- `inst` folder = This is the "install" folder. It contains the most important parts of the study: the study cohort JSONs (analogous to what ATLAS shows you in the Export tab), the study settings, a sub-folder that contains information to the Shiny app, and the study cohort SQL scripts that [SqlRender](https://cran.r-project.org/web/packages/SqlRender/index.html) will use to translate these into your RDBMS.

Below you will find instructions for how to bring this package into your `R`/ `RStudio` environment. Note that if you are not able to connect to the internet in `R`/ `RStudio` to download pacakges, you will have to pull the [TAR file](https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/archive/master.zip). 

#### *What should I do if I get an error when I run the package?*
If you have any issues running the package, please report bugs / roadblocks via GitHub Issues on this repo. Where possible, we ask you share error logs and snippets of warning messages that come up in your `R` console. You may also attach screenshots. Please include the RDMBS (aka your SQL dialect) you work on. If possible, run `traceback()` in your `R` and paste this into your error as well. The study leads will triage these errors with you.

#### *What should I do when I finish?*
If you finish running a study package and upload results to the SFTP, please send an email to [Anthony Sena](mailto:asena5@its.jnj.com) to notify you have dropped results in the folder. The study team will be in touch within 24 hours to acknowledge receipt of your results and review results. If there are no issues, the results will be pushed to the RShiny app. If any errors occur in this process, the study lead will communicate with you and work to resolve this.

## Package Requirements
- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- Suggested: 25 GB of free disk space

See [this video](https://youtu.be/K9_0s2Rchbo) for instructions on how to set up the R environment on Windows.

## How to Run the Study
1. In `R`, you will build an `.Renviron` file. An `.Renviron` is an R environment file that sets variables you will be using in your code. It is encouraged to store these inside your environment so that you can protect sensitive information. Below are brief instructions on how to do this:

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
#    DB_PORT = 5432
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

2. To install the study package (which will build a new R library for you that is specifically for `Covid19CharacterizationCharybdis`), type the following into a new `R` script and run. You can also retrieve this code from `extras/CodeToRun.R`.

````
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
````

*Note: When using this installation method it can be difficult to 'retrace' because you will not see the same folders that you see in the GitHub Repo. If you would prefer to have more visibility into the study contents, you may alternatively download the [TAR file]((https://github.com/ohdsi-studies/Covid19CharacterizationCharybdis/archive/master.zip) for this repo and bring this into your `R`/`RStudio` environment. An example of how to call ZIP files into your `R` environment can be found in the [The Book of OHDSI](https://ohdsi.github.io/TheBookOfOhdsi/PopulationLevelEstimation.html#running-the-study-package).*

3. Great work! Now you have set-up your environment and installed the library that will run the package. You can use the following `R` script to load in your library and configure your environment connection details:

```
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
````
4. You will first need to run the `CohortDiagnostics` package on your entire database. This package is used as a diagnostic to provide transparency into the concept prevalence in your database as it relates to the concept sets and phenotypes we've prepared for the Target, Stratum and Features included in this analysis. We encourage sites to share this information so that we can help design better studies that capture the nuance of your local care delivery and coding practices.

````
# Run cohort diagnostics -----------------------------------
runCohortDiagnostics(connectionDetails = connectionDetails,
                     cdmDatabaseSchema = cdmDatabaseSchema,
                     cohortDatabaseSchema = cohortDatabaseSchema,
                     cohortStagingTable = cohortStagingTable,
                     oracleTempSchema = oracleTempSchema,
                     cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
                     exportFolder = outputFolder,
                     #cohortGroupNames = c("covid", "influenza", "strata", "feature"), # Optional - will use all groups by default
                     databaseId = databaseId,
                     databaseName = databaseName,
                     databaseDescription = databaseDescription,
                     minCellCount = minCellCount)
````

this package may take some time to run. This is normal. Allow at least 1-2 hours for this step. Sites with very large databases may experience longer run times.

When the package is completed, you can view the `CohortDiagnostics` output in a local Shiny viewer:
````
# Use the next command to review cohort diagnostics and replace "covid" with
# one of these options: "covid", "influenza", "strata", "feature"
# CohortDiagnostics::launchDiagnosticsExplorer(file.path(outputFolder, "diagnostics", "covid"))
````

5. Once you have run `CohortDiagnostics` you are encouraged to reach out to the study leads to review your outputs. 

6. You can now run the characterization package. This step is designed to take advantage of incremental building. This means if the job fails, the R package will start back up where it left off. This package has been designed to be computationally efficient. It is estimated this would take a half hour or less to execute this step.

In your `R` script, you will use the following code:
````
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
         #cohortGroups = c("covid", "influenza"), # Optional - will use all groups by default
         cohortIdsToExcludeFromExecution = cohortIdsToExcludeFromExecution,
         cohortIdsToExcludeFromResultsExport = cohortIdsToExcludeFromResultsExport,
         incremental = TRUE,
         useBulkCharacterization = useBulkCharacterization,
         minCellCount = minCellCount) 
  ````

7. You can now look at the characterization output in a local Shiny application:
````
CohortDiagnostics::preMergeDiagnosticsFiles(outputFolder)
launchShinyApp(outputFolder)
````

6. If the study code runs to completion, your outputFolder will have the following contents:
- RecordKeeping = a folder designed to store incremental information such that if the study code dies, it will restart where it left off
- cohort.csv: An export of the cohort definitions used in the study. This is simply a cross reference for the other files and does not contain sensitive information.
- _**cohort_count.csv**_: Contains the list of target and strata cohorts in the study with their counts. The fields `cohort_entries` and cohort_subjects` contain the number of people in the cohort. 
- _**cohort_staging_count.csv**_: Contains a full list of all cohorts produced by the code in the study inclusive of features. The fields `cohort_entries` and cohort_subjects` contain the number of people in the cohort. 
- covariate.csv: A list of features that were identified in the analyzed cohorts. This is a cross reference file with names and does not contain sensitive information.
- _**covariate_value.csv**_: Contains the statistics produced by the study. The field `mean` will contain the proportion computed. When censored, you will see negative values in this field. 
- database.csv: Contains metadata information that you supplied as part of running the package to identify the database across the OHDSI network. Additionally, the vocabulary version used in your CDM is included.
- **_feature_proportion.csv_**: This file contains the list of feature proportions calculated through the combination of target/stratified and features. The fields `total_count`,`feature_count`, contain the subject counts for the cohort and feature respectively. The field `mean` contains the proportion of `total_count/feature_count`. 

Those files noted in **_bold italics_** above should be reviewed for sensitive information for your site. The package will censor values based on the `minCellCount` parameter specified when calling the `runStudy` function. Censored values will be represented with a negative to show it has been censored. In the case of the fields `cohort_entries` and cohort_subjects`, this will be -5 (where 5=your min cell count specified). In the case of the `mean` field, this will be a negative representation of that proportion that was censored.

As a data owner, you will want to inspect these files for adherence to the minCellCount you input. You may find that only some files are generated. If this happens, please reach out to the study leads to debug. 

5. To utilize the `OhdsiSharing` library to connect and upload results to the OHDSI STFP server, you will need a site key. You may reach out to the study leads to get a key file. You will store this key file in a place that is retrievable by your `R`/`RStudio` environment (e.g. on your desktop if local `R` or uploaded to a folder in the cloud for `RServer`)

Once you have checked results, you can use the following code to send:
````
# For uploading the results. You should have received the key file from the study coordinator:
#keyFileName <- "c:/home/keyFiles/study-data-site-covid19.dat"
#userName <- "study-data-site-covid19"

# Upload results to OHDSI SFTP server:
#uploadResults(outputFolder, keyFileName, userName)
````

Please send an email to [Anthony Sena](mailto:asena5@its.jnj.com) to notify you have dropped results in the folder.
