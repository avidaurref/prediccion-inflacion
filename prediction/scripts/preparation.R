####################################
# Predicción
####################################

# Obtener el conjunto de datos a predecir
m       <- readRDS(paste0(dirModel,nameModel))
cols    <- colnames(m$trainingData)
cols    <- cols[!cols %in% ".outcome"]
datosBL <- infoecobol[,cols]
rm(cols)

####################################
# Tratamiento de valores faltantes
####################################

datosV1   <- datosBL
nulos     <- colMeans(is.na(datosV1))
naColumns <- colnames(datosBL[nulos>0]) 

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

remove(x,y,kr,id.na,j,co,fit,fitL,x2,col,id.na2)
rm(naColumns,nulos)

##################################################
# Valores atipicos
##################################################

datosV2 <- datosV1

#buscando outliers
outlierVars <- colnames(datosV2[,!(names(datosV2) %in% c("INFL01"))])
outColumns<-c()
for (col in outlierVars) {
  p <- chisq.out.test(datosV2[,col],variance=var(datosV2[,col]))
  outColumns[col]<-p$p.value
}

#outliers encontrados
colOutliers <- names(outColumns[outColumns<outlierPvalue])

#remplazo de valores atipicos
while(length(outlierVars) > 0) {
  outColumns<-c()
  for (col in outlierVars) {
    p <- chisq.out.test(datosV2[,col],variance=var(datosV2[,col]))
    outColumns[col]<-p$p.value
  }
  outlierVars <- names(outColumns[outColumns<outlierPvalue])
  
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
#remove(outlierVars,outColumns,pointOutliers,i,x,y,fit,kr,id.na,p,col,colOutliers)
#rm(outlierPvalue)

####################################
# Eliminación de tendencia
####################################
datosV3 <- datosV2

nameColumns <- colnames(datosV3[,!(names(datosV3) %in% c("INFL01"))])
for(col in nameColumns) {
  fit <- detrend(datosV3[,col],"linear")
  datosV3[,col] <- fit
}
#remove(fit,col,nameColumns)

##################################################
# Ajuste de varianza
##################################################

datosV4     <- datosV3
#limitPvalue <- 0.030

nameColumns<-c()
adjColumns<-c()

#test of zaphiro
for(col in 1:ncol(datosV4)) {
  serie<-as.vector(datosV4[,col])
  testStationary<-shapiro.test(serie)
  adjColumns[col]<-testStationary$p.value
  if(testStationary$p.value>limitPvalue){
    nameColumns<-c(nameColumns,colnames(datosV4)[col])
  }
}

#box cox transformation
for(col in nameColumns) {
  lambda = BoxCox.lambda(datosV3[,col])
  fit = BoxCox(datosV3[,col],lambda)
  datosV4[,col] <- fit
}

#remove(fit,col,lambda,testStationary,serie,nameColumns,adjColumns,limitPvalue)

##################################################
# Suavización lineal
##################################################

datosV5  <- datosV4
#valueacf <- 0.18

nameColumns<-c()
acfColumns<-c()

for(col in 1:ncol(datosV5)) {
  serie<-acf(datosV5[,col],plot=FALSE)
  vacf<-max(abs(serie$acf[-1]))
  acfColumns[col]<-vacf
  if(vacf<valueacf){
    nameColumns<-c(nameColumns,colnames(datosV4)[col])
  }
}
for(col in nameColumns) {
  #print(col)
  fit <- smooth(datosV4[,col], "3R")
  datosV5[,col] <- fit
}
#remove(fit,col,valueacf,serie,nameColumns,acfColumns)


##################################################
# Normalización
##################################################

datosDP <- datosV5
datosDP <- as.data.frame(scale(datosV5))