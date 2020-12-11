ALTER TABLE @network_results_schema.cohort_count ADD PRIMARY KEY (cohort_id, database_id);
CREATE INDEX idx_cohort_count ON @network_results_schema.cohort_count (cohort_id, database_id);

ALTER TABLE @network_results_schema.covariate ADD PRIMARY KEY (covariate_id);
CREATE INDEX idx_covariate_time_window_id ON @network_results_schema.covariate (time_window_id);

ALTER TABLE @network_results_schema.covariate_value ADD PRIMARY KEY (cohort_id, covariate_id, database_id);
CREATE INDEX idx_cv_cohort_id ON @network_results_schema.covariate_value (cohort_id);
CREATE INDEX idx_cv_covariate_id ON @network_results_schema.covariate_value (covariate_id);
CREATE INDEX idx_cv_database_id ON @network_results_schema.covariate_value (database_id);

ALTER TABLE @network_results_schema.database ADD PRIMARY KEY (database_id);