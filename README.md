# Fermi HiPS Updater

This Docker image is used to **update the Fermi HiPS** hosted at:  
👉 [http://astrobrowser.ft.uam.es/skymaps/](http://astrobrowser.ft.uam.es/skymaps/)

## Overview

The HiPS datasets are generated using **Fermi diffuse weekly files** published by NASA:  
🔗 [Fermi LAT Weekly Diffuse Data](https://heasarc.gsfc.nasa.gov/FTP/fermi/data/lat/weekly/diffuse/)

From these data, six energy-binned maps are produced:

| Energy Range       | HiPS ID                        |
|--------------------|--------------------------------|
| 1 – 3 GeV          | `UAM_P_Fermi_1_3gev`           |
| 3 – 10 GeV         | `UAM_P_Fermi_3_10gev`          |
| 10 – 30 GeV        | `UAM_P_Fermi_10_30gev`         |
| 30 – 100 GeV       | `UAM_P_Fermi_30_100gev`        |
| 100 – 300 GeV      | `UAM_P_Fermi_100_300gev`       |
| 300 – 1000 GeV     | `UAM_P_Fermi_300_1000gev`      |

## Processing Pipeline

The full process is broken into several steps, executed inside the Docker image:

1. **Download** the latest diffuse and spacecraft files  
   → `download_latest_diffuse.sh`
2. **Generate** count and exposure maps using Fermi TOOLS  
   → `fermiTools_step.sh`
3. **Create** HEALPix maps from the count and exposure maps  
   → `create_healpix.py`
4. **Generate** HiPS from the HEALPix maps  
   → `run_hipsgen.sh`
5. **Concatenate** the new HiPS with the official HiPS  
   → `run_hipsgen_concat.sh`

## Requirements

Before running the image, ensure you have:

- A file called **`last_week.txt`** containing the last processed week number.  
  This value will be **incremented by 1** to determine the next week to process.  
  It will be mounted in the container at `/fermihips/last_week.txt`.  
  At the end of the process, it will be **overwritten** with the new value.

- A directory containing the **official HiPS directories** to be updated.  
  It will be mounted in the container at `/fermihips/hips`.

## 🛠️ Build the Docker Image

```bash
docker build -t fermihips .
```

## ▶️ Run the Docker Image
```bash
docker run -it \
  -v /path/to/hips:/fermihips/hips \
  -v /path/to/last_week.txt:/fermihips/last_week.txt \
  fermihips sh /fermihips/run_all.sh
```

Replace /path/to/hips and /path/to/last_week.txt with your actual paths.


