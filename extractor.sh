#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo ""
    echo "Error: Wrong number of arguments"
    echo ""
    echo "Usage: extractor.sh <input> <output>"
    echo "        <input>: Full path to folder with .tgz files"
    echo "       <output>: Full path to folder of the classified output"
    echo ""
    exit
fi

find_deep_sources() {
    cd "$2/$1"
    initial="$pwd"

    src="${sources[$1]}"
    hdr="${headers[$1]}"

    # Find full path of first level directories
    dirs=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)

    for project in "${dirs[@]}"
    do
        i=1
        cd "$project"
        while [ $i -le $max_depth ]
        do
            myarray=(`find $PWD -maxdepth $i -mindepth $i -type d`)
            for path in "${myarray[@]}"
            do
                # Need to check if files exist inside
                count=`ls -1 "$path"/*"$src" "$path"/*"$hdr" \
                    2>/dev/null | wc -l`
                if [ $count != 0 ]
                then 
                    cp -r "$path"/* "$project"
                fi 
            done
            let i++
        done

        # Delete empty directories
        myarray=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
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
        dir=${dir%*/}
        cd "$dir"

        myarray=(`find ./ -maxdepth $max_depth -name "${any_src[$1]}"`)
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

inputdir="$1"
outputdir="$2"

declare -A any_src=(["C"]="*.c" ["C++"]="*.cpp" ["Java"]="*.java")
declare -A sources=(["C"]=".c"  ["C++"]=".cpp"  ["Java"]=".java")
declare -A headers=(["C"]=".h"  ["C++"]=".h"    ["Java"]=".java")

cd "$inputdir"
for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xvzf "$file" -C "$exdir" --strip-components=1
done

mkdir "$outputdir/C"
mkdir "$outputdir/C++"
mkdir "$outputdir/Java"

max_depth=10

classify_projects "C" "$inputdir" "$outputdir"
classify_projects "C++" "$inputdir" "$outputdir"
classify_projects "Java" "$inputdir" "$outputdir"

printf "\n... done.\n\n"
