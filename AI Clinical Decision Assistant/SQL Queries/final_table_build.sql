/*
* File name: final_table_build.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Aggregates hourly vitals into one table. Run following code between
*  star lines in order from top to bottom.
* 
* NOTE: Must run after xhr_cohort_vitals.sql for all 24 hours. 
* Retrieves 12,809 patients' hourly vitals 
*/


/***************************************************************************
*   Getting rid of duplicate IDs by partitioning over IDs ONLY. 
*   There are duplicate IDs since last query took the minimum rank for EACH 
*   vital type. Therefore, here we choose ONE time and hope that most of the 
*   vitals were taken at charttime closest to the hour mark. 
***************************************************************************/
SELECT *   -- Initial vitals 12,779 distinct IDs.
FROM(
  SELECT *
  , DENSE_RANK() OVER (PARTITION BY cii.subject_id, cii.hadm_id, cii.icustay_id ORDER BY cii.charttime_0) AS time_rank
  FROM `cs138-421120.mimicIII.cohort_initial_vitals` cii
)
WHERE time_rank = 1


/***************************************************************************
*   Adding the 1-hr vitals to final_data table
*   Resulted in 18,336 rows. 
***************************************************************************/
WITH hr_table AS(
    SELECT *  -- 1hr had 15,470 distinct IDs. still more than initial...
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_1) AS time_rank
    FROM `cs138-421120.mimicIII.1hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT fd.subject_id, fd.hadm_id, fd.icustay_id, fd.charttime_0, fd.heartrate_0, fd.sysbp_0, fd.diasbp_0, fd.meanbp_0, fd.resprate_0, fd.tempc_0, fd.spo2_0, fd.glucose_0
, ht.charttime_1, ht.heartrate_1, ht.sysbp_1, ht.diasbp_1, ht.meanbp_1, ht.resprate_1, ht.tempc_1, ht.spo2_1, ht.glucose_1
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id


/***************************************************************************
*   Adding the 2-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT *  -- 1hr had 15,470 distinct IDs. still more than initial...
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_2) AS time_rank
    FROM `cs138-421120.mimicIII.2hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;

ALTER TABLE `cs138-421120.mimicIII.final_data` 
DROP COLUMN num_measurements;

ALTER TABLE `cs138-421120.mimicIII.final_data` 
DROP COLUMN time_rank;

ALTER TABLE `cs138-421120.mimicIII.final_data` 
DROP COLUMN min_rank;


/***************************************************************************
*   Adding the 3-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_3, heartrate_3, sysbp_3, diasbp_3, meanbp_3, resprate_3, tempc_3, spo2_3, glucose_3
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_3) AS time_rank
    FROM `cs138-421120.mimicIII.3hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id


/***************************************************************************
*   Adding the 4-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_4, heartrate_4, sysbp_4, diasbp_4, meanbp_4, resprate_4, tempc_4, spo2_4, glucose_4
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_4) AS time_rank
    FROM `cs138-421120.mimicIII.4hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 5-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_5, heartrate_5, sysbp_5, diasbp_5, meanbp_5, resprate_5, tempc_5, spo2_5, glucose_5
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_5) AS time_rank
    FROM `cs138-421120.mimicIII.5hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Noticed we were getting duplicate rows. Below query reduced down to
*   12,809 rows.
***************************************************************************/
select distinct *
from `cs138-421120.mimicIII.final_data` 


