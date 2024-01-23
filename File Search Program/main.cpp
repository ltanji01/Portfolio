#include <iostream>
#include <string>
#include <cstdlib>
#include "gerp.h"

/*
* name:      main()
* purpose:   entry point of program
* arguments: int argc: the number of command line arguments
*            char *argv: 
* returns:   0 if the program runs successfully - if not, returns exit failure
* effects:   
*/
int main(int argc, char *argv[]){
    // Check if the correct number of command line arguments are provided
    if (argc == 3) {
        Gerp start;
        start.commands(argv[1], argv[2]);
    }
    else {
        cerr << "Usage: ./gerp inputDirectory outputFile" << endl;
        return EXIT_FAILURE;
    }
    
    return 0;
}