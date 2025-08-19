# ModLand — MaxEnt modelling (archaeology)

This repository provides a **clear, single‑file R Markdown** workflow to model archaeological
presence‑only data with **MaxEnt** using environmental covariates.  
It follows the original ModLand code closely, with small practical adjustments for
reproducibility (relative paths, Shapefile study area, concise UK‑English captions).

---

## Contents

- **MaxEnt_ModLand_analysis.Rmd** – the end‑to‑end workflow (run/knit from RStudio).
- **data/** – expected inputs (see below).
- **outputs/** – model outputs (raster + figures).

Only these R packages are used:
`terra`, `sf`, `raster`, `dismo`, `maxnet`, `ggplot2`.

---

## Data layout & expected files

Place your inputs under `data/`:

