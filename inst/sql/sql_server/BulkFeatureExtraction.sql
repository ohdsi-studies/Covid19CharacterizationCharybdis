{DEFAULT @gender_analysis_id = 1}
{DEFAULT @age_group_analysis_id = 3}
{DEFAULT @drug_group_analysis_id = 412}
{DEFAULT @condition_group_analysis_id = 212}

@cohort_subset_table_create

@feature_time_window_table_create

IF OBJECT_ID('tempdb..#cov_ref', 'U') IS NOT NULL
  DROP TABLE #cov_ref;

IF OBJECT_ID('tempdb..#analysis_results', 'U') IS NOT NULL
  DROP TABLE #analysis_results;

CREATE TABLE #cov_ref (
  covariate_id BIGINT,
  covariate_name VARCHAR(512),
  analysis_id INT,
  analysis_name VARCHAR(512),
  concept_id INT
);

CREATE TABLE #analysis_results (
  cohort_id BIGINT,
  covariate_id BIGINT,
  sum_value BIGINT,
  mean FLOAT,
  sd FLOAT
);

-- Get the cohort counts
IF OBJECT_ID('tempdb..#cohort_counts', 'U') IS NOT NULL
  DROP TABLE #cohort_counts;

SELECT cohort_definition_id, COUNT_BIG(DISTINCT subject_id) total_count
INTO #cohort_counts
FROM @cohort_database_schema.@cohort_table c
INNER JOIN #cohort_subset xref ON xref.cohort_id = c.cohort_definition_id
GROUP BY c.cohort_definition_id
;

/*************/
/* Age Group */
/*************/
IF OBJECT_ID('tempdb..#age_group', 'U') IS NOT NULL DROP TABLE #age_group
;

SELECT 
  cohort.cohort_definition_id,
  CAST(FLOOR((YEAR(cohort_start_date) - year_of_birth) / 5) * 1000 + @age_group_analysis_id AS BIGINT) AS covariate_id,
	COUNT_BIG(DISTINCT cohort.subject_id) AS sum_value
INTO #age_group
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN #cohort_subset xref ON cohort.cohort_definition_id = xref.cohort_id
INNER JOIN @cdm_database_schema.person
	ON cohort.subject_id = person.person_id
GROUP BY 
  cohort.cohort_definition_id,
  FLOOR((YEAR(cohort_start_date) - year_of_birth) / 5)
;

-- Reference construction
INSERT INTO #cov_ref (
	covariate_id,
	covariate_name,
	analysis_id,
	concept_id
	)
SELECT 
  covariate_id * 10 + 1, -- To match way the cohort construction is done when running sequentially in R
	CAST(CONCAT (
		'age group: ',
		RIGHT(CONCAT('00', CAST(5 * (covariate_id - @age_group_analysis_id) / 1000 AS VARCHAR)), 2),
		'-',
		RIGHT(CONCAT('00', CAST((5 * (covariate_id - @age_group_analysis_id) / 1000) + 4 AS VARCHAR)), 2)
		) AS VARCHAR(512)) AS covariate_name,
	@age_group_analysis_id AS analysis_id,
	0 AS concept_id
FROM (
	SELECT DISTINCT covariate_id
	FROM #age_group
) t1;

/*************/
/*  Gender   */
/*************/
IF OBJECT_ID('tempdb..#gender', 'U') IS NOT NULL drop table #gender
;

SELECT 
  cohort_definition_id,
	CAST(gender_concept_id AS BIGINT) * 1000 + @gender_analysis_id AS covariate_id,
	COUNT_BIG(DISTINCT cohort.subject_id) AS sum_value
INTO #gender
FROM @cohort_database_schema.@cohort_table cohort
INNER JOIN #cohort_subset xref ON cohort.cohort_definition_id = xref.cohort_id
INNER JOIN @cdm_database_schema.person
	ON cohort.subject_id = person.person_id
WHERE gender_concept_id != 0		
GROUP BY cohort_definition_id, gender_concept_id
;

-- Reference construction
INSERT INTO #cov_ref (
	covariate_id,
	covariate_name,
	analysis_id,
	concept_id
	)
SELECT 
  covariate_id * 10 + 1, -- To match way the cohort construction is done when running sequentially in R
	CAST(CONCAT('gender = ', CASE WHEN concept_name IS NULL THEN 'Unknown concept' ELSE concept_name END) AS VARCHAR(512)) AS covariate_name,
	@gender_analysis_id AS analysis_id,
	CAST((covariate_id - @gender_analysis_id) / 1000 AS INT) AS concept_id
FROM (
	SELECT DISTINCT covariate_id
	FROM #gender
	) t1
LEFT JOIN @cdm_database_schema.concept
	ON concept_id = CAST((covariate_id - @gender_analysis_id) / 1000 AS INT);

