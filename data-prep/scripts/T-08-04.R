library(openxlsx)

# Setting variable
cod        <- "BZCD"
stardate   <- "1997/01/1"
informecsv <- "T-08-04.csv"
informexls <- "T-08-04 Balanza cambiaria detallada.xlsx"
filas      <- c(5:83)
columnas   <- c(1,3:327)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2[datosV2 == 0] <- NA
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV2 <- datosV2[!is.na(datosV2[,1]),-1]

datosV3 <- as.data.frame(t(datosV2))
datosV3 <- datosV3[rowSums(is.na(datosV3)) != ncol(datosV3),]
datosV3 <- datosV3[seq(-1,-nrow(datosV3),-17),]
datosV3 <- datosV3[seq(0,-nrow(datosV3),-4),]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
