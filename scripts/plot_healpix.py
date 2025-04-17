import os
import matplotlib.pyplot as plt
import numpy as np
import healpy as hp
from astropy.io import fits

# count_file = "./data/working/proc4/lat_source_zmax90_gt1gev_ccube.fits"
# exp_file = "./data/working/proc4/lat_source_zmax90_gt1gev_expcube.fits" # cm x cm x seg

in_dir = "/Users/fabriziogiordano/Desktop/PhD/code/fermi_pipeline/test/working/fermi_1_3gev/"
healpix_filename = "final_healpix_degrees.fits"
healpix_file = os.path.join (in_dir, healpix_filename)

map = hp.read_map(healpix_file)
hp.mollview(
    map,
    norm="log",
    min=1e-11,
    # min=1,
    )
hp.graticule()
plt.show()