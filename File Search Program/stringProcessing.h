/*
 * stringProcessing.h
 * Date: 27-Mar-2023
 * 
 * Purpose: declare a function stripNonAlphaNum that can be used to strip all 
 *          leading and trailing non-alphanumeric characters from a given string
*/

#ifndef _STRINGPROCESSING_H_
#define _STRINGPROCESSING_H_
#include <istream>
#include <iostream>
#include <fstream>
#include <ostream>
#include <string>
#include <sstream>


using namespace std;

string stripNonAlphaNum (string input);
int getFirst(string &input);
int getLast(string &input);

#endif