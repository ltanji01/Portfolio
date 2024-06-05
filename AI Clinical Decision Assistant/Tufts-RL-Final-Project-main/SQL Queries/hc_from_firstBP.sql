/*
* File name: hc_from_firstBP.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Finding patients who meet HC criteria after finding the first BPs 
*          since coming to the icu.
* NOTE: MUST BE RUN AFTER firstBP.sql 
*/    

--GOT 41,815 PATIENTS FROM THIS CALCULATION.
SELECT subject_id, hadm_id, icustay_id, intime
FROM(
  SELECT fbp.subject_id, fbp.hadm_id, fbp.icustay_id, fbp.intime, COUNT(first_BP) AS num_BPs
  FROM(
    -- Just in case there are multiple bps due to different measurements being done for the first time at different times.
    SELECT subject_id, hadm_id, icustay_id, intime, min(first_charttime) AS first_bp --counting sys and dias separately.
    FROM `cs138-421120.mimicIII.firstBP`
    GROUP BY subject_id, hadm_id, icustay_id, intime) AS fbp
  INNER JOIN `cs138-421120.mimicIII.firstBP` vt ON fbp.first_bp = vt.first_charttime AND fbp.subject_id = vt.subject_id AND fbp.hadm_id = vt.hadm_id
  -- clinical HC criteria.
  WHERE (vt.sysbp>180 OR vt.diasbp>100)
  GROUP BY fbp.subject_id, fbp.hadm_id, fbp.icustay_id, fbp.first_bp, intime)
WHERE num_BPs <3 -- Shouldn't account for patients with more than 
                -- 2 num_BPs, sys and dias separately, as HC pts. 
