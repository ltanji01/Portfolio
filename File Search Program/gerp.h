/*
 * gerp.h
 * 
 * Purpose: header file for the Gerp class
 *          provides functionality for searching through directories of files 
 *            and finding specific words or phrases within those files
*/

#ifndef GERP_H
#define GERP_H

#include "HashTable.h"
#include "FileIndex.h"
#include <string>
#include <iostream>
#include <fstream>
#include <istream>
#include <cstdlib>
#include <queue>
#include <ostream>
#include <stack>

using namespace std;

class Gerp {
public:
    void commands(string directory, const string output_file);

private:
    void newTable(string directory, HashTable &theTable);
    void setOutputFile(ofstream &outstream, const string &output_file);

    template<typename streamtype>
    void open_or_die(streamtype &stream, std::string file_name);
};

#endif