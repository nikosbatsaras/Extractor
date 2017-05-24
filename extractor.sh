#!/bin/bash

if [ "$#" -ne 2 ]
then
    echo ""
    echo "Error: Wrong number of arguments"
    echo ""
    echo "Usage: ./extractor.sh <input> <output>"
    echo ""
    echo "        <input>: Path to folder with .tgz files"
    echo "       <output>: Path to folder of the classified output"
    echo ""
    exit
fi

cd "$1"
output="$2"
max_depth=5

mkdir "$output/C"
mkdir "$output/Java"
mkdir "$output/C++"

for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xvzf "$file" -C "$exdir" --strip-components=1
done

for dir in ./*/
do
    dir=${dir%*/}
    cd "$dir"

    myarray=(`find ./ -maxdepth $max_depth -name "*.c"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/C"
        continue
    fi

    myarray=(`find ./ -maxdepth $max_depth -name "*.java"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/Java"
        continue
    fi

    myarray=(`find ./ -maxdepth $max_depth -name "*.cpp"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/C++"
        continue
    fi

    cd ".."
done

printf "\n\nListing directories in deeper levels:\n"

i=3
while [ $i -le $max_depth ]
do    
    printf "\n\nListing directories of depth $i:\n\n"
    find "$output" -maxdepth $i -mindepth $i -type d
    i=$[$i+1]
done

printf "\n... done.\n\n"
