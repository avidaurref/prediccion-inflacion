# Setting variable
cod        <- "BAXS"
stardate   <- "2013/12/1"
informecsv <- "M-29.csv"
informexls <- "M-29 Activos externos netos de otras sociedades de depósito.xlsx"
filas      <- c(5:277)
columnas   <- c(3:26)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 2, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV3 <- datosV2[seq(-1,-nrow(datosV2),-13),-11]
datosV3 <- datosV3[,c(-20,-21)]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
