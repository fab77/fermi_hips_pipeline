#!/bin/bash

# sudo su - fermi
# su - fermi
# conda activate fermi
# pip install matplotlib numpy healpy astropy
# punlearn gtselect

LOG_PREFIX="[run_all.sh]-> "

cd /fermihips
LAST_WEEK_FILE="last_week.txt"
echo "${LOG_PREFIX} Read starting week number"
# Read starting week number
if [[ ! -f "$LAST_WEEK_FILE" ]]; then
  echo "${LOG_PREFIX} LAST_WEEK_FILE not found in ${LAST_WEEK_FILE}. Exit"
  exit -1
fi

last_week=$(cat "$LAST_WEEK_FILE")
echo "${LOG_PREFIX} Starting week number is ${last_week}"
week=$((last_week + 1))
echo "${LOG_PREFIX} Preparing to download new week number ${week}"

echo "${LOG_PREFIX} ### Step1 - Downloading latest diffuse and spacecraft files [download_latest_diffuse.sh]"
sh download_latest_diffuse.sh ${week}
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} Download completed. Files downloaded:"
    ls ./newdata
else
    echo "${LOG_PREFIX} Error downloading new data. Exiting"
    exit -1
fi

# echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) files with FERMI Tools [fermiTools_step.sh] (1000 3000 MeV)"
# sh run_one_band.sh 1000 3000
# if [ $? -eq 0 ]; then
#     echo "${LOG_PREFIX} (1000 3000 MeV) DONE"
# else
#     echo "${LOG_PREFIX} (1000 3000 MeV) not updated as an error occurred in one previous step. Exiting"
#     exit -1
# fi


echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) file with FERMI Tools [fermiTools_step.sh] (3000 10000 MeV)"
sh run_one_band.sh 3000 10000
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} (3000 10000 MeV) DONE"
else
    echo "${LOG_PREFIX} (3000 10000 MeV) not updated as an error occurred in one previous step. Exiting"
    exit -1
fi

echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) file with FERMI Tools [fermiTools_step.sh] (10000 30000 MeV)"
sh run_one_band.sh 10000 30000
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} (10000 30000 MeV) DONE"
else
    echo "${LOG_PREFIX} (10000 30000 MeV) not updated as an error occurred in one previous step. Exiting"
    exit -1
fi

echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) file with FERMI Tools [fermiTools_step.sh] (30000 100000 MeV)"
sh run_one_band.sh 30000 100000
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} (30000 100000 MeV) DONE"
else
    echo "${LOG_PREFIX} (30000 100000 MeV) not updated as an error occurred in one previous step. Exiting"
    exit -1
fi

echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) file with FERMI Tools [fermiTools_step.sh] (100000 300000 MeV)"
sh run_one_band.sh 100000 300000
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} (100000 300000 MeV) DONE"
else
    echo "${LOG_PREFIX} (100000 300000 MeV) not updated as an error occurred in one previous step. Exiting"
    exit -1
fi

echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) file with FERMI Tools [fermiTools_step.sh] (300000 1000000 MeV)"
sh run_one_band.sh 300000 1000000

if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} (300000 1000000 MeV) DONE"
        echo "${LOG_PREFIX} Updating ${LAST_WEEK_FILE} with week ${week}"
    echo ${week} > ${LAST_WEEK_FILE}
else
    echo "${LOG_PREFIX} (300000 1000000 MeV) not updated as an error occurred in one previous step. Exiting"
    echo "${LOG_PREFIX} ${LAST_WEEK_FILE} not updated as an error occurred in one previous step. Exiting"
    exit -1
fi



