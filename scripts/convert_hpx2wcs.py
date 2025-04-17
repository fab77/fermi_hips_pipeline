from astropy.io import fits
from astropy.wcs import WCS
from reproject import reproject_from_healpix
# import reproject
# print(reproject.__file__)


# File paths
input_healpix = "/fermihips/working/fermi_1_3gev/final_healpix_degrees.fits"
output_wcs = "/fermihips/working/fermi_1_3gev/wcs_healpix_degrees.fits"
# input_healpix = "/Users/fabriziogiordano/Desktop/PhD/code/fermi_pipeline/test/working/fermi_1_3gev/final_healpix_degrees.fits"
# output_wcs = "/Users/fabriziogiordano/Desktop/PhD/code/fermi_pipeline/test/working/fermi_1_3gev/wcs_healpix_degrees.fits"
shape_out = (1024, 2048)  # (ny, nx)

# ---- Ensure COORDSYS is present ----
with fits.open(input_healpix, mode='update') as hdul:
    hdr = hdul[1].header
    if "COORDSYS" not in hdr:
        hdr["COORDSYS"] = "G"  # "G" = Galactic; use "C" for ICRS
        print("🔧 Added missing COORDSYS = 'G' to header")
    hdul.flush()

# ---- Create a WCS object for output projection ----
w = WCS(naxis=2)
w.wcs.ctype = ["GLON-CAR", "GLAT-CAR"]
w.wcs.crpix = [shape_out[1] / 2, shape_out[0] / 2]  # [x_center, y_center]
w.wcs.crval = [0.0, 0.0]  # center at (0,0)
w.wcs.cdelt = [-360.0 / shape_out[1], 180.0 / shape_out[0]]
w.wcs.cunit = ["deg", "deg"]

# ---- Reproject from HEALPix to WCS ----
array, footprint = reproject_from_healpix(
    input_healpix,
    output_projection=w,
    shape_out=shape_out,
    nested=False  # your file is RING ordered
)


# ---- Write the output FITS file ----
hdu = fits.PrimaryHDU(data=array, header=w.to_header())
hdu.writeto(output_wcs, overwrite=True)

print(f"✅ WCS FITS saved as: {output_wcs}")