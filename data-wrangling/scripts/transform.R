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
# Tiempo
##################################################
fechaFinal <- "2015-12-01"
cantMeses <- nrow(datosBL)
fechaInicial <-  as.Date(fechaFinal) - months(meses+cantMeses-1)
tiempoDim <- seq(as.Date(fechaInicial), by = "month", length.out = cantMeses)
remove(fechaFinal,cantMeses,fechaInicial)

##################################################
# Parameters
##################################################

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

##################################################
# Sin modificaciones
##################################################
nulos   <- colMeans(is.na(datosBL))
datosV0 <- datosBL[nulos <= 0]

##################################################
# Remplazo de valores faltantes
##################################################

#param$percentageNA       <- 0.05
nulos   <- colMeans(is.na(datosBL))
datosV1 <- datosBL[nulos <= param$percentageNA]
naColumns <- colnames(datosV1)[colMeans(is.na(datosV1)) > 0]
hist.vacios<-hist(nulos[nulos>0],main="Porcentaje de nulos", 
                  breaks = 10, xlab = "", ylab = "Frecuencia", col="cyan")

if(param$percentageNA > 0){
  for(col in naColumns) {
    print(col)
    
    #establecimiento de variables
    x <- as.numeric(datosV1[,col])
    y <- x
    
    id.na <- which(is.na(x))
    id.na2 <- id.na
    
    #remplazo de valores iniciales
    x2 <- 1:length(y)
    fitL <- lm(y~poly(x2,3))
    co = 0
    if(id.na[1]==1){
      for (i in id.na){
        co = co + 1
        if(i==co) { y[i] <- predict(fitL,data.frame(x2=i))  
        } else{ break }
      }
    }
    
    id.na <- which(is.na(y))
    #modelo autoregresivo
    fit <- auto.arima(y)
    kr <- KalmanRun(y, fit$model)
    for (j in id.na){
      if ( j == 1){ y[j] <- predict(fitL,data.frame(x2=j))}
      else{ y[j] <- fit$model$Z %*% kr$states[j,] }
    }
    datosV1[,col]<-y
    
  }
  remove(x,y,kr,id.na,j,co,fit,fitL,x2,col)
}

remove(naColumns,nulos,hist.vacios)

##################################################
# Valores atipicos
##################################################

#param$outlierPvalue      <- 1e-15
datosV2<-datosV1

if(param$removeOutliers == "Y"){
  
  #buscando outliers
  outlierVars <- colnames(datosV2[,!(names(datosV2) %in% c("INFL01"))])
  outColumns<-c()
  for (col in outlierVars) {
    p <- chisq.out.test(datosV2[,col],variance=var(datosV2[,col]))
    outColumns[col]<-p$p.value
  }
  
  #outliers encontrados
  colOutliers <- names(outColumns[outColumns<param$outlierPvalue])
  hist(outColumns[outColumns<0.1],col='green',main="Test-Chi-Square")
  #hist(outColumns,col='green',main="Test-Chi-Square")
  for (col in colOutliers) {
    jpeg(file=paste(mypath,"/Outliers/",colnames(datosV2[col]),'.jpg',sep=""))
    plot(datosV2[,col],type="l")
    title(main=colnames(datosV2[col]),sub=col)
    dev.off()
  }
  
  #remplazo de valores atipicos
  while(length(outlierVars) > 0) {
    print(length(outlierVars))
    outColumns<-c()
    for (col in outlierVars) {
      p <- chisq.out.test(datosV2[,col],variance=var(datosV2[,col]))
      outColumns[col]<-p$p.value
    }
    outlierVars <- names(outColumns[outColumns<param$outlierPvalue])
    
    #eliminando outliers
    for (col in outlierVars) {
      pointOutliers<-outlier(datosV2[,col], logical = TRUE)
      datosV2[pointOutliers,col]<-NA
    }
    
    #remplazando outliers
    for(col in outlierVars) {
      x <- as.numeric(datosV2[,col])
      y <- x
      
      fit <- auto.arima(x)
      kr <- KalmanRun(x, fit$model)
      id.na <- which(is.na(x))
      for (i in id.na){
        y[i] <- fit$model$Z %*% kr$states[i,]  
      }
      datosV2[,col]<-y
    }
  }
}


##################################################
# Eliminación de valores con poca varianza
##################################################

#param$uniPercentage      <-  40
datosV3<-datosV2
nzv <- nearZeroVar(datosV2, saveMetrics = TRUE)

#plot
hist.unicos<-hist(nzv[nzv$percentUnique<100,]$percentUnique,
                  breaks = 20, main="Varianza de las variables", 
                  xlab = "Porcentaje de datos únicos",ylab = "Frecuencia", col="purple")

