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
# @file   extractorB.sh
#
# @author Nikos Batsaras <nickbatsaras@gmail.com>
#
# @desc   A script to extract a group of .tgz files and classify them based on
#         the source files they contain.
#         Update/replace phase1 files in case of resubmission.
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
    echo "      extractorB.sh -i <input-dir> -a <phase1-output> -b <phase2-output> -q <query> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -a   Directory holding the output of phase 1"
    echo "      -b   Directory to hold the output of phase 2"
    echo "      -q   Query for phase 1"
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

        local files=(`find . -regex "${sources[$1]}"`)
        if [ ${#files[@]} -gt 0 ]
        then

            for dir2 in `ls`
            do
                if [ ! -d "$dir2" ]
                then
                    res=(`grep "$5" "$dir2" &> /dev/null`)
                    if [ ${#res[@]} -gt 0 ]
                    then
			if [ -d "$4"/"$1"/"`basename $dir`" ]; then
				((resubs++))
			else
				mkdir -p "$4"/"$1"/"`basename $dir`"
			fi
                        # Maybe mv ?!
                        cp "$dir2" "$4"/"$1"/"`basename $dir`"
                        rm "$dir2"
			((updated++))
                    fi
                    continue
                fi

                cd "$dir2"

                res=(`grep -r "$5" "$PWD" | awk '{print $1}' | cut -f1 -d":" | uniq`)
                if [ ${#res[@]} -gt 0 ]
                then
                    cd ".."

		    if [ -d "$4"/"$1"/"`basename $dir`" ]; then
			    ((resubs++))
			    rm -rf "$4"/"$1"/"`basename $dir`"/*
		    else
			    mkdir -p "$4"/"$1"/"`basename $dir`"
		    fi

                    for fl in "${res[@]}"
                    do
                        cp -r "`dirname $fl`" "$4"/"$1"/"`basename $dir`"/
                        rm -rf "`dirname $fl`"
                    done

		    ((updated++))
                    continue
                fi
                cd ".."
            done

            cd ".."
            mv "$dir" "$3/$1"
	    ((classified++))
            continue
        fi

        cd ".."
    done

    restructure "$1" "$3"
    restructure "$1" "$4"
}
 
# Parse command-line arguments
while getopts ":i:a:b:q:h" opt
do
    case $opt in
        i) 
            if [ ! -d "$OPTARG" ]; then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            cd "$OPTARG"; inputdir="`pwd`"; cd - &> /dev/null;; 
        a) 
            if [ ! -d "$OPTARG" ]; then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            cd "$OPTARG"; phase1="`pwd`"; cd - &> /dev/null;;
        b) 
            if [ ! -d "$OPTARG" ]; then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            cd "$OPTARG"; phase2="`pwd`"; cd - &> /dev/null;;
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
if [ -z "$inputdir" ]; then
    echo "ERROR: Missing input directory" >&2
    usage
fi

if [ -z "$phase1" ]; then
    echo "ERROR: Missing output directory of phase 1" >&2
    usage
fi

if [ -z "$phase2" ]; then
    echo "ERROR: Missing output directory of phase 2" >&2
    usage
fi

if [ -z "$query" ]; then
    echo "ERROR: Missing query" >&2
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
mkdir "$phase2/C"
mkdir "$phase2/C++"
mkdir "$phase2/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$phase2" "$phase1" "$query"
classify "C++"  "$inputdir" "$phase2" "$phase1" "$query"
classify "Java" "$inputdir" "$phase2" "$phase1" "$query"

echo "DONE!"
echo
echo " Resubs:     $resubs"
echo " Updated:    $updated"
echo " Classified: $classified"
echo " Total:      $(ls -l $inputdir | grep .tgz | wc -l)"
echo
echo "Output saved in: $phase1 and $phase2"
echo
