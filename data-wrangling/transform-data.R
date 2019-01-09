##################################################
# Configurando directorio de trabajo
##################################################

setwd("C:/Users/Alvaro/Proyectos/prediccion-inflacion/")

##################################################
# Librerías requeridas
##################################################

library(openxlsx)  #para leer archivos xls
library(lubridate) #para operaciones con fecha
library(Metrics)   #mse
library(caret)    #nzv tree decission
library(forecast) #autoarima missing values
library(pracma) #remove of trend
library(e1071) #libreria de modelo de SVM
library(gbm)
library(randomForest)
library(glmnet)
library(moments)
library(tseries)
library(rpart)
library(nnet)
library(corrplot)
library(outliers)

##################################################
# Conjunto de datos para un rezago de 5 meses
##################################################

meses <- 5
param<-c()

#Feature selection
param$percentageNA       <- 0.05
param$removeOutliers     <- 'N'
param$outlierPvalue      <- 1e-10
param$varianceFilter     <- 'N'
param$uniPercentage      <-  40  
param$removeCorr         <- 'Y'
param$corrFilter         <- 0.9999999999

#Feature construction
param$removeTrend        <- 'Y' #-Y -N
param$adjustVariance     <- 'Y' #-Y -N
param$limitPvalue        <- 0.015
param$smoothSerie        <- 'Y' #-Y -N
param$vacf               <- 0.03

#Feature reduction
param$pcaDescomp         <-  'N'
param$ncomp              <-   58

source("data-wrangling/scripts/baseline.R")
source("data-wrangling/scripts/transform.R")
write.table(datosDP, paste0("data-wrangling/BDATA",meses,".csv"),sep = ",", 
            row.names=FALSE, qmethod = "double",na = "")
rm(list=ls())


##################################################
# Conjunto de datos para un rezago de 14 meses
##################################################

meses <- 14
param<-c()

#Feature selection
param$percentageNA       <- 0.2
param$removeOutliers     <- 'Y'
param$outlierPvalue      <- 1e-13
param$varianceFilter     <- 'N'
param$uniPercentage      <-  40  
param$removeCorr         <- 'Y'
param$corrFilter         <- 0.999

#Feature construction
param$removeTrend        <- 'Y' #-Y -N
param$adjustVariance     <- 'Y' #-Y -N
param$limitPvalue        <- 0.010
param$smoothSerie        <- 'Y' #-Y -N
param$vacf               <- 0.15

#Feature reduction
param$pcaDescomp         <-  'N'
param$ncomp              <-   58

source("data-wrangling/scripts/baseline.R")
source("data-wrangling/scripts/transform.R")
write.table(datosDP, paste0("data-wrangling/BDATA",meses,".csv"),sep = ",", 
            row.names=FALSE, qmethod = "double",na = "")
rm(list=ls())

##################################################
# Conjunto de datos para un rezago de 23 meses
##################################################

meses <- 23
param<-c()

#Feature selection
param$percentageNA       <- 0.5
param$removeOutliers     <- 'Y'
param$outlierPvalue      <- 1e-10
param$varianceFilter     <- 'N'
param$uniPercentage      <-  40  
param$removeCorr         <- 'Y'
param$corrFilter         <- 0.99999999

#Feature construction
param$removeTrend        <- 'Y' #-Y -N
param$adjustVariance     <- 'Y' #-Y -N
param$limitPvalue        <- 0.030
param$smoothSerie        <- 'Y' #-Y -N
param$vacf               <- 0.18

#Feature reduction
param$pcaDescomp         <-  'N'
param$ncomp              <-   58

source("data-wrangling/scripts/baseline.R")
source("data-wrangling/scripts/transform.R")
write.table(datosDP, paste0("data-wrangling/BDATA",meses,".csv"),sep = ",", 
            row.names=FALSE, qmethod = "double",na = "")
rm(list=ls())