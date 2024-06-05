/*
* File name: all_cohort_vitals.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Getting all chartevents for patients with HC who received IV 
* nitroglycerin in the ICU.
* NOTE: Must run after nitro_hc_from_firstBP.sql
*/


SELECT *
FROM(
  SELECT bp.SUBJECT_ID, bp.ICUSTAY_ID, bp.HADM_ID, ce.ITEMID, ce.CHARTTIME, bp.intime
  , ce.STORETIME, ce.CGID, ce.VALUE, ce.VALUENUM, ce.VALUEUOM, ce.WARNING
  , ce.WARNING, ce.ERROR, ce.RESULTSTATUS, ce.STOPPED
  , DATETIME_DIFF(ce.charttime,bp.intime, HOUR) AS hour_diff
  , DATETIME_DIFF(ce.charttime,bp.intime, MINUTE) AS minute_diff 
  , DATETIME_DIFF(ce.charttime,bp.intime, SECOND) AS sec_diff 
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  INNER JOIN `cs138-421120.mimicIII.nitro_hc_from_firstBP` bp
  ON ce.SUBJECT_ID = bp.SUBJECT_ID and ce.HADM_ID = bp.HADM_ID and ce .ICUSTAY_ID = bp.ICUSTAY_ID)
-- Only want vitals after patient entered icu.
WHERE hour_diff >=0 and minute_diff>=0 and sec_diff>=0