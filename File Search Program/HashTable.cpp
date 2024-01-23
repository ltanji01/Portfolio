/*
 *  HashTable.cpp
 *  04/19/2022
 *
 *  Purpose: defines the implementation of the HashTable class, which provides 
 *           a hash table data structure used for efficient searching and 
 *           storage of Word objects. This file defines various functions for 
 *           the class, such as constructors, destructor, and methods for 
 *           inserting and searching for Words in the hash table. It also 
 *           defines a custom overloaded assignment operator for deep copying of 
 *           the hash table, as well as other utility functions such as checking 
 *           the size and capacity of the hash table.
 */
#include "words.h"
#include "FileIndex.h"
#include "gerp.h"
#include "HashTable.h"
#include <string>
#include <iostream>
#include <vector>
#include <list>
#include <cctype>

using namespace std; 

/*
 * name:      HashTable
 * purpose:   Creates an instance of the HashTable class with an array of size 
 *            50 and initializes the capacity and count to 0. Each element in 
 *            the array is a Word vector that is initially empty. 
 * arguments: none
 * returns:   none
 * effects:   Allocates memory on the heap for the array and for a Words object 
 *            to hold search results. Initializes the array to size 50 with 
 *            empty Word vectors, and sets the capacity and count to 0. 
 */
HashTable::HashTable(){
    table = new vector<Words>[50];
    capacity = 50;
    count = 0;
    results = new Words(-1, "", "");
}

/*
 * name:      HashTable
 * purpose:   Second constructor for hash table. Creates an instance of the 
 *            HashTable class with an array of given size and initializes the 
 *            capacity and count to 0. Each element in the array is a Word 
 *            vector with size 1 that is initially empty. 
 * arguments: cap - int representing desired hashtable capacity.
 * returns:   none
 * effects:   Allocates memory on the heap for the array and for a Words object 
 *            to hold search results. Initializes the array to the given size 
 *            with empty Word vectors of size 1, and sets the capacity to the 
 *            given argument and count to 0. 
 */
HashTable::HashTable(int cap){
    table = nullptr;
    capacity = cap;
    count = 0;
    results = new Words(-1, "", "");
}

/*
 * name:      Copy constructor for class
 * purpose:   Creates deep copy of the hashtable.
 * arguments: constant hashtable.
 * returns:   none
 * effects:   creates a deep copy of referenced hashtable array.
 */
HashTable::HashTable(const HashTable &other){
    vector<Words> *lhs = new vector<Words>[other.capacity];

    for (int i = 0; i < count; i++) {
        lhs[i] = other.table[i];
    }

    capacity = other.capacity;
    count = other.count;
    table = lhs;
}

/*
 * name:      Overloaded assignment operator
 * purpose:   redefines an assignment operator (=) to create deep copy.
 * arguments: constant HashTable.
 * returns:   new deep copy with name of left hand side. 
 * effects:   Creates deep copy of array on the right with name on left.
 */
HashTable &HashTable::operator=(const HashTable &other){   
    if (this == &other){
        return *this;
    }
    if (table != nullptr){    //Prevent segfault.
        delete [] table;
    }

    table = new vector<Words>[other.capacity];
        
    for (int i = 0; i < other.count; i++){
        table[i] = other.table[i];
    }
    cout << other.capacity;
    capacity = other.capacity;
    count = other.count;
    return *this;
}

/*
 * name:      ~HashTable
 * purpose:   destructor for hash table
 * arguments: none
 * returns:   none
 * effects:   deallocates memory used by hash table and its contents
 */
HashTable::~HashTable() {
    delete [] table;
}

/*
 * name:      Size
 * purpose:   Returns number of members
 * arguments: None
 * returns:   None
 * effects:   None
 */
int HashTable::size() const {
    return count;
}

/*
 * name:      cap
 * purpose:   Returns number of buckets in the hash table.
 * arguments: None
 * returns:   None
 * effects:   None
 */
int HashTable::cap() const {
    return capacity;
}

/*
 * name:      isEmpty
 * purpose:   identifies whether  is empty.
 * arguments: None
 * returns:   boolean - true if is empty. False if full.
 * effects:   None
 */
bool HashTable::isEmpty() const {
    return size() == 0;
}

/*
 * name:      insert
 * purpose:   inserts words into the table or updates an existing word's line 
 *            and path vectors
 * arguments: num - the line number the word occurs on
 *            oWord - the original word being inserted
 *            road - the path to the file containing the word
 * returns:   nothing
 * effects:   modifies the hash table by inserting a new Word object or 
 *            updating an existing one with new line and path information. 
 *            Also checks the load factor of the table and resizes if necessary.
 */
void HashTable::insert(int num, string oWord, string road) {
    Words newWord = Words(num, oWord, road);  
    
    // compute hash value of current word
    std::string key = newWord.lword; 
    cout << "thekey: " << key << endl;
    int hash_val = std::hash<std::string>{}(key) % capacity;

    //If table is empty at the hash index.
    if(table[hash_val].empty()){
        count ++;
        table[hash_val].push_back(newWord);
    }
    //If the key already exists in the table
    else if(table[hash_val].size() >= 1){
        bool exists = false;
        int n = table[hash_val].size();
        for(int i=0; i < n; i++){ 
            if(table[hash_val].at(i).lword == key){
                count++;
                exists = true;  
                table[hash_val].at(i).origWord.push_back(newWord.origWord[0]);
                table[hash_val].at(i).line.push_back(num);
                table[hash_val].at(i).path.push_back(road);
            }
        }
        if(exists == false) {   //value was never found.
            table[hash_val].push_back(newWord);
        }
    }
    at_cap();   //check load factor. Resize if needed.
}

