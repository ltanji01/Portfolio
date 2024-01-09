import numpy as np
import pandas as pd
import os

"""
load_data
Input:         The name of two files containing the training set. 
Description:   Takes names of two files containing the training set and puts it 
               into a list.
Output:        List of websites, reviews, and ratings.
"""
def load_data(x_data, y_data):
    data_dir = 'data_reviews'
    x_df = pd.read_csv(os.path.join(data_dir, x_data))
    y_df = pd.read_csv(os.path.join(data_dir, y_data))
    N, n_cols = x_df.shape

    # print("Shape of x_df: (%d, %d)" % (N,n_cols))
    # print("Shape of y_df: %s" % str(y_df.shape))
    # print(type(x_df))
    # print(type(y_df))

    # Print out the first five rows and last five rows
    website_list = x_df['website_name'].values.tolist()
    text_list = x_df['text'].values.tolist()
    rating_list = y_df['is_positive_sentiment'].values.tolist()
    # print(text_list)
    return website_list, text_list, rating_list