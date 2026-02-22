#!/bin/bash

BASE_URL="https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/diffuse"
BASE_DIR="/data/fermi/"
OUTPUT_DIR=${BASE_DIR}"diffuse"
STATE_FILE=${BASE_DIR}"last_diffuse_week.txt"
NEW_LIST_FILE=${BASE_DIR}"new_diffuse.txt"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR" || exit 1

# Read last processed week
if [[ -f "$STATE_FILE" ]]; then
    LAST_WEEK=$(cat "$STATE_FILE")
else
    LAST_WEEK=0
fi

echo "Last processed week: $LAST_WEEK"

# Get remote file list
REMOTE_LIST=$(wget -q -O - "$BASE_URL/" \
    | grep -o 'rcdiff_lat_photon_weekly_w[0-9]\+_p305_v001.fits')

NEW_FILES=()
MAX_WEEK=$LAST_WEEK

for FILE in $REMOTE_LIST; do
    WEEK=$(echo "$FILE" | sed -E 's/.*_w([0-9]+)_p305_v001.fits/\1/')

    if (( WEEK > LAST_WEEK )); then
        echo "Downloading $FILE"
        wget -q -c "$BASE_URL/$FILE"

        NEW_FILES+=("$OUTPUT_DIR/$FILE")

        if (( WEEK > MAX_WEEK )); then
            MAX_WEEK=$WEEK
        fi
    fi
done

# Write machine-readable list of new files
printf "%s\n" "${NEW_FILES[@]}" >> "$NEW_LIST_FILE"

# Update state file only if new files were downloaded
if (( MAX_WEEK > LAST_WEEK )); then
    echo "$MAX_WEEK" > "$STATE_FILE"
    echo "Updated last processed week to $MAX_WEEK"
fi

echo "New diffuse file list written to $NEW_LIST_FILE"