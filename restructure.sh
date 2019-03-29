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
# @file   restructure.sh
#
# @author Nikos Batsaras <nickbatsaras@gmail.com>
#
# @desc   A script to re-structure the extracted and classified output.
#         This script is used internally. You are not supposed to execute it
#         manually.
#
##


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

        local directories=(`find "$PWD"/* -type d 2> /dev/null`) # ATTENTION!
        for dir in "${directories[@]}"
        do
            # Need to check if files exist inside
            local num=`ls "$dir" 2>/dev/null | grep "$src" 2>/dev/null | wc -l`
	    ((num=num+`ls "$dir" 2>/dev/null | grep "$hdr" 2>/dev/null | wc -l`))
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
