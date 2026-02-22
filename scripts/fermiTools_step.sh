#!/bin/bash

export HEADASNOQUERY=1
export HEADASPROMPT=/dev/null

# fermiTools_step.sh: Script to run the Fermi Tools steps for a given energy range and HEALPix order.
# This script is called by run_fermihips.sh and performs the following steps:
# 1. gtselect: Selects events based on energy range and region of interest.
# 2. gtmktime: Applies quality cuts to select good time intervals (GTIs).
# 3. gtbin: Bins the selected events into a HEALPix map (counts map).
# 4. gtltcube: Creates the livetime cube.
# 5. gtexpcube2: Generates the exposure map by combining the livetime cube with the instrument response functions.

LOG_PREFIX="[fermiTools_step.sh]-> "

# EMIN=1000 # in mev
# EMAX=3000 # in mev
EMIN=$1 # in mev
EMAX=$2 # in mev
HPX_ORDER=$3 # integer, e.g., 10 or 12
DIFFUSE_FILE=$4
SPACECRAFT_FILE=$5

# source /opt/anaconda/etc/profile.d/conda.sh
# conda activate fermi

WORKDIR="/fermihips/working/"
mkdir -p ${WORKDIR}


ftmerge @${SPACECRAFT_FILE} ${WORKDIR}/spacecraft.fits lastkey='TSTOP,DATE-END' clobber=yes
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} ftmerge ERROR"
    exit -1
fi
echo "${LOG_PREFIX} ftmerge DONE"
SCFILE="${WORKDIR}/spacecraft.fits"
# Run gtselect
# Parameters
RA=0
DEC=0
RAD=180
ZMAX=90

EMIN_gev=`echo $(( ${EMIN}/1000 ))`
EMAX_gev=`echo $(( ${EMAX}/1000 ))`
OUTDIR=`echo ${WORKDIR}/fermi_${EMIN_gev}_${EMAX_gev}gev`
OUTFILE="${OUTDIR}/diffuse_source_zmax90.fits"

if [ ! -d ${OUTDIR} ]; then
    mkdir ${OUTDIR}
fi
# cp ${INFILE} ${OUTDIR}/
# cp ${SCFILE} ${OUTDIR}/
# cd ${OUTDIR}
# echo `pwd`
# ls ${INFILE}
# ls ${SCFILE}


# evclass=128 → Event class (128 for P8R3_SOURCE).
# evtype=3 → Event type (e.g., front+back events).
# infile=@filelist.txt → Input file (list of FT1 files via @filelist.txt).
# outfile=diffuse_source_zmax90_1-500gev.fits → Output FT1 file.
# ra=0 and dec=0 → Center coordinates (Right Ascension and Declination in degrees).
# rad=180 → Search radius in degrees.
# tmin=INDEF and tmax=INDEF → Time range (use INDEF for unspecified).
# emin=1000 and emax=500000 → Energy range in MeV (1 GeV to 3 GeV).
# zmax=90 → Maximum zenith angle in degrees (to reduce Earth limb contamination).
echo "In gtselect: Filters events based on user-defined criteria, including energy range and region of interest."
gtselect evclass=128 evtype=3 infile=$DIFFUSE_FILE outfile=$OUTFILE ra=$RA dec=$DEC rad=$RAD tmin=INDEF tmax=INDEF emin=$EMIN emax=$EMAX zmax=$ZMAX
#gtselect evclass=128 evtype=3 infile=/fermihips/working/filelist.txt outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90.fits ra=0 dec=0 rad=180 tmin=INDEF tmax=INDEF emin=1000 emax=3000 zmax=90
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} gtselect ERROR"
    exit -1
fi
echo "${LOG_PREFIX} gtselect DONE"

# Run gtmktime
# Parameters
# SCFILE="spacecraft.fits"
FILTER="DATA_QUAL>0 && LAT_CONFIG==1 && ABS(ROCK_ANGLE)<52"
ROICUT="no"
EVFILE="${OUTDIR}/diffuse_source_zmax90.fits"
OUTFILE="${OUTDIR}/diffuse_source_zmax90_gti.fits"
# scfile=spacecraft.fits → Input spacecraft data file.
# filter="DATA_QUAL>0 && LAT_CONFIG==1 && ABS(ROCK_ANGLE)<52" → Time selection filter:
#     DATA_QUAL>0 ensures good data quality.
#     LAT_CONFIG==1 selects standard science mode.
#     ABS(ROCK_ANGLE)<52 limits the rocking angle to 52°.
# roicut=no → No additional ROI-based zenith angle cut.
# evfile=diffuse_source_zmax90_1-3gev.fits → Input event data file (from gtselect output).
# outfile=diffuse_source_zmax90_1-3gev_gti.fits → Output file with GTI (Good Time Intervals) applied.
echo "In gtmktime: Applies quality cuts to select good time intervals (GTIs), ensuring data reliability based on spacecraft conditions."
gtmktime scfile=$SCFILE filter="$FILTER" roicut=$ROICUT evfile=$EVFILE outfile=$OUTFILE
# gtmktime scfile=/fermihips/working/spacecraft.fits filter="DATA_QUAL>0 && LAT_CONFIG==1 && ABS(ROCK_ANGLE)<52" roicut=no evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90.fits outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} gtmktime ERROR"
    exit -1
fi
echo "${LOG_PREFIX} gtmktime DONE"