/***************************************************************************
*   Adding the 6-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_6, heartrate_6, sysbp_6, diasbp_6, meanbp_6, resprate_6, tempc_6, spo2_6, glucose_6
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_6) AS time_rank
    FROM `cs138-421120.mimicIII.6hr_ cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 7-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_7, heartrate_7, sysbp_7, diasbp_7, meanbp_7, resprate_7, tempc_7, spo2_7, glucose_7
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_7) AS time_rank
    FROM `cs138-421120.mimicIII.7hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 8-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_8, heartrate_8, sysbp_8, diasbp_8, meanbp_8, resprate_8, tempc_8, spo2_8, glucose_8
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_8) AS time_rank
    FROM `cs138-421120.mimicIII.8hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 9-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_9, heartrate_9, sysbp_9, diasbp_9, meanbp_9, resprate_9, tempc_9, spo2_9, glucose_9
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_9) AS time_rank
    FROM `cs138-421120.mimicIII.9hr_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 10-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_10, heartrate_10, sysbp_10, diasbp_10, meanbp_10, resprate_10, tempc_10, spo2_10, glucose_10
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_10) AS time_rank
    FROM `cs138-421120.mimicIII.10hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 11-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_11, heartrate_11, sysbp_11, diasbp_11, meanbp_11, resprate_11, tempc_11, spo2_11, glucose_11
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_11) AS time_rank
    FROM `cs138-421120.mimicIII.11hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 12-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_12, heartrate_12, sysbp_12, diasbp_12, meanbp_12, resprate_12, tempc_12, spo2_12, glucose_12
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_12) AS time_rank
    FROM `cs138-421120.mimicIII.12hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 13-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_13, heartrate_13, sysbp_13, diasbp_13, meanbp_13, resprate_13, tempc_13, spo2_13, glucose_13
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_13) AS time_rank
    FROM `cs138-421120.mimicIII.13hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 14-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_14, heartrate_14, sysbp_14, diasbp_14, meanbp_14, resprate_14, tempc_14, spo2_14, glucose_14
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_14) AS time_rank
    FROM `cs138-421120.mimicIII.14hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 15-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_15, heartrate_15, sysbp_15, diasbp_15, meanbp_15, resprate_15, tempc_15, spo2_15, glucose_15
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_15) AS time_rank
    FROM `cs138-421120.mimicIII.15hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 16-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_16, heartrate_16, sysbp_16, diasbp_16, meanbp_16, resprate_16, tempc_16, spo2_16, glucose_16
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_16) AS time_rank
    FROM `cs138-421120.mimicIII.16hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 18-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_18, heartrate_18, sysbp_18, diasbp_18, meanbp_18, resprate_18, tempc_18, spo2_18, glucose_18
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_18) AS time_rank
    FROM `cs138-421120.mimicIII.18hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 19-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_19, heartrate_19, sysbp_19, diasbp_19, meanbp_19, resprate_19, tempc_19, spo2_19, glucose_19
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_19) AS time_rank
    FROM `cs138-421120.mimicIII.19hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 20-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_20, heartrate_20, sysbp_20, diasbp_20, meanbp_20, resprate_20, tempc_20, spo2_20, glucose_20
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_20) AS time_rank
    FROM `cs138-421120.mimicIII.20hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 21-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_21, heartrate_21, sysbp_21, diasbp_21, meanbp_21, resprate_21, tempc_21, spo2_21, glucose_21
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_21) AS time_rank
    FROM `cs138-421120.mimicIII.21hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 22-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_22, heartrate_22, sysbp_22, diasbp_22, meanbp_22, resprate_22, tempc_22, spo2_22, glucose_22
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_22) AS time_rank
    FROM `cs138-421120.mimicIII.22hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 23-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_23, heartrate_23, sysbp_23, diasbp_23, meanbp_23, resprate_23, tempc_23, spo2_23, glucose_23
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_23) AS time_rank
    FROM `cs138-421120.mimicIII.23hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Adding the 24-hr vitals to final_data table
***************************************************************************/
WITH hr_table AS(
    SELECT subject_id, hadm_id, icustay_id, charttime_24, heartrate_24, sysbp_24, diasbp_24, meanbp_24, resprate_24, tempc_24, spo2_24, glucose_24
  FROM(
    SELECT *
    , DENSE_RANK() OVER (PARTITION BY ocv.subject_id, ocv.hadm_id, ocv.icustay_id ORDER BY ocv.charttime_24) AS time_rank
    FROM `cs138-421120.mimicIII.24hr_cohort_vitals` ocv 
  )
  WHERE time_Rank = 1
)
SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
LEFT JOIN hr_table ht
ON fd.subject_id = ht.subject_id and fd.hadm_id = ht.hadm_id and fd.icustay_id = ht.icustay_id;


