import os
import argparse
import matplotlib.pyplot as plt
import healpy as hp
from healpy.visufunc import cartview


parser = argparse.ArgumentParser(description="Plot Fermi HEALPix maps generated via FermiTools.")
parser.add_argument("indir", type=str, help="Input directory path containing the HEALPix FITS file.")
parser.add_argument("hpxfile", type=str, help="Name of the HEALPix FITS file to plot.")
args = parser.parse_args()

in_dir = args.indir
healpix_filename = args.hpxfile
healpix_file = os.path.join (in_dir, healpix_filename)

map = hp.read_map(healpix_file)
# projview(map, coord=["G"], norm="log", flip="astro", projection_type="mollweide", min=1e-11)
# cartview( map, coord=["G"], norm="log", flip="astro", min=1e-11, lonra=[0, 10], latra=[-5,5])
cartview( map, coord=["G"], flip="astro",  lonra=[0, 10], latra=[-5,5], cmap="nipy_spectral")

# hp.mollview(
#     map,
#     norm="log",
#     min=1e-11,
#     # min=1,
#     )
# hp.graticule()
plt.show()
