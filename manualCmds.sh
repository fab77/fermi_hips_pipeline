# build the Docker image using the provided Dockerfile
$ docker build -t fermihips .

# bash command to run the Fermi Tools processing inside a Docker container, with
$ docker run -it \
    -v /Volumes/MyHD/FERMI/input/testdata:/fermihips/newdata \
    -v /Volumes/MyHD/FERMI/output/hips:/fermihips/hips \
    -v /Volumes/MyHD/FERMI/input/working:/fermihips/working \
    -v /Volumes/MyHD/FERMI/output/last_week.txt:/fermihips/last_week.txt \
    fermihips 

# enter into the container and run the following commands to process the data:
$ docker exec -it <container_id> bash

# Inside the docker container, run the following commands to process the data:
$ source /opt/anaconda/etc/profile.d/conda.sh
$ conda activate fermi

$ mkdir -p /fermihips/working/fermi_1_3gev
$ cd /fermihips
$ ls newdata/rcdiff_lat_photon_weekly_w* > working/filelist.txt
$ ls newdata/lat_spacecraft_weekly_w* > working/spacecraftlist.txt
$ ftmerge @working/spacecraftlist.txt working/spacecraft.fits lastkey='TSTOP,DATE-END' clobber=yes




$ gtselect evclass=128 evtype=3 \
    infile=/fermihips/working/filelist.txt \
    outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90.fits \
    ra=0 dec=0 rad=180 tmin=INDEF tmax=INDEF emin=1000 emax=3000 zmax=90

$ gtmktime scfile=/fermihips/working/spacecraft.fits \
    filter="DATA_QUAL>0 && LAT_CONFIG==1 && ABS(ROCK_ANGLE)<52" roicut=no \
    evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90.fits \
    outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits

# Run gtbin to create a counts map (CCUBE) 
    # WITH 10 HEALPIX BINS
    $ gtbin algorithm=HEALPIX \
        evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits \
        outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ccube_hpx10.fits \
        scfile=/fermihips/working/spacecraft.fits \
        hpx_ordering_scheme=RING hpx_order=10 coordsys=GAL ebinalg=LOG \
        emin=1000 emax=3000 enumbins=1 hpx_ebin=yes hpx_region=""
    # WITH 12 HEALPIX BINS
    $ gtbin algorithm=HEALPIX \
        evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits \
        outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ccube_hpx12.fits \
        scfile=/fermihips/working/spacecraft.fits \
        hpx_ordering_scheme=RING hpx_order=12 coordsys=GAL ebinalg=LOG \
        emin=1000 emax=3000 enumbins=1 hpx_ebin=yes hpx_region=""

$ gtltcube \
    evfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_gti.fits \
    scfile=/fermihips/working/spacecraft.fits \
    outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ltcube.fits \
    zmax=90 dcostheta=0.025 binsz=1

# Run gtexpcube2 to create the exposure map (EXPCUBE) 
    # WITH 10 HEALPIX BINS
    $ gtexpcube2 infile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ltcube.fits \
        cmap=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ccube_hpx10.fits \
        outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_expcube_hpx10.fits \
        irfs=P8R3_SOURCE_V3 hpx_ordering_scheme=RING hpx_order=10 coordsys=GAL \
        ebinalg=LOG emin=1000 emax=3000 enumbins=1
    # WITH 12 HEALPIX BINS
    $ gtexpcube2 infile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ltcube.fits \
        cmap=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_ccube.fits \
        outfile=/fermihips/working/fermi_1_3gev/diffuse_source_zmax90_expcube_hpx12.fits \
        irfs=P8R3_SOURCE_V3 hpx_ordering_scheme=RING hpx_order=12 coordsys=GAL \
        ebinalg=LOG emin=1000 emax=3000 enumbins=1

# in the host machine, run the following command to plot the HEALPix maps using the generated EXPCUBE and CCUBE files:
$ python3 scripts/plot_healpix.py /Volumes/MyHD/FERMI/input/working/fermi_1_3gev/ diffuse_source_zmax90_expcube_hpx10.fits

# in the container, run the following command to create the HEALPix maps using the generated EXPCUBE and CCUBE files:
$ python3 create_healpix.py 1 3 

# in the docker container, run the following command to create the HiPS maps using the generated HEALPix files:
$ sh run_hipsgen.sh /fermihips/working/fermi_1_3gev/final_healpix_degrees.fits /fermihips/working/fermi_1_3gev/hips/ 1 3