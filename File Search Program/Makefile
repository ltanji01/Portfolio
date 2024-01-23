###
### Makefile for gerp
### Date: April-14-2023
### Purpose: Rules to compile and run gerp 

MAKEFLAGS += -L

CXX      = clang++
CXXFLAGS = -g3 -O2 -Wall -Wextra -Wpedantic -Wshadow
LDFLAGS  = -g3 -O2

#Rule to create gerp.
gerp: FSTree.o DirNode.o words.o HashTable.o FileIndex.o gerp.o main.o
	$(CXX) $(LDLFLAGS) -o gerp FSTree.o DirNode.o HashTable.o main.o words.o \
	FileIndex.o gerp.o

#Rule to make main.o
main.o: main.cpp gerp.h
	$(CXX) $(CXXFLAGS) -c main.cpp

#Rule for gerp.o
gerp.o: gerp.cpp gerp.h HashTable.h FileIndex.h
	$(CXX) $(CXXFLAGS) -c gerp.cpp

#Rule to make FileIndex.o
FileIndex.o: FileIndex.cpp FileIndex.h FSTree.h DirNode.h words.h HashTable.o
	$(CXX) $(CXXFLAGS) -c FileIndex.cpp


#Rule to make word.o
words.o: words.h words.cpp
	$(CXX) $(CXXFLAGS) -c words.cpp

#Rule to create HashTable.o
HashTable.o: HashTable.h HashTable.cpp words.h gerp.h
	$(CXX) $(CXXFLAGS) -c HashTable.cpp

# Rule to create unit_test
unit_test: unit_test_driver.o words.o HashTable.o FileIndex.o DirNode.o FSTree.o
	$(CXX) $(CXXFLAGS) $^

# Below make rules were ONLY for phase 1 of the assignment. Not applicable to \
	run full gerp program.
#Rule to create FSTreeTraversal function for phase 1 of gerp assignment.
#treeTraversal: FSTreeTraversal.o FSTree.h DirNode.h\
	$(CXX) $(LDLFLAGS) -o treeTraversal FSTreeTraversal.o FSTree.o DirNode.o

#Rule to make FSTreeTraversal.o for phase 1 of ferp assignment.
#FSTreeTraversal.o: FSTreeTraversal.cpp FSTree.h DirNode.h\
	$(CXX) $(CXXFLAGS) -c FSTreeTraversal.cpp

# Rule to make stringProcessing.o for phase 1 of Gerp
#stringProcessing.o: stringProcessing.cpp stringProcessing.h\
	$(CXX) $(CXXFLAGS) -c stringProcessing.cpp

clean: 
	rm -f main.o gerp.o unit_test.o HashTable.o FileIndex.o words.o *~ *.gch

provide:
	provide comp15 proj4_gerp README Makefile FSTreeTraversal.cpp \
							  stringProcessing.h stringProcessing.cpp \
							  FileIndex.cpp FileIndex.h gerp.cpp gerp.h \
							  HashTable.cpp HashTable.h main.cpp unit_tests.h\
							  words.cpp words.h tinyData.out





