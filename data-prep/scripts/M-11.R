# ------------------
# M-11 Captaciones
# ------------------
cod = "BPCR"


dirxls = 'data-prep/raw-data/M-11 Crédito al sector privado.xlsx'

datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 52, colNames =  FALSE, skipEmptyRows = TRUE)
datosV2 <- datosV1[c(1:137),1:12]
datosV3 <- datosV2[seq(-8,-137,-13),-11]

#Colocar nombres
datosV3[,1]<-seq(as.Date("2005/6/1"), by = "month", length.out = nrow(datosV3))
x <- c()
for(i in 1:ncol(datosV3)-1) {
  if(i < 10){
    x[i] <- paste(paste(cod, "0", sep = ""), i, sep = "")
  }
  else {
    x[i] <- paste(cod, i, sep = "")  
  }
}
colnames(datosV3) <- append(c("MES"),x)
write.table(datosV3, "data-prep/clean-data/M-11.csv", sep = ","
            ,row.names=FALSE, qmethod = "double", na = "")
#Sys.setenv(R_ZIPCMD= "C:/Rtools/bin/zip")
#write.xlsx(datosV3, 'foo.xlsx')
