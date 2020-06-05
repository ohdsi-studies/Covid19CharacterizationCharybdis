## README

For this study, it was necessary to utilize several files and folder for storing the settings. The contents of this folder and subfolders is described here.

- **CohortGroups.csv**: This file contains the cohort groups that are used in this package along with the reference to the files that hold the individual cohort details. 
- **CohortGroupsDiagnostics.csv**: Same in purpose as the CohortGroups.csv mentioned above except that it points to resource files in the "diagnostics" folder. This was done for calling CohortDiagnostics since that package expects the "name" field to match the SQL file name. It is a work-around for now.
- **CohortsToCreate<Group>.csv**: This group of files contain the cohorts to create per <group>. Unlike other OHDSI study packages, the cohortId is used to identify the cohort's SQL/JSON in the inst/sql/sql_server and inst/cohorts folders respectively.
- **BulkStrata.csv**: This file contains the list of "bulk" strata that are created in the study. The difference between this and the CohortsToCreateStrata.csv is that the bulk operations utilize separate SQL files.
- **featureTimeWindows.csv**: Contains the list of time windows in which to create features.
- **targetStrataXref.csv**: Contains the full list of all combination of target/strata cohorts. This file is produced by the extras/PackageMaintenance.R file.

The "subset" folder contains the same files as above but for a subset of the full study cohorts.
