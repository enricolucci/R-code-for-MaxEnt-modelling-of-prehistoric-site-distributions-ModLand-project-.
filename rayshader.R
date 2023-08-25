

library(raster)
library(rayshader)
library(rayrender)
library(rayimage)

setwd("/Users/enric/Documenti/R analisi/ModLand/")
#importo il DEM

DEM_SA = raster("/Users/enric/Documenti/GIS_ModLandWGS84/raster/DEM90_WGS84.tif")
SA_EAA23<-shapefile("~/GIS_ModLandWGS84/shapefile/study_area_EAA23.shp")
DEM_SA<-crop(DEM_SA, SA_EAA23)

DEM_SA = aggregate(DEM_SA, fact = 4)
#rayshader lavora con le matrici, dunque il raster DEM va convertito in matrice
DEM_SA_mat = raster_to_matrix(DEM_SA)




#rendering the study area

DEM_SA_mat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_3d(DEM_SA_mat, zscale = 100, fov = 20, theta = 0, zoom = 0.4, 
          phi = 45, windowsize = c(2000, 1800), water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5,
          background="white")
Sys.sleep(1)
render_snapshot(clear=TRUE)


# rendering Abruzzo 

sa<-shapefile("~/GIS_ModLandWGS84/shapefile/regioni.shp")
sa_A<-subset(sa, DEN_REG == "Abruzzo")

dem_A<-crop(DEM_SA, sa_A)
plot(dem_A)

dem_A_mat<-raster_to_matrix(dem_A)

dem_A_mat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_3d(dem_A_mat, zscale = 100, fov = 0, theta = 0, zoom = 0.3, 
          phi = 60, windowsize = c(2000, 1800), water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5,
          background="white")
Sys.sleep(1)
render_snapshot(clear=TRUE)


# rendering Puglia
sa<-shapefile("~/GIS_ModLandWGS84/shapefile/Samples area 4.shp")
sa_P<-subset(sa, name == "C")

dem_P<-crop(DEM_SA, sa_P)
plot(dem_P)

dem_P_mat<-raster_to_matrix(dem_P)

dem_P_mat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_3d(dem_P_mat, zscale = 100, fov = 0, theta = 0, zoom = 0.3, 
          phi = 60, windowsize = c(2000, 1800), water = TRUE, waterdepth = 2, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5,
          background="white")
Sys.sleep(1)
render_snapshot(clear=TRUE)



#high_quality render NON FUNZIONA
DEM_SA_mat %>%
  sphere_shade(texture = "imhof1") %>%
  plot_3d(DEM_SA_mat, zscale = 100, fov = 0, theta = 100, zoom = 0.6, 
          phi = 45, windowsize = c(1000, 800), water = TRUE, waterdepth = 0, wateralpha = 0.5, watercolor = "lightblue",
          waterlinecolor = "white", waterlinealpha = 0.5,
          background="white")
Sys.sleep(0.2)
render_highquality(filename = "test.png",clear = TRUE)


