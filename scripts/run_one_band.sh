#!/bin/bash

LOG_PREFIX="[run_one_band.sh]-> Activating conda fermi env"

source /opt/anaconda/etc/profile.d/conda.sh
conda activate fermi

EMIN_mev=$1
EMAX_mev=$2

EMIN_gev=`echo $(( ${EMIN_mev}/1000 ))`
EMAX_gev=`echo $(( ${EMAX_mev}/1000 ))`

echo "${LOG_PREFIX} ### Step2  - Generating HEALPix (counts and exposure) files with FERMI Tools [fermiTools_step.sh] (${EMIN_mev} ${EMAX_mev} MeV)"
sh fermiTools_step.sh ${EMIN_mev} ${EMAX_mev}
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} ${EMIN_mev} ${EMAX_mev} [mev] counts and exposure HEALPix generated:"
    ls ./working/fermi_${EMIN_gev}_${EMAX_gev}gev/diffuse*
else
    echo "${LOG_PREFIX} Error generating ${EMIN_mev} ${EMAX_mev} [mev] counts and exposure HEALPix. Exiting"
    exit -1
fi

echo "${LOG_PREFIX} ### Step3 - Creaating final HEALPix files [create_healpix.py] ${EMIN_gev} ${EMAX_gev} GeV"
python3 create_healpix.py ${EMIN_gev} ${EMAX_gev}
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} final HEALPix files generated:"
    ls ./working/fermi_${EMIN_gev}_${EMAX_gev}gev/final_healpix*
else
    echo "${LOG_PREFIX} Error generating final healpix. Exiting"
    exit -1
fi



# pip install --upgrade reproject
# python -c "import reproject; print(reproject.__version__)"
# echo "${LOG_PREFIX} ### Step4 - Reproject [convert_hpx2wcs.py]"
# python convert_hpx2wcs.py


echo "${LOG_PREFIX} ### Step4 - Updating HiPS [run_hipsgen.sh] ${EMIN_gev}_${EMAX_gev}gev"
echo "${LOG_PREFIX} ### Step4 - Selected final_healpix_degrees.fits as input."
sh run_hipsgen.sh /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/final_healpix_degrees.fits /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/hips/ ${EMIN_gev} ${EMAX_gev}
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} HiPS ${EMIN_gev} ${EMAX_gev} generated."
else
    echo "${LOG_PREFIX} HiPS not generated. Exiting"
    exit -1
fi



echo "${LOG_PREFIX} ### Step5 - Merge HiPS [run_hipsgen_concat.sh] ${EMIN_gev}_${EMAX_gev}gev"
sh run_hipsgen_concat.sh /fermihips/working/fermi_${EMIN_gev}_${EMAX_gev}gev/hips/UAM_P_Fermi_${EMIN_gev}_${EMAX_gev}gev/ /fermihips/hips/UAM_P_Fermi_${EMIN_gev}_${EMAX_gev}gev/ UAM/P/Fermi_${EMIN_gev}_${EMAX_gev}gev
if [ $? -eq 0 ]; then
    echo "${LOG_PREFIX} HiPS ${EMIN_gev} ${EMAX_gev} updated."
else
    echo "${LOG_PREFIX} HiPS not updated. Exiting"
    exit -1
fi

