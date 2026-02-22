#!/bin/bash
# run_fermihips.sh: Main script to run the entire Fermi HiPS pipeline for a given energy range and HEALPix order.
# This script is intended to be run inside the Docker container, and it assumes that the necessary input files (diffuse and spacecraft lists) are mounted at the specified paths.

# run example:
# ./run_fermihips.sh \
#     -o 7 \
#     -m 1000 \
#     -M 3000 \
#     -d /fermihips/new_diffuse_list.txt \
#     -s /fermihips/new_spacecraft_list.txt
source /opt/anaconda/etc/profile.d/conda.sh
conda activate fermi
cd /fermihips

set -euo pipefail


usage() {
    echo "Usage:"
    echo "  $0 -o <hpx_order> -m <emin_mev> -M <emax_mev> -d <new_diffuse.txt> -s <new_spacecraft.txt>"
    echo
    exit 1
}

HPX_ORDER=""
ENERGY_MIN=""
ENERGY_MAX=""
NEW_DIFFUSE=""
NEW_SC=""

while getopts ":o:m:M:d:s:h" opt; do
    case ${opt} in
        o ) HPX_ORDER="$OPTARG" ;;
        m ) ENERGY_MIN="$OPTARG" ;;
        M ) ENERGY_MAX="$OPTARG" ;;
        d ) NEW_DIFFUSE="$OPTARG" ;;
        s ) NEW_SC="$OPTARG" ;;
        h ) usage ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            usage ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            usage ;;
    esac
done

shift $((OPTIND -1))

# ----------------------------
# Validation
# ----------------------------

if [[ -z "$HPX_ORDER" || -z "$ENERGY_MIN" || -z "$ENERGY_MAX" || -z "$NEW_DIFFUSE" || -z "$NEW_SC" ]]; then
    echo "Error: all options are required."
    usage
fi

if ! [[ "$HPX_ORDER" =~ ^[0-9]+$ ]]; then
    echo "Error: hpx_order must be integer."
    exit 1
fi

if ! [[ "$ENERGY_MIN" =~ ^[0-9]+$ ]]; then
    echo "Error: energy_min must be integer."
    exit 1
fi

if ! [[ "$ENERGY_MAX" =~ ^[0-9]+$ ]]; then
    echo "Error: energy_max must be integer."
    exit 1
fi

if (( ENERGY_MIN >= ENERGY_MAX )); then
    echo "Error: energy_min must be smaller than energy_max."
    exit 1
fi

if [[ ! -f "$NEW_DIFFUSE" ]]; then
    echo "Error: diffuse list not found: $NEW_DIFFUSE"
    exit 1
fi

if [[ ! -f "$NEW_SC" ]]; then
    echo "Error: spacecraft list not found: $NEW_SC"
    exit 1
fi

# ----------------------------
# Load file lists
# ----------------------------


NSIDE=$((2**HPX_ORDER))
echo "HEALPix order: $HPX_ORDER"
echo "Derived NSIDE: $NSIDE"
echo "Energy range: ${ENERGY_MIN}-${ENERGY_MAX} MeV"
echo "Diffuse file list: ${NEW_DIFFUSE}"
echo "Spacecraft file list: ${NEW_SC}"

# ----------------------------
# Main Processing Loop
# ----------------------------
echo "Generating HEALPix (counts and exposure) files with FERMI Tools [fermiTools_step.sh] (${ENERGY_MIN} ${ENERGY_MAX} MeV) and HPX_ORDER ${HPX_ORDER}"
/fermihips/fermiTools_step.sh "$ENERGY_MIN" "$ENERGY_MAX" "$HPX_ORDER" "$NEW_DIFFUSE" "$NEW_SC"
if [ $? -ne 0 ]; then
    echo "Error in fermiTools_step.sh for $ENERGY_MIN $ENERGY_MAX $HPX_ORDER $NEW_DIFFUSE $NEW_SC."
    exit -1
fi

EMIN_gev=`echo $(( ${ENERGY_MIN}/1000 ))`
EMAX_gev=`echo $(( ${ENERGY_MAX}/1000 ))`

echo "Creating final HEALPix files [create_healpix.py] ${ENERGY_MIN} ${ENERGY_MAX} MeV"
python3 /fermihips/create_healpix.py ${EMIN_gev} ${EMAX_gev}
if [ $? -ne 0 ]; then
    echo "Error in create_healpix.py for ${EMIN_gev}GeV ${EMAX_gev}GeV."
    exit -1
fi

echo "Updating HiPS [run_hipsgen.sh] ${ENERGY_MIN} ${ENERGY_MAX} MeV"
/fermihips/run_hipsgen.sh /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/final_healpix_degrees.fits /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/hips/ ${EMIN_gev} ${EMAX_gev}
if [ $? -ne 0 ]; then
    echo "Error in run_hipsgen.sh for fermi_${EMIN_gev}_${EMAX_gev}gev map."
    exit -1
fi  

echo "Merge HiPS [run_hipsgen_concat.sh] ${ENERGY_MIN}_${ENERGY_MAX}gev"
/fermihips/run_hipsgen_concat.sh /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/hips/UAM_P_Fermi_${EMIN_gev}_${EMAX_gev}gev/ /fermihips/hips/UAM_P_Fermi_${EMIN_gev}_${EMAX_gev}gev/ UAM/P/Fermi_${EMIN_gev}_${EMAX_gev}gev
if [ $? -ne 0 ]; then
    echo "Error in run_hipsgen_concat.sh for fermi_${EMIN_gev}_${EMAX_gev}gev map."
    exit -1
fi

echo "Incremental HiPS update complete."