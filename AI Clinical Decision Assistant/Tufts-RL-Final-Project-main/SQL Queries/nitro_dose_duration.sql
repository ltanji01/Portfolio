/*
* File name: hourly_nitro_dose.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Getting the nitroglycerin dose by the hour. Query based on query 
*           below            
* https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts_postgres/durations/vasopressin_dose.sql
*   
*/    

-- Get drug administration data from CareVue first
with nitrocv1 as
(
    select
    icustay_id, charttime, SUBJECT_ID, HADM_ID
    -- case statement determining whether the ITEMID is an instance of nitroglycerin usage
    , max(case when itemid = 30049 then 1 else 0 end) as nitro -- nitroglycerin

    -- the 'stopped' column indicates if a nitroglycerin has been disconnected
    , max(case when itemid = 30049 and (stopped = 'Stopped' OR stopped like 'D/C%') then 1
          else 0 end) as nitro_stopped

    , max(case when itemid = 30049 and rate is not null then 1 else 0 end) as nitro_null
    , max(case when itemid = 30049 then rate else null end) as nitro_rate
    , max(case when itemid = 30049 then amount else null end) as nitro_amount

  FROM `physionet-data.mimiciii_clinical.inputevents_cv`
  where itemid = 30049 -- nitroglycerin
  group by icustay_id, charttime, SUBJECT_ID, HADM_ID
)
, nitrocv2 as
(
  select v.*
    , sum(nitro_null) over (partition by icustay_id order by charttime) as nitro_partition
  from
    nitrocv1 v
)
, nitrocv3 as
(
  select v.*
    , first_value(nitro_rate) over (partition by icustay_id, nitro_partition order by charttime) as nitro_prevrate_ifnull
  from
    nitrocv2 v
)
, nitrocv4 as
(
select
    icustay_id
    , hadm_id
    , subject_id
    , charttime
    -- , (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, nitro order by charttime))) AS delta

    , nitro
    , nitro_rate
    , nitro_amount
    , nitro_stopped
    , nitro_prevrate_ifnull

    -- We define start time here
    , case
        when nitro = 0 then null

        -- if this is the first instance of the nitroactive drug
        when nitro_rate > 0 and
          LAG(nitro_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, nitro, nitro_null, hadm_id, subject_id
          order by charttime
          )
          is null
          then 1

        -- you often get a string of 0s
        -- we decide not to set these as 1, just because it makes nitro sequential
        when nitro_rate = 0 and
          LAG(nitro_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, nitro, subject_id, hadm_id
          order by charttime
          )
          = 0
          then 0

        -- sometimes you get a string of NULL, associated with 0 volumes
        -- same reason as before, we decide not to set these as 1
        -- nitro_prevrate_ifnull is equal to the previous value *iff* the current value is null
        when nitro_prevrate_ifnull = 0 and
          LAG(nitro_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, nitro, subject_id, hadm_id
          order by charttime
          )
          = 0
          then 0

        -- If the last recorded rate was 0, newnitro = 1
        when LAG(nitro_prevrate_ifnull,1)
          OVER
          (
          partition by icustay_id, nitro
          order by charttime
          ) = 0
          then 1

        -- If the last recorded nitro was D/C'd, newnitro = 1
        when
          LAG(nitro_stopped,1)
          OVER
          (
          partition by icustay_id, nitro, subject_id, hadm_id
          order by charttime
          )
          = 1 then 1

        -- ** not sure if the below is needed
        --when (CHARTTIME - (LAG(CHARTTIME, 1) OVER (partition by icustay_id, nitro order by charttime))) > (interval '4 hours') then 1
      else null
      end as nitro_start

