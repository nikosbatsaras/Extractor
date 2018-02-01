#!/bin/bash

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
#   4) In case a student re-submits the 1rst phase of the project
#      at phase 2, take into account the latter submission for phase 1
#
#
# @file   extractorB.sh
#
# @author Nick Batsaras <nickbatsaras@gmail.com>
#
# @desc   A script to extract a group of .tgz files and classify them based on
#         the source files they contain.
#         Update/replace phase1 files in case of resubmission.
#
# TODOs:
#    1. Add support for more extensions
#    2. Add support for regular expressions
#
##


##
# Prints usage/help message and terminates script
##
usage() {
    echo
    echo "Usage:"
    echo "      ./extractorB.sh -i <input-dir> -a <phase1-output> -b <phase2-output> -q <query> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -a   Directory to hold output of phase 1"
    echo "      -b   Directory to hold output of phase 2"
    echo "      -q   Query for phase 1"
    echo "      -h   Show usage"
    echo

    exit 1
}


##
# Includes the script for the restructure function
##
source ~/Extractor/restructure.sh


##
# Searches each directory for files with specific extensions (.c, .java, etc)
# and classifies it based on the files it contains.
# In case a re-submission is detected (using the provided query), it updates
# the files of the phase-A submission with the new ones.
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
# @param $3 The phase 2 directory
# @param $4 The phase 1 directory
# @param $5 The query
##
classify() {
    cd "$2"
    for dir in ./*/
    do
        local dir=${dir%*/}
        cd "$dir"

        local files=(`find . -name "${sources[$1]}"`)
        if [ ${#files[@]} -gt 0 ]
        then

            for dir2 in `ls`
            do
                if [ ! -d "$dir2" ]
                then
                    res=(`grep "$5" "$dir2"`)
                    if [ ${#res[@]} -gt 0 ]
                    then
                        # Maybe mv ?!
                        cp "$dir2" "$4"/"$1"/"`basename $dir`"
                        rm "$dir2"
                    fi
                    continue
                fi

                cd "$dir2"

                res=(`grep -r "$5" "$PWD" | awk '{print $1}' | tr -d :`)
                if [ ${#res[@]} -gt 0 ]
                then
                    cd ".."
                    if [ ! -d "$4"/"$1"/"`basename $dir`" ]
                    then
                        mkdir "$4"/"$1"/"`basename $dir`"
                    fi
                    rm -rf "$4"/"$1"/"`basename $dir`"/*

                    for fl in "${res[@]}"
                    do
                        cp -r "`dirname $fl`" "$4"/"$1"/"`basename $dir`"/ 2> /dev/null
                        rm -rf "`dirname $fl`"
                    done

                    continue
                fi
                cd ".."
            done

            cd ".."
            mv "$dir" "$3/$1"
            continue
        fi

        cd ".."
    done

    restructure "$1" "$3"
    restructure "$1" "$4"
}
 
query=""
inputdir=""
phase1=""
phase2=""

# Parse command-line arguments
while getopts ":i:c:p:q:h" opt
do
    case $opt in
        i) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            inputdir="`pwd`"; cd "$curr_dir"
            ;; 
        a) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            phase1="`pwd`"; cd "$curr_dir"
            ;;
        b) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            phase2="`pwd`"; cd "$curr_dir"
            ;;
        q) 
            query="$OPTARG";;
       \?)
            echo "ERROR: Invalid option: -$OPTARG" >&2; usage;;
        :)
            echo "ERROR: Option -$OPTARG requires an argument." >&2; usage;;
        h | *)
            usage;;
    esac
done

# Check if input/output options were specified
if [ "$inputdir" = "" ]
then
    echo "ERROR: Missing input directory" >&2
    check=1
fi

if [ "$phase1" = "" ]
then
    echo "ERROR: Missing output directory of phase 1" >&2
    check=1
fi

if [ "$phase2" = "" ]
then
    echo "ERROR: Missing output directory of phase 2" >&2
    check=1
fi

if [ "$query" = "" ]
then
    echo "ERROR: Missing query" >&2
    check=1
fi

if [ ! -z $check ]; then usage; fi

declare -A sources=(["C"]="*.c" ["C++"]="*.cpp" ["Java"]="*.java")
declare -A headers=(["C"]="*.h" ["C++"]="*.h"   ["Java"]="*.java")

# Extract all .tgz files inside input directory
cd "$inputdir"
for file in *.tgz
do
    exdir="${file%%.*}"
    mkdir "$exdir" 2> /dev/null
    tar xzf "$file" -C "$exdir"
done

# Create directories for classified output
mkdir "$phase2/C"
mkdir "$phase2/C++"
mkdir "$phase2/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$phase2" "$phase1" "$query"
classify "C++"  "$inputdir" "$phase2" "$phase1" "$query"
classify "Java" "$inputdir" "$phase2" "$phase1" "$query"
