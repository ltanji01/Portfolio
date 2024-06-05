/*
* File name: nitro_hc_from_firstBP.sql
* Author: Leigh Tanji
* Date: 10-May-2024
* Purpose: Finding HC patients who were treated with IV nitroglycerin. 
* NOTE: MUST BE RUN AFTER hc_from_firstBP.sql. Drug names and route found 
* through nitroglycerin.sql
*/    
-- THIS RETURNS 37,885 PATIENTS
SELECT DISTINCT cp.SUBJECT_ID, cp.HADM_ID, cp.ICUSTAY_ID, hpi.intime
FROM `physionet-data.mimiciii_clinical.prescriptions` cp
--Getting people who met HC criteria.
INNER JOIN `cs138-421120.mimicIII.hc_from_firstBP` hpi ON cp.SUBJECT_ID = hpi.subject_id AND cp.HADM_ID=hpi.hadm_id AND cp.ICUSTAY_ID=hpi.icustay_id
-- Based on information from "nitroglycerin" query.
WHERE cp.DRUG_NAME_GENERIC IS NULL OR cp.DRUG_NAME_GENERIC = "Nitroglycerin" 
  AND cp.DRUG_NAME_POE IS NULL OR cp.DRUG_NAME_POE IN("NITROGLYCERIN", 
"Nitroglycerin")
  AND cp.DRUG IN ("Nitroglycerin", "NITROGLYCERIN")
  and cp.ROUTE IS NULL OR cp.ROUTE IN ("IV", "IV DRIP");
