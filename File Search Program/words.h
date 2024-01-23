/*
 * words.h
 * Date: 20-April-2023
 * 
 * Purpose: declares "Words" struct and its member functions, which will be
 *          used in other parts of the program
*/ 
#ifndef _WORDS_H
#define _WORDS_H

#include <string>
#include <iostream>
#include <vector>
#include <list>
#include <cctype>

using namespace std;

struct Words {
    vector<string>origWord, path;
    vector<int> line;
    string lword;

    Words(int ln, string oWrd, string road){
        string transformed = stripNonAlphaNum(oWrd);
        lword = lower(transformed);
        origWord.push_back(transformed); 
        path.push_back(road);
        line.push_back(ln);
    }

    void print();
    string lower(string aWord);
    string stripNonAlphaNum (string input);
    int getFirst(std::string &input);
    int getLast(std::string &input);
};
#endif