/***************************************************************************
*   Selecting the desired columns at the end. 
***************************************************************************/
SELECT
subject_id, hadm_id, icustay_id, charttime_0, heartrate_0, sysbp_0, diasbp_0, meanbp_0, resprate_0, tempc_0, spo2_0, glucose_0
, charttime_1, heartrate_1, sysbp_1, diasbp_1, meanbp_1, resprate_1, tempc_1, spo2_1, glucose_1
, charttime_2, heartrate_2, sysbp_2, diasbp_2, meanbp_2, resprate_2, tempc_2, spo2_2, glucose_2
, charttime_3, heartrate_3, sysbp_3, diasbp_3, meanbp_3, resprate_3, tempc_3, spo2_3, glucose_3
, charttime_4, heartrate_4, sysbp_4, diasbp_4, meanbp_4, resprate_4, tempc_4, spo2_4, glucose_4
, charttime_5, heartrate_5, sysbp_5, diasbp_5, meanbp_5, resprate_5, tempc_5, spo2_5, glucose_5
, charttime_6, heartrate_6, sysbp_6, diasbp_6, meanbp_6, resprate_6, tempc_6, spo2_6, glucose_6
, charttime_7, heartrate_7, sysbp_7, diasbp_7, meanbp_7, resprate_7, tempc_7, spo2_7, glucose_7
, charttime_8, heartrate_8, sysbp_8, diasbp_8, meanbp_8, resprate_8, tempc_8, spo2_8, glucose_8
, charttime_9, heartrate_9, sysbp_9, diasbp_9, meanbp_9, resprate_9, tempc_9, spo2_9, glucose_9
, charttime_10, heartrate_10, sysbp_10, diasbp_10, meanbp_10, resprate_10, tempc_10, spo2_10, glucose_10
, charttime_11, heartrate_11, sysbp_11, diasbp_11, meanbp_11, resprate_11, tempc_11, spo2_11, glucose_11
, charttime_12, heartrate_12, sysbp_12, diasbp_12, meanbp_12, resprate_12, tempc_12, spo2_12, glucose_12
, charttime_13, heartrate_13, sysbp_13, diasbp_13, meanbp_13, resprate_13, tempc_13, spo2_13, glucose_13
, charttime_14, heartrate_14, sysbp_14, diasbp_14, meanbp_14, resprate_14, tempc_14, spo2_14, glucose_14
, charttime_15, heartrate_15, sysbp_15, diasbp_15, meanbp_15, resprate_15, tempc_15, spo2_15, glucose_15
, charttime_16, heartrate_16, sysbp_16, diasbp_16, meanbp_16, resprate_16, tempc_16, spo2_16, glucose_16
, charttime_17, heartrate_17, sysbp_17, diasbp_17, meanbp_17, resprate_17, tempc_17, spo2_17, glucose_17
, charttime_18, heartrate_18, sysbp_18, diasbp_18, meanbp_18, resprate_18, tempc_18, spo2_18, glucose_18
, charttime_19, heartrate_19, sysbp_19, diasbp_19, meanbp_19, resprate_19, tempc_19, spo2_19, glucose_19
, charttime_20, heartrate_20, sysbp_20, diasbp_20, meanbp_20, resprate_20, tempc_20, spo2_20, glucose_20
, charttime_21, heartrate_21, sysbp_21, diasbp_21, meanbp_21, resprate_21, tempc_21, spo2_21, glucose_21
, charttime_22, heartrate_22, sysbp_22, diasbp_22, meanbp_22, resprate_22, tempc_22, spo2_22, glucose_22
, charttime_23, heartrate_23, sysbp_23, diasbp_23, meanbp_23, resprate_23, tempc_23, spo2_23, glucose_23
, charttime_24, heartrate_24, sysbp_24, diasbp_24, meanbp_24, resprate_24, tempc_24, spo2_24, glucose_24
FROM `cs138-421120.mimicIII.final_data`
