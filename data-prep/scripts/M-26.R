# ------------------
# M-26 Importaciones
# ------------------

library(openxlsx)


dirxls = 'data-prep/raw-data/M-26 Importaciones.xlsx'

datosV1 <- read.xlsx(dirxls, sheet = "CUADRO 25", startRow = 11, colNames =  FALSE, skipEmptyRows = TRUE)
datosV2 <- datosV1[c(11:131),1:18]
datosV3 <- datosV2[seq(-1,-168,-13),]

#Colocar nombres
datosV3[,1]<-seq(as.Date("2003/1/1"), by = "month", length.out = nrow(datosV3))
x <- c()
for(i in 1:ncol(datosV3)-1) {
  if(i < 10){
    x[i] <- paste("SEIM0", i, sep = "")
  }
  else {
    x[i] <- paste("SEIM", i, sep = "")  
  }
}
colnames(datosV3) <- append(c("MES"),x)
#write.xlsx(datosV3, "data-prep/clean-data/M-26.csv")
# Guardar archivo csv
write.table(datosV3,"data-prep/clean-data/M-26.csv",
            sep = ",", row.names=FALSE, qmethod = "double",na = "")


#Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")
#write.xlsx(datosV3, 'foo.xlsx')