FROM
  nitrocv3
)
-- propagate start/stop flags forward in time
, nitrocv5 as
(
  select v.*
    , SUM(nitro_start) OVER (partition by icustay_id, nitro, subject_id, hadm_id order by charttime) as nitro_first
FROM
  nitrocv4 v
)
, nitrocv6 as
(
  select v.*
    -- We define end time here
    , case
        when nitro = 0
          then null

        -- If the recorded nitro was D/C'd, this is an end time
        when nitro_stopped = 1
          then nitro_first

        -- If the rate is zero, this is the end time
        when nitro_rate = 0
          then nitro_first

        -- the last row in the table is always a potential end time
        -- this captures patients who die/are discharged while on nitroglycerin
        -- in principle, this could add an extra end time for the nitroglycerin
        -- however, since we later group on nitro_start, any extra end times are ignored
        when LEAD(CHARTTIME,1)
          OVER
          (
          partition by icustay_id, nitro, subject_id, hadm_id
          order by charttime
          ) is null
          then nitro_first

        else null
        end as nitro_stop
    from nitrocv5 v
)

-- -- if you want to look at the results of the table before grouping:
-- select
--   icustay_id, charttime, nitro, nitro_rate, nitro_amount
--     , nitro_stopped
--     , nitro_start
--     , nitro_first
--     , nitro_stop
-- from nitrocv6 order by icustay_id, charttime;

, nitrocv7 as
(
select
  icustay_id
  ,subject_id
  , hadm_id
  , charttime as starttime
  , lead(charttime) OVER (partition by icustay_id, nitro_first order by charttime) as endtime
  , nitro, nitro_rate, nitro_amount, nitro_stop, nitro_start, nitro_first
from nitrocv6
where
  nitro_first is not null -- bogus data
and
  nitro_first != 0 -- sometimes *only* a rate of 0 appears, i.e. the drug is never actually delivered
and
  icustay_id is not null -- there are data for "floating" admissions, we don't worry about these
and
  subject_id is not null
and
  hadm_id is not null
)
-- table of start/stop times for event
, nitrocv8 as
(
  select
    icustay_id,subject_id, hadm_id
    , starttime, endtime
    , nitro, nitro_rate, nitro_amount, nitro_stop, nitro_start, nitro_first
  from nitrocv7
  where endtime is not null
  and nitro_rate > 0
  and starttime != endtime
)
-- collapse these start/stop times down if the rate doesn't change
, nitrocv9 as
(
  select
    icustay_id, subject_id, hadm_id
    , starttime, endtime
    , case
        when LAG(endtime) OVER (partition by icustay_id order by starttime, endtime) = starttime
        AND  LAG(nitro_rate) OVER (partition by icustay_id order by starttime, endtime) = nitro_rate
        THEN 0
      else 1
    end as nitro_groups
    , nitro, nitro_rate, nitro_amount, nitro_stop, nitro_start, nitro_first
  from nitrocv8
  where endtime is not null
  and nitro_rate > 0
  and starttime != endtime
)
, nitrocv10 as
(
  select
    icustay_id, subject_id, hadm_id
    , starttime, endtime
    , nitro_groups
    , SUM(nitro_groups) OVER (partition by icustay_id order by starttime, endtime) as nitro_groups_sum
    , nitro, nitro_rate, nitro_amount, nitro_stop, nitro_start, nitro_first
  from nitrocv9
)
, nitrocv as
(
  select icustay_id, subject_id, hadm_id
  , min(starttime) as starttime
  , max(endtime) as endtime
  , nitro_groups_sum
  , nitro_rate
  , sum(nitro_amount) as nitro_amount
  from nitrocv10
  group by icustay_id, nitro_groups_sum, nitro_rate, subject_id, hadm_id
)
-- now we extract the associated data for metavision patients
, nitromv as
(
  select
    icustay_id, linkorderid, subject_id, hadm_id
    , CASE WHEN rateuom = 'units/min' THEN rate*60.0 ELSE rate END as nitro_rate
    , amount as nitro_amount
    , starttime
    , endtime
  from `physionet-data.mimiciii_clinical.inputevents_mv`
  where itemid = 222056 -- nitroglycerin
  and statusdescription != 'Rewritten' -- only valid orders
)
-- now assign this data to every hour of the patient's stay
-- nitro_amount for carevue is not accurate
SELECT icustay_id, subject_id, hadm_id
  , starttime, endtime
  , nitro_rate, nitro_amount
from nitrocv
UNION ALL
SELECT icustay_id, subject_id, hadm_id
  , starttime, endtime
  , nitro_rate, nitro_amount
from nitromv
order by icustay_id, starttime;