
### VARIACION MULTITEMPORAL NDVI

# Autor: Ignacio Díaz H.
# fecha : junio 2017

# Cargar paquetes
library(raster)
library(maptools)
library(spatial)
library(rgdal)
library(geosphere)
library(XML)
library(xts)

## Setear espacio de trabajo y carpeta de temporales
rasterOptions(tmpdir="C:/Users/idiaz/Documents/temp/")
rm(list=ls())
Sys.time()

## Setear directorio de imagenes
mypath <- "C:/Users/idiaz/Documents/GEODATABASE/RASTER/L8SR/"
folders <- list.files(path=mypath, pattern=glob2rx("LC0823308420*"), full.names=T)

## Lectura de limites vectoriales
setwd("C:/Users/idiaz/Documents/GEODATABASE/Geodata/SHP/")
#myclip<-readOGR("Limite_RNRC.shp")
myclip<-readOGR("altitud_estepa.shp")

## definir poryeccion de limites vectoriales
projection(myclip) <- CRS("+proj=utm +south +zone=19 +datum=WGS84")
myclip<- spTransform(myclip, CRS("+proj=utm +north +zone=19 +datum=WGS84"))


tabla<-NULL
tablaM<-NULL

## iteración por escena Landsat

for(i in 1:length(folders)){
  
  # Define y extrae bandas por directorio
  mypath<-folders[i]
  myband4<-list.files(path=mypath,pattern=glob2rx("*sr_band4.tif"),full.names=TRUE) 
  escene4<-substr(myband4,90,200)
  nameR<-substr(myband4,107,114)
  setwd(mypath)
  b4<-raster(escene4)
  myband5<-list.files(path=mypath,pattern=glob2rx("LC08_L1TP_*_T1_sr_band5.tif"),full.names=TRUE) 
  escene5<-substr(myband5,90,200)
  b5<-raster(escene5)
  
  # Extrae fecha de adquisicion del metadata
  metapath<-list.files(path=folders[i],pattern=glob2rx("*T1.xml"),full.names=TRUE)
  meta <- xmlParse(metapath,getDTD=T,addAttributeNamespaces=T)
  xml_meta <- xmlToList(meta)
  date <- xml_meta$global_metadata$acquisition_date[1]
  
  # calcula indices de vegetación
  ndvi<-(b5-b4)/(b5+b4)
  # savi<- ((b5-b4)/(b5+b4+0.5))*(1+0.5)
  # Mmsavi2<-(2*b5+1-sqrt(((2*b5+1)^2)-8*(b5-b4)))/2
  
  index<-ndvi ## elegir indice segun coprresponda
  
  # Corta el indice con el limite vectorial
  cr <- crop(index, extent(myclip), snap="out")                    
  fr <- rasterize(myclip, cr)   
  mycrop <- mask(x=cr, mask=fr)

  # Reclasifica NDVI
  m <- c(-Inf, 0.2, 0, 0.2,0.4,1,0.4,0.6,2,0.6,0.9,3,0.9, Inf, 4)
  rcla <- matrix(m, ncol=3, byrow=TRUE)
  mycrop <- reclassify(mycrop, rcla)
  
  ## calcula area en hectareas
  area<-aggregate(getValues(area(mycrop, weights=FALSE)), by=list(getValues(mycrop)), sum)
  area<-area/10000
  
  ## Genera tabla con areas por tipo vegetal
  data<-cbind(date=date,roca=area[1,2],estepa_rala=area[2,2],estepa_densa=area[3,2],vegas=area[4,2],
               sombra=area[5,2])
  tabla<-rbind(tabla,data)

  # guardar raster reclasificado
  setwd("C:/Users/idiaz/Documents/GEODATABASE/RASTER/L8SR/NDVI/")
  # writeRaster(mycropM,paste("ndviM",nameR,".tif",sep=""))
  writeRaster(mycrop,paste("ndvi",nameR,".tif",sep=""))
  
}


## juntar formato fecha y numero
tabla2<-as.data.frame(tabla)
indx <- sapply(tabla2, is.factor)
tabla2[indx] <- lapply(tabla2[indx], function(x) as.numeric(as.character(x)))
tabla3<-as.data.frame(tabla)
dates <- as.Date(tabla3$date, format='%Y-%m-%d')
tabla2$date<-dates
tabla_final<-tabla2

tabla2M<-as.data.frame(tablaM)
indx <- sapply(tabla2M, is.factor)
tabla2M[indx] <- lapply(tabla2M[indx], function(x) as.numeric(as.character(x)))
tabla3M<-as.data.frame(tablaM)
dates <- as.Date(tabla3M$date, format='%Y-%m-%d')
tabla2M$date<-dates
tabla_finalM<-tabla2M


rm(list= ls()[!(ls() %in% c("tabla_final","tabla_finalM"))])


## subset por mes especifico
tabla_ene<-tabla_final[format.Date(tabla_final$date, "%m")=="01" &
          !is.na(tabla_final$date),]
tabla_feb<-tabla_final[format.Date(tabla_final$date, "%m")=="02" &
                      !is.na(tabla_final$date),]
tabla_mar<-tabla_final[format.Date(tabla_final$date, "%m")=="03" &
                         !is.na(tabla_final$date),]

tabla<-rbind(tabla_ene,tabla_feb,tabla_mar)
tabla<-tabla[order(as.Date(tabla$date, format="%Y/%m/%d")),]

par(mfrow=c(2,2))
par(mar=c(4,4,1.5,1))

plot(estepa_rala ~ date, tabla, xaxt = "n",xlab="Fecha",ylab="Superficie (ha)",type="l",lwd=2,
     col="gold3",ylim=c(0,max(tabla$estepa_rala)))
axis(1, tabla$date, format(tabla$date, "%m/%Y"), cex.axis = .7)
legend("bottomright", lty=1,lwd=2, legend="Estepa",col="gold3")

plot(estepa_densa ~ date, tabla, xaxt = "n",xlab="Fecha",ylab="Superficie (ha)",type="l",lwd=2,
     col="chartreuse3",ylim=c(0,max(tabla$estepa_densa)))
axis(1, tabla$date, format(tabla$date, "%m/%Y"), cex.axis = .7)
legend("bottomright", lty=1,lwd=2, legend="Matorral abierto",col="chartreuse3")

plot(vegas ~ date, tabla, xaxt = "n",xlab="Fecha",ylab="Superficie (ha)",type="l",lwd=2,
     col="darkgreen",ylim=c(0,max(tabla$vegas)))
axis(1, tabla$date, format(tabla$date, "%m/%Y"), cex.axis = .7)
legend("bottomright", lty=1,lwd=2, legend="Matorral denso",col="darkgreen")


Sd<-apply(tabla[,2:6], 2, sd)
Mean<-apply(tabla[,2:6], 2, mean)
Prop<-(Sd*100)/Mean
resumen<-rbind(Sd,Mean,Prop)