if(param$varianceFilter == "Y"){
  nzv <- nearZeroVar(datosV2, saveMetrics = TRUE)
  
  #plot
  #hist.unicos<-hist(nzv[nzv$percentUnique<100,]$percentUnique,
  #  breaks = 20, main="Varianza de las variables", 
  #  xlab = "Porcentaje de datos únicos",ylab = "Frecuencia", col="purple")
  
  #remove cols with percenta
  datosV3 <- datosV2[c(rownames(nzv[nzv$percentUnique < param$uniPercentage,])) ]
  remove(nzv,hist.unicos)  
}


##################################################
# Eliminación de valores idénticos
##################################################

#param$corrFilter         <- 0.9999999999
datosV4<-datosV3

if(param$removeCorr == "Y"){
  
  datosCorr <- datosV3
  #plot
  hist.cor<-hist(cor(datosV4),main = "Histograma de correlaciones",
                 xlab="Correlaciones",breaks = 40, col="orange",prob=FALSE)
  lines(density(cor(datosCorr)))
  
  datosCorr$INFL01<- NULL
  highlyCor <- findCorrelation(cor(datosCorr),param$corrFilter)
  datosV4 <- datosV3[,-highlyCor]
  remove(datosCorr,highlyCor,hist.cor)
}

##################################################
# Eliminación de tendencia
##################################################

datosV6 <- datosV4

if (param$removeTrend == 'Y'){
  nameColumns <- colnames(datosV4[,!(names(datosV4) %in% c("INFL01"))])
  for(col in nameColumns) {
    fit <- detrend(datosV6[,col],"linear")
    datosV6[,col] <- fit
  }
  remove(fit,col,nameColumns)
}
hist.cor<-hist(cor(datosV6),main = "Tendencia eliminada",
               xlab="Correlaciones",breaks = 40, col="yellow",prob=FALSE)


##################################################
# Ajuste de varianza
##################################################

# param$limitPvalue        <- 0.015
datosV7 <- datosV6

if (param$adjustVariance == 'Y'){
  
  datosV7$INFL01<-NULL
  nameColumns<-c()
  adjColumns<-c()
  
  #test of zaphiro
  for(col in 1:ncol(datosV7)) {
    serie<-as.vector(datosV7[,col])
    testStationary<-shapiro.test(serie)
    adjColumns[col]<-testStationary$p.value
    if(testStationary$p.value>param$limitPvalue){
      nameColumns<-c(nameColumns,colnames(datosV7)[col])
    }
  }
  
  #plot
  hist(adjColumns[adjColumns<0.1],col='brown',main="Test-Shapiro", breaks = 20)
  
  #box cox transformation
  for(col in nameColumns) {
    lambda = BoxCox.lambda(datosV6[,col])
    fit = BoxCox(datosV6[,col],lambda)
    datosV7[,col] <- fit
  }
  
  datosV7<-cbind(datosV7,INFL01=datosV6$INFL01)
  
}


##################################################
# Suavización lineal
##################################################

#param$vacf               <- 0.03
datosV8<-datosV7
datosV8$INFL01<-NULL

nameColumns<-c()
acfColumns<-c()

if (param$adjustVariance == 'Y'){
  for(col in 1:ncol(datosV8)) {
    serie<-acf(datosV8[,col],plot=FALSE)
    vacf<-max(abs(serie$acf[-1]))
    acfColumns[col]<-vacf
    if(vacf<param$vacf){
      nameColumns<-c(nameColumns,colnames(datosV7)[col])
    }
  }
  
  #plot
  hist(acfColumns[acfColumns<0.2],col='dodgerblue',main="Autocorrelación", breaks = 20)
  
  
  for(col in nameColumns) {
    print(col)
    fit <- smooth(datosV7[,col], "3R")
    datosV8[,col] <- fit
  }
  datosV8<-cbind(datosV8,INFL01=datosV7$INFL01)
  
  remove(fit,col,vacf,serie,nameColumns)
}

##################################################
# Normalización
##################################################

datosV9 <- datosV8
datosV9$INFL01<- NULL
datosNorm <- as.data.frame(scale(datosV9))
datosV9 <-cbind(datosNorm,INFL01=datosV8$INFL01)
remove(datosNorm)

##################################################
# PCA
###################################################
param$ncomp              <-   60
pmatrix <- as.matrix(datosV9[,!(names(datosV9) %in% c("INFL01"))])
princ   <- prcomp(pmatrix,scale = FALSE)
sumprinc<- summary(princ)
flprinc <- sumprinc$importance
colnames(flprinc)<-c(1:ncol(flprinc))
barplot(flprinc[3,],col='sienna1',main="PCA"
        ,xlab="Componentes",ylab="Representación")
datosV10 <- datosV9
if (param$pcaDescomp == 'Y'){
  dfComponents <- predict(princ, newdata=pmatrix)[,1:param$ncomp]
  datosV10 <- cbind(as.data.frame(dfComponents),INFL01 = datosV9$INFL01)
}

##################################################
# Output
##################################################

datosDP<-datosV10
