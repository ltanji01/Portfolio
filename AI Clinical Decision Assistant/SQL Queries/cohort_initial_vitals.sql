/*
* File name: cohort_initial_vitals.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: We must aggregate to show ALL the vitals for each patient using 1
           one row. Although we're averaging here, it SHOULD only include 1
           value per vital and not change any values. 
* NOTE: Must run after cohort_chartevents_byRank.sql 
* Retrieves 22,971 patients
*/

SELECT subject_id, hadm_id, icustay_id, intime, charttime as charttime_0
  , avg(heartrat) as heartrate_0
  , avg(sysbp) as sysbp_0
  , avg(diasbp) as diasbp_0
  , avg(meanbp) as meanbp_0
  , avg(resprate) as resprate_0
  , avg(tempc) as tempc_0
  , avg(spo2) as spo2_0
  , avg(glucose) as glucose_0

FROM `cs138-421120.mimicIII.cohort_vitals_byRank` vbr
GROUP BY subject_id, hadm_id, icustay_id, intime, charttime

