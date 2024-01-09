"""
clean_tokens.py
Author:     Leigh Tanji
Purpose:    Series of functions to preprocess words before they are fed into 
            the logitstic regression to classify the sentiment of the review.
"""
import nltk
import os
import numpy as np
import pandas as pd
from nltk.tag import pos_tag
nltk.download('averaged_perceptron_tagger')
nltk.download('universal_tagset')
nltk.download('wordnet')
from nltk.corpus import stopwords
from nltk.tokenize import regexp_tokenize
from nltk.corpus import webtext, brown
from nltk import ngrams, FreqDist
from nltk.stem import WordNetLemmatizer

"""
tokenizing
Input:         A list of raw reviews. 
Description:   Divides each review into word using whitespace and makes them
               lowercase. 
Output:        A list of tokens.
"""
#tokenizing specific reviews
def tokenizing(reviews):
    tokenz = []
    for reviewIdx in range(len(reviews)):
        cur_review = regexp_tokenize(str(reviews[reviewIdx]), "[\w']+")
        for i in range(len(cur_review)):
            #can't get rid of stopwords/punctuation here. It doesn't work.
            tokenz.append(cur_review[i].lower()) 
    return tokenz


"""
clean_tokens
Input:         A list of tokens in lower case. 
Description:   Cleans tokens further by removing special characters and 
               punctuation. Also, removes stopwords from the NLTK library
               and any added to the stop_words list in the function.
Output:        A list of tokens without punctuation and stopwords. 
"""
def clean_tokens(token_list):
    punc = ['.', '..', '...', ',', '"', "'", '?', '!', ':', ';', '(', ')', '[', ']', '{', '}','%', '$']

    stop_words = stopwords.words('english')     #Adding stopwords
    added_words = ["i've", "i'd", "i'm", "that's", "i'll", "was", "as", "us", "was", "as"]
    stop_words.extend(added_words) 

    #Removing stopwords and punctuation:
    for cur_token in token_list:
        if cur_token in punc or cur_token in stop_words:
            token_list.remove(cur_token)
    return token_list


"""
lemmetize
Input:         A list of tokens in lower case and without stopwords. 
Description:   Lemmetizes words in cleaned tokens list. 
Output:        A list of words that were lemmetized. 
"""
def lemmetize(all_cleaned_tokens):
    
    #list of words that are made worse by lemmatization
    delete = ['was', 'us', 'as']    

    wordnet_lemmatizer = WordNetLemmatizer()
    lemmed_tokens = []
    for w in all_cleaned_tokens:
        cur_word = wordnet_lemmatizer.lemmatize(w)	
        if cur_word not in delete:
            lemmed_tokens.append(cur_word)
    return lemmed_tokens


"""
token_wrap
Input:         list of raw reviews.
Description:   A wrapper function putting together tokenizing, clean_tokens, 
               and lemmetize functions. 
Output:        A list of cleaned words from reviews and lemmetized tokens.
"""
def token_wrap(reviews):
    cleaned_list = clean_tokens(tokenizing(reviews))
    final_words= lemmetize(cleaned_list)
    return final_words


"""
lemmetize2
Input:         List of raw reviews
Description:   Second lemmetize function that takes raw list of reviews,
               divides everything into tokens by whitespace, makes it lowercase, and removes stop words, and lemmetizes words.
Output:        Final list of reviews for logistic regression pipeline.
"""
#puts reviews back together with words lemmetized.
def lemmetize2(reviews):
    lemmed_reviews = list()
    wordnet_lemmatizer = WordNetLemmatizer()

    for a_review in reviews: 
        new_review = ''
        for w in str(a_review).split():
            lwr_word = w.lower()
            # if lwr_word not in stoppedWords:
            lemmed_str= wordnet_lemmatizer.lemmatize(lwr_word)	
            lemmed_str = lemmed_str + ' '
            new_review = new_review + lemmed_str
        lemmed_reviews.append(new_review)
    
    return lemmed_reviews