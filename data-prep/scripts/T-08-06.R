library(openxlsx)

# Setting variable
cod        <- "SIED"
stardate   <- "1997/01/1"
informecsv <- "T-08-06.csv"
informexls <- "T-08-06 Egreso de divisas.xlsx"
hoja       <-  1
filas      <- c(49:322)
columnas   <- c(2:17)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = hoja, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2 <- datosV1[filas,columnas]
datosV2[datosV2 == 0] <- NA
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
rownames(datosV2)<-seq(1:nrow(datosV2))
colnames(datosV2)<-seq(1:ncol(datosV2))

#datosV3 <- datosV2[seq(-125,-130),-9]
datosV3 <- datosV2[seq(-1,-nrow(datosV2),-13),c(-12,-15)]


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
