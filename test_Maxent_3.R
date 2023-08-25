# Test MaxEnt- Abruzzo and Northern Apulia sites


##### TEST MAXENT EMPIRICAL DATA #####
#utils::download.file(url = "https://raw.githubusercontent.com/mrmaxent/Maxent/master/ArchivedReleases/3.3.3k/maxent.jar", 
# destfile = paste0(system.file("java", package = "dismo"), 
#"/maxent.jar"), mode = "wb")


#test con siti
library(terra)
library(dismo)
library(raster)
sites = shapefile("data/BA_agriculture.shp")
study_area <- vect("data/studyareaWGS84.shp")
plot(study_area)
plot(sites, add = TRUE)



# this creates a 4-decimal-degree buffer around the
# occurrence data
occ_buff <- buffer(sites, 20000)

# plot the first element ([[1]]) in the raster stack
plot(study_area)
plot(sites, add = T, col = "red")  # adds occurrence data to the plot
plot(occ_buff, add = T, col = "blue")  # adds buffer polygon to the plot



### Extracting climatic gridraster
library(pastclim)

bio01<- region_slice(time_bp=-4000,
                     bio_variables = "bio01",
                     dataset= "Beyer2020",
                     path_to_nc = NULL,
                     ext = c(11.283872604,21.787487030, 37.029506683,44.070816040),
                     crop = study_area
)


bio12<- region_slice(time_bp=-4000,
                     bio_variables = "bio12",
                     dataset= "Beyer2020",
                     path_to_nc = NULL,
                     ext = c(11.283872604,21.787487030, 37.029506683,44.070816040),
                     crop = study_area
)

plot(bio01, main = "bio01")
plot(bio12, main = "bio12")

bio01<- focal(bio01,w=3, fun = mean, na.policy="only", na.rm = TRUE) #funzione che colma le celle NA del raster estratto precedentemente
bio12<- focal(bio12,w=3, fun = mean,na.policy="all",  na.rm = TRUE) 
plot(bio01)
plot(bio12)

### Importing gridraster
#physical landscape
r1 <- rast("~/R analisi/ModLand/data/raster/rec_elev.tiff")

r2 <- rast("~/R analisi/ModLand/data/raster/aspect.tiff")
r3 <- rast("~/R analisi/ModLand/data/raster/slope.tiff")
r4 <- rast("~/R analisi/ModLand/data/raster/rec_TRI.tiff")


#Soil
r5 <- rast("~/GIS_ModLandWGS84/raster/Carta_ecopedo_ita.tif")
r6 <- rast("~/GIS_ModLandWGS84/raster/Carta_geo_ita.tif")

#Hidrology
r7 <- rast("~/R analisi/ModLand/data/raster/TWI.tif")

#Climatic data
r8 <- crop(resample(bio01, r1, method = "near"), r1, mask=T)
r9 <- crop(resample(bio12, r1, method = "near"), r1, mask=T)
#library(spatialEco)
#r9g<-raster.gaussian.smooth(r9, s=2, n=21, type = "mean")
#plot(r9g)

#r9 <- focal(r9, w=53,fun = mean,na.rm = TRUE) #questa linea di codice potrebbe servire a ricampionare il raster dei fattori climatici per evitare che compaiano i quadratoni nel modello


#resample rasters

r2 <- resample(r2, r1, method = "near")
r3 <- resample(r3, r1, method = "near")
r4 <- resample(r4, r1, method = "near")
r5 <- resample(r5, r1, method = "near")
r6 <- resample(r6, r1, method = "near")
r7 <- resample(r7, r1, method = "near")



r1 <- raster(r1)
r2 <- raster(r2)
r3 <- raster(r3)
r4 <- raster(r4)
r5 <- raster(r5)
r6 <- raster(r6)
r7 <- raster(r7)
r8 <- raster(r8)
r9 <- raster(r9)

#rename some rastergrids
names(r1)<-"Elevation"
names(r4)<-"TRI"
names(r8)<-"Bio01"
names(r9)<-"Bio12"

env <- stack(r1,r2,r3,r4,r5,r6,r7,r8,r9)




