/*
 * HashTable.h
 * Date: 23-April-2023
 *
 * Purpose: provides the interface for using the HashTable class and its member 
 *          functions in other parts of the program.
 *          The HashTable class represents a hash table data structure, which is
 *          used for storing and retrieving data.
*/ 

#ifndef HASHTABLE_H
#define HASHTABLE_H

#include "words.h"
#include <string>
#include <iostream>
#include <vector>
#include <cctype>
#include <list>
#include <ostream>

class HashTable{
public:
    HashTable();
    HashTable(int cap);

    ~HashTable();

    HashTable(const HashTable &other); //copy constructor    
    HashTable &operator=(const HashTable &other); //overloaded assign. operator
    void insert(int num, string oWord, string road);
    
    bool isEmpty() const;
    int size() const;
    int cap() const;
    Words* search(std::string query, bool csensitive);
    void searchPrint(string query, bool csensitive, ofstream &gerpOut);

private:
    int capacity;
    int count;  //number of items in hashtable
    Words* results;
    const static int tablesize = 50;
    vector<Words>* table;
    void resize();
    void at_cap();
    Words* senSearch(Words *lowered, string query);
    string getPathLine(int index, Words *wrd);
    void formatOutput(string query, Words *wrd, ostream &outfile, bool csensitive);
    void clearResults();
};

#endif