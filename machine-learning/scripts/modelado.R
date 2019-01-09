##################################################
# Parámetros
##################################################

# Parametrizacion del proceso
param$splitVal  <- 'N' # --Y --N
param$showError <- 'N' # --Y --N
param$compare   <- 'N' # --Y --N

# Modelos a utilizar 
# opciones: "lasso","ridge","svmLinear","svmRadial","svmPoly","rf","gbm","rpart"
param$optModels <- c("svmLinear")

# Opciones de cada modelo
gridLASSO<- expand.grid(fraction=c(0.9))
gridRIDGE<- expand.grid(lambda=c(0.01))
gridSVML <- expand.grid(C=param$cost)
gridSVMR <- expand.grid(C=c(0.1),sigma=c(0.05))
gridSVMP <- expand.grid(C=c(0.01),scale=c(2),degree=c(3))
gridDT   <- expand.grid(cp=c(0.01))
gridRF   <- expand.grid(mtry = c(30))
gridGBM  <- expand.grid(n.trees = c(10), 
                        interaction.depth = c(3), 
                        shrinkage = c(0.7),
                        n.minobsinnode = c(30) )

##################################################
# Split Training,validation and testing data
##################################################

train <- datosDP

# Separando el 80% de los datos para entrenar
window    <- nrow(train)
iniWindow <- round(window * 0.80, 0)
horWindow <- window - iniWindow 

# Separando el 75% del entrenamiento para validación
if(param$splitVal == "Y"){
  percentageTrain <- 0.8
  numberRowsTrain = round(nrow(datosDP) * percentageTrain, 0)
  index <- c(1:numberRowsTrain)
  train <- datosDP[index,]
  test  <- datosDP[-index,]
  remove(percentageTrain,numberRowsTrain,index)
  
  window    <- nrow(train)
  iniWindow <- round(window * 0.75, 0)
  horWindow <- window - iniWindow 
}

# Para hacer reproducibles los modelos
set.seed(123)
seeds <- vector(mode = "list", length = 2)
for(i in 1:2) seeds[[i]] <- rep(123,50)

# Para entrenar el modelo mediante validacion en
# series de tiempo
fitControl<- trainControl(
  method="timeslice",
  initialWindow=iniWindow, 
  fixedWindow=TRUE, 
  horizon=horWindow,
  savePredictions = "all",
  seeds = seeds
)
rm(window,iniWindow,horWindow,i,seeds)

##################################################
# Modelado
##################################################

modelList<-list()
if(match("lm",param$optModels,nomatch = 0) > 0){
  modelLM <- train(INFL01~., data=train,
                   trControl=fitControl,
                   method="lm")
  modelList <- append(modelList,list(modelLM))
  rm(modelLM)
}
if(match("lasso",param$optModels,nomatch = 0) > 0){
  modelLASSO <- train(INFL01~., data=train,
                      trControl=fitControl,
                      tuneGrid=gridLASSO,
                      method="lasso")
  modelList <- append(modelList,list(modelLASSO))
  rm(modelLASSO)
}
if(match("ridge",param$optModels,nomatch = 0) > 0){
  modelRIDGE <- train(INFL01~., data=train,
                      trControl=fitControl,
                      tuneGrid=gridRIDGE,
                      method="ridge")
  modelList <- append(modelList,list(modelRIDGE))
  rm(modelRIDGE)
}
if(match("svmLinear",param$optModels,nomatch = 0) > 0){
  modelSVML <- train(INFL01~., data=train,
                     trControl=fitControl,
                     tuneGrid=gridSVML,
                     method="svmLinear")
  modelList <- append(modelList,list(modelSVML))
  rm(modelSVML)
}
if(match("svmRadial",param$optModels,nomatch = 0) > 0){
  modelSVMR <- train(INFL01~., data=train,
                     trControl=fitControl,
                     tuneGrid=gridSVMR,
                     method="svmRadial")
  modelList <- append(modelList,list(modelSVMR))
  rm(modelSVMR)
}
if(match("svmPoly",param$optModels,nomatch = 0) > 0){
  modelSVMP <- train(INFL01~., data=train,
                     trControl=fitControl,
                     tuneGrid=gridSVMP,
                     method="svmPoly")
  modelList <- append(modelList,list(modelSVMP))
  rm(modelSVMP)
}
if(match("rpart",param$optModels,nomatch = 0) > 0){
  modelDT <- train(INFL01~., data=train,
                   trControl=fitControl,
                   tuneGrid=gridDT,
                   method="rpart")
  modelList <- append(modelList,list(modelDT))
  rm(modelDT)
}
if(match("rf",param$optModels,nomatch = 0) > 0){
  modelRF <- train(INFL01~., data=train,
                   trControl=fitControl,
                   tuneGrid=gridRF,
                   method="rf")
  modelList <- append(modelList,list(modelRF))
  rm(modelRF)
}
if(match("gbm",param$optModels,nomatch = 0) > 0){
  modelGBM <- train(INFL01~., data=train,
                    trControl=fitControl,
                    tuneGrid=gridGBM,
                    method="gbm")
  modelList <- append(modelList,list(modelGBM))
  rm(modelGBM)
}

rm(gridLASSO,gridRIDGE,
   gridSVML,gridSVMP,gridSVMR,
   gridRF,gridDT,gridGBM,fitControl)

##################################################
# Calcular MSE, VAR y R2
##################################################

if(param$showError == "Y"){
  
  # Vectores donde se guardan los errores
  #errorList <- list()
  errores <- data.frame("reduction"=character(1),"method"=character(1),"error"=numeric(1),
                        "var"=numeric(1),"r2"=numeric(1),stringsAsFactors = FALSE)
  
  # Recopilación errores 
  for(m in modelList){
    
    until <- ncol(m$pred) - 1 
    resultSplit <- split(m$pred,m$pred[4:until])
    
    # Recopilar los errores de las pruebas del modelo
    for (i in resultSplit){
      # Nombres de los parametros
      namepar <- ""
      for(a in c(4:until)){
        namepar <- paste0(namepar,paste0(paste(names(i[a]),i[1,a]),","))
      }
      testvalue <- paste(m$method,"|")
      title <- paste0(testvalue,namepar)
      
      # Calculo de los errores
      error<-mse(i$obs,i$pred)
      var<-var(i$pred)
      r2<-cor(i$obs,i$pred)^2
      errores<-rbind(errores,c(param$title,title,error,var,r2))
      
      # Ploteo de las predicciones
      title <- paste(m$method,namepar)
      if(param$title != ""){
        title <- paste(param$title,title)  
      }
      plot(i$obs,type = "l",main=title)
      lines(i$pred,col="red")
    }
    
    #errorList[[m$method]] <- errores  
  }
  rm(a,i,error,m,namepar,r2,resultSplit,testvalue,var,title,until)
  errores <- errores[-1,]
  View(errores)
}

##################################################
# Comparar resultados
##################################################

if(param$compare == "Y"){
  compare <- data.frame(no = c(1:nrow(modelList[[1]]$pred)))
  for(m in modelList){
    compare[[m$method]]<-m$pred$pred
  }
  compare<-compare[,-1]
  View(compare)
  View(cor(compare))
}