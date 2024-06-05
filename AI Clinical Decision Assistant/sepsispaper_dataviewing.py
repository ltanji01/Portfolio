import time
import pickle  # Open the pickle package
import numpy as np

from scipy.stats import zscore, rankdata

# Custom function to compute z-score, mean, and standard deviation
def my_zscore(x):
    return zscore(x, ddof=1), np.mean(x, axis=0), np.std(x, axis=0, ddof=1)

# Load the dataset from a pickle file named '1 hour.pkl'
with open('1_hour.pkl', 'rb') as file:
    MIMICtable = pickle.load(file)  # Data of [278751 rows x 59 columns]

# Make a copy of the dataset values for processing
reformat5 = MIMICtable.values.copy()

# -----------------------After selection, the number of features = 37 -------------------------------
# Define the list of features to be normalized
colnorm = ['SOFA', 'age', 'Weight_kg', 'GCS', 'HR', 'SysBP', 'MeanBP', 'DiaBP', 'RR', 'Temp_C',
           'Sodium', 'Chloride', 'Glucose', 'Calcium', 'Hb', 'WBC_count', 'Platelets_count',
           'PTT', 'PT', 'Arterial_pH', 'paO2', 'paCO2', 'HCO3', 'Arterial_lactate', 'Shock_Index',
           'PaO2_FiO2', 'cumulated_balance', 'CO2_mEqL', 'Ionised_Ca']

# Define the list of features to apply log transformation and then normalize
collog = ['SpO2', 'BUN', 'Creatinine', 'SGOT', 'Total_bili', 'INR', 'input_total', 'output_total']

# Find the indices of the selected features in the MIMIC table and apply normalization
colnorm = np.where(np.isin(MIMICtable.columns, colnorm))[0]
collog = np.where(np.isin(MIMICtable.columns, collog))[0]

# Scale the MIMIC table by concatenating normalized colnorm and log-transformed then normalized collog features
scaleMIMIC = np.concatenate([zscore(reformat5[:, colnorm], ddof=1),
                             zscore(np.log(0.1 + reformat5[:, collog]), ddof=1)], axis=1)

# Make a copy of the MIMIC table for modifications
MIMICtablecopy = MIMICtable

# Setup for processing data in blocks
stayID = reformat5[:, 1]
blocID = reformat5[:, 1]
bloc = 1
count = 0
timestep = 8

# Process data in chunks of 'timestep' and update the MIMIC table copy with new values
for i in range(0, len(blocID) - timestep, timestep):
    MIMICtablecopy.iloc[count, 1:] = MIMICtable.iloc[i, 1:]
    MIMICtablecopy.iloc[count, 0] = bloc
    count += 1
    bloc += 1
    if stayID[i] != stayID[i + timestep]:
        bloc = 1

# Extract the final processed dataset
MIMICtablecopydown = MIMICtablecopy.iloc[0:count, :]
