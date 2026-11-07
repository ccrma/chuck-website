#!/usr/bin/env bash

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
dir_path="$script_dir/../../chugl/examples"
template="$script_dir/webchugl-example-template.html"
site_root="$(cd "$script_dir/../.." && pwd)"

find_assets() {
    local file="$1" subdir="$2" page_to_examples="$3"
    local ref target match sep="" json="["

    while IFS= read -r ref; do
        [ -z "$ref" ] && continue

        target=$(python3 -c 'import os, sys; print(os.path.relpath(os.path.join(sys.argv[1], sys.argv[2], sys.argv[3]), sys.argv[1]))' "$dir_path" "$subdir" "$ref")

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

    page_to_examples=$(python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$dir_path" "$out_dir")
    css_path=$(python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$site_root/css" "$out_dir")

    export CSS_PATH="$css_path"
    export FILENAME="./$filename"
    export TITLE="${filename%.*}"
    export VFS_PATH="/$rel"
    export ASSETS=$(find_assets "$file" "$subdir" "$page_to_examples")

    envsubst '${FILENAME} ${TITLE} ${VFS_PATH} ${ASSETS} ${CSS_PATH}' \
        < "$template" > "$out_dir/${filename%.*}.html"

    echo "HTML page generated successfully at $out_dir/${filename%.*}.html"
done < <(find "$dir_path" -type f -name '*.ck' | sort)