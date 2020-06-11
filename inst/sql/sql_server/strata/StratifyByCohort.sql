@target_strata_xref_table_create

DELETE FROM @cohort_database_schema.@cohort_staging_table
WHERE cohort_definition_id IN (SELECT DISTINCT cohort_id FROM #TARGET_STRATA_XREF)
;

--find T with S, create a temp table to hold these new cohorts
select cr1.cohort_id cohort_definition_id, 
  t.subject_id,
  t.cohort_start_date,
  t.cohort_end_date
into #t_w_s_cohort
from
(select * from #TARGET_STRATA_XREF where cohort_type = 'TwS') cr1
inner join
(
   select c1.cohort_definition_id, c1.subject_id, c1.cohort_start_date, c1.cohort_end_date
   from @cohort_database_schema.@cohort_staging_table as c1
   inner join (SELECT DISTINCT target_id cohort_definition_id FROM #TARGET_STRATA_XREF) as cr1
   on c1.cohort_definition_id = cr1.cohort_definition_id
) t
on cr1.target_id = t.cohort_definition_id
inner join
(
   select c1.cohort_definition_id, c1.subject_id, c1.cohort_start_date, c1.cohort_end_date
   from @cohort_database_schema.@cohort_staging_table as c1
   inner join (SELECT DISTINCT strata_id cohort_definition_id FROM #TARGET_STRATA_XREF) as cr1
   on c1.cohort_definition_id = cr1.cohort_definition_id
) s
on cr1.strata_id = s.cohort_definition_id
and t.subject_id = s.subject_id
and s.cohort_start_date <= t.cohort_start_date
and s.cohort_end_date >= t.cohort_start_date
;


--find T without S, create a temp table to hold these new cohorts
select cr1.cohort_id cohort_definition_id, 
  t.subject_id,
  t.cohort_start_date,
  t.cohort_end_date
into #t_wo_s_cohort
from
(select * from #TARGET_STRATA_XREF where cohort_type = 'TwoS') cr1
inner join
(
   select c1.cohort_definition_id, c1.subject_id, c1.cohort_start_date, c1.cohort_end_date
   from @cohort_database_schema.@cohort_staging_table as c1
   inner join (SELECT DISTINCT target_id cohort_definition_id FROM #TARGET_STRATA_XREF) as cr1
   on c1.cohort_definition_id = cr1.cohort_definition_id
) t
on cr1.target_id = t.cohort_definition_id
left join
(
   select c1.cohort_definition_id, c1.subject_id, c1.cohort_start_date, c1.cohort_end_date
   from @cohort_database_schema.@cohort_staging_table as c1
   inner join (SELECT DISTINCT strata_id cohort_definition_id FROM #TARGET_STRATA_XREF) as cr1
   on c1.cohort_definition_id = cr1.cohort_definition_id
) s
on cr1.strata_id = s.cohort_definition_id
and t.subject_id = s.subject_id
and s.cohort_start_date <= t.cohort_start_date
and s.cohort_end_date >= t.cohort_start_date
where s.cohort_definition_id is null
;

INSERT INTO @cohort_database_schema.@cohort_staging_table (
	cohort_definition_id,
	subject_id,
	cohort_start_date,
	cohort_end_date
)
-- T with S
select cohort_definition_id, subject_id, cohort_start_date, cohort_end_date
from #t_w_s_cohort

union all
-- T without S
select cohort_definition_id, subject_id, cohort_start_date, cohort_end_date
from #t_wo_s_cohort
;


TRUNCATE TABLE #t_w_s_cohort;
DROP TABLE #t_w_s_cohort;

TRUNCATE TABLE #t_wo_s_cohort;
DROP TABLE #t_wo_s_cohort;

@target_strata_xref_table_drop