# Call libraries
library(openxlsx)

# Configurar el directorio del proyecto
setwd("C:/Users/Alvaro/Proyectos/prediccion-inflacion/")

########################
# Limpiar los informes
########################

# Ejecuta un script de limpieza por cada informe
scripts <- list.files("data-prep/scripts")
for (file_name in scripts){
  print(file_name)
  scrip_dir <- (paste0("data-prep/scripts/",file_name))
  source(scrip_dir)
}
rm(list=ls())

##############################
# Unificar todos los informes
##############################

informes    <- list.files("data-prep/clean-data")
informe_dir <- paste0('data-prep/clean-data/', informes[1])
informe_base <- read.csv(informe_dir,header = TRUE)
for (i in 2:length(informes)){
  informe_dir <- paste0('data-prep/clean-data/', informes[i])
  informe_csv <- read.csv(informe_dir,header = TRUE)
  informe_base <- merge(informe_base,informe_csv, id=~MES, all = TRUE)
}

##########################################
# Correccion de los tipos de cada columna
##########################################

informe_base <- informe_base[order(as.Date(informe_base[,1])),]
informe_base[informe_base == 0] <- NA
f  <- colnames(informe_base[sapply(informe_base,is.factor)])
ch <- colnames(informe_base[sapply(informe_base,is.character)])
f <- f[!f=="MES"]
ch <- ch[!ch=="MES"]
for (i in f) {
  informe_base[, i] <- as.numeric(informe_base[, i])
}
for (i in ch) {
  informe_base[, i] <- as.numeric(informe_base[, i])
}

##########################################
# Guardar dataset
##########################################

write.table(informe_base, "info-economia-bolivia.csv",sep = ",", 
            row.names=FALSE, qmethod = "double",na = "")
