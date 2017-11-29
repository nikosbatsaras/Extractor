#!/bin/bash

usage() {
    echo
    echo "Usage:"
    echo "      ./check.sh -d <directory> -q <query> [-h]"
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
            if [ ! -d "$OPTARG" ]
            then
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

# Check if query option was specified
if [ -z $directory ]
then
    echo "ERROR: Directory not specified" >&2
    usage
fi

if [ -z $query ]
then
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
