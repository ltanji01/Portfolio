/*
 *  words.cpp
 *  04/19/2022
 *
 *  Purpose: declares "Words" struct and its member functions, which will be
 *          used in other parts of the program
 */

#include "words.h"
#include <string>
#include <cctype>
#include <iostream>
#include <sstream>
#include <vector>
#include <list>

using namespace std;

/*
* name:      print
* purpose:   prints all memebers of the word for testing!
* arguments: none
* returns:   nothing
* effects:   none
*/
void Words::print(){
    std::cout << lword;
    int num = line.size();
    for(int i = 0; i < num; i++){
        cout << ", line#: "<< line[i];
        cout << ", origWord: " << origWord[i];
        cout << ", path: " << path[i] << endl;
    }
}

/*
* name:      lower
* purpose:   turns original word into lowercase version
* arguments: the original formatted word
* returns:   nothing
* effects:   none
*/
string Words::lower(string aWord){
    int num = aWord.length()+1;
    //string lowerWrd;
    for(int i = 0; i < num; i++) {
        //char c = tolower(aWord[i]);
        aWord[i] = tolower(aWord[i]);
        //lowerWrd.push_back(c);
    }
    return aWord;
    //return lowerWrd;
}

/*
 * name:      stripNonAlphaNum
 * purpose:   strips all leading and trailing non-alphanumeric characters from a
 *            given string
 * arguments: string input - the string to be stripped
 * returns:   the stripped version of the input string
 * effects:   none
 */
string Words::stripNonAlphaNum(std::string input) {
    int first = getFirst(input);
    int last = getLast(input);
    if (first == last){
        return input.substr(0, 1);
    }
    else if(first < last){
        return input.substr(first, last - first + 1);
    }
    else{
        return "";
    }
}

/*
 * name:      getFirst
 * purpose:   find the position of the first alphanumeric character in a string
 * arguments: string input - the string to be stripped
 * returns:   the stripped version of the input string
 * effects:   none
 */
int Words::getFirst(std::string &input) {
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
int Words::getLast(std::string &input) {
    int size = input.length();
    for (int i = size; i >= 0; i--) {
        if((input[i] >= '0' and input[i] <= '9') or 
            (input[i] >= 'A' and input[i] <= 'Z') or 
            (input[i] >= 'a' and input[i] <= 'z')) {

            return i;
        }
    }
    return -1;
}