#!/bin/bash

for file in *; do
    if [ -f "$file" ] && [ "$file" != "MediaOrganizer.sh" ]; then
        dirname="${file%.*}"
        mkdir -p "$dirname" && mv "$file" "$dirname"
    fi
done
