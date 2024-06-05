/*
* File name: nitroglycerin.sql
* Author: Kyle Dimock
* Date: 10-May-2024
* Purpose: Finding the drug name and route for nitroglycerin in mimic_iii
* NOTE: Needed for nitro_hc_from_firstBP.sql
*/      

SELECT drug_name_generic, drug_name_poe, drug, ROUTE, count(*) as numobs
FROM `physionet-data.mimiciii_clinical.prescriptions`

WHERE lower(drug) LIKE '%nitroglycerin%'
OR lower(drug_name_generic) LIKE '%nitroglycerin%'
OR lower(drug_name_poe) LIKE '%nitroglycerin%'
OR lower(drug) LIKE '%clevidipine%'
OR lower(drug_name_generic) LIKE '%clevidipine%'
OR lower(drug_name_poe) LIKE '%clevidipine%'
OR lower(drug) LIKE '%nitroprusside%'
OR lower(drug_name_generic) LIKE '%nitroprusside%'
OR lower(drug_name_poe) LIKE '%nitroprusside%'
GROUP BY drug, drug_name_generic, drug_name_poe, ROUTE
ORDER BY drug_name_generic, drug_name_poe, drug, ROUTE;