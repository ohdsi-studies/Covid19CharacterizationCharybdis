@target_strata_xref_table_create

DELETE FROM @cohort_database_schema.@cohort_staging_table
WHERE cohort_definition_id IN (SELECT DISTINCT cohort_id FROM #TARGET_STRATA_XREF)
;

INSERT INTO @cohort_database_schema.@cohort_staging_table (
  cohort_definition_id,
  subject_id,
  cohort_start_date,
  cohort_end_date
)
SELECT 
  x.cohort_id,
  s.subject_id,
  s.cohort_start_date,
  s.cohort_end_date
FROM (
  -- Stratify the cohort
  SELECT 
    c.cohort_definition_id, 
    c.subject_id, 
    c.cohort_start_date, 
    c.cohort_end_date  FROM @cohort_database_schema.@cohort_staging_table c
  INNER JOIN (SELECT DISTINCT target_id FROM #TARGET_STRATA_XREF) x ON x.target_id = c.cohort_definition_id
  INNER JOIN @cdm_database_schema.person p ON c.subject_id = p.person_id
    AND (
      YEAR(c.cohort_start_date) - p.year_of_birth @lb_operator @lb_strata_value AND
      YEAR(c.cohort_start_date) - p.year_of_birth @ub_operator @ub_strata_value
    )
) s
INNER JOIN #TARGET_STRATA_XREF x ON s.cohort_definition_id = x.target_id
;


@target_strata_xref_table_drop