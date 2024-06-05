/*
* File name: 5hr_BP.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Retrieving the first 5 hours of blood pressure data for all patients 
*          to cut down on query time to find HC patients.
* NOTE: MUST BE RUN BEFORE tag_5hr_vitals.sql 
*/      

SELECT pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.charttime, pvt.intime, pvt.itemid, pvt.valuenum
-- Getting time difference to rank charttimes later.
, DATETIME_DIFF(pvt.charttime, pvt.intime, HOUR) AS hour_diff
, DATETIME_DIFF(pvt.charttime, pvt.intime, MINUTE) AS minute_diff
FROM  (
  select ie.subject_id, ie.hadm_id, ie.icustay_id, ce.CHARTTIME, ie.intime, ce.ITEMID, ce.VALUENUM
  from `physionet-data.mimiciii_clinical.icustays` ie
  left join `physionet-data.mimiciii_clinical.chartevents` ce
  on ie.icustay_id = ce.icustay_id AND ie.subject_id = ce.subject_id AND ie.HADM_ID = ce.hadm_id
  and ce.charttime between ie.intime and DATETIME_ADD(ie.intime, INTERVAL '5' HOUR)
  and DATETIME_DIFF(ce.charttime, ie.intime, SECOND) > 0
  and DATETIME_DIFF(ce.charttime, ie.intime, HOUR) <= 5
  -- exclude rows marked as error
  and (ce.error IS NULL or ce.error = 0)
  where ce.itemid in
  (
  -- Systolic/diastolic

  51, --	Arterial BP [Systolic]
  442, --	Manual BP [Systolic]
  455, --	NBP [Systolic]
  6701, --	Arterial BP #2 [Systolic]
  220179, --	Non Invasive Blood Pressure systolic
  220050, --	Arterial Blood Pressure systolic

  8368, --	Arterial BP [Diastolic]
  8440, --	Manual BP [Diastolic]
  8441, --	NBP [Diastolic]
  8555, --	Arterial BP #2 [Diastolic]
  220180, --	Non Invasive Blood Pressure diastolic
  220051 --	Arterial Blood Pressure diastolic
  )
) pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.charttime, pvt.intime, pvt.itemid, pvt.valuenum
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.charttime, pvt.intime, pvt.itemid, pvt.valuenum;