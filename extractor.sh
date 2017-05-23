cd "$1"

for file in *.tgz
do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xvzf "$file" -C "$exdir" --strip-components=1
done

mkdir "C"
mkdir "Java"
mkdir "C++"

for dir in ./*/
do
    dir=${dir%*/}
    cd "$dir"

    myarray=(`find ./ -maxdepth 3 -name "*.c"`)
    if [ ${#myarray[@]} -gt 0 ]
    then 
        cd ".."
        mv "$dir" ./C/
        continue
    fi

    myarray=(`find ./ -maxdepth 3 -name "*.java"`)
    if [ ${#myarray[@]} -gt 0 ]
    then 
        cd ".."
        mv "$dir" ./Java/
        continue
    fi

    myarray=(`find ./ -maxdepth 3 -name "*.cpp"`)
    if [ ${#myarray[@]} -gt 0 ]
    then 
        cd ".."
        mv "$dir" ./C++/
        continue
    fi

    cd ".."
done
