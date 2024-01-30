# Summary of Image Classifier Project:
This project was assigned was during the Intro. to Machine Learning course (CS135) at Tufts University in the Fall 2023 semester.

Students had to build three MLP classifier that took in a 28x28 pixel, greyscale image and classifies it as one of six types of clothing. The given training set purposely had an uneven representation of each class.

Below are the specifications for each of the three classifiers:
1. We needed to develop an MLP with 1 hidden later at most. We were only allowed to use the provided training and validation sets. 
2. Build an MLP classifier by only duplicating, not altering, the training images and corresponding labels.
3. A MLP classifier trained using ONLY the provided data, or augmented versions of that data.


## Credit:
* Leigh Tanji
* Avtar Rekhi
* Professor Michael Hughes, the instructor for CS135, provided the dataset in the data_reviews folder and wrote the [assignment]().


## Official Image Classifier (a.k.a. Project B) Instructions


## Files in this repository:
* Project_B_Report - The final report submitted by the authors as part of this assignment. 
* Problem1B.ipynb - The Jupytr notebook consisting of the 1st MLP classifier and search for best hyperparameters.
* Part1D.ipynb - The second Jupytr notebook building another MLP classifier. Again, we were only allowed to use duplicated versions of the training set.
* problem2.ipynb - Final Jupytr notebook showing how we augmented each image to artificially create an even training set. This file also includes the third MLP classifier
* transformations.py - Functions written to augment the training images for problem 2.
* load_data.py - Function to load csv datasets into a pandas dataframe.
* data_fashion - This file contains csv files with all reviews.
* cs135_projectB_spec.pdf - A pdf copy of assignment provided to students.

