/*
* File name: tag_5hr_BP.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Tagging itemids in 5hr_BP table with sysBP and diasBP labels. Still
*          looking for HC patients.
* NOTE: MUST BE RUN AFTER 5hr_vitals.sql 
*/      


SELECT subject_id, hadm_id, icustay_id, VitalID, hour_diff, minute_diff, valuenum, charttime, intime
FROM  (
  select vt.subject_id, vt.hadm_id, vt.icustay_id, vt.charttime, vt.hour_diff, vt.minute_diff, vt.valuenum, vt.intime
  , case
  -- sanity check. 
    when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
    when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
    else null end as vitalid
  FROM `cs138-421120.mimicIII.5hr_BPs`vt

) 
GROUP BY subject_id, hadm_id, icustay_id, vitalid, hour_diff, minute_diff, valuenum, charttime, intime