/*
* File name: xhr_cohort_vitals.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Query to obtain vitals for each hour. From the list of cohort 
*          patients and all their vitals, get the difference between the time  
*          the first vital was taken in the icu and all the chart event times. 
*          Then, rank all of them in order of difference.
* NOTE: Must run this multiple times for each hour.  
*
* baseline has 29,774 vitals.
* 1hr vitals returns 57,110  | 13hr vitals returns 14,191
* 2hr vitals returns 20,730  | 14hr vitals returns 14,079
* 3hr vitals returns 19,113  | 15hr vitals returns 13,988
* 4hr vitals returns 18,159  | 16hr vitals returns 13,922
* 5hr vitals returns 17,285  | 17hr vitals returns 13,608
* 6hr vitals returns 16,634  | 18hr vitals returns 13,272
* 7hr vitals returns 15,961  | 19hr vitals returns 12,987
* 8hr vitals returns 15,344  | 20hr vitals returns 12,695
* 9hr vitals returns 15,059  | 21hr vitals returns 12,499
* 10hr vitals returns 14,842 | 22hr vitals returns 12,148
* 11hr vitals returns 14,588 | 23hr vitals returns 11,882
* 12hr vitals returns 14,346 | 24hr vitals returns 11,644
*/


WITH near_hr AS(
  SELECT subject_id, hadm_id, icustay_id, vitalid, valuenum, charttime, min_diff
  --Ranking the difference between the true xhr mark and charttimes between minute interval.
  , DENSE_RANK() over (partition by vitalid, subject_id, hadm_id, icustay_id ORDER BY min_diff) AS vital_rank  
  FROM (
    SELECT subject_id, hadm_id, icustay_id, vitalid, valuenum, CHARTTIME 
    , ABS(DATETIME_DIFF(xhr_mark, charttime, MINUTE)) as min_diff --Getting absolute diff between xhr mark and chart time.
    FROM (
      SELECT subject_id, hadm_id, icustay_id, vitalid, valuenum, CHARTTIME 
      , DATETIME_ADD(charttime_0, INTERVAL '24' HOUR) as xhr_mark --getting x hr time AFTER from first vital.
      FROM `cs138-421120.mimicIII.all_cohort_vitals` 
      /* want x hour after baseline vitals. Not necessarily the time they got to the icu.
        1hr interval: 45 and 75     | 13hr interval: 765 and 795
        2hr interval: 105 and 135   | 14hr interval: 825 and 855
        3hr interval: 165 and 195   | 15hr interval: 885 and 915 
        4hr interval: 225 and 255   | 16hr interval: 945 and 975
        5hr interval: 285 and 315   | 17hr interval: 1005 and 1035
        6hr interval: 345 and 375   | 18hr interval: 1065 and 1095
        7hr interval: 405 and 435   | 19hr interval: 1125 and 1155
        8hr interval: 465 and 495   | 20hr interval: 1185 and 1215
        9hr interval: 525 and 555   | 21hr interval: 1245 and 1275
        10hr interval: 585 and 615  | 22hr interval: 1305 and 1335
        11hr interval: 645 and 675  | 23hr interval: 1365 and 1395
        12hr interval: 705 and 735  | 24hr interval: 1425 and 1455
      */
      WHERE charttime between DATETIME_ADD(charttime_0, INTERVAL '1425' MINUTE) and DATETIME_ADD(charttime_0, INTERVAL '1455' MINUTE)
      GROUP BY subject_id, hadm_id, icustay_id, vitalid, valuenum, CHARTTIME, charttime_0 
    ) 
  )
) 
SELECT civ.subject_id, civ.hadm_id, civ.icustay_id--, nh.min_diff_1
--civ.charttime_0, civ.heartrate_0, civ.sysbp_0, civ.diasbp_0, civ.meanbp_0,
--civ.resprate_0, civ.tempc_0, civ.spo2_0, civ.glucose_0
  , nh.CHARTTIME AS charttime_24 -- renaming to make sure we know this is 1hr_vitals
  --, COUNT(nh.charttime) as num_measurements
  , avg(case when nh.VitalID = 1 then nh.valuenum ELSE NULL END) AS heartrate_24
  , avg(case when nh.VitalID = 2 then nh.valuenum ELSE NULL END) AS sysbp_24
  , avg(case when nh.VitalID = 3 then nh.valuenum ELSE NULL END) AS diasbp_24
  , avg(case when nh.VitalID = 4 then nh.valuenum ELSE NULL END) AS meanbp_24
  , avg(case when nh.VitalID = 5 then nh.valuenum ELSE NULL END) AS resprate_24
  , avg(case when nh.VitalID = 6 then nh.valuenum ELSE NULL END) AS tempc_24
  , avg(case when nh.VitalID = 7 then nh.valuenum ELSE NULL END) AS spo2_24
  , avg(case when nh.VitalID = 8 then nh.valuenum ELSE NULL END) AS glucose_24
  , min(vital_rank) AS min_rank
FROM near_hr nh
INNER JOIN `cs138-421120.mimicIII.cohort_initial_vitals` civ ON civ.subject_id = nh.subject_id
and civ.hadm_id = nh.hadm_id and civ.icustay_id = nh.icustay_id
GROUP BY nh.charttime, civ.subject_id, civ.hadm_id, civ.icustay_id--, nh.min_diff_1;