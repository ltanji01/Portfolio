import time
import pickle
import numpy as np
import os
import pandas as pd

if __name__ == '__main__':
    # Calculate time
    start = time.perf_counter()
    # Load total data
    # Filename of the CSV
    filename = 'final_cohort_data_edited.csv'
    
    # Current working directory
    current_working_directory = os.getcwd()
    
    # Complete path to the file in the current working directory
    file_path = os.path.join(current_working_directory, filename)
    
    MIMICtable = pd.read_csv(file_path)

    #####################Model Parameter Settings##############################
    ncv = 10  # Number of cross-validation runs (each is 80% training / 20% testing)
    icustayidlist = MIMICtable['subject_id']
    icuuniqueids = np.unique(icustayidlist)
    N = icuuniqueids.size
    grp = np.floor(ncv * np.random.rand(N, 1) + 1)
    
    crossval1 = 1  # Using equals to 1 and not equals to 1
    crossval2 = 2  # Using equals to 1 and not equals to 1
    trainidx = icuuniqueids[np.where(grp > crossval2)[0]]
    validationidx = icuuniqueids[np.where(grp == crossval1)[0]]
    testidx = icuuniqueids[np.where(grp == crossval2)[0]]
    train = np.isin(icustayidlist, trainidx)
    validation = np.isin(icustayidlist, validationidx)
    test = np.isin(icustayidlist, testidx)
    # Save to file
    np.save('dataset/train.npy', train)
    np.save('dataset/validation.npy', validation)
    np.save('dataset/test.npy', test)
