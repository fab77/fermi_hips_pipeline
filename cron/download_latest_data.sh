#!/bin/bash

set -euo pipefail

BASE_DIR="/data/fermi"

DIFFUSE_URL="https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/diffuse"
SC_URL="https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/spacecraft"

DIFFUSE_DIR="${BASE_DIR}/diffuse"
SC_DIR="${BASE_DIR}/spacecraft"

STATE_FILE="${BASE_DIR}/last_week.txt"

NEW_DIFF_FILE="${BASE_DIR}/new_diffuse.txt"
NEW_SC_FILE="${BASE_DIR}/new_spacecraft.txt"

mkdir -p "$DIFFUSE_DIR" "$SC_DIR"

# Read last fully processed contiguous week
if [[ -f "$STATE_FILE" ]]; then
    LAST_WEEK=$(cat "$STATE_FILE")
else
    LAST_WEEK=0
fi

echo "Last fully processed contiguous week: $LAST_WEEK"

# Clear previous lists
> "$NEW_DIFF_FILE"
> "$NEW_SC_FILE"

CURRENT_WEEK=$((LAST_WEEK + 1))


while true; do

    WEEK_PADDED=$(printf "%03d" "$CURRENT_WEEK")
    
    DIFF_FILE="rcdiff_lat_photon_weekly_w${WEEK_PADDED}_p305_v001.fits"
    SC_FILE="lat_spacecraft_weekly_w${WEEK_PADDED}_p310_v001.fits"

    DIFF_URL_FULL="${DIFFUSE_URL}/${DIFF_FILE}"
    SC_URL_FULL="${SC_URL}/${SC_FILE}"

    echo "Checking week $WEEK_PADDED... (Diffuse: $DIFF_URL_FULL, Spacecraft: $SC_URL_FULL)"

    # Check remote existence
    if wget --spider -q "$DIFF_URL_FULL" && wget --spider -q "$SC_URL_FULL"; then

        echo "Week $CURRENT_WEEK complete. Downloading if needed..."

        # Download diffuse if missing
        if [[ ! -f "${DIFFUSE_DIR}/${DIFF_FILE}" ]]; then
            wget -q -P "$DIFFUSE_DIR" "$DIFF_URL_FULL"
        fi

        # Download spacecraft if missing
        if [[ ! -f "${SC_DIR}/${SC_FILE}" ]]; then
            wget -q -P "$SC_DIR" "$SC_URL_FULL"
        fi

        # Append full paths in strict week order
        printf "%s\n" "${DIFF_FILE}" >> /fermihips/newdata/diffuse/"$NEW_DIFF_FILE"
        printf "%s\n" "${SC_FILE}" >> /fermihips/newdata/spacecraft/"$NEW_SC_FILE"

        CURRENT_WEEK=$((CURRENT_WEEK + 1))

    else
        echo "Week $CURRENT_WEEK incomplete remotely. Stopping."
        break
    fi

done

# Update state file
NEW_LAST_WEEK=$((CURRENT_WEEK - 1))

if (( NEW_LAST_WEEK > LAST_WEEK )); then
    echo "$NEW_LAST_WEEK" > "$STATE_FILE"
    echo "Updated last fully processed week to $NEW_LAST_WEEK"
else
    echo "No new contiguous weeks available."
fi

echo "New diffuse list: $NEW_DIFF_FILE"
echo "New spacecraft list: $NEW_SC_FILE"

docker run -v /Volumes/MyHD/FERMI/hips:/fermihips/hips \
-v /Volumes/MyHD/FERMI/working:/fermihips/working \
-v /Volumes/MyHD/FERMI/data/diffuse:/fermihips/newdata/diffuse \
-v /Volumes/MyHD/FERMI/data/spacecraft:/fermihips/newdata/spacecraft \
-v $NEW_DIFF_FILE:/fermihips/new_diffuse_list.txt \
-v $NEW_SC_FILE:/fermihips/new_spacecraft_list.txt \
fermihips sh /fermihips/run_fermihips.sh \
    -o 10 \
    -m 1000 \
    -M 3000 \
    -d /fermihips/new_diffuse_list.txt \ 
    -s /fermihips/new_spacecraft_list.txt

# docker run -v /Volumes/MyHD/FERMI/test/hips:/fermihips/hips -v /Volumes/MyHD/FERMI/test/working:/fermihips/working -v /Volumes/MyHD/FERMI/test/data/diffuse:/fermihips/newdata/diffuse -v /Volumes/MyHD/FERMI/test/data/spacecraft:/fermihips/newdata/spacecraft -v /Volumes/MyHD/FERMI/test/data/new_diffuse_list.txt:/fermihips/new_diffuse_list.txt -v /Volumes/MyHD/FERMI/test/data/new_spacecraft_list.txt:/fermihips/new_spacecraft_list.txt fermihips_v2 sh /fermihips/run_fermihips.sh     -o 10     -m 1000     -M 3000     -d /fermihips/new_diffuse_list.txt     -s /fermihips/new_spacecraft_list.txt