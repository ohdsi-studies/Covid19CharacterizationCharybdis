CREATE TABLE #Codesets (
  codeset_id int NOT NULL,
  concept_id bigint NOT NULL
)
;

INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 4 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (262,9201)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (262,9201)
  and c.invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 13 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (4146943,46274060,4266367,42537960,4112824,4299935,46269710,763011)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4146943,46274060,4266367,42537960,4112824,4299935,46269710,763011)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (4042202)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (4042202)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 14 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (45757530,4262075)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (45757530,4262075)
  and c.invalid_reason is null

) I
) C;
INSERT INTO #Codesets (codeset_id, concept_id)
SELECT 15 as codeset_id, c.concept_id FROM (select distinct I.concept_id FROM
( 
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (44789500,37392950,37394410,36676240,3001703,3016424,3038149,3016676,3017256,3020370,2213094,2213181,2213063,2213062,40757080,40756900,4039357,37392220,44806470,37394300,4044987,4039358,37392220,44807860,37394300,4044988,37392760,40653950,40655680,40655680,40655680,40655680,40655680,40655690,40655690,37080280,40655690,40655690,40655690,40655690,4047171,40655690,40484560,3002988,3002646,3003682)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (44789500,37392950,37394410,36676240,3001703,3016424,3038149,3016676,3017256,3020370,2213094,2213181,2213063,2213062,40757080,40756900,4039357,37392220,44806470,37394300,4044987,4039358,37392220,44807860,37394300,4044988,37392760,40653950,40655680,40655680,40655680,40655680,40655680,40655690,40655690,37080280,40655690,40655690,40655690,40655690,4047171,40655690,40484560,3002988,3002646,3003682)
  and c.invalid_reason is null

) I
LEFT JOIN
(
  select concept_id from @vocabulary_database_schema.CONCEPT where concept_id in (37066970,3002696,3000619,3023674,3001047,3007341,37398130,4201049,37393220,44805900,45757530,37393230,4196405,44805900,4262075,40760330,37048820,37058510,37055730,37040770,37023170,37075080,37041510,37066450,37057350,37054340,37022660,37068000,37028300,37054450,37036580,37078460,37067500,37070650,37048010,37071080,37042030,37024680,37042070,37052160,37037250,37072520,37044560,37025180,37063380,37068550,37045810,37036250,37064420,37037940,37062170,37076140,37034230,37051890,37075960,37022370,37031120,37073630,37057850,37042870,37075260,37030630,37059250,37037960,37047320,37075850,37073490,37056310,37029360,37023420,37073270,37076380,37069810,37026920,37048910,37074410,37040740,37076800,37075490,37072740,40758390,42869810,40758150,3043198,4017924,37050280,3026510,3027889)
UNION  select c.concept_id
  from @vocabulary_database_schema.CONCEPT c
  join @vocabulary_database_schema.CONCEPT_ANCESTOR ca on c.concept_id = ca.descendant_concept_id
  and ca.ancestor_concept_id in (37066970,3002696,3000619,3023674,3001047,3007341,37398130,4201049,37393220,44805900,45757530,37393230,4196405,44805900,4262075,40760330,37048820,37058510,37055730,37040770,37023170,37075080,37041510,37066450,37057350,37054340,37022660,37068000,37028300,37054450,37036580,37078460,37067500,37070650,37048010,37071080,37042030,37024680,37042070,37052160,37037250,37072520,37044560,37025180,37063380,37068550,37045810,37036250,37064420,37037940,37062170,37076140,37034230,37051890,37075960,37022370,37031120,37073630,37057850,37042870,37075260,37030630,37059250,37037960,37047320,37075850,37073490,37056310,37029360,37023420,37073270,37076380,37069810,37026920,37048910,37074410,37040740,37076800,37075490,37072740,40758390,42869810,40758150,3043198,4017924,37050280,3026510,3027889)
  and c.invalid_reason is null

) E ON I.concept_id = E.concept_id
WHERE E.concept_id is null
) C;


