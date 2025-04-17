
import os
import healpy as hp
import numpy as np
import astropy.io.fits as fits

# Load the HEALPix map (FITS file)
in_dir = "./data/working/proc5"
healpix_filename = "myhealpix.fits"
healpix_file_path = os.path.join (in_dir, healpix_filename)

healpix_map = hp.read_map(healpix_file_path)

# Define latitude and longitude (in degrees)
latitude = 45.0
longitude = 90.0

# Convert latitude and longitude to theta and phi (radians)
theta = np.radians(90 - latitude)  # colatitude (0 at North Pole, pi at South Pole)
phi = np.radians(longitude)        # longitude (0 to 2*pi)

# Get the pixel index corresponding to the given coordinates
nside = hp.get_nside(healpix_map)  # Get the map resolution
order = hp.nside2order(nside)
print(f"nside: {nside}, order: {order}")

pixel_index = hp.ang2pix(nside, theta, phi)

# Retrieve the pixel value
pixel_value = healpix_map[pixel_index]

print(f"Pixel index: {pixel_index}, Pixel value: {pixel_value}")


input_file = healpix_map
output_dir = os.path.join(in_dir, "fits")

# Ensure output directory exists
os.makedirs(output_dir, exist_ok=True)


# Ensure NSIDE is correct
assert nside == 64, f"Expected NSIDE=64, but found NSIDE={nside}"

# Number of pixels in the map
npix = hp.nside2npix(nside)

# Loop over each pixel and extract data
for pix in range(npix):
    # Get pixel value
    pixel_value = healpix_map[pix]

    # Get pixel boundaries: shape (2, Nvertices)
    boundaries = hp.boundaries(nside, pix, step=1)
    
    # Separate theta and phi
    theta = boundaries[0]  # Colatitude (in radians)
    phi = boundaries[1]    # Longitude (in radians)

    # Convert boundaries to (latitude, longitude) in degrees
    latitudes = 90 - np.degrees(theta)  # Colatitude to latitude
    longitudes = np.degrees(phi) % 360  # Keep longitude within [0, 360]

    # Create FITS header with pixel information
    header = fits.Header()
    header['NSIDE'] = nside
    header['PIXEL'] = pix
    header['VALUE'] = pixel_value
    header['LATS'] = str(latitudes.tolist())
    header['LONS'] = str(longitudes.tolist())

    # Create FITS Primary HDU
    hdu = fits.PrimaryHDU(data=np.array([pixel_value]), header=header)

    # Save to individual FITS file
    output_path = os.path.join(output_dir, f"pixel_{pix:05d}.fits")
    hdu.writeto(output_path, overwrite=True)

    print(f"Saved: {output_path}")

print(f"✅ Completed! {npix} FITS files generated in '{output_dir}'")