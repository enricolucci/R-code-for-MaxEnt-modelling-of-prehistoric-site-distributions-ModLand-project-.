

#Pastclim data


library(pastclim)
library(terra)#il pacchetto raster per questa analisi funziona meglio perché permette di ricavare x e y direttamente nella trasformazione a dataframe


#########################Download dataset###################
#Krapp et al 2021
get_vars_for_dataset("Krapp2021") #elenco delle risorse disponibili nel dataset
get_time_steps("Krapp2021")
download_dataset(dataset = "Krapp2021", bio_variables = "bio06")

#Beyer et al 2020
get_vars_for_dataset("Beyer2020") #elenco delle risorse disponibili nel dataset
get_time_steps("Beyer2020")
download_dataset(dataset = "Beyer2020", bio_variables = "bio19")
get_downloaded_datasets()
#############################################################

#set_data_path(path_to_nc = "~/R analisi/ModLand/my_reconstructions")

locations <- vect("data/CA_BA_sites.shp")
dem<-rast("~/GIS_ModLandWGS84/raster/Abr_Mol_Pug.tif")

plot(dem)
plot(locations, add=T)

locations<-extract(dem, locations, bind = TRUE)

library(raster)
locations<-as(locations, "Spatial") #per convertire l'oggeto da SpatVector in Spatialpointsdataframe del pacchetto raster

locations = as.data.frame(locations)
colnames(locations)[14]  <- "longitude" 
colnames(locations)[15]  <- "latitude"
colnames(locations)[13]  <- "elev"

View(locations)

#Subs1<-subset(locations, (!is.na(locations[,12])) & crono_gen == 'bronzo')
#Subs2<-subset(locations, crono_gen == 'bronzo')
#plot(Subs1$longitude, Subs1$latitude)
#plot(Subs2$longitude, Subs2$latitude)

climatic_data = location_slice(x = locations, bio_variables = c("bio01", "bio12"), dataset = "Beyer2020", time_bp = 4000,
                                nn_interpol = TRUE, directions = "8")

View(climatic_data)


##### Plotting data
library(ggplot2)

ggplot(climatic_data, aes(elev, bio01)) + 
  geom_jitter(width = .05, alpha = .3, cex = 3, aes(col = regione))+ xlab("elev m asl")+ylab("°celsius")+ 
  ggtitle("BIO1: Annual mean temperature (4000 BP)")+ theme(legend.title = element_blank())


ggplot(climatic_data, aes(elev, bio12, fill = regione)) + 
  geom_jitter(width = .05, alpha = .3, cex = 3,aes(col = regione))+  xlab("elev m asl") +ylab("mm") + 
  ggtitle("BIO12: Annual precipitation (4000 BP)") + theme(legend.title = element_blank())

##### Write climatic dataset

write.csv(climatic_data, "my_reconstructions/climatic_data.csv", row.names=FALSE)
