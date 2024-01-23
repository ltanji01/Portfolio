/*
 *  FSTreeTraversal.h
 *
 *  Purpose: declares the function prototypes for functions that deal with 
 * FSTrees, such as printing paths
 */

#ifndef FSTREETRAVERSAL_H_
#define FSTREETRAVERSAL_H_

#include "FSTree.h"
#include "DirNode.h"
#include <string>
#include <sstream>
#include <vector>

void printPaths(DirNode *rt, std::string path, std::ostream &outfile);
std::string printAllFilePaths(std::string directory);

#endif

    