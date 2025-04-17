import os
import argparse
import matplotlib.pyplot as plt
import numpy as np
import healpy as hp
from astropy.io import fits

# energy_param_1 = argparse ....
# energy_param_2 = argparse ....

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Process Fermi HEALPix maps with given energy range.")
parser.add_argument("energy_param_1", type=int, help="Lower energy bound (e.g., 1 for 1 GeV)")
parser.add_argument("energy_param_2", type=int, help="Upper energy bound (e.g., 3 for 3 GeV)")
args = parser.parse_args()

energy_param_1 = args.energy_param_1
energy_param_2 = args.energy_param_2

# Build directories based on energy params
in_dir = f"./working/fermi_{energy_param_1}_{energy_param_2}gev"
out_dir = in_dir
count_file = os.path.join (in_dir, "diffuse_source_zmax90_ccube.fits")
exp_file = os.path.join (out_dir, "diffuse_source_zmax90_expcube.fits") # cm x cm x seg

# to check how to read map when tehere are more bins. Does it read only the first one by default?
counts = hp.read_map(count_file)

exp = hp.read_map(exp_file)

nside = hp.get_nside(counts)
# ADD in the HiPS generation metadata the unit used.
# for pixel
reshape_factor = counts.size / exp.size 

# for sterad
# reshape_factor = counts.size / exp.size / hp.pixelfunc.nside2pixarea(nside, False)

# for squaredeg
# reshape_factor = counts.size / exp.size / hp.pixelfunc.nside2pixarea(nside, True)

# Reshape counts into (49152, 256) blocks
counts_reshaped = counts.reshape(exp.size, int(reshape_factor))

# Divide each block by corresponding exp value
result_reshaped = counts_reshaped / exp[:, np.newaxis]

map_pixels = result_reshaped.ravel()
hp.write_map(os.path.join(out_dir,"final_healpix_pixels.fits"), map_pixels, overwrite=True)


# Compute the pixel area in steradians
pixel_area_sterad = hp.nside2pixarea(nside, degrees=False)  # degrees=False gives area in steradians
# Divide each count by the pixel area
counts_per_sterad = result_reshaped / pixel_area_sterad
# Flatten back to 1D
map_sterad = counts_per_sterad.ravel()
hp.write_map(os.path.join(out_dir,"final_healpix_sterad.fits"), map_sterad, overwrite=True)


# Compute the pixel area in degrees
pixel_area_deg = hp.nside2pixarea(nside, degrees=True)  # degrees=False gives area in steradians
# Divide each count by the pixel area
counts_per_degrees = result_reshaped / pixel_area_deg
# Flatten back to 1D
map_deg = counts_per_degrees.ravel()
hp.write_map(os.path.join(out_dir,"final_healpix_degrees.fits"), map_deg, overwrite=True)










# my_map = os.path.join(out_dir,"myhealpix_degrees.fits")
# map = hp.read_map(my_map)
# hp.mollview(
#     map,
#     norm="log",
#     min=1e-11,
#     # min=1,
#     )
# hp.graticule()
# plt.show()