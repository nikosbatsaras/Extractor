# Extractor

Suppose you have the following directory structure:
```
input-folder
    |
    |--- project1.tgz
    |----project2.tgz
    |----project3.tgz
    |----project4.tgz
    |----project5.tgz
    |----project6.tgz
    |---- ...
```
Inside these compressed files, there is folder that holds the source/header
files. The name of the inner folder can be anything, it doesn't matter.

Running the script like this:
```
./extractor input-folder output-folder
```
will produce a similar result:
```
output-folder
    |
    |---C
    |   |--- project1
    |   |----project3
    |   |---- ...
    |
    |---Java
    |   |--- project2
    |   |----project5
    |   |---- ...
    |
    |---C++
        |--- project4
        |----project6
        |---- ...
```
Now projectN is a folder with the name of the initial .tgz file and inside
holds the source/header files.

At the end, the script also prints all directories that are deeper than those
in the depicted example. You might want to edit them by hand and the output
indicates the path to those folders so that you don't have to search for them
