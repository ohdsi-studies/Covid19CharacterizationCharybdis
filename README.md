Characterizing Health Associated Risks, and Your Baseline Disease In SARS-COV-2 (CHARYBDIS)
=============

<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started"> 

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

Objectives: 1) Describe the baseline demographic, clinical characteristics, treatments and outcomes of interest among individuals tested for SARS-CoV-2 and/or diagnosed with COVID-19 overall and stratified by sex, age and specific comorbidities; 2) Describe characteristics and outcomes of hospitalized influenza patients between September 2017 and April 2018 compared to the COVID-19 population.

## Installation

To install, in R type:

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
devtools::install_github("ohdsi-studies/Covid19Characterization")
````

See `extras/CodeToRun.R` for instructions on how to run.
