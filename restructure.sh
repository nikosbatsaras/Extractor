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
