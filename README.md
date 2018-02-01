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


## Running extractorA.sh

Running the first script like this:
```
extractorA.sh  -i input-folder -o output-folder
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


## Running extractorB.sh

You can run the second script like this:
```
extractorB.sh  -i input-folder -a phase1-output -b phase2-output -q query
```
* *input-folder* is the folder with the compressed projects of the second phase
* *phase1-output* is the folder that holds the classified output of the first
  phase
* *phase2-output* is the folder to hold the classified output of the second
  phase
* *query* is used to differentiate between the two phases. Use something that
  exists in all phase 1 projects but in none of the phase 2. In order to check
  the quality of your query, you can first try it out using the check.sh
  script like this:

```
check.sh -d phase1-output -q query
```
If your query is able to find 100% of the phase 1 projects and 0% of the
phase 2 projects, then it's a good candidate.
