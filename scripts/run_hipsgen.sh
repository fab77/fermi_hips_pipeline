#!/bin/bash

# mkdir finalHealpix
# mkdir hips
# FILE=myhealpix_degrees.fits
# cp $FILE finalHealpix/

# ENERGY=`basename $(pwd)`
# echo "ENERGY $ENERGY"
# EMIN_GEV=`echo ${ENERGY} | awk -F"_" '{print $1}'`
# echo "EMIN_GEV $EMIN_GEV"
# EMAX_GEV=`echo ${ENERGY} | awk -F"_" '{print $2}' | sed 's/gev//'`
# echo "EMAX_GEV $EMAX_GEV"

# Generate or Update HiPS
# INPUT_DIR="./working"
# OUTPUT_DIR="./hips"
INPUT_DIR=$1
OUTPUT_DIR=$2
EMIN_gev=$3
EMAX_gev=$4
ENERGY="${EMIN_gev}_${EMAX_gev}gev"
HIPS_GEN_JAR="Hipsgen.jar"
HIPS_PROPERTIES="hips/properties"


echo "Running HIPSgen..."
echo "java -jar ${HIPS_GEN_JAR} \
    in=${INPUT_DIR} \
    out=${OUTPUT_DIR} \
    creator_did=UAM/Fab \
    frame=galactic \
    bitpix=-64 \
    dataRange="${EMIN_gev} ${EMAX_gev}" \
    incremental=true \
    id=UAM/P/Fermi_${ENERGY} \
    title="Fermi ${ENERGY}" \
    creator="Fabrizio Giordano" \
    status=public "
java -jar ${HIPS_GEN_JAR} \
    in=${INPUT_DIR} \
    out=${OUTPUT_DIR} \
    creator_did=UAM/Fab \
    frame=galactic \
    bitpix=-64 \
    dataRange="${EMIN_gev} ${EMAX_gev}" \
    incremental=true \
    id=UAM/P/Fermi_${ENERGY} \
    title="Fermi ${ENERGY}" \
    creator="Fabrizio Giordano" \
    status=public 