# crop study area to a manageable extent (rectangle shaped)
env1 <- crop(env,extent(occ_buff))  

# the 'study area' created by extracting the buffer area from the raster stack
env1 <- mask(env,occ_buff)
# output will still be a raster stack, just of the study area


# stacking the bioclim variables to process them at one go
plot(env1)

plot(env1[[1]])
# plot the final occurrence data on the environmental layer
plot(sites,add =T, col = "red")  # the 'add=T' tells R to put the incoming data on the existing layer



set.seed(1) 
bg <- sampleRandom(x=env1,
                   size=100,
                   na.rm=T, #removes the 'Not Applicable' points  
                   sp=T) # return spatial points 

plot(env1[[1]])
# add the background points to the plotted raster
plot(bg,add=T) 
# add the occurrence data to the plotted raster
plot(sites,add=T,col="red")



# get the same random sample for training and testing
set.seed(1)

# randomly select 50% for training
selected <- sample(1:nrow(sites), nrow(sites) * 0.5)

occ_train <- sites[selected, ]  # this is the selection to be used for model training
occ_test <- sites[-selected, ]

p <- extract(env, occ_train)
# env conditions for testing occ
p_test <- extract(env, occ_test)
# extracting env conditions for background
a <- extract(env, bg)


# repeat the number 1 as many numbers as the number of rows
# in p, and repeat 0 as the rows of background points
pa <- c(rep(1, nrow(p)), rep(0, nrow(a)))

# (rep(1,nrow(p)) creating the number of rows as the p data
# set to have the number '1' as the indicator for presence;
# rep(0,nrow(a)) creating the number of rows as the a data
# set to have the number '0' as the indicator for absence;
# the c combines these ones and zeros into a new vector that
# can be added to the Maxent table data frame with the
# environmental attributes of the presence and absence
# locations
pder <- as.data.frame(rbind(p, a))



##3 Maxent models ###3.1 Simple implementation
# train Maxent with spatial data
# mod <- maxent(x=clim,p=occ_train)

# train Maxent with tabular data
mod <- maxent(x=pder, ## env conditions
              p=pa,   ## 1:presence or 0:absence
              
              path=paste0("../output/maxent_outputs"), ## folder for maxent output; 
              # if we do not specify a folder R will put the results in a temp file, 
              # and it gets messy to read those. . .
              args=c("responsecurves") ## parameter specification
)
# the maxent functions runs a model in the default settings. To change these parameters,
# you have to tell it what you want...i.e. response curves or the type of features

# view the maxent model in a html brower
mod



# view detailed results
mod@results


# example 1, project to study area [raster]
ped <- predict(mod, env) 


#writeRaster(ped, '~/R analisi/ModLand/output/maxent_outputs/ped.tiff', overwrite=TRUE)


library(RColorBrewer)
cols <- brewer.pal(9, "BuGn")
pal <- colorRampPalette(cols)

plot(ped, main ="Land suitability for ceral production", col=pal(20))  # plot the continuous prediction


### Plotting Abruzzo and Northern Apulia for the EAA23

ped<-rast("output/maxent_outputs/ped.tiff")
plot(ped, main ="Land suitability for ceral production", col=pal(20))
wb<-vect("~/GIS_ModLandWGS84/shapefile/waterbodies.shp")
sitesBA<-vect("data/BA_sites.shp")

eA<-ext(13.270633333,14.099383333, 41.814552778,42.408380556 )
pedA<-crop(ped, eA)
plot(pedA, col=pal(999))
plot(subset(wb, wb$type =="lake"), col = "lightblue", add=T)
plot(subset(wb, wb$type =="marsh"), col = "lightblue", alpha = 0.5, add=T)
plot(sitesBA, add=T, col = "red")

eP<-ext(15.21875000,15.985916666,41.253352778, 41.752558333)
pedP<-crop(ped, eP)
plot(pedP, col=pal(999))
plot(subset(wb, wb$type =="lagoon"), col = "lightblue", add=T)
plot(subset(wb, wb$type =="marsh"), col = "lightblue", alpha = 0.5, add=T)
plot(sitesBA, add=T, col = "red")













