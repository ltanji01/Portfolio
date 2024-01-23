/*
 * stringProcessing.cpp
 * Date: 13-Apr-2023
 * 
 * Purpose: define the function stripNonAlphaNum() which takes a string input, 
 * strips all leading and trailing non-alphanumeric characters from it, and 
 * returns the stripped version of the input string
 */

#include "stringProcessing.h"
#include <iostream>
#include <string>
#include <sstream>

using namespace std;

/*
 * name:      stripNonAlphaNum
 * purpose:   strips all leading and trailing non-alphanumeric characters from a
 *            given string
 * arguments: string input - the string to be stripped
 * returns:   the stripped version of the input string
 * effects:   none
 */
string stripNonAlphaNum(std::string input) {
    int first = getFirst(input);
    int last = getLast(input);
    if (first >= last ){
        return "";
    }
    return input.substr(first, last - first + 1);
}

/*
 * name:      getFirst
 * purpose:   find the position of the first alphanumeric character in a string
 * arguments: string input - the string to be stripped
 * returns:   the stripped version of the input string
 * effects:   none
 */
int getFirst(std::string &input) {
    int size = input.length();
    for (int j = 0; j < size; j++) {
        if ((input[j] >= '0' and input[j] <= '9') or 
            (input[j] >= 'A' and input[j] <= 'Z') or 
            (input[j] >= 'a' and input[j] <= 'z')) {
            return j;
        }
    }
    return -1; 
}

/*
 * name:      getLast
 * purpose:   find the position of the last alphanumeric character in a string
 * arguments: string input - the string to be stripped
 * returns:   the stripped version of the input string
 * effects:   none
 */
int getLast(std::string &input) {
    int size = input.length();
    for(int i = size; i >= 0; i--) {
        if((input[i] >= '0' and input[i] <= '9') or 
            (input[i] >= 'A' and input[i] <= 'Z') or 
            (input[i] >= 'a' and input[i] <= 'z')) {

            return i;
        }
    }
    return -1; 
}
