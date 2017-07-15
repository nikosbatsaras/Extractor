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
./extractor.sh  -i /full/path/to/input-folder -o /full/path/to/output-folder
```
will produce a similar result:
```
output-folder
    |
    |---C
    |   |--- project1
    |   |       |
    |   |       |---*.c
    |   |       |---*.h
    |   |       |
    |   |----project3
    |   |       |
    |   |       |---*.c
    |   |       |---*.h
    |   |       |
    |   |---- ...
    |   |
    |---Java
    |   |--- project2
    |   |       |
    |   |       |---*.java
    |   |       |
    |   |----project5
    |   |       |
    |   |       |---*.java
    |   |       |
    |   |---- ...
    |   |
    |---C++
    |   |--- project4
    |   |       |
    |   |       |---*.cpp
    |   |       |---*.h
    |   |       |
    |   |----project6
    |   |       |
    |   |       |---*.cpp
    |   |       |---*.h
    |   |       |
    |   |---- ...
```
The script will find the source files, even in a really deep directory, and
place them right under their respective project folder, as shown above
