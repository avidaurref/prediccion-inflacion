library(openxlsx)  #para leer archivos xls
library(lubridate) #para operaciones con fecha
library(Metrics)   #mse
library(caret)    #nzv tree decission

# Read data
ecovariables <- read.csv("data-prep/info-economia-bolivia.csv",header = TRUE)
inflacion    <- ecovariables[,c("MES","INFL01")]
inflacion <- inflacion[!is.na(inflacion$INFL01),]
ecovariables$INFL01 <- NULL

# Limpieza de datos
datosV1  <- ecovariables
datosV2  <- datosV1[,colSums(is.na(datosV1))< nrow(datosV1)] # Drop empty columns
datosV3  <- datosV2[!duplicated(lapply(datosV2,summary))]    # Drop duplicated columns
datosECO <- datosV3
rm(datosV1,datosV2,datosV3)

# Armar conjunto de datos
datosINF     <- inflacion
datosINF$MES <- as.Date(datosINF$MES) - months(meses)
datosECO$MES <- as.Date(datosECO$MES)
datosV1      <- merge(datosECO,datosINF, id=~MES)
datosV1$MES  <- NULL

rm(datosINF,datosECO,ecovariables,inflacion)

# Limpieza de datos
datosV2 <- datosV1[,colSums(is.na(datosV1))< nrow(datosV1)] # Drop empty columns
datosV3 <- datosV2[!duplicated(lapply(datosV2,summary))]    # Drop duplicated columns

# Eliminación de valores constantes
nzv <- nearZeroVar(datosV3, saveMetrics = TRUE)
datosV4 <- datosV3[c(rownames(nzv[nzv$zeroVar==FALSE,])) ]
remove(nzv)

datosBL <- datosV4
rm(datosV1,datosV2,datosV3,datosV4)