/*************/
/** Demographics Results **/
/*************/

-- Consolidate results
INSERT INTO #analysis_results (
  cohort_id,
  covariate_id,
  sum_value,
  mean,
  sd
)
SELECT 
  c.cohort_definition_id, 
  f.covariate_id,
  f.sum_value,
  1.0*f.sum_value/c.total_count AS mean,
  sqrt(1.0*(total_count*f.sum_value - f.sum_value*f.sum_value)/(c.total_count*(c.total_count - 1))) AS sd
FROM #cohort_counts c
INNER JOIN (
	SELECT 
	  cohort_definition_id,
	  (covariate_id * 10 + 1) covariate_id, -- To match way the cohort construction is done when running sequentially in R
	  sum_value
	FROM #age_group
	UNION
	SELECT 
	  cohort_definition_id,
	  (covariate_id * 10 + 1) covariate_id, -- To match way the cohort construction is done when running sequentially in R
	  sum_value
	FROM #gender
) f ON f.cohort_definition_id = c.cohort_definition_id
;

/***************

summarize drug groups

****************/
IF OBJECT_ID('tempdb..#groups', 'U') IS NOT NULL DROP TABLE #groups;

SELECT DISTINCT descendant_concept_id,
ancestor_concept_id
INTO #groups
FROM @cdm_database_schema.concept_ancestor
INNER JOIN @cdm_database_schema.concept
ON ancestor_concept_id = concept_id
WHERE ((vocabulary_id = 'ATC'
	  AND LEN(concept_code) IN (1, 3, 4, 5))
	 OR (standard_concept = 'S' 
		 AND concept_class_id = 'Ingredient'
		 AND domain_id = 'Drug'))
AND concept_id != 0
;

IF OBJECT_ID('tempdb..#dg_covariate_table', 'U') IS NOT NULL drop table #dg_covariate_table;


SELECT 
	cohort_definition_id,
	window_id,
	CAST(ancestor_concept_id AS BIGINT) * 1000 + @drug_group_analysis_id AS covariate_id,
	sum_value
INTO #dg_covariate_table
FROM (
  SELECT 
	cohort.cohort_definition_Id, 
	cohort.window_id,
	g1.ancestor_concept_id,
    COUNT_BIG(DISTINCT cohort.subject_id) AS sum_value
  FROM (
	SELECT *
	FROM @cohort_database_schema.@cohort_table cohort, #feature_windows w
  ) cohort
  INNER JOIN #cohort_subset xref ON cohort.cohort_definition_id = xref.cohort_id
  INNER JOIN @cdm_database_schema.drug_era de
  ON cohort.subject_id = de.person_id
  INNER JOIN #groups g1
  ON de.drug_concept_id = g1.descendant_concept_id
    WHERE de.drug_era_start_date <= DATEADD(DAY, cohort.window_end, cohort.cohort_start_date)
    AND de.drug_era_end_date >= DATEADD(DAY, cohort.window_start, cohort.cohort_start_date)
  GROUP BY 
	cohort.cohort_definition_Id, 
	cohort.window_id,
	g1.ancestor_concept_id
) temp
;

-- Reference construction
INSERT INTO #cov_ref (
	covariate_id,
	covariate_name,
	analysis_id,
	concept_id
	)
SELECT 
	covariate_id * 10 + window_id,
	CAST(CONCAT('drug_era group during day ', t1.window_start, ' through ', t1.window_end, ' days relative to index: ', CASE WHEN concept_name IS NULL THEN 'Unknown concept' ELSE concept_name END) AS VARCHAR(512)) AS covariate_name,
	@drug_group_analysis_id AS analysis_id,
	CAST((covariate_id - @drug_group_analysis_id) / 1000 AS INT) AS concept_id
FROM (
	SELECT DISTINCT cov.covariate_id, w.window_id, w.window_start, w.window_end
	FROM #dg_covariate_table cov
	INNER JOIN #feature_windows w ON cov.window_id = w.window_id
) t1
LEFT JOIN @cdm_database_schema.concept
	ON concept_id = CAST((covariate_id - @drug_group_analysis_id) / 1000 AS INT)
;

/***************

summarize condition groups

****************/
IF OBJECT_ID('tempdb..#groups', 'U') IS NOT NULL DROP TABLE #groups;

SELECT DISTINCT descendant_concept_id,
  ancestor_concept_id