# Run gtbin
# Parameters
EVFILE="${OUTDIR}/diffuse_source_zmax90_gti.fits"
OUTFILE="${OUTDIR}/diffuse_source_zmax90_ccube.fits"
ORDERING="RING"
COORDSYS="GAL"
EBINALG="LOG"
ENUMBINS=1
# algorithm=HEALPIX → Output type is a HEALPix map.
# evfile=diffuse_source_zmax90_1-3gev_gti.fits → Input event data file (from gtmktime output).
# outfile=diffuse_source_zmax90_1-3gev_ccube.fits → Output HEALPix file.
# scfile=spacecraft.fits → Spacecraft data file (for time and pointing information).
# ordering=RING → HEALPix ordering scheme (RING format).
# hpx_order=12 → Map order (HEALPix resolution, 12 is high-resolution).
# coordsys=GAL → Galactic coordinate system.
# ebinalg=LOG → Use logarithmic binning for energy.
# emin=1000 → Minimum energy (in MeV).
# emax=3000 → Maximum energy (in MeV).
# enumbins=1 → Number of energy bins (1 bin for the entire energy range).

# plist gtbin

# gtbin algorithm=HEALPIX evfile=diffuse_source_zmax90_gti.fits outfile=diffuse_source_zmax90_ccube.fits \
#     scfile=spacecraft.fits hpx_order=12 hpx_ordering_scheme=RING coordsys=GAL \
#     ebinalg=LOG emin=1000 emax=500000 enumbins=1 hpx_ebin=yes hpx_region=""
echo "In gtbin: ins filtered events into a HEALPix map, producing a spatial distribution
of gamma-ray counts."
gtbin algorithm=HEALPIX evfile=$EVFILE outfile=$OUTFILE scfile=$SCFILE \
      hpx_ordering_scheme=$ORDERING hpx_order=$HPX_ORDER coordsys=$COORDSYS \
      ebinalg=$EBINALG emin=$EMIN emax=$EMAX enumbins=$ENUMBINS hpx_ebin=yes hpx_region=""
# gtbin algorithm=HEALPIX evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits outfile=/fermihips/working/fermi_1_3gev//diffuse_source_zmax90_ccube.fits scfile=/fermihips/working/spacecraft.fits \
#      hpx_ordering_scheme=RING hpx_order=12 coordsys=GAL \
#      ebinalg=LOG emin=1000 emax=3000 enumbins=1 hpx_ebin=yes hpx_region=""
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} gtbin ERROR"
    exit -1
fi
echo "${LOG_PREFIX} gtbin DONE"
# Run gtltcube
# Parameters
# EVFILE="${WORKDIR}/diffuse_source_zmax90_gti.fits"
OUTFILE="${OUTDIR}/diffuse_source_zmax90_ltcube.fits"
ZMAX=90
DCOSTHETA=0.025
BINSZ=1
# evfile=diffuse_source_zmax90_1-3gev_gti.fits → Input event file (from gtmktime output).
# scfile=spacecraft.fits → Input spacecraft file (pointing and time data).
# outfile=diffuse_source_zmax90_1-3gev_ltcube.fits → Output livetime cube file.
# zmax=90 → Maximum zenith angle (degrees) to avoid Earth limb contamination.
# dcostheta=0.025 → Step size in cos(θ) (smaller values give better accuracy).
# binsz=1 → Pixel size in degrees (affects spatial resolution).
echo "In gtltcube: Creates the livetime cube, representing the total observation time across the sky."
gtltcube evfile=$EVFILE scfile=$SCFILE outfile=$OUTFILE zmax=$ZMAX dcostheta=$DCOSTHETA binsz=$BINSZ
# gtltcube evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits scfile=/fermihips/working/spacecraft.fits outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ltcube.fits zmax=90 dcostheta=0.025 binsz=1
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} gtltcube ERROR"
    exit -1
fi
echo "${LOG_PREFIX} gtltcube DONE"

# Run gtexpcube2
# Parameters
LTCUBE="${OUTDIR}/diffuse_source_zmax90_ltcube.fits"
CCUBE="${OUTDIR}/diffuse_source_zmax90_ccube.fits"
OUTFILE="${OUTDIR}/diffuse_source_zmax90_expcube.fits"
IRFS="P8R3_SOURCE_V3"
# infile=diffuse_source_zmax90_1-3gev_ltcube.fits → Input livetime cube (from gtltcube output).
# cmap=diffuse_source_zmax90_1-3gev_ccube.fits → Input counts map (from gtbin output).
# outfile=diffuse_source_zmax90_1-3gev_expcube.fits → Output exposure map.
# irfs=P8R3_SOURCE_V3 → Instrument response function (IRF) used. Ensure this matches the event class (evclass=128 corresponds to P8R3_SOURCE_V3 for Pass 8 data).
echo "In gtexpcube2: Generates the exposure map by combining the livetime cube with the instrument response functions."
gtexpcube2 infile=$LTCUBE cmap=$CCUBE outfile=$OUTFILE irfs=$IRFS hpx_ordering_scheme=RING hpx_order=$HPX_ORDER coordsys=GAL ebinalg=LOG emin=1000 emax=3000 enumbins=1
# gtexpcube2 infile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ltcube.fits cmap=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ccube.fits outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_expcube.fits irfs=P8R3_SOURCE_V3 \
# hpx_ordering_scheme=RING hpx_order=10 coordsys=GAL \
#     ebinalg=LOG emin=1000 emax=3000 enumbins=1
if [ $? -ne 0 ]; then 
    echo "${LOG_PREFIX} gtexpcube2 ERROR"
    exit -1
fi
echo "${LOG_PREFIX} gtexpcube2 DONE"

# echo "create_healpix.py"
# python3 ../create_healpix.py
# echo "create_healpix.py DONE"

# sh ../run_hipsgen.sh