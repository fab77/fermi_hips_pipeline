#!/bin/bash

INPUT_HIPS=$1
OUTPUT_HIPS=$2
HIPS_ID=$3
HIPS_GEN_JAR="Hipsgen.jar"

echo "Running merge with HIPSgen..."
echo "java -jar ${HIPS_GEN_JAR} \
  id=${HIPS_ID} \
  in=${INPUT_HIPS} \
  out=${OUTPUT_HIPS} CONCAT"
java -jar ${HIPS_GEN_JAR} \
  id=${HIPS_ID} \
  in=${INPUT_HIPS} \
  out=${OUTPUT_HIPS} CONCAT

