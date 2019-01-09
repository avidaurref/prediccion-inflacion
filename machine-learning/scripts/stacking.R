##################################################
# Parameter
##################################################
# Modelos a utilizar 
# opciones: "lasso","ridge","svmLinear","svmRadial","svmPoly","rf","gbm","rpart"
modelSel <- c("lasso","ridge")
param$ensemble <- "Y"

##################################################
# Obtener las predicciones del entrenamiento
##################################################

count = 1
for(m in modelList){
  
  resModel<-m$pred[,c("rowIndex","Resample","pred")]
  colnames(resModel)<-c("rowIndex","Resample",m$method)
  if(count!=1){
    resultTrain<-merge(resultTrain,resModel,by=c("rowIndex","Resample"))  
  }else{
    resultTrain<-resModel
  }
  count = count + 1
  
}

obs<-data.frame(rowIndex=c(1:nrow(train)), INFL01=train$INFL01)
resultTrain<-merge(resultTrain,obs,by="rowIndex")
resultTrain$rowIndex<-NULL
resultTrain$Resample<-NULL

rm(obs,resModel,count,m)

##################################################
# Calcular MSE,VAR y R2 del Testing
##################################################

# Data frames para guardar los errores y las predicciones
errorRTest <- data.frame("model"=character(1),"error"=numeric(1),
                         "var"=numeric(1),"r2"=numeric(1),stringsAsFactors = FALSE)
resultTest <- data.frame(no = c(1:nrow(test)))

for(m in modelList){
  
  # Solamente calcular los errores de los parametros realizados
  if(match(m$method,modelSel,nomatch = 0) > 0){
    
    #prediction
    pred <-  predict(m,newdata=test[,!(names(test) %in% c("INFL01"))])
    resultTest[[m$method]] <- pred
    
    if(param$ensemble != "Y"){
      
      #save errors
      error <- mse(pred,test$INFL01)
      var   <- var(pred)
      r2    <- cor(pred,test$INFL01) ^ 2
      errorRTest <- rbind(errorRTest,c(m$method,error,var,r2))
      
      #plot results
      plot(test$INFL01,type = "l",main=m$method)
      lines(pred,col="red")      
    }
    
    
    
  }
}
rm(error,m,pred,r2,var)

resultTest <- resultTest[,-1]
resultTest[["INFL01"]] <- test$INFL01

#View(errorRTest)
#View(cor(resultTest))


##################################################
# Testing sub results
##################################################

if(param$ensemble == "Y"){
  
  #combinations
  colSel <- modelSel[!modelSel %in% c('INFL01')]
  combModels <- c()
  for(i in c(2:length(colSel))){
    x <- combn(colSel,i,simplify = FALSE)
    combModels <- c(combModels,x)
  }
  
  for(l in combModels){
    info<-paste(l,collapse = "+")
    l <- append(l,'INFL01')
    modelEns <- glm(INFL01 ~ ., data = resultTrain[,l])
    resultTestSel <- resultTest[,l]
    #predEns  <- predict(modelEns,newdata=resultTest[,!(names(resultTest) %in% c("INFL01"))])
    predEns  <- predict(modelEns,
                        newdata=resultTestSel[,!(names(resultTestSel) %in% c("INFL01"))])
    resultTest[[info]]<-predEns
    
    errorEns <- mse(test$INFL01, predEns)
    varEns   <- var(predEns)
    r2Ens    <- cor(test$INFL01, predEns) ^2
    nameTitle <- paste(colnames(resultTestSel[,!(names(resultTestSel) %in% c("INFL01"))]), 
                       collapse = '+')
    errorRTest <- rbind(errorRTest,c(nameTitle,errorEns,varEns,r2Ens))
    
    plot(test$INFL01,type = "l",main=nameTitle)
    lines(predEns,col="red")
    
  }
}

errorRTest <- errorRTest[-1,]
View(errorRTest)
View(resultTest)

#saveRDS(modelList[[1]], file = "mymodel.rds")
#readRDS("mymodel.rds")