INTO #groups
FROM @cdm_database_schema.concept_ancestor
  INNER JOIN (
    SELECT concept_id
    FROM @cdm_database_schema.concept
    INNER JOIN (
      SELECT *
        FROM @cdm_database_schema.concept_ancestor
      WHERE ancestor_concept_id = 441840 /* SNOMED clinical finding */
        AND (min_levels_of_separation > 2
             OR descendant_concept_id IN (433736, 433595, 441408, 72404, 192671, 137977, 434621, 437312, 439847, 4171917, 438555, 4299449, 375258, 76784, 40483532, 4145627, 434157, 433778, 258449, 313878)
        ) 
    ) temp
    ON concept_id = descendant_concept_id
    WHERE concept_name NOT LIKE '%finding'
    AND concept_name NOT LIKE 'Disorder of%'
    AND concept_name NOT LIKE 'Finding of%'
    AND concept_name NOT LIKE 'Disease of%'
    AND concept_name NOT LIKE 'Injury of%'
    AND concept_name NOT LIKE '%by site'
    AND concept_name NOT LIKE '%by body site'
    AND concept_name NOT LIKE '%by mechanism'
    AND concept_name NOT LIKE '%of body region'
    AND concept_name NOT LIKE '%of anatomical site'
    AND concept_name NOT LIKE '%of specific body structure%'
    AND domain_id = 'Condition'
) valid_groups
  ON ancestor_concept_id = valid_groups.concept_id
;

IF OBJECT_ID('tempdb..#cg_covariate_table', 'U') IS NOT NULL drop table #cg_covariate_table;

SELECT 
	cohort_definition_id,
	window_id,
	CAST(ancestor_concept_id AS BIGINT) * 1000 + @condition_group_analysis_id AS covariate_id,
	sum_value
INTO #cg_covariate_table
FROM (
  SELECT 
	cohort.cohort_definition_id, 
	cohort.window_id,
	g1.ancestor_concept_id,
    COUNT_BIG(DISTINCT cohort.subject_id) AS sum_value
  FROM (
	SELECT *
	FROM @cohort_database_schema.@cohort_table cohort, #feature_windows w
  ) cohort
  INNER JOIN #cohort_subset xref ON cohort.cohort_definition_id = xref.cohort_id
  INNER JOIN @cdm_database_schema.condition_era ce
  ON cohort.subject_id = ce.person_id
  INNER JOIN #groups g1
  ON ce.condition_concept_id = g1.descendant_concept_id
    WHERE ce.condition_era_start_date <= DATEADD(DAY, cohort.window_end, cohort.cohort_start_date)
    AND ce.condition_era_end_date >= DATEADD(DAY, cohort.window_start, cohort.cohort_start_date)
  GROUP BY 
	cohort.cohort_definition_id, 
	cohort.window_id,
	g1.ancestor_concept_id
) temp
;

-- Reference construction
INSERT INTO #cov_ref (
	covariate_id,
	covariate_name,
	analysis_id,
	concept_id
	)
SELECT 
	covariate_id * 10 + window_id,
	CAST(CONCAT('condition_era group during day ', t1.window_start, ' through ', t1.window_end, ' days relative to index: ', CASE WHEN concept_name IS NULL THEN 'Unknown concept' ELSE concept_name END) AS VARCHAR(512)) AS covariate_name,
	@condition_group_analysis_id AS analysis_id,
	CAST((covariate_id - @condition_group_analysis_id) / 1000 AS INT) AS concept_id
FROM (
	SELECT DISTINCT cov.covariate_id, w.window_id, w.window_start, w.window_end
	FROM #cg_covariate_table cov
	INNER JOIN #feature_windows w ON cov.window_id = w.window_id
) t1
LEFT JOIN @cdm_database_schema.concept
	ON concept_id = CAST((covariate_id - @condition_group_analysis_id) / 1000 AS INT)
;

/*************/
/** Drug/Condition Group Results **/
/*************/

-- Consolidate results
INSERT INTO #analysis_results (
  cohort_id,
  covariate_id,
  sum_value,
  mean,
  sd
)
SELECT 
  c.cohort_definition_id, 
  f.covariate_id * 10 + window_id,
  f.sum_value,
  1.0*f.sum_value/c.total_count AS mean,
  sqrt(1.0*(total_count*f.sum_value - f.sum_value*f.sum_value)/(c.total_count*(c.total_count - 1))) AS sd
FROM #cohort_counts c
INNER JOIN (
	SELECT *
	FROM #dg_covariate_table 
	UNION
	SELECT *
	FROM #cg_covariate_table 
)f ON f.cohort_definition_id = c.cohort_definition_id
;

TRUNCATE TABLE #age_group;
DROP TABLE #age_group;

TRUNCATE TABLE #gender;
DROP TABLE #gender;

TRUNCATE TABLE #groups;
DROP TABLE #groups;

TRUNCATE TABLE #dg_covariate_table;
DROP TABLE #dg_covariate_table;

TRUNCATE TABLE #cg_covariate_table;
DROP TABLE #cg_covariate_table;

@cohort_subset_table_drop

@feature_time_window_table_drop
