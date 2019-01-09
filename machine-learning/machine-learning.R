##################################################
# Configurando directorio de trabajo
##################################################

setwd("C:/Users/Alvaro/Proyectos/prediccion-inflacion/")

##################################################
# Librerías requeridas
##################################################

library(openxlsx)  #para leer archivos xls
library(Metrics)   #para calcular errores
library(caret)     #libreria de algoritmos
library(glmnet)    #selección de columnas
library(nnet)

##################################################
# Construir modelo para un rezago de 5 meses
##################################################
param <- c()
param$dir      <- "transform-data/BDATA5.csv"
param$feature  <- 'lasso' # --lasso --pca --none
param$ratio    <- c(100)     # opcion para lasso
param$cost <- c(0.01)

source("machine-learning/scripts/feature-engineer.R")
source("machine-learning/scripts/modelado.R")
saveRDS(modelList[[1]], file = "machine-learning/BMODEL5.rds")

##################################################
# Construir modelo para un rezago de 14 meses
##################################################
param <- c()
param$dir      <- "transform-data/BDATA14.csv"
param$feature  <- 'lasso' # --lasso --pca --none
param$ratio    <- c(100)     # opcion para lasso
param$cost <- c(0.01)

source("machine-learning/scripts/feature-engineer.R")
source("machine-learning/scripts/modelado.R")
saveRDS(modelList[[1]], file = "machine-learning/BMODEL14.rds")

##################################################
# Construir modelo para un rezago de 23 meses
##################################################
param <- c()
param$dir      <- "transform-data/BDATA23.csv"
param$feature  <- 'lasso' # --lasso --pca --none
param$ratio    <- c(90)     # opcion para lasso
param$cost <- c(0.1)

source("machine-learning/scripts/feature-engineer.R")
source("machine-learning/scripts/modelado.R")
saveRDS(modelList[[1]], file = "machine-learning/BMODEL23.rds")

