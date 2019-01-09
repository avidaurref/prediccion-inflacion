##################################################
# Configurando directorio de trabajo
##################################################

setwd("C:/Users/Alvaro/Proyectos/prediccion-inflacion/")

##################################################
# Librerías requeridas
##################################################

library(openxlsx)  # para leer archivos xls
library(lubridate) # para operaciones con fecha
library(forecast)  # autoarima missing values
library(caret)     # utilizacion de modelos
library(outliers)  # test de chi-square
library(pracma)    # remove of trend
library(data.table)# calcs data table
library(ggplot2)   # calcs data table
library(scales)

##################################################
# Configuracion
##################################################

dirRoot <- getwd()
fileInfo      <- "/data-prep/"
fileEconomia <- "info-economia-bolivia.csv"
fileModels  <- "/machine-learning/"
filePrediction  <- "/prediction/"
modelosCortoPlazo   <- c('BMODEL5.rds')
modelosMedianoPlazo <- c('BMODEL14.rds')
modelosLargoPlazo   <- c('BMODEL23.rds')
fileLib      <- "/prediction/scripts/"

source(paste0("prediction/scripts/base.R"))