with primary_events (event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id) as
(
-- Begin Primary Events
select P.ordinal as event_id, P.person_id, P.start_date, P.end_date, op_start_date, op_end_date, cast(P.visit_occurrence_id as bigint) as visit_occurrence_id
FROM
(
  select E.person_id, E.start_date, E.end_date,
         row_number() OVER (PARTITION BY E.person_id ORDER BY E.sort_date ASC) ordinal,
         OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date, cast(E.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM 
  (
  -- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C

WHERE (C.visit_start_date >= DATEFROMPARTS(2017, 09, 01) and C.visit_start_date <= DATEFROMPARTS(2018, 04, 01))
-- End Visit Occurrence Criteria

  ) E
	JOIN @cdm_database_schema.observation_period OP on E.person_id = OP.person_id and E.start_date >=  OP.observation_period_start_date and E.start_date <= op.observation_period_end_date
  WHERE DATEADD(day,0,OP.OBSERVATION_PERIOD_START_DATE) <= E.START_DATE AND DATEADD(day,0,E.START_DATE) <= OP.OBSERVATION_PERIOD_END_DATE
) P

-- End Primary Events

)
SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, visit_occurrence_id
INTO #qualified_events
FROM 
(
  select pe.event_id, pe.person_id, pe.start_date, pe.end_date, pe.op_start_date, pe.op_end_date, row_number() over (partition by pe.person_id order by pe.start_date ASC) as ordinal, cast(pe.visit_occurrence_id as bigint) as visit_occurrence_id
  FROM primary_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM primary_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
SELECT 0 as index_id, p.person_id, p.event_id
FROM primary_events P
INNER JOIN
(
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date,
       C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.condition_start_date as sort_date
FROM 
(
  SELECT co.* 
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 13))
) C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 1 as index_id, p.person_id, p.event_id
FROM primary_events P
INNER JOIN
(
  -- Begin Measurement Criteria
select C.person_id, C.measurement_id as event_id, C.measurement_date as start_date, DATEADD(d,1,C.measurement_date) as END_DATE,
       C.measurement_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.measurement_date as sort_date
from 
(
  select m.* 
  FROM @cdm_database_schema.MEASUREMENT m
JOIN #Codesets codesets on ((m.measurement_concept_id = codesets.concept_id and codesets.codeset_id = 14))
) C


-- End Measurement Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 2 as index_id, p.person_id, p.event_id
FROM primary_events P
INNER JOIN
(
  -- Begin Measurement Criteria
select C.person_id, C.measurement_id as event_id, C.measurement_date as start_date, DATEADD(d,1,C.measurement_date) as END_DATE,
       C.measurement_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.measurement_date as sort_date
from 
(
  select m.* 
  FROM @cdm_database_schema.MEASUREMENT m
JOIN #Codesets codesets on ((m.measurement_concept_id = codesets.concept_id and codesets.codeset_id = 15))
) C

WHERE C.value_as_concept_id in (4126681,45877990,9191,4181412,45879440,45884080)
-- End Measurement Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 3 as index_id, p.person_id, p.event_id
FROM primary_events P
INNER JOIN
(
  -- Begin Observation Criteria
select C.person_id, C.observation_id as event_id, C.observation_date as start_date, DATEADD(d,1,C.observation_date) as END_DATE,
       C.observation_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.observation_date as sort_date
from 
(
  select o.* 
  FROM @cdm_database_schema.OBSERVATION o
JOIN #Codesets codesets on ((o.observation_concept_id = codesets.concept_id and codesets.codeset_id = 15))
) C

WHERE C.value_as_concept_id in (4126681,45877990,9191,45884080,4181412,45879440)
-- End Observation Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) > 0
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id and AC.event_id = pe.event_id

) QE

;

--- Inclusion Rule Inserts

select 0 as inclusion_rule_id, person_id, event_id
INTO #Inclusion_0
FROM 
(
  select pe.person_id, pe.event_id
  FROM #qualified_events pe
  
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM #qualified_events E
  INNER JOIN
  (
    -- Begin Correlated Criteria
SELECT 0 as index_id, p.person_id, p.event_id
FROM #qualified_events P
LEFT JOIN
(
  select PE.person_id, PE.event_id, PE.start_date, PE.end_date, PE.target_concept_id, PE.visit_occurrence_id, PE.sort_date FROM (
-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria

) PE
JOIN (
-- Begin Criteria Group
select 0 as index_id, person_id, event_id
FROM
(
  select E.person_id, E.event_id 
  FROM (SELECT Q.person_id, Q.event_id, Q.start_date, Q.end_date, Q.visit_occurrence_id, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
FROM (-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria
) Q
JOIN @cdm_database_schema.OBSERVATION_PERIOD OP on Q.person_id = OP.person_id 
  and OP.observation_period_start_date <= Q.start_date and OP.observation_period_end_date >= Q.start_date
) E
  INNER JOIN
  (
    -- Begin Correlated Criteria
SELECT 0 as index_id, p.person_id, p.event_id
FROM (SELECT Q.person_id, Q.event_id, Q.start_date, Q.end_date, Q.visit_occurrence_id, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
FROM (-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria
) Q
JOIN @cdm_database_schema.OBSERVATION_PERIOD OP on Q.person_id = OP.person_id 
  and OP.observation_period_start_date <= Q.start_date and OP.observation_period_end_date >= Q.start_date
) P
INNER JOIN
(
  -- Begin Condition Occurrence Criteria
SELECT C.person_id, C.condition_occurrence_id as event_id, C.condition_start_date as start_date, COALESCE(C.condition_end_date, DATEADD(day,1,C.condition_start_date)) as end_date,
       C.CONDITION_CONCEPT_ID as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.condition_start_date as sort_date
FROM 
(
  SELECT co.* 
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  JOIN #Codesets codesets on ((co.condition_concept_id = codesets.concept_id and codesets.codeset_id = 13))
) C


-- End Condition Occurrence Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 1 as index_id, p.person_id, p.event_id
FROM (SELECT Q.person_id, Q.event_id, Q.start_date, Q.end_date, Q.visit_occurrence_id, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
FROM (-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria
) Q
JOIN @cdm_database_schema.OBSERVATION_PERIOD OP on Q.person_id = OP.person_id 
  and OP.observation_period_start_date <= Q.start_date and OP.observation_period_end_date >= Q.start_date
) P
INNER JOIN
(
  -- Begin Measurement Criteria
select C.person_id, C.measurement_id as event_id, C.measurement_date as start_date, DATEADD(d,1,C.measurement_date) as END_DATE,
       C.measurement_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.measurement_date as sort_date
from 
(
  select m.* 
  FROM @cdm_database_schema.MEASUREMENT m
JOIN #Codesets codesets on ((m.measurement_concept_id = codesets.concept_id and codesets.codeset_id = 14))
) C


-- End Measurement Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 2 as index_id, p.person_id, p.event_id
FROM (SELECT Q.person_id, Q.event_id, Q.start_date, Q.end_date, Q.visit_occurrence_id, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
FROM (-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria
) Q
JOIN @cdm_database_schema.OBSERVATION_PERIOD OP on Q.person_id = OP.person_id 
  and OP.observation_period_start_date <= Q.start_date and OP.observation_period_end_date >= Q.start_date
) P
INNER JOIN
(
  -- Begin Measurement Criteria
select C.person_id, C.measurement_id as event_id, C.measurement_date as start_date, DATEADD(d,1,C.measurement_date) as END_DATE,
       C.measurement_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.measurement_date as sort_date
from 
(
  select m.* 
  FROM @cdm_database_schema.MEASUREMENT m
JOIN #Codesets codesets on ((m.measurement_concept_id = codesets.concept_id and codesets.codeset_id = 15))
) C

WHERE C.value_as_concept_id in (4126681,45877990,9191,45884080,4181412,45879440)
-- End Measurement Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

UNION ALL
-- Begin Correlated Criteria
SELECT 3 as index_id, p.person_id, p.event_id
FROM (SELECT Q.person_id, Q.event_id, Q.start_date, Q.end_date, Q.visit_occurrence_id, OP.observation_period_start_date as op_start_date, OP.observation_period_end_date as op_end_date
FROM (-- Begin Visit Occurrence Criteria
select C.person_id, C.visit_occurrence_id as event_id, C.visit_start_date as start_date, C.visit_end_date as end_date,
       C.visit_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.visit_start_date as sort_date
from 
(
  select vo.* 
  FROM @cdm_database_schema.VISIT_OCCURRENCE vo
JOIN #Codesets codesets on ((vo.visit_concept_id = codesets.concept_id and codesets.codeset_id = 4))
) C


-- End Visit Occurrence Criteria
) Q
JOIN @cdm_database_schema.OBSERVATION_PERIOD OP on Q.person_id = OP.person_id 
  and OP.observation_period_start_date <= Q.start_date and OP.observation_period_end_date >= Q.start_date
) P
INNER JOIN
(
  -- Begin Observation Criteria
select C.person_id, C.observation_id as event_id, C.observation_date as start_date, DATEADD(d,1,C.observation_date) as END_DATE,
       C.observation_concept_id as TARGET_CONCEPT_ID, C.visit_occurrence_id,
       C.observation_date as sort_date
from 
(
  select o.* 
  FROM @cdm_database_schema.OBSERVATION o
JOIN #Codesets codesets on ((o.observation_concept_id = codesets.concept_id and codesets.codeset_id = 15))
) C

WHERE C.value_as_concept_id in (4126681,45877990,9191,45884080,4181412,45879440)
-- End Observation Criteria

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-21,P.START_DATE) AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= DATEADD(day,0,P.END_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) >= 1
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) > 0
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id and AC.event_id = pe.event_id

) A on A.person_id = P.person_id  AND A.START_DATE >= P.OP_START_DATE AND A.START_DATE <= P.OP_END_DATE AND A.START_DATE >= DATEADD(day,-180,P.START_DATE) AND A.START_DATE <= DATEADD(day,-1,P.START_DATE)
GROUP BY p.person_id, p.event_id
HAVING COUNT(A.TARGET_CONCEPT_ID) = 0
-- End Correlated Criteria

  ) CQ on E.person_id = CQ.person_id and E.event_id = CQ.event_id
  GROUP BY E.person_id, E.event_id
  HAVING COUNT(index_id) = 1
) G
-- End Criteria Group
) AC on AC.person_id = pe.person_id AND AC.event_id = pe.event_id
) Results
;

SELECT inclusion_rule_id, person_id, event_id
INTO #inclusion_events
FROM (select inclusion_rule_id, person_id, event_id from #Inclusion_0) I;
TRUNCATE TABLE #Inclusion_0;
DROP TABLE #Inclusion_0;


with cteIncludedEvents(event_id, person_id, start_date, end_date, op_start_date, op_end_date, ordinal) as
(
  SELECT event_id, person_id, start_date, end_date, op_start_date, op_end_date, row_number() over (partition by person_id order by start_date ASC) as ordinal
  from
  (
    select Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date, SUM(coalesce(POWER(cast(2 as bigint), I.inclusion_rule_id), 0)) as inclusion_rule_mask
    from #qualified_events Q
    LEFT JOIN #inclusion_events I on I.person_id = Q.person_id and I.event_id = Q.event_id
    GROUP BY Q.event_id, Q.person_id, Q.start_date, Q.end_date, Q.op_start_date, Q.op_end_date
  ) MG -- matching groups

  -- the matching group with all bits set ( POWER(2,# of inclusion rules) - 1 = inclusion_rule_mask
  WHERE (MG.inclusion_rule_mask = POWER(cast(2 as bigint),1)-1)

)
select event_id, person_id, start_date, end_date, op_start_date, op_end_date
into #included_events
FROM cteIncludedEvents Results
WHERE Results.ordinal = 1
;

-- date offset strategy

select event_id, person_id, 
  case when DATEADD(day,0,end_date) > start_date then DATEADD(day,0,end_date) else start_date end as end_date
INTO #strategy_ends
from #included_events;


-- generate cohort periods into #final_cohort
with cohort_ends (event_id, person_id, end_date) as
(
	-- cohort exit dates
  -- End Date Strategy
SELECT event_id, person_id, end_date from #strategy_ends

),
first_ends (person_id, start_date, end_date) as
(
	select F.person_id, F.start_date, F.end_date
	FROM (
	  select I.event_id, I.person_id, I.start_date, E.end_date, row_number() over (partition by I.person_id, I.event_id order by E.end_date) as ordinal 
	  from #included_events I
	  join cohort_ends E on I.event_id = E.event_id and I.person_id = E.person_id and E.end_date >= I.start_date
	) F
	WHERE F.ordinal = 1
)
select person_id, start_date, end_date
INTO #cohort_rows
from first_ends;

with cteEndDates (person_id, end_date) AS -- the magic
(	
	SELECT
		person_id
		, DATEADD(day,-1 * 0, event_date)  as end_date
	FROM
	(
		SELECT
			person_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal 
			, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY event_date, event_type) AS overall_ord
		FROM
		(
			SELECT
				person_id
				, start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY start_date) AS start_ordinal
			FROM #cohort_rows
		
			UNION ALL
		

			SELECT
				person_id
				, DATEADD(day,0,end_date) as end_date
				, 1 AS event_type
				, NULL
			FROM #cohort_rows
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
cteEnds (person_id, start_date, end_date) AS
(
	SELECT
		 c.person_id
		, c.start_date
		, MIN(e.end_date) AS end_date
	FROM #cohort_rows c
	JOIN cteEndDates e ON c.person_id = e.person_id AND e.end_date >= c.start_date
	GROUP BY c.person_id, c.start_date
)
select person_id, min(start_date) as start_date, end_date
into #final_cohort
from cteEnds
group by person_id, end_date
;

DELETE FROM @target_database_schema.@target_cohort_table where cohort_definition_id = @target_cohort_id;
INSERT INTO @target_database_schema.@target_cohort_table (cohort_definition_id, subject_id, cohort_start_date, cohort_end_date)
select @target_cohort_id as cohort_definition_id, person_id, start_date, end_date 
FROM #final_cohort CO
;



TRUNCATE TABLE #strategy_ends;
DROP TABLE #strategy_ends;


TRUNCATE TABLE #cohort_rows;
DROP TABLE #cohort_rows;

TRUNCATE TABLE #final_cohort;
DROP TABLE #final_cohort;

TRUNCATE TABLE #inclusion_events;
DROP TABLE #inclusion_events;

TRUNCATE TABLE #qualified_events;
DROP TABLE #qualified_events;

TRUNCATE TABLE #included_events;
DROP TABLE #included_events;

TRUNCATE TABLE #Codesets;
DROP TABLE #Codesets;
