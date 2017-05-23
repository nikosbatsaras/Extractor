cd "$1"
for file in *.tgz; do
    exdir="${file%.tgz}"
    mkdir "$exdir"
    tar xvzf "$file" -C "$exdir" --strip-components=1
done
