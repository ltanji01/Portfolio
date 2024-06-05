/*
* File name: tag_5hr_BP.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Using tag_5hr_vitals_for_firstBP to get actual initial BP from all
*          patients once arriving in the ICU.
* NOTE: MUST BE RUN AFTER tag_5hr_vitals.sql 
*/      

WITH vt2 AS(
  SELECT vt1.subject_id, vt1.hadm_id, vt1.icustay_id, vt1.VitalID
  -- Getting vitals with minimum difference between icu transfer and chart time.
  , min(vt1.hour_diff) AS min_hour
  , min(vt1.minute_diff) AS min_minute
  FROM `cs138-421120.mimicIII.tag_5hr_BP` vt1
  WHERE vt1.VitalID IS NOT NULL
  GROUP BY vt1.subject_id, vt1.hadm_id, vt1.icustay_id, vt1.VitalID
)
SELECT vt3.subject_id, vt3.hadm_id, vt3.icustay_id, vt3.intime, vt3.charttime AS first_charttime
-- Easier names
, (case when vt2.VitalID = 2 then vt3.valuenum ELSE NULL END) AS sysbp
, (case when vt2.VitalID = 3 then vt3.valuenum ELSE NULL END) AS diasbp
FROM `cs138-421120.mimicIII.tag_5hr_BP` vt3
INNER JOIN vt2 ON vt3.subject_id = vt2.subject_id AND vt3.icustay_id = vt2.icustay_id AND vt3.hadm_id= vt2.hadm_id 
--Want to keep vitals that are from first measurements only. 
AND vt3.hour_diff = vt2.min_hour AND vt3.minute_diff = min_minute
GROUP BY vt3.subject_id, vt3.hadm_id, vt3.icustay_id, vt2.VitalID, vt3.charttime, vt3.valuenum, vt3.intime
