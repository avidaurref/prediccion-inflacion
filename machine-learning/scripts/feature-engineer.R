##################################################
# Datas Source
###################################################
datosBL <- read.csv(param$dir,header = TRUE)

##################################################
# Parameter for Feature Enginneer
###################################################

param$ncomp    <- c(80)      # opcion para pca
param$title    <- "none"
param$evalMode <- 'N'     # --Y --N

##################################################
# Feature Enginneer
###################################################

datosDP <- datosBL

if(param$feature == "lasso"){
  
  evalFtrError <- data.frame("reduction"=character(1),"method"=character(1),"error"=numeric(1),
                             "var"=numeric(1),"r2"=numeric(1),stringsAsFactors = FALSE)
  
  x <- data.matrix(datosBL[,!(names(datosBL) %in% c("INFL01"))])
  y <- datosBL$INFL01  
  flasso <- glmnet(x, y, alpha=1)
  rm(x,y)
  
  for (r in param$ratio) {
    
    param$title <- paste0(r)
    sl <- flasso$lambda[r]
    coef <- predict(flasso,type = "coefficients",s=sl)[1:ncol(datosBL),]
    coef<-abs(coef[coef!=0])
    coef["(Intercept)"]<-NA
    fselect <- names(na.omit(coef))
    fselect <- append(fselect,"INFL01")
    
    datosDP<-datosBL[fselect]
    
    if(param$evalMode == "Y"){
      ### Train Model
      source(paste0(param$fileDir,'Modelado/C02 Modelado.R'))
      ### Join error
      evalFtrError <- rbind(evalFtrError,errores)
    }
  }
  
  rm(fselect,coef,sl,flasso,r)
}

if(param$feature == "pca"){
  
  evalFtrError <- data.frame("reduction"=character(1),"method"=character(1),"error"=numeric(1),
                             "var"=numeric(1),"r2"=numeric(1),stringsAsFactors = FALSE)
  
  pmatrix <- as.matrix(datosBL[,!(names(datosBL) %in% c("INFL01"))])
  princ   <- prcomp(pmatrix,scale = FALSE)
  dfComponents <- predict(princ, newdata=pmatrix)
  
  for (n in param$ncomp) {
    param$title <- paste0(n)
    datosDP <- cbind(as.data.frame(dfComponents[,1:n]),INFL01 = datosBL$INFL01)
    if(param$evalMode == "Y"){
      ### Train Model
      source(paste0(param$fileDir,'Modelado/C02 Modelado.R'))
      ### Join error
      evalFtrError <- rbind(evalFtrError,errores)
    }
  }
  
  rm(n,princ,dfComponents,pmatrix)
}

if(param$evalMode == "Y"){
  evalFtrError <- evalFtrError[-1,c(-4,-5)]
  evalFtrError <- reshape(evalFtrError,direction="wide",idvar="reduction",timevar="method")
  View(evalFtrError)
}