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
    echo ""
    echo "Usage:"
    echo "      ./extractor.sh [-h] [-d max_depth] -i <input-dir> -o <output-dir>"
    echo ""
    echo "Options:"
    echo "      -h   Show usage"
    echo "      -d   Maximum depth to use with 'find' function (defaults to 10)"
    echo "      -i   Directory with compressed projects"
    echo "      -o   Directory to hold output"
    echo ""

    exit 1
}

##
# Finds all source/header files until max_depth and copies the folder
# containing them at the right depth, deleting any unwanted directories.
#
# @param $1 The programming language
# @param $2 The output directory
##
find_deep_sources() {
    cd "$2/$1"
    local origin="$pwd"

    local src="${sources[$1]}"
    local hdr="${headers[$1]}"

    # Find full path of first level directories
    local projects=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)

    for project in "${projects[@]}"
    do
        local i=1
        cd "$project"
        while [ $i -le $max_depth ]
        do
            local directories=(`find $PWD -maxdepth $i -mindepth $i -type d`)
            for dir in "${directories[@]}"
            do
                # Need to check if files exist inside
                local count=`ls -1 "$dir"/*"$src" "$dir"/*"$hdr" \
                    2>/dev/null | wc -l`
                if [ $count != 0 ]
                then 
                    cp -r "$dir"/* "$project"
                fi 
            done
            ((i++))
        done

        # Delete unwanted directories
        local unwanted_dirs=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
        for dir in "${unwanted_dirs[@]}"
        do
            rm -r "$dir"
        done

        cd $origin
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
# Then, proceeds to call find_deep_sources to re-structure the classified
# directory.
#
# @param $1 The programming language
# @param $2 The input directory
# @param $3 The output directory
##
classify_projects() {
    cd "$2"
    for dir in ./*/
    do
        local dir=${dir%*/}
        cd "$dir"

        local files=(`find ./ -maxdepth $max_depth -name "${any_src[$1]}"`)
        if [ ${#files[@]} -gt 0 ]
        then
            cd ".."
            mv "$dir" "$3/$1"
            continue
        fi

        cd ".."
    done

    find_deep_sources "$1" "$3"
}

inputdir=""
outputdir=""

# Parse command-line arguments
while getopts ":d:i:o:h" opt
do
    case $opt in
        d) 
            if [ ! $OPTARG -gt 0 ]
            then
                echo "ERROR: Option -$opt must take a positive argument" >&2
                exit 1
            fi
            max_depth=$OPTARG
            ;; 
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

##
# Define maximum depth for use with 'find' function
# Tune for more simple or complicated directory structures
# If user did not specify a value for max_depth, give a default value of 10
##
if [ -z $max_depth ]; then max_depth=10; fi

declare -A any_src=(["C"]="*.c" ["C++"]="*.cpp" ["Java"]="*.java")
declare -A sources=(["C"]=".c"  ["C++"]=".cpp"  ["Java"]=".java" )
declare -A headers=(["C"]=".h"  ["C++"]=".h"    ["Java"]=".java" )

# Extract all .tgz files inside input directory
cd "$inputdir"
for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xzf "$file" -C "$exdir" --strip-components=1
done

# Create directories for classified output
mkdir "$outputdir/C"
mkdir "$outputdir/C++"
mkdir "$outputdir/Java"

# Classify extracted directories
classify_projects "C"    "$inputdir" "$outputdir"
classify_projects "C++"  "$inputdir" "$outputdir"
classify_projects "Java" "$inputdir" "$outputdir"
