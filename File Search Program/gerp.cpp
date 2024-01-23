/*
 * gerp.cpp
 * 
 * Purpose: - implementation file for the Gerp class, which is a program that 
 *              performs text searches across multiple files and directories
 *          - defines several functions that are used to handle user commands
 * 
 */

#include "gerp.h"
#include "HashTable.h"
#include "FileIndex.h"
#include <string>
#include <iostream>
#include <fstream>
#include <istream>
#include <ostream>
#include <sstream>
#include <cstdlib>
#include <queue>
#include <list>
#include <stack>

using namespace std;

/*
* name:      commands
* purpose:   handles user input and dispatches appropriate function for each cmd
* arguments: directory - a string representing the directory to be searched
*            output_file - a string representing the name of the output file to 
*            be written to
* returns:   nothing
* effects:   reads user input, performs various actions based on the input, and 
*            prints messages to the stdout console to prompt user for input
* calls other functions such as handle_quit_command(), handle_file_command(),
* and handle_insensitive_command() based on user input. 
*/
void Gerp::commands(string directory, const string output_file) {
    HashTable theTable;
    newTable(directory, theTable);
    /*for(int i = 0; i < 50; i++){    //TEST CODE
        int n = theTable.table[i].size();

        if(n >= 1){
            for(int j = 0; j < n; j++) {
                theTable.table[i].at(j).print();
            }
        }
    }*/
    ofstream outfile; 
    open_or_die(outfile, output_file);
    string qs, filename, cmd;
    cout << "Query? ";
    cin >> cmd;
    while(not cin.eof()){
        if (cmd == "@q" or cmd== "@quit") {
            cout << "Goodbye! Thank you and have a nice day." << endl;
            return;
        } else if (cmd == "@f") {
            cin >> filename;
            setOutputFile(outfile, filename);
        } else if (cmd == "@i" or cmd == "@insensitive") {
            cin >> qs;
            theTable.searchPrint(qs, false, outfile);
        }
        else {
            theTable.searchPrint(cmd, true, outfile);
        }
        cout << "Query? ";
        cin >> cmd;
    }
    outfile.close();    
}

/*
* name:      newTable
* purpose:   creates a new hash table for the given directory and populates it 
*            with file content
* arguments: string directory, HashTable theTable
* returns:   nothing
* effects:   reads all files in the directory and populates the given hashtable 
*            with their content
*/
void Gerp::newTable(string directory, HashTable &theTable){
    FileIndex indexing;
    indexing.printAllFilePaths(directory, theTable);
}

/*
* name:      open_or_die
* purpose:   opens input/output files and exits if not able to open the file.
* arguments: stream: A reference to a stream object of the streamtype template 
*             type, which can be either an input or output stream.
*            file_name: A string representing the name of the file to be opened.
* returns:   nothing
* effects:   If the file specified by file_name cannot be opened, an error 
*            message is printed to cerr, and the program exits w/ failure status
*/
template<typename streamtype>
void Gerp::open_or_die(streamtype &stream, string file_name){
    stream.open(file_name);
    if (not stream.is_open()) {
        cerr << "Unable to open:  " + file_name << endl;
        exit(EXIT_FAILURE);
    }
}

/*
* name:      setOutputFile
* purpose:   sets the output file for the search results
* arguments: - outstream: reference to the output stream to set the output file
*            - output_file: constant reference to the output file name to set
* returns:   nothing
* effects:   closes output stream if it's open. If not, opens the given file.
*/
void Gerp::setOutputFile(ofstream &outstream, const string &output_file) {
    //reset the stream.
    if (outstream.is_open()) {
        outstream.close(); 
    }
    else{
        open_or_die(outstream, output_file); //open new output stream.
    }
}

