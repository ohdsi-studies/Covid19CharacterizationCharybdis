@target_strata_xref_table_create

IF OBJECT_ID('@cohort_database_schema.@cohort_table', 'U') IS NOT NULL
	DROP TABLE @cohort_database_schema.@cohort_table;

CREATE TABLE @cohort_database_schema.@cohort_table (
	cohort_definition_id INT,
	subject_id BIGINT,
	cohort_start_date DATE,
	cohort_end_date DATE
);


--summarize counts of cohorts so we can filter to those that are feasible
select cohort_definition_id, count(distinct subject_id) as num_persons
into #cohort_summary
from @cohort_database_schema.@cohort_staging_table
group by cohort_definition_id
;


--find all feasible analyses:   T > X;   TwS and TwoS  > X
INSERT INTO @cohort_database_schema.@cohort_table (
	cohort_definition_id,
	subject_id,
	cohort_start_date,
	cohort_end_date
)
-- T > X;
select 
  s.cohort_definition_id,
	s.subject_id,
	s.cohort_start_date,
	s.cohort_end_date
from @cohort_database_schema.@cohort_staging_table as s
inner join (
  SELECT cs.cohort_definition_id
  FROM #cohort_summary cs
  INNER JOIN (SELECT DISTINCT target_id cohort_definition_id FROM #TARGET_STRATA_XREF) t 
  ON t.cohort_definition_id = cs.cohort_definition_id 
  where cs.num_persons > @min_cell_count
  UNION ALL
  -- Bulk strata cohorts will contain only 1 entry
  -- so they must be identified by the presence of only a single
  -- cohort_type
  SELECT DISTINCT xref.cohort_id
  FROM (
  	SELECT strata_id, target_id, COUNT(DISTINCT cohort_type) cnt
  	FROM #TARGET_STRATA_XREF
  	group by strata_id, target_id HAVING COUNT(DISTINCT cohort_type) = 1
  ) single
  INNER JOIN #TARGET_STRATA_XREF xref ON single.strata_id = xref.strata_id
    AND single.target_id = xref.target_id
) cs1 on s.cohort_definition_id = cs1.cohort_definition_id

union all
-- TwS and TwoS  > X
select 
  s.cohort_definition_id,
	s.subject_id,
	s.cohort_start_date,
	s.cohort_end_date
from @cohort_database_schema.@cohort_staging_table as s
inner join (
  SELECT cr1.cohort_id cohort_definition_id
  from #TARGET_STRATA_XREF cr1
  inner join #cohort_summary cs1
  on cr1.cohort_id = cs1.cohort_definition_id
  inner join #TARGET_STRATA_XREF cr2
  on cr1.target_id = cr2.target_id
  and cr1.strata_id = cr2.strata_id
  and cr1.cohort_type <> cr2.cohort_type
  inner join #cohort_summary cs2
  on cr2.cohort_id = cs2.cohort_definition_id 
  where cs1.num_persons > @min_cell_count
    and cs2.num_persons > @min_cell_count
) cs1 ON s.cohort_definition_id = cs1.cohort_definition_id
;

CREATE INDEX IDX_@cohort_table ON @cohort_database_schema.@cohort_table (cohort_definition_id, subject_id, cohort_start_date);

TRUNCATE TABLE #cohort_summary;
DROP TABLE #cohort_summary;

@target_strata_xref_table_drop