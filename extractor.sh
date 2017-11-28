#!/bin/bash

##
# Extractor
#
# @author Nick Batsaras <nickbatsaras@gmail.com>
#
# A bash script to extract a bunch of .tgz files and classify them based on the
# source files they contain.
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
    echo "      ./extractor.sh -i <input-dir> -o <output-dir> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -o   Directory to hold output"
    echo "      -h   Show usage"
    echo

    exit 1
}

##
# Finds all source/header files and copies the folder containing them at the
# right depth, deleting any unwanted directories.
#
# @param $1 The programming language
# @param $2 The output directory
##
restructure() {
    cd "$2/$1"
    local origin="$pwd"

    local src="${sources[$1]}"
    local hdr="${headers[$1]}"

    # Find full path of first level directories
    local projects=(`find "$PWD" -maxdepth 1 -mindepth 1 -type d`)

    for project in "${projects[@]}"
    do
        cd "$project"

        local directories=(`find "$PWD"/* -type d`)
        for dir in "${directories[@]}"
        do
            # Need to check if files exist inside
            local num=`ls -1 "$dir"/$src "$dir"/$hdr 2>/dev/null | wc -l`
            if [ $num != 0 ]
            then 
                cp -r "$dir"/* "$project"
            fi 
        done

        # Delete unwanted directories
        local unwanted_dirs=()
        while IFS=  read -r -d $'\0'
        do
            unwanted_dirs+=("$REPLY")
        done < <(find "$PWD" -maxdepth 1 -mindepth 1 -type d -print0)

        for dir in "${unwanted_dirs[@]}"
        do
            rm -r "$dir"
        done

        cd "$origin"
    done
}

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

        local files=(`find . -name "${sources[$1]}"`)
        if [ ${#files[@]} -gt 0 ]
        then
            cd ".."
            mv "$dir" "$3/$1"
            continue
        fi

        cd ".."
    done

    restructure "$1" "$3"
}

inputdir=""
outputdir=""

# Parse command-line arguments
while getopts ":i:o:h" opt
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
        o) 
            if [ ! -d "$OPTARG" ]
            then
                echo "ERROR: Directory $OPTARG does not exist" >&2
                exit 1
            fi
            curr_dir="`pwd`"; cd "$OPTARG"
            outputdir="`pwd`"; cd "$curr_dir"
            ;;
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

if [ "$outputdir" = "" ]
then
    echo "ERROR: Missing output directory" >&2
    check=1
fi

if [ ! -z $check ]; then usage; fi

declare -A sources=(["C"]="*.c" ["C++"]="*.c[(c)|(pp)|(xx)]" ["Java"]="*.java")
declare -A headers=(["C"]="*.h" ["C++"]="*.h(h)?"            ["Java"]="*.java")

# Extract all .tgz files inside input directory
cd "$inputdir"
for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xzf "$file" -C "$exdir"
done

# Create directories for classified output
mkdir "$outputdir/C"
mkdir "$outputdir/C++"
mkdir "$outputdir/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$outputdir"
classify "C++"  "$inputdir" "$outputdir"
classify "Java" "$inputdir" "$outputdir"
