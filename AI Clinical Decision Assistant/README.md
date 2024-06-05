## Summary of Review Classifier Project:
Hypertensive crises (HC) is a condition characterized by very high blood 
pressure (BP), with systolic readings over 180mmHG, or diastolic readings over
100mmHG that can lead to organ damage and death.[4] Over 1 billion people
worldwide are affected by the condition and it's responsible for 7.1 million deaths per year. It has also been estimated that hypertensive emergencies, the
acute form of HC involving rapid deterioration of major organs, account for 25%
of all emergency department visits [5, 7] Patients with HC are best treated in 
the ICU with titratable IV hypotensive agents, typically vasodilators, with the 
goal of safely but aggressively lowering BP. Unfortunately, HC is one of the 
most misunderstood and mismanage of acute medical emergencies today.[5] 
In an effort to assist with high-stakes decisions in real time, researchers have 
begun to build artificial intelligence that using the growing availability of 
electronic medical records (EMR).[8]

In this work, we hope to re-create and explore the use of Weighted Dueling
Double Deep Q-Network (WD3QNE) with human expertise towards supporting
clinicians in caring for HC patients. This combined supervised and unsupervised
algorithm is based heavily on work done by Wu et al. to inform clinician decision
for the treatment of sepsis.[8] Our aim is to use similar WD3QNE architecture
to produce the optimal policy for vasodilator administration to safely lower HC
patients blood pressure within a 24 hour time frame.


## Credit:
* Leigh Tanji
* Kyle Dimock

## Official Review Classifier (a.k.a. Project A) Instructions
https://github.com/ltanji01/Portfolio/blob/0a86be3a2b29a0c5850adf0a19b35c652172085c/projectA/Project%20A_%20Classifying%20Sentiment%20from%20Text%20Reviews%20_%20Intro%20to%20Machine%20Learning.pdf

## Files in this repository:
### SQL Queries: 
* 5hr_BP
* tag_5hr_BP
* firstBP
* hc_from_firstBP
* nitro_hc_from_firstBP
* cohort_chartevents
* cohort_vitals_byRank
* cohort_initial_vitals
* all_cohort_vitals
* xhr_cohort_vitals
* final_table_build
* hourly_nitro_dose
* combine_nitro_and_vitals
 
### Python Files:
* LunarLanderTest.py
* sepsispaper_DeepQNet.py
* sepsispaper_datasplit.py
* sepsispaper_dataviewing.py
* sepsispaper_evaluate.py

## Compile/Run:
### SQL Files:
Assuming that you have access to the mimic-iii database, follow the following
link to obtain access to each table in Google BigQuery:
https://mimic.mit.edu/docs/gettingstarted/cloud/bigquery/ 
Load the submitted SQL files into your project and hit "run" to run each query.
*PLEASE run in order since some of the queries are based on tables resulting 
from previous queries.

###Python Files:
To run type ```python sepsispaper_main.py``` in the console.

## References:
1. Mimic-iii clinical database, 2016.
2. Mit-lcp group's github repository with tutorial queries, 2016.
3. Mimic-iii vesopressen dose.sql, 2022.
4. Suzanne Oparil David A. Calhoun. Treatment of hypertensive crisis. New
England Journal of Medicine, 23(17):1177-83, Oct 1990.
5. Costas Thomopoulos Thomas Makris Dimitris P. Papadopoulos, Iordanis Mourouzis and Vasilios Papademetriou. Hypertension crisis. Blood Pressure, 19(6):328-336, 2010. PMID: 20504242.
6. Richard S. Sutton and Andrew G. Barto. Reinforcement Learning: An Introduction. Adaptive computation and machine learning series. The MIT
Press, Cambridge, Massachusetts, 2 edition, 2018. Licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 2.0 Generic License.
7. Renan Oliveira; Kuniyoshi Cristina Hiromi; Abdo Andre Neder Ramires;
Yugar-Toledo Juan Carlos Vilela-Martin, Jose Fernando; Vaz-de-Melo. Hypertension crisis. Hypertension Research, 34(3):367-371, 2011. PMID:
20504242.
8. XiaoDan Wu, RuiChang Li, Zhen He, TianZhi Yu, and ChangQing Cheng.
A value-based deep reinforcement learning model with human expertise in
optimal treatment of sepsis. npj Digital Medicine, 6(1):15, 2023
