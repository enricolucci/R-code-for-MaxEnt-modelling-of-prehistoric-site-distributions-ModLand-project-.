# ModLand — MaxEnt modelling

A clear, single‑file **R Markdown** workflow for MaxEnt modelling of archaeological presence‑only data.
It follows the original ModLand code closely, with only small practical changes:

- relative paths (no absolute paths)
- **Shapefile** for the study area
- captions and comments in **UK English**

## Data layout
```
data/
  study_area.shp  (+ .dbf .shx .prj)
  presence.csv    # lon,lat[,label] in WGS84
  rasters/        # *.tif (DEM, TPI, TRI, TWI, etc.)
outputs/
  suitability.tif
  figures/
```

## Run
Open **MaxEnt_ModLand_analysis.Rmd** in RStudio and *Knit* (HTML).  
The script will:
1) read the study area (Shapefile) and presence points (CSV),  
2) stack all rasters in `data/rasters/`, align/crop/mask,  
3) fit MaxEnt with `dismo::maxent` (if available) or fall back to `{maxnet}`,  
4) report **AUC** on a held‑out test set,  
5) export `outputs/suitability.tif` and a quick PNG map.

## Packages
Only these are used: `terra`, `sf`, `raster`, `dismo`, `maxnet`, `ggplot2`.

## Licence
Code under GPL‑3. Please cite the ModLand project when reusing.
