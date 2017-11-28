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
    echo "      ./extractor.sh -i <input-dir> -c <output-current> -p <output-previous> [-h]"
    echo
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -c   Directory to hold output of current-phase"
    echo "      -p   Directory to hold output of preivous-phase"
    echo "      -h   Show usage"
    echo

    exit 1
}


source "./restructure.sh"


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

            for dir2 in `ls`
            do
                # Check for ph-like project
                if [ ! -d "$dir2" ]
                then
                    continue
                fi

                # local dir2=${dir2%*/}
                cd "$dir2"

                res=(`grep -r "TEST"`) # Need to add a cli switch
                if [ ${#res[@]} -gt 0 ]
                then
                    local tocopy="`pwd`"
                    cd ".."
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

inputdir=""
currPhase=""
prevPhase=""

# Parse command-line arguments
while getopts ":i:c:p:h" opt
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

if [ ! -z $check ]; then usage; fi

declare -A sources=(["C"]="*.c" ["C++"]="*.c[(c)|(pp)|(xx)]" ["Java"]="*.java")
declare -A headers=(["C"]="*.h" ["C++"]="*.h(h)?"            ["Java"]="*.java")

# Extract all .tgz files inside input directory
cd "$inputdir"
for file in *.tgz
do
    exdir="${file%%-*}"
    mkdir "$exdir" 2> /dev/null
    tar xzf "$file" -C "$exdir"
done

# Create directories for classified output
mkdir "$currPhase/C"
mkdir "$currPhase/C++"
mkdir "$currPhase/Java"

# Classify extracted directories
classify "C"    "$inputdir" "$currPhase" "$prevPhase"
classify "C++"  "$inputdir" "$currPhase" "$prevPhase"
classify "Java" "$inputdir" "$currPhase" "$prevPhase"
