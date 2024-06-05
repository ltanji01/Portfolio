/*
* File name: cohort_vitals_byRank.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Ranks relevant vital measurements by time closest to icu admit time.
*          This is to just get the baseline vitals
* NOTE: Must run after cohort_chartevents.sql 
* Retrieves 103,162 rows
*/

WITH first_vitals AS(
  SELECT pvt.vitalid, pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.CHARTTIME, pvt.intime, pvt.valuenum
  --Ranking by the time each vital was taken.
  , DENSE_RANK() OVER (PARTITION BY vitalid, subject_id, hadm_id, icustay_id ORDER BY minute_diff) AS vital_rank
  FROM  (
    select ce.subject_id, ce.hadm_id, ce.icustay_id, ce.CHARTTIME, ce.hour_diff, ce.minute_diff, ce.sec_diff, ce.intime
    , case
      when itemid in (211,220045) and valuenum > 0 and valuenum < 300 then 1 -- HeartRate
      when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
      when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
      when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 300 then 4 -- MeanBP
      when itemid in (615,618,220210,224690) and valuenum > 0 and valuenum < 70 then 5 -- RespRate
      when itemid in (223761,678) and valuenum > 70 and valuenum < 120  then 6 -- TempF, converted to degC in valuenum call
      when itemid in (223762,676) and valuenum > 10 and valuenum < 50  then 6 -- TempC
      when itemid in (646,220277) and valuenum > 0 and valuenum <= 100 then 7 -- SpO2
      when itemid in (807,811,1529,3745,3744,225664,220621,226537) and valuenum > 0 then 8 -- Glucose

      else null end as vitalid
        -- convert F to C
    , case when itemid in (223761,678) then (valuenum-32)/1.8 else valuenum end as valuenum

    from `cs138-421120.mimicIII.cohort_chartevents` ce --ONLY HC with Nitro cohort :)
    where ce.itemid in
    (
    -- HEART RATE
    211, --"Heart Rate"
    220045, --"Heart Rate"

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
    220051, --	Arterial Blood Pressure diastolic


    -- MEAN ARTERIAL PRESSURE
    456, --"NBP Mean"
    52, --"Arterial BP Mean"
    6702, --	Arterial BP Mean #2
    443, --	Manual BP Mean(calc)
    220052, --"Arterial Blood Pressure mean"
    220181, --"Non Invasive Blood Pressure mean"
    225312, --"ART BP mean"

    -- RESPIRATORY RATE
    618,--	Respiratory Rate
    615,--	Resp Rate (Total)
    220210,--	Respiratory Rate
    224690, --	Respiratory Rate (Total)


    -- SPO2, peripheral
    646, 220277,

    -- GLUCOSE, both lab and fingerstick
    807,--	Fingerstick Glucose
    811,--	Glucose (70-105)
    1529,--	Glucose
    3745,--	BloodGlucose
    3744,--	Blood Glucose
    225664,--	Glucose finger stick
    220621,--	Glucose (serum)
    226537,--	Glucose (whole blood)

    -- TEMPERATURE
    223762, -- "Temperature Celsius"
    676,	-- "Temperature C"
    223761, -- "Temperature Fahrenheit"
    678 --	"Temperature F"
    ) 
    and ce.hour_diff = 0 --limiting to 0 since we're getting vitals from each hour.
  ) pvt
  --group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.vitalid, pvt.CHARTTIME, pvt.hour_diff, pvt.minute_diff, pvt.sec_diff, pvt.valuenum
  --order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.vitalid, pvt.CHARTTIME, pvt.hour_diff, pvt.minute_diff, pvt.sec_diff
)
SELECT fv.subject_id, fv.hadm_id, fv.icustay_id, fv.CHARTTIME, fv.intime
, (case when VitalID = 1 then valuenum ELSE NULL END) AS heartrat
, (case when VitalID = 2 then valuenum ELSE NULL END) AS sysbp
, (case when VitalID = 3 then valuenum ELSE NULL END) AS diasbp
, (case when VitalID = 4 then valuenum ELSE NULL END) AS meanbp
, (case when VitalID = 5 then valuenum ELSE NULL END) AS resprate
, (case when VitalID = 6 then valuenum ELSE NULL END) AS tempc
, (case when VitalID = 7 then valuenum ELSE NULL END) AS spo2
, (case when VitalID = 8 then valuenum ELSE NULL END) AS glucose
FROM first_vitals fv
where vital_rank=1 --Want the vitals closest to intime.
GROUP BY fv.charttime, fv.intime, fv.subject_id, fv.hadm_id, fv.icustay_id, fv.vitalid, fv.valuenum --,heartrat,sysbp, diasbp, meanbp, resprate, tempc, spo2, glucose, vital_rank;






