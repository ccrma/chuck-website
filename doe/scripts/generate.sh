#!/usr/bin/env bash

dir_path="./examples"

find_assets() {
    local file="$1" subdir="$2" page_to_examples="$3"
    local ref target match sep="" json="["

    while IFS= read -r ref; do
        [ -z "$ref" ] && continue
        target=$(realpath -m --relative-to="$dir_path" "$dir_path/$subdir/$ref")

        if [ -f "$dir_path/$target" ]; then
            json+="$sep{\"url\":\"$page_to_examples/$target\",\"path\":\"/$target\"}"; sep=","
        elif matches=$(find "$dir_path" -type f -path "$dir_path/$target*" | sort) && [ -n "$matches" ]; then
            while IFS= read -r match; do
                match=${match#"$dir_path/"}
                json+="$sep{\"url\":\"$page_to_examples/$match\",\"path\":\"/$match\"}"; sep=","
            done <<< "$matches"
        elif match=$(find "$dir_path" -type f -name "$(basename "$ref")" | sort | head -n 1) && [ -n "$match" ]; then
            match=${match#"$dir_path/"}
            json+="$sep{\"url\":\"$page_to_examples/$match\",\"path\":\"/$target\"}"; sep=","
        else
            echo "  warning: $subdir/$(basename "$file") references missing file: $ref" >&2
        fi
    done < <(grep -vE '^\s*//' "$file" | grep -oE 'me\.dir\(\) *\+ *"[^"]*"' | sed -E 's/.*"([^"]*)"$/\1/' | sort -u)

    echo "$json]"
}

while IFS= read -r file; do
    rel=${file#"$dir_path/"}
    subdir=$(dirname "$rel")
    filename=$(basename "$rel")

    out_dir="$dir_path/$subdir"
    page_to_examples=$(realpath -m --relative-to="$out_dir" "$dir_path")

    export FILENAME="$page_to_examples/$rel"
    export TITLE="${filename%.*}"
    export VFS_PATH="/$rel"
    export ASSETS=$(find_assets "$file" "$subdir" "$page_to_examples")

    envsubst '${FILENAME} ${TITLE} ${VFS_PATH} ${ASSETS}' < template.html > "$out_dir/${filename%.*}.html"
    echo "HTML page generated successfully at $out_dir/${filename%.*}.html"
done < <(find "$dir_path" -type f -name '*.ck' | sort)
