/*
* File name: combine_nitro_and_vitals.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Combine hourly vital table and hourly nitroglycerin administration
*          table.
* NOTE: MUST BE RUN AFTER hourly_nitro_dose.sql and final_table_build.sql
*/    

SELECT *
FROM `cs138-421120.mimicIII.final_data` fd
RIGHT JOIN `cs138-421120.mimicIII.hourly_nitro_dose` hnd
ON fd.subject_id = hnd.subject_id and fd.hadm_id = hnd.hadm_id and fd.icustay_id = hnd.icustay_id

