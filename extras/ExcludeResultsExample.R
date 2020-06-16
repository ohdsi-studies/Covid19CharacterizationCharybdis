allCohorts <- Covid19CharacterizationCharybdis::getAllStudyCohortsWithDetails()
kidneyCohorts <- allCohorts[allCohorts$strataCohortName %in% c("Prevalent chronic kidney disease", "Prevalent chronic kidney disease broad"), ]
Covid19CharacterizationCharybdis::exportResults("E:/CHARYBDIS/DATABASE_ID", "DATABASE_ID", kidneyCohorts$cohortId)
