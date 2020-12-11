-- Since each site produces its own list of covarites, our data
-- load into the network results table will contain duplicates if 
-- more than 1 site has the same covariate entry. This script
-- will deduplicate the results and replace the existing covariate 
-- table
with cvData AS (
	select covariate_id, covariate_name, covariate_analysis_id, CAST(RIGHT(CAST(covariate_id AS varchar), 1) AS INTEGER) as time_window_id, ROW_NUMBER() OVER (PARTITION BY covariate_id) rn
	from @network_results_schema.covariate
)
SELECT covariate_id, covariate_name, covariate_analysis_id, time_window_id
INTO @network_results_schema.covariate_deduped
FROM cvData
WHERE rn = 1
;

DROP TABLE @network_results_schema.covariate;
ALTER TABLE @network_results_schema.covariate_deduped RENAME TO covariate;
