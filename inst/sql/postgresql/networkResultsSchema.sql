DROP TABLE IF EXISTS @network_results_schema.cohort;
CREATE TABLE @network_results_schema.cohort
(
    cohort_id bigint NOT NULL,
    target_id bigint,
    target_name character varying(4000),
    subgroup_id bigint,
    subgroup_name character varying(4000),
    cohort_type character varying(4000)
)
;

DROP TABLE IF EXISTS @network_results_schema.cohort_count;
CREATE TABLE @network_results_schema.cohort_count
(
    cohort_id bigint,
    cohort_entries bigint,
    cohort_subjects bigint,
    database_id character varying(255)
)
;

DROP TABLE IF EXISTS @network_results_schema.covariate;
CREATE TABLE @network_results_schema.covariate
(
    covariate_id bigint,
    covariate_name character varying(4000),
    covariate_analysis_id bigint,
    time_window_id bigint
)
;

DROP TABLE IF EXISTS @network_results_schema.covariate_value;
CREATE TABLE @network_results_schema.covariate_value
(
    cohort_id bigint,
    covariate_id bigint,
    mean numeric,
    sd numeric,
    database_id character varying(255)
)
;

DROP TABLE IF EXISTS @network_results_schema.database;
CREATE TABLE @network_results_schema.database
(
    database_id character varying(255),
    database_name character varying(255),
    description character varying(4000),
    vocabulary_version character varying(255),
    min_obs_period_date character varying(255),
    max_obs_period_date character varying(255),
    is_meta_analysis integer
)
