###########################
# Declaración de parámetros
###########################
# Direcciones
dirLib <- paste0(dirRoot,fileLib)
dirInfo <- paste0(dirRoot,fileInfo)
dirModel <- paste0(dirRoot,fileModels)
dirPrediction <- paste0(dirRoot,filePrediction)
# Declaración variables
rezagos <- c()
rezagos$cortoPlazo   <- c()
rezagos$medianoPlazo <- c()
rezagos$largoPlazo   <- c()
# Corto plazo
rezagos$cortoPlazo$nombre   <- 'CortoPlazo-05'
rezagos$cortoPlazo$meses    <- 5
rezagos$cortoPlazo$models   <- modelosCortoPlazo
rezagos$cortoPlazo$ensemble <- 'CP-STACK.rds'
rezagos$cortoPlazo$outlier  <- 0
rezagos$cortoPlazo$varianza <- 0.015
rezagos$cortoPlazo$ruido    <- 0.03
# Mediano plazo
rezagos$medianoPlazo$nombre   <- 'MedianoPlazo-14'
rezagos$medianoPlazo$meses    <- 14
rezagos$medianoPlazo$models   <- modelosMedianoPlazo
rezagos$medianoPlazo$ensemble <- 'MP-STACK.rds'
rezagos$medianoPlazo$outlier  <- 1e-13
rezagos$medianoPlazo$varianza <- 0.010
rezagos$medianoPlazo$ruido    <- 0.15
# Largo plazo
rezagos$largoPlazo$nombre   <- 'LargoPlazo-23'
rezagos$largoPlazo$meses    <- 23
rezagos$largoPlazo$models   <- modelosLargoPlazo
rezagos$largoPlazo$ensemble <- ''
rezagos$largoPlazo$outlier  <- 1e-10
rezagos$largoPlazo$varianza <- 0.030
rezagos$largoPlazo$ruido    <- 0.18

#####################################
# Lectura de las variables económicas
#####################################
infoecobol <- read.csv(file=paste0(dirInfo,fileEconomia),header = TRUE)
#infoecobol$MES<-as.Date(infoecobol$MES)
infoecobol <- infoecobol[!is.na(infoecobol$INFL01),]
infoecobol<-infoecobol[order(infoecobol$MES),]

####################################
# Predicción
####################################

fini01 <- infoecobol$MES[1]
fechaInicio <- fini01
#fechaInicio <- paste(c(substr(fini01,1,4),substr(fini01,5,6),"01"),collapse = "-")
seqFechas <- seq(as.Date(fechaInicio), by = "month", length.out = nrow(infoecobol))
fechaFin <- seqFechas[length(seqFechas)]
predicciones <- list()

# rezago <- rezagos[[1]]
for(rezago in rezagos){
  
  # Parametros para cada rezago
  nombre        <- rezago$nombre
  meses         <- rezago$meses
  outlierPvalue <- rezago$outlier
  limitPvalue   <- rezago$varianza
  valueacf      <- rezago$ruido
  models        <- rezago$models
  ensemble      <- rezago$ensemble
  nameModel     <- models[1]
  
  
  predModel <- data.frame(MES = (seqFechas + months(meses)) )
  
  # Preparacion de los datos
  source(paste0(dirLib,'preparation.R'))
  
  # Obtener las predicciones de los modelos
  for(m in models){
    nameModel  <- paste0(dirModel,m)
    model      <- readRDS(nameModel)
    
    pred       <- predict(model,newdata=datosDP)
    predModel[[model$method]]  <- pred 
  }
  #predModel <- predModel[,-1]
  
  predModel <- data.frame(MES = (seqFechas + months(meses)) )
  predModel[[paste0('REZAGO',meses)]] <- pred
  predicciones[[nombre]] <- predModel
  
}

#predicciones
proyeccion <- merge(predicciones[[1]],predicciones[[2]],by='MES', all.y = TRUE)
proyeccion <- merge(proyeccion,predicciones[[3]],by='MES', all.y = TRUE)
proyeccion <- proyeccion[proyeccion[,'MES']>fechaFin, ]

#Unir modelos
proyeccion[,2][is.na(proyeccion[,2])] <- proyeccion[,3][is.na(proyeccion[,2])]
proyeccion[,2][is.na(proyeccion[,2])] <- proyeccion[,4][is.na(proyeccion[,2])]
proyeccion <- proyeccion[,c(1,2)]

#calculo de la inflacion anual acumulada
res <- data.frame(
  MES=c(seqFechas,proyeccion$MES),
  YEAR = substr(as.character(c(seqFechas,proyeccion$MES)),1,4),
  MONTH = substr(as.character(c(seqFechas,proyeccion$MES)),6,7),
  INFL=c(infoecobol$INFL01,proyeccion[,2])
)
DT <- data.table(res)
DT[, Cum.Sum := cumsum(INFL), by=list(YEAR)]
DT<-DT[DT[,MES]>fechaFin,]
pred <- as.data.frame(DT)
colnames(pred)<-c('MES','YEAR','MONTH','INFMENSUAL','INFACUMULADA')

#Guardar datos
write.table(pred[,-1], paste0(dirPrediction,"proyeccion.csv"),sep = ",", 
            row.names=FALSE, qmethod = "double",na = "")

####################################
# Graficas de la predicción
####################################


#Graficar proyección anual aumulada
ggplot(pred, aes(x=MES,y=INFACUMULADA)) +
  geom_bar(stat = "identity",position = "dodge", fill="darkblue") +
  ggtitle("Inflación acumulada anual proyectada") +
  geom_text(aes(label=paste0(round(INFACUMULADA,2),"%")), 
            position=position_dodge(width=0.7), vjust=-0.55)+
  theme(plot.title = element_text(lineheight=.8, face="bold", size = 20))+
  (scale_x_date(breaks = date_breaks("2 months"),labels = date_format("%b %y"))) +
  ylab("inflación acumulada") + xlab("Mes")
ggsave(paste0(dirPrediction,"infacumulada.png"), width = 32, height = 20, units = "cm")

#Graficar proyección mensual
ggplot(pred, aes(MES,INFMENSUAL)) +
  geom_line(color="blue",size=1,position=position_dodge(width=0)) +
  geom_point() + 
  ggtitle("Inflación mensual proyectada") +
  geom_text(aes(label=paste0(round(INFMENSUAL,2),"%")), 
            position=position_dodge(width=0.7), vjust=-0.55)+
  theme(plot.title = element_text(lineheight=.8, face="bold", size = 20))+
  (scale_x_date(breaks = date_breaks("2 months"),labels = date_format("%b %y"))) +
  ylab("Inflación mensual") + xlab("Mes")
ggsave(paste0(dirPrediction,"infmensual.png"), width = 32, height = 20, units = "cm")

print("Proceso concluido correctamente")
