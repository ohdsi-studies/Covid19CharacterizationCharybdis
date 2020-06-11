SELECT 
  c.cohort_definition_id, 
  f.feature_cohort_definition_id,
  f.window_id,
  c.total_count,
  f.feature_count,
  1.0*f.feature_count/c.total_count AS mean,
  sqrt(1.0*(total_count*f.feature_count - f.feature_count*f.feature_count)/(c.total_count*(c.total_count - 1))) AS sd
FROM (
  SELECT cohort_definition_id, COUNT_BIG(DISTINCT subject_id) total_count
  FROM @cohort_database_schema.@cohort_table 
  GROUP BY cohort_definition_id
) c
INNER JOIN @cohort_database_schema.@feature_summary_table f -- Feature Count
  ON c.cohort_definition_id = f.cohort_definition_id
  AND c.total_count > 1 -- Prevent divide by zero
;