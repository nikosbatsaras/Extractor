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

    myarray=(`find ./ -maxdepth 5 -name "*.c"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/C"
        continue
    fi

    myarray=(`find ./ -maxdepth 5 -name "*.java"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/Java"
        continue
    fi

    myarray=(`find ./ -maxdepth 5 -name "*.cpp"`)
    if [ ${#myarray[@]} -gt 0 ]
    then
        cd ".."
        mv "$dir" "$output/C++"
        continue
    fi

    cd ".."
done

echo ""
echo ""
echo ""
echo "Checking for deep directories ..."
echo ""
echo ""
echo "Listing directories of depth 3:"
echo ""
find "$output" -maxdepth 3 -mindepth 3 -type d
echo ""
echo ""
echo "Listing directories of depth 4:"
echo ""
find "$output" -maxdepth 4 -mindepth 4 -type d
echo ""
echo ""
echo "Listing directories of depth 5:"
echo ""
find "$output" -maxdepth 5 -mindepth 5 -type d
echo ""
echo "Done."
