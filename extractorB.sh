#!/bin/bash

##
#
# Extractor
# =========
#
# 
# This script is part of a collection of scripts used mainly for the purposes
# of CS-240 (Data Structures) at University of Crete, Computer Science Department.
#
# The main goal is to automate the process of:
#   1) Extracting all the student submitted projects
#   2) Classify them based on what programming language was used
#   3) Re-structure the extracted and classified projects path
#   4) In case a student re-submits the 1rst phase of the project
#      at phase 2, take into account the latter submission for phase 1
#
#
# @file   extractorB.sh
#
# @author Nick Batsaras <nickbatsaras@gmail.com>
#
# @desc   A script to extract a group of .tgz files and classify them based on
#         the source files they contain. This script can also replace an old
#         version of a project with the new version found the the current
#         directory. To achive that, it uses a user-provided query, that
#         distinguishes phase A and phase B of the project.
#
# TODOs:
#    1. Add support for more extensions
#
##


##
# Prints usage/help message and terminates script
##
usage() {
    echo
    echo "Usage:"
    echo "      ./extractorB.sh -i <input-dir> -c <output-current> -p <output-previous> -q <query> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -c   Directory to hold output of current-phase"
    echo "      -p   Directory to hold output of previous-phase"
    echo "      -q   Query for phase 1"
    echo "      -h   Show usage"
    echo

    exit 1
}


##
# Includes the script for the restructure function
##
source "./restructure.sh"


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
# @param $3 The current phase directory
# @param $4 The previous phase directory
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

                res=(`grep -r "$5"`)
                if [ ${#res[@]} -gt 0 ]
                then
                    local tocopy="`pwd`"
                    cd ".."
                    if [ ! -d "$4"/"$1"/"`basename $dir`" ]
                    then
                        mkdir "$4"/"$1"/"`basename $dir`"
                    fi
                    rm -rf "$4"/"$1"/"`basename $dir`"/*
                    cp -r "$tocopy"/* "$4"/"$1"/"`basename $dir`"
                    rm -rf "$tocopy"
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
currPhase=""
prevPhase=""

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
        c) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            currPhase="`pwd`"; cd "$curr_dir"
            ;;
        p) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            prevPhase="`pwd`"; cd "$curr_dir"
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

if [ "$currPhase" = "" ]
then
    echo "ERROR: Missing output directory of current phase" >&2
    check=1
fi

if [ "$prevPhase" = "" ]
then
    echo "ERROR: Missing output directory of previous phase" >&2
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
mkdir "$currPhase/C"
mkdir "$currPhase/C++"
mkdir "$currPhase/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$currPhase" "$prevPhase" "$query"
classify "C++"  "$inputdir" "$currPhase" "$prevPhase" "$query"
classify "Java" "$inputdir" "$currPhase" "$prevPhase" "$query"
