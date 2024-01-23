/*
 *  FileIndex.cpp
 *
 *  Purpose: provide the implementation for the FileIndex class, which is 
 *      responsible for indexing files in a given directory and building a data 
 *      structure to efficiently search for words in those files.
 */

#include "FileIndex.h"
#include "DirNode.h"
#include "HashTable.h"
#include "words.h"
#include "FSTree.h"
#include "gerp.h"
#include <iostream>
#include <string>
#include <sstream>
#include <fstream>
#include <istream>
#include <queue>
#include <list>
#include <cctype>  
#include <functional>
#include <vector>
#include <stdexcept>

using namespace std; 

/*
 * name:      printAllFilePaths
 * purpose:   traverses the directory tree starting from the given directory 
 *            and prints the full paths of each file.
 * arguments: - directory: a string that represents the directory to be 
 *               traversed.
 *            - theTable: a reference to a HashTable object to store the file 
 *               paths and their indices.
 * returns:   nothing
 * effects:   none
 * notes:     The function uses the FSTree class to traverse the directory tree 
 *            and calls a helper function named `printPaths` that recursively 
 *            prints the full paths of each file found, using the parent 
 *            directory path and the file name. The function also populates the 
 *            HashTable with the full path of each file and its index. The 
 *            function will throw a std::runtime_error if the directory cannot 
 *            be opened.
 */
void FileIndex::printAllFilePaths(std::string directory, HashTable &theTable) {
    ifstream dirIn;
    dirIn.open(directory);

    if(not dirIn.is_open()){    //An edge case.
        cerr << "Could not build index, exiting." << endl;
        exit(EXIT_FAILURE);
    }
    else{
        dirIn.close();
    }

    FSTree tree = FSTree(directory);
    DirNode* root = tree.getRoot(); 
    string none = "";
    printPaths(root, none, theTable);
}

/*
 * name:      printPaths
 * purpose:   recursively prints the path of all files in a directory tree 
 *            rooted at rt to an output stream and populates the HashTable with 
 *            the full path of each file and its index.
 * arguments: rt - pointer to the root directory node
 *            path - current path of the node
 *            indexTable - a reference to a HashTable object to store the file 
 *            paths and their indices.
 * returns:   nothing
 * effects:   modifies the output stream by printing the file paths of all files 
 *            in the directory tree
 * Note:      The function recursively traverses the directory tree starting 
 *            from the root node rt and prints the full paths of each file using 
 *            the parent directory path and the file name. The function checks 
 *            if the current directory is empty or has files, and then prints 
 *.           the full path of each file and populates the HashTable with its 
 *            index. If the current folder has a subdirectory, the function 
 *            recursively calls itself on the subdirectory.
 */
void FileIndex::printPaths(DirNode* rt, string path, HashTable &indexTable) {
    cout << "get to print paths" << endl;
    std::stringstream ss;
    path += rt->getName() + "/";
    if(rt->isEmpty()){  //current directory is empty
        return;     
    }
    if((rt->hasFiles())){   //current directory has files
        int filenum = rt->numFiles();
        for(int i = 0; i < filenum; i++){
            ss << path << rt->getFile(i); // << '\n';
            cout << ss.str() << endl;
            traverseFile(ss.str(), indexTable);
        }
    }
    if(rt->hasSubDir()){        //current folder has a subdirectory
        int foldernum = rt->numSubDirs();
        for(int j = 0; j < foldernum; j++){
            printPaths(rt->getSubDir(j), path, indexTable);
        }
        return;
    }
}

/*
 * name:      traverseFile
 * purpose:   traverses through the given file, finds all the words and inserts 
 *            them into the hash table
 * arguments: string path, HashTable &indexTable
 * returns:   nothing
 * effects:   opens the file, reads line by line, splits the lines into words, 
 *            and inserts each word into the hash table
 */
void FileIndex::traverseFile(string path, HashTable &indexTable) {
    cout << "Path in traverse: " << path << endl;
    ifstream inFile;
    inFile.open(path);
    if(not inFile.is_open()){ //check file opened
        return;
    }
    string line, word;
    int lineNum = 0;
    while(getline(inFile, line)){ //read file taken by line
        lineNum ++;    
        stringstream ss(line); //Convert line into stringstream to extract words
        while(ss >> word){ //extract each word from the line
            cout << word <<" ";
            //Insert the word with its line number and path into the hash table
            indexTable.insert(lineNum, word, path); 
            /*for(int i = 0; i < 50; i++){    //TEST CODE
                int n = tinyTable.table[i].size();
                if(n >= 1){
                    for(int j = 0; j < n; j++) {
                        tinyTable.table[i].at(j).print();
                    }
                }
            }*/
        }
    }
}

