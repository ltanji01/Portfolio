/*
 *  FSTreeTraversal.cpp
 *
 *  Purpose: file which contains implementation of functions related to FSTrees
 *
 */

#include <iostream>
#include <string>
#include <ostream>
#include <sstream>
#include "FSTree.h"
#include "DirNode.h"

using namespace std;
void printPaths(DirNode *rt, string path);
void printAllFilePaths(std::string directory);

/*
* name:      main()
* purpose:   entry point of the program, takes a single command line argument, 
*            traverses the directory and prints full paths of each file
* arguments: int argc: the number of command line arguments
*            char *argv: an array of pointers to the command line arguments
* returns:   0 if the program runs successfully - if not, an error code
* effects:   prints the full paths of all files in the specified directory.
*/
int main(int argc, char **argv) {
    // Check if the correct number of command line arguments are provided
    if (argc != 2) {
        cerr << "Usage: ./treeTraversal Directory" << endl;
        return EXIT_FAILURE;
    }
    
    // Call the function to print all file paths and write result to the output
    printAllFilePaths(string (argv[1]));
    return 0;
}

/*
* name:      printPaths
* purpose:   recursively prints the path of all files in a directory tree 
*            rooted at rt to an output stream
* arguments: rt - pointer to the root directory node
*            path - current path of the node
* returns:   nothing
* effects:   modifies the output stream by printing the file paths of all files 
*            in the directory tree
*/
void printPaths(DirNode* rt, string path) {
    path += rt->getName() + "/";

    // Return if current directory is empty
    if(rt->isEmpty()){
        return;
    }
    
    // If current directory has files, write their paths to the output stream
    if((rt->hasFiles())){
        int filenum = rt->numFiles();
        for(int i = 0; i < filenum; i++){
            cout << path;
            cout << rt->getFile(i);
            cout << '\n';
        }
    }

    // Recursively call printPaths on all subdirectories of current directory
    if(rt->hasSubDir()){        //If current folder has a subdirectory
        int foldernum = rt->numSubDirs();
        for(int j = 0; j < foldernum; j++){
            printPaths(rt->getSubDir(j), path);
        }
        return;
    }
}

/*
* name:      printAllFilePaths
* purpose:   traverses the directory tree starting from the given directory and 
*            prints the full paths of each file.
* arguments: a string directory that represents the directory to be traversed.
* returns:   nothing
* effects:   none
*/
void printAllFilePaths(std::string directory) {
    FSTree tree = FSTree(directory);
    DirNode* root = tree.getRoot(); 
    string none = "";
    printPaths(root, none);
}



