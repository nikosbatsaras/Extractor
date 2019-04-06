#!/usr/bin/env bash

##
#
# Extractor
# =========
# 
#
# This script is used for the purposes of CS-240 (Data Structures) at
# University of Crete, Computer Science Department.
#
# The main goal is to automate the process of:
#   1) Extracting all the student submitted projects
#   2) Classify them based on what programming language was used
#   3) Re-structure the directory tree of the extracted and classified projects
#   4) In case a student re-submits the 1st phase of the project
#      at phase 2, take into account the latter submission for phase 1
#
#
# @file   extractorA.sh
#
# @author Nikos Batsaras <nickbatsaras@gmail.com>
#
# @desc   A script to extract a group of .tgz files and classify them based on
#         the source files they contain.
#
##

clear

echo
echo " +--------------------------------------------------------------------+"
echo " |  ________   _________ _____            _____ _______ ____  _____   |"
echo " | |  ____\ \ / /__   __|  __ \     /\   / ____|__   __/ __ \|  __ \  |"
echo " | | |__   \ V /   | |  | |__) |   /  \ | |       | | | |  | | |__) | |"
echo " | |  __|   > <    | |  |  _  /   / /\ \| |       | | | |  | |  _  /  |"
echo " | | |____ / . \   | |  | | \ \  / ____ \ |____   | | | |__| | | \ \  |"
echo " | |______/_/ \_\  |_|  |_|  \_\/_/    \_\_____|  |_|  \____/|_|  \_\ |"
echo " |   __              _____  _____     ___  _  _    ___                |"
echo " |  / _|            / ____|/ ____|   |__ \| || |  / _ \               |"
echo " | | |_ ___  _ __  | |    | (___ ______ ) | || |_| | | |              |"
echo " | |  _/ _ \| '__| | |     \___ \______/ /|__   _| | | |              |"
echo " | | || (_) | |    | |____ ____) |    / /_   | | | |_| |              |"
echo " | |_| \___/|_|     \_____|_____/    |____|  |_|  \___/               |"
echo " |                                                                    |"
echo " +--------------------------------------------------------------------+"
echo


##
# Prints usage/help message and terminates script
##
usage() {
    echo
    echo "Usage:"
    echo "      extractorA.sh -i <input-dir> -o <output-dir> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -o   Directory to hold output"
    echo "      -h   Show usage"
    echo

    exit 1
}


##
# Includes the script for the restructure function
##
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"/restructure.sh

##
# Searches each directory for files with specific extensions (.c, .java, etc)
# and classifies it based on the files it contains.
#
# If directory contains .c files, it goes to a C/ directory
# If directory contains .java files, it goes to a Java/ directory
# ...
#
# Then, proceeds to call restructure to re-structure the classified
# directory.
#
# @param $1 The programming language
# @param $2 The input directory
# @param $3 The output directory
##
classify() {
    cd "$2"
    for dir in ./*/
    do
        local dir=${dir%*/}
        cd "$dir"

        local files=(`find . -regex "${sources[$1]}"`)
        if [ ${#files[@]} -gt 0 ]
        then
            cd ".."
            mv "$dir" "$3/$1"
	    ((classified++))
            continue
        fi

        cd ".."
    done

    restructure "$1" "$3"
}

# Parse command-line arguments
while getopts ":i:o:h" opt
do
    case $opt in
        i) 
            if [ ! -d "$OPTARG" ]; then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            cd "$OPTARG"; inputdir="`pwd`"; cd - &> /dev/null;; 
        o) 
            if [ ! -d "$OPTARG" ]; then
                mkdir "$OPTARG"
            fi
            cd "$OPTARG"; outputdir="`pwd`"; cd - &> /dev/null;;
       \?)
            echo "ERROR: Invalid option: -$OPTARG" >&2; usage;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument." >&2; usage;;
        h | *)
            usage;;
    esac
done

# Check if input/output options were specified
if [ -z "$inputdir" ]; then
    echo "ERROR: Missing input directory" >&2
    usage
fi

if [ -z "$outputdir" ]; then
    echo "ERROR: Missing output directory" >&2
    usage
fi

declare -A sources=(["C"]=".*\.c\|.*\.C" ["C++"]=".*\.cpp\|.*\.cc" ["Java"]=".*\.java")
declare -A headers=(["C"]=".*\.h\|.*\.H" ["C++"]=".*\.hpp\|.*\.hh\|.*\.h" ["Java"]=".*\.java")

echo -n "Extracting .... "

# Extract all .tgz files inside input directory
cd "$inputdir"
for file in *.tgz
do
    exdir="${file%%.*}"
    mkdir "$exdir" 2> /dev/null
    tar xzf "$file" -C "$exdir"
done

echo "DONE!"

find "$inputdir" -name "* *" -type d | rename 's/ /_/g'

echo -n "Classifying ... "

# Create directories for classified output
mkdir "$outputdir/C"
mkdir "$outputdir/C++"
mkdir "$outputdir/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$outputdir"
classify "C++"  "$inputdir" "$outputdir"
classify "Java" "$inputdir" "$outputdir"

echo "DONE!"
echo
echo " Classified: $classified"
echo " Total:      $(ls -l $inputdir | grep .tgz | wc -l)"
echo
echo "Output saved in: $outputdir"
echo
