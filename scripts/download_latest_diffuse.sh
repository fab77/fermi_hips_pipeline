#!/bin/bash

week=$1
# Configuration
DIFFUSE_BASE_URL="https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/diffuse/"
SC_BASE_URL="https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/spacecraft/"
# LAST_WEEK_FILE="last_week.txt"

# # Read starting week number
# if [[ ! -f "$LAST_WEEK_FILE" ]]; then
#   echo "LAST_WEEK_FILE not found in ${LAST_WEEK_FILE}. Exit"
#   exit -1
# fi

# last_week=$(cat "$LAST_WEEK_FILE")


# week=$((last_week + 1))


# Download spacecraft
sc_filename="lat_spacecraft_weekly_w${week}_p310_v001.fits"
sc_url=${SC_BASE_URL}/${sc_filename}

echo "Trying to download week $week: $sc_url"
wget -q --show-progress -O /fermihips/newdata/${sc_filename} ${sc_url}
if [ $? -eq 0 ]; then
    echo "Downloaded: $sc_filename"
else
    echo "File not found: $sc_filename. Stopping."
    exit -1
    break
fi


# Download diffuse file and increasing LAST_WEEK_FILE value
diffuse_filename="rcdiff_lat_photon_weekly_w${week}_p305_v001.fits"
diffuse_url=${DIFFUSE_BASE_URL}/${diffuse_filename}

echo "Trying to download week $week: $diffuse_url"
wget -q --show-progress -O /fermihips/newdata/${diffuse_filename} ${diffuse_url}
# if [ $? -eq 0 ]; then
#     echo "Downloaded: $diffuse_filename"
#     echo ${week} > ${LAST_WEEK_FILE}
# else
#     echo "File not found: $diffuse_filename. Stopping."
#     break
# fi

