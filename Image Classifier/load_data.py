"""
load_data.py
Purpose: List of functions used to augment the training set images. Uses Pillow
Author: Leigh Tanji
"""
import os
import pandas as pd


"""
load_data
Input: string name of csv file to make into a pandas dataframe.
Output: A pandas dataframe version of the csv file.
"""
def load_data(x_file, y_file):
    data_dir = os.path.abspath("data_fashion/")

    # Load data
    x_df = pd.read_csv(os.path.join(data_dir, x_file)).to_numpy()
    y_df = pd.read_csv(os.path.join(data_dir, y_file))
    
    return x_df, y_df