/*
 * name:      resize
 * purpose:   resizes the hash table by creating a new array and copying 
 *            elements over
 * arguments: none
 * returns:   nothing
 * effects:   deallocates memory used by old hash table, creates new hash table
 *            with new size, and copies elements over
 */
void HashTable::resize() {
    int newsize = capacity * 2; //double the size
    vector<Words> *temp_table = new vector<Words>[newsize];
    // Rehash all the words into the new table
    for (int i = 0; i < capacity; i++) {   //table index
        int vectorsize = table[i].size();
        for (int j = 0; j < vectorsize; j++) {    //for chained words
            std::string key = table[i].at(j).lword;    
            int hash_val = std::hash<std::string>{}(key) % newsize;
            temp_table[hash_val].push_back(table[i].at(j));
        }
    }
    capacity = newsize;
    delete [] table;
    table = temp_table;
}

/*
 * name:      check_cap()
 * purpose:   checks load factor of hash table
 * arguments: none
 * returns:   none
 * effects:   calls resize function if over 70% load factor.
 */
void HashTable::at_cap() {
    if(capacity != 0){
        float load = (count/capacity)*1.0;

        if (load >= 0.7) {
            resize();   //expands HashTable if load factor over 70%
        } 
    }
}

/*
 * name:      searchPrint
 * purpose:   Executes both search and printing to output file. 
 * arguments: query - string representing the word to search for
 *            csensitive - boolean indicating whether search is case sensitive
 *            gerpOut - reference to output file stream to write results
 * returns:   nothing
 * effects:   modifies gerpOut by writing search results to file
 */
void HashTable::searchPrint(string query, bool csensitive, ofstream &gerpOut){
    Words *ws = search(query, csensitive);
    formatOutput(query, ws, gerpOut, csensitive);
}

/*
 * name:      search
 * purpose:   reformats query word and searches for the string in files. 
 * arguments: original string query, bool indicating whether search is case 
 *            sensitive or not.
 * returns:   pointer to struct with file information.
 * effects:   none.
 */
Words *HashTable::search(string query, bool csensitive) {
    clearResults();
    string stripped = results->stripNonAlphaNum(query);
    string lowered = results->lower(stripped);
    results->lword = lowered;

    //compute hash for lowercase string of query.
    int hash_val = std::hash<std::string>{}(lowered) % capacity;
    if(table[hash_val].empty()){
        cout << "is empty" << endl;
        return nullptr;
    }
    //if word is matching, return pointer to words struct
    else if (table[hash_val].size() >= 1){
        cout << "get into else if" << endl;
        int num = table[hash_val].size();
        for(int i = 0; i < num; i++) {
            cout << "lword: " << table[hash_val].at(i).lword << endl;
            if (table[hash_val].at(i).lword == lowered){
                cout << "in first if statement" << endl;
                if(csensitive){
                    return senSearch(&table[hash_val].at(i), stripped);
                }
                else{
                    return &(table[hash_val].at(i));
                }
            }
        }
    }
    return nullptr;
}

/*
 * name:      senSearch
 * purpose:   performs case sensitive search for gerp.
 * arguments: Words pointer and formatted word.
 * returns:   pointer to word object with file information.
 * effects:   saves information from hash table into a words object called 
 *            results
 */
Words *HashTable::senSearch(Words *lowered, string stripped){
    int num = lowered->path.size();

    for(int i = 0; i < num; i++) {  //skipp first initializer object.
        //First search result creates Words object.
        if(lowered->origWord[i] == stripped){
            results->origWord.push_back(stripped);
            results->path.push_back(lowered->path[i]);
            results->line.push_back(lowered->line[i]);
        }
    }
    if(results->origWord.size() == 1){   //we don't find any matches.
        return nullptr;
    }
    else {
       return results;    //have to ignore the first member
    }
}

/*
 * name:      formatOutput
 * purpose:   sends formatted output into applicable stream from gerp class
 * arguments: output stream where results should be printed. Word pointer with
 *            information about the output.
 * returns:   none
 * effects:   none
 */
void HashTable::formatOutput(
    string query, Words *wrd, ostream &outfile, bool csensitive)
{
    //Skipping the first member which is just there to initialize Words obj.
    if ((wrd == nullptr) and csensitive){
        outfile << query;
        outfile << " Not Found. Try with @insensitive or @i.\n";
    }
    else if((wrd == nullptr) and (not csensitive)){
        outfile << query;
        outfile << " Not Found.\n";
    }
    else{
        int num = (wrd->origWord.size());
        for(int i = 1; i < num; i++){
            outfile << wrd->path[i];
            outfile << ":";
            outfile << wrd->line[i];
            outfile << ": ";
            outfile << getPathLine(i, wrd);
            outfile << ":\n";
        }
    }
}

/*
 * name:      getPathLine
 * purpose:   gets entire line from file.
 * arguments: Hash table index of lowercase version of word. Pointer to the 
 *            vector node with the word.
 * returns:   string with entire line from the file.
 * effects:   Opens file from path to retreive the given line and closes it.
 */
string HashTable::getPathLine(int index, Words *wrd){
    ifstream files;
    string reading;
    files.open(wrd->path[index]);
    
    for (int i = 0; i < index; i++){
        getline(files, reading);
    }
    files.close();
    return reading;
}

/*
 * name:      clearResults
 * purpose:   clear results (heap allocated struct object)
 * arguments: none
 * returns:   nothing
 * effects:   modifies the heap allocated object pointed to by 'results'
 */
void HashTable::clearResults(){
    results->lword = "";
    if(results->origWord.size() != 1){
        int num = results->origWord.size();
        for (int i = 0; i < num-1; i++) {
            results->origWord.pop_back();
            results->path.pop_back();
            results->line.pop_back();
        }
    }
}