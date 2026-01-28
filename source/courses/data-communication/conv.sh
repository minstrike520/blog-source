#!/bin/bash

QUALITY=80

for file in IMG_20251226_*.jpg; do
    [ -e "$file" ] || continue

    filename="${file%.*}"

    echo "Converting: $file -> $filename.webp"

    # -i: input file
    # -q:v: video quality (for images) 0-100
    ffmpeg -i "$file" -q:v "$QUALITY" "${filename}.webp"
done

echo "Batch conversion complete!"
