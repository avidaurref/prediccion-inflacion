library(openxlsx)

# Setting variable
cod        <- "INFL"
stardate   <- "2008/4/1"
informecsv <- "M-38.csv"
informexls <- "M-38 IPC Base 2007.xlsx"
filas      <- c(7:115)
columnas   <- c(1,39)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV3 <- datosV2[!is.na(datosV2[,2]),]

#datosV3 <- datosV2[seq(0,-nrow(datosV2),-14),]
#datosV3 <- datosV3[seq(-1,-nrow(datosV3),-13),c(-4,-7,-10)]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")
