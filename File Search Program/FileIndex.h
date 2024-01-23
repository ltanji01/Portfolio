/*
 * FileIndex.h
 * 
 * Purpose: class to store the file names with their paths in a hash table
*/ 

#ifndef FILEINDEX_H
#define FILEINDEX_H

#include "FSTree.h"
#include "DirNode.h"
#include "words.h"
#include "HashTable.h"
#include <string>
#include <iostream>
#include <fstream>
#include <istream>
#include <functional>
#include <sstream>
#include <queue>
#include <vector>
#include <list>

using namespace std;

class FileIndex {
public:
    void printAllFilePaths(std::string directory, HashTable &theTable);

private:
    void printPaths(DirNode* rt, std::string path, HashTable &indexTable);
    void traverseFile(string path, HashTable &indexTable);
};  

#endif