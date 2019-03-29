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
# @file   check.sh
#
# @author Nikos Batsaras <nickbatsaras@gmail.com>
#
# @desc   This script is used to check the quality of a query.
#         A query is used to distinguish between phase 1 and phase 2 of a
#         project. The query is supposed to be a keyword that exists in every
#         project (folder) of phase 1 BUT not in any project of phase 2.
#         An example could be a data structure used only in phase 1, etc
#
#         The reasoning behind the query, is to avoid setting a strict rule to
#         how the students submit the projects. They never do it as told!
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
    echo "      check.sh -d <directory> -q <query> [-h]"
    echo
    echo "Options:"
    echo "      -d   Directory to check"
    echo "      -q   Query to check"
    echo "      -h   Show usage"
    echo

    exit 1
}

# Parse command-line arguments
while getopts ":d:q:h" opt
do
    case $opt in
        d) 
            if [ ! -d "$OPTARG" ]; then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            directory="$OPTARG";;
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

# Check if input options were specified
if [ -z $directory ]; then
    echo "ERROR: Directory not specified" >&2
    usage
fi

if [ -z $query ]; then
    echo "ERROR: Query not specified" >&2
    usage
fi


total=($(find "$directory" -maxdepth 2 -mindepth 2 -type d | wc -l))
found=$(grep -r "$query" "$directory" | awk '{print $1}' | cut -f1 -d:)

if [ "${found[@]}" == "" ]
then
    found="0"
else
    found=$(dirname $found)
    found=($(echo "${found[@]}" |  tr ' ' '\n' | sort | uniq | wc -l))
fi

echo
echo "###########################################"
echo "For query: $query, in directory: $directory"
echo
echo "  Found: $found matching directories"
echo "  Total: $total directories"
echo "###########################################"
echo
