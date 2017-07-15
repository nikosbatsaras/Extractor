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

cd "$1"
output="$2"
max_depth=10

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

cd "$output/C++"
initial="$pwd"

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
            count=`ls -1 "$path"/*.cpp "$path"/*.h 2>/dev/null | wc -l`
            if [ $count != 0 ]
            then 
                mv "$path"/* "$project"
                rm -r "$path"
            fi 
        done
        i=$[$i+1]
    done

    # Delete empty directories
    myarray=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
    for emptydir in "${myarray[@]}"
    do
        rm -r "$emptydir"
    done

    cd $initial
done

cd "$output/Java"
initial="$pwd"

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
            count=`ls -1 "$path"/*.java 2>/dev/null | wc -l`
            if [ $count != 0 ]
            then 
                mv "$path"/* "$project"
                rm -r "$path"
            fi 
        done
        i=$[$i+1]
    done

    # Delete empty directories
    myarray=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
    for emptydir in "${myarray[@]}"
    do
        rm -r "$emptydir"
    done

    cd $initial
done

cd "$output/C"
initial="$pwd"

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
            count=`ls -1 "$path"/*.c "$path"/*.h 2>/dev/null | wc -l`
            if [ $count != 0 ]
            then 
                mv "$path"/* "$project"
                rm -r "$path"
            fi 
        done
        i=$[$i+1]
    done

    # Delete empty directories
    myarray=(`find $PWD -maxdepth 1 -mindepth 1 -type d`)
    for emptydir in "${myarray[@]}"
    do
        rm -r "$emptydir"
    done

    cd $initial
done

printf "\n... done.\n\n"
