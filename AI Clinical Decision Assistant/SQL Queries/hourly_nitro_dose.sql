/*
* File name: hourly_nitro_dose.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Getting the nitroglycerin dose by the hour.
* NOTE: MUST BE RUN AFTER nitro_dose_duration.sql
*/    

SELECT subject_id, hadm_id, icustay_id
, SUM(case when time_bucket = 1 then nitro_amount ELSE 0 END) AS dose_1
, SUM(case when time_bucket = 2 then nitro_amount ELSE 0 END) AS dose_2
, SUM(case when time_bucket = 3 then nitro_amount ELSE 0 END) AS dose_3
, SUM(case when time_bucket = 4 then nitro_amount ELSE 0 END) AS dose_4
, SUM(case when time_bucket = 5 then nitro_amount ELSE 0 END) AS dose_5
, SUM(case when time_bucket = 6 then nitro_amount ELSE 0 END) AS dose_6
, SUM(case when time_bucket = 7 then nitro_amount ELSE 0 END) AS dose_7
, SUM(case when time_bucket = 8 then nitro_amount ELSE 0 END) AS dose_8
, SUM(case when time_bucket = 9 then nitro_amount ELSE 0 END) AS dose_9
, SUM(case when time_bucket = 10 then nitro_amount ELSE 0 END) AS dose_10
, SUM(case when time_bucket = 11 then nitro_amount ELSE 0 END) AS dose_11
, SUM(case when time_bucket = 12 then nitro_amount ELSE 0 END) AS dose_12
, SUM(case when time_bucket = 13 then nitro_amount ELSE 0 END) AS dose_13
, SUM(case when time_bucket = 14 then nitro_amount ELSE 0 END) AS dose_14
, SUM(case when time_bucket = 15 then nitro_amount ELSE 0 END) AS dose_15
, SUM(case when time_bucket = 16 then nitro_amount ELSE 0 END) AS dose_16
, SUM(case when time_bucket = 17 then nitro_amount ELSE 0 END) AS dose_17
, SUM(case when time_bucket = 18 then nitro_amount ELSE 0 END) AS dose_18
, SUM(case when time_bucket = 19 then nitro_amount ELSE 0 END) AS dose_19
, SUM(case when time_bucket = 20 then nitro_amount ELSE 0 END) AS dose_20
, SUM(case when time_bucket = 21 then nitro_amount ELSE 0 END) AS dose_21
, SUM(case when time_bucket = 22 then nitro_amount ELSE 0 END) AS dose_22
, SUM(case when time_bucket = 23 then nitro_amount ELSE 0 END) AS dose_23
, SUM(case when time_bucket = 24 then nitro_amount ELSE 0 END) AS dose_24
FROM(
  WITH every_hr AS(
    SELECT *
    , datetime_add(intime, INTERVAL 1 HOUR) AS hr_1
    , datetime_add(intime, INTERVAL 2 HOUR) AS hr_2
    , datetime_add(intime, INTERVAL 3 HOUR) AS hr_3
    , datetime_add(intime, INTERVAL 4 HOUR) AS hr_4
    , datetime_add(intime, INTERVAL 5 HOUR) AS hr_5
    , datetime_add(intime, INTERVAL 6 HOUR) AS hr_6
    , datetime_add(intime, INTERVAL 7 HOUR) AS hr_7
    , datetime_add(intime, INTERVAL 8 HOUR) AS hr_8
    , datetime_add(intime, INTERVAL 9 HOUR) AS hr_9
    , datetime_add(intime, INTERVAL 10 HOUR) AS hr_10
    , datetime_add(intime, INTERVAL 11 HOUR) AS hr_11
    , datetime_add(intime, INTERVAL 12 HOUR) AS hr_12
    , datetime_add(intime, INTERVAL 13 HOUR) AS hr_13
    , datetime_add(intime, INTERVAL 14 HOUR) AS hr_14
    , datetime_add(intime, INTERVAL 15 HOUR) AS hr_15
    , datetime_add(intime, INTERVAL 16 HOUR) AS hr_16
    , datetime_add(intime, INTERVAL 17 HOUR) AS hr_17
    , datetime_add(intime, INTERVAL 18 HOUR) AS hr_18
    , datetime_add(intime, INTERVAL 19 HOUR) AS hr_19
    , datetime_add(intime, INTERVAL 20 HOUR) AS hr_20
    , datetime_add(intime, INTERVAL 21 HOUR) AS hr_21
    , datetime_add(intime, INTERVAL 22 HOUR) AS hr_22
    , datetime_add(intime, INTERVAL 23 HOUR) AS hr_23
    , datetime_add(intime, INTERVAL 24 HOUR) AS hr_24
    FROM(
      --Getting the cohort's intime to get dosing time.
      SELECT distinct fd.subject_id, fd.hadm_id, fd.icustay_id, cc.intime
      FROM `cs138-421120.mimicIII.cohort_chartevents` cc
      LEFT join `cs138-421120.mimicIII.final_data` fd
      ON cc.subject_id=fd.subject_id and cc.hadm_id = fd.hadm_id and cc.icustay_id = fd.icustay_id
    )
  )
  SELECT ndd.subject_id, ndd.hadm_id, ndd.icustay_id, every_hr.intime, ndd.nitro_amount,
  case
    when starttime between every_hr.intime and every_hr.hr_1 then 1 
    when starttime between every_hr.hr_1 and every_hr.hr_2 then 2 
    when starttime between every_hr.hr_2 and every_hr.hr_3 then 3 
    when starttime between every_hr.hr_3 and every_hr.hr_4 then 4 
    when starttime between every_hr.hr_4 and every_hr.hr_5 then 5 
    when starttime between every_hr.hr_5 and every_hr.hr_6 then 6 
    when starttime between every_hr.hr_6 and every_hr.hr_7 then 7 
    when starttime between every_hr.hr_7 and every_hr.hr_8 then 8 
    when starttime between every_hr.hr_8 and every_hr.hr_9 then 9 
    when starttime between every_hr.hr_9 and every_hr.hr_10 then 10 
    when starttime between every_hr.hr_10 and every_hr.hr_11 then 11 
    when starttime between every_hr.hr_11 and every_hr.hr_12 then 12 
    when starttime between every_hr.hr_12 and every_hr.hr_13 then 13
    when starttime between every_hr.hr_13 and every_hr.hr_14 then 14 
    when starttime between every_hr.hr_14 and every_hr.hr_15 then 15 
    when starttime between every_hr.hr_15 and every_hr.hr_16 then 16 
    when starttime between every_hr.hr_16 and every_hr.hr_17 then 17 
    when starttime between every_hr.hr_17 and every_hr.hr_18 then 18 
    when starttime between every_hr.hr_18 and every_hr.hr_19 then 19 
    when starttime between every_hr.hr_19 and every_hr.hr_20 then 20 
    when starttime between every_hr.hr_20 and every_hr.hr_21 then 21 
    when starttime between every_hr.hr_21 and every_hr.hr_22 then 22 
    when starttime between every_hr.hr_22 and every_hr.hr_23 then 23 
    when starttime between every_hr.hr_23 and every_hr.hr_24 then 23 
  ELSE null end as time_bucket
  FROM `cs138-421120.mimicIII.nitro_dose_duration` ndd
  INNER JOIN every_hr on every_hr.icustay_id = ndd.icustay_id 
    and every_hr.hadm_id = ndd.hadm_id 
    and every_hr.subject_id = ndd.subject_id
    and ndd.starttime between every_hr.intime and DATETIME_ADD(every_hr.intime, INTERVAL '1' DAY)
    and ndd.endtime between every_hr.intime and DATETIME_ADD(every_hr.intime, INTERVAL '1' DAY)
    and DATETIME_DIFF(ndd.starttime, every_hr.intime, SECOND) > 0
    and DATETIME_DIFF(ndd.starttime, every_hr.intime, HOUR) <= 24
    and DATETIME_DIFF(ndd.endtime, every_hr.intime, SECOND) > 0
    and DATETIME_DIFF(ndd.endtime, every_hr.intime, HOUR) <= 24 
)
GROUP BY subject_id, hadm_id, icustay_id;

