#!/bin/bash

usage() {
    echo ""
    echo "Usage:"
    echo "      ./extractor.sh -h"
    echo "      ./extractor.sh -i <input-dir> -o <output-dir>"
    echo ""
    echo "Options:"
    echo "      -i   Directory with compressed projects"
    echo "      -o   Directory to hold output"
    echo "      -h   Show usage"
    echo ""

    exit 1
}

find_deep_sources() {
    cd "$2/$1"
    local initial="$pwd"

    local src="${sources[$1]}"
    local hdr="${headers[$1]}"

    # Find full path of first level directories
    local dirs=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)

    for project in "${dirs[@]}"
    do
        local i=1
        cd "$project"
        while [ $i -le $max_depth ]
        do
            local myarray=(`find $PWD -maxdepth $i -mindepth $i -type d`)
            for path in "${myarray[@]}"
            do
                # Need to check if files exist inside
                local count=`ls -1 "$path"/*"$src" "$path"/*"$hdr" \
                    2>/dev/null | wc -l`
                if [ $count != 0 ]
                then 
                    cp -r "$path"/* "$project"
                fi 
            done
            let i++
        done

        # Delete unwanted directories
        local myarray=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
        for emptydir in "${myarray[@]}"
        do
            rm -r "$emptydir"
        done

        cd $initial
    done
}

classify_projects() {
    cd "$2"
    for dir in ./*/
    do
        local dir=${dir%*/}
        cd "$dir"

        local myarray=(`find ./ -maxdepth $max_depth -name "${any_src[$1]}"`)
        if [ ${#myarray[@]} -gt 0 ]
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
        h|*)
            usage;;
    esac
done

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

declare -A any_src=(["C"]="*.c" ["C++"]="*.cpp" ["Java"]="*.java")
declare -A sources=(["C"]=".c"  ["C++"]=".cpp"  ["Java"]=".java" )
declare -A headers=(["C"]=".h"  ["C++"]=".h"    ["Java"]=".java" )

cd "$inputdir"
for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xzf "$file" -C "$exdir" --strip-components=1
done

mkdir "$outputdir/C"
mkdir "$outputdir/C++"
mkdir "$outputdir/Java"

max_depth=10

classify_projects "C"    "$inputdir" "$outputdir"
classify_projects "C++"  "$inputdir" "$outputdir"
classify_projects "Java" "$inputdir" "$outputdir"
