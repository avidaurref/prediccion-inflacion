library(openxlsx)

# Setting variable
cod        <- "STBL"
stardate   <- "1997/1/1"
informecsv <- "M-32.csv"
informexls <- "M-32 Bolsin Principales Indicadores.xlsx"
filas      <- c(10:278)
columnas   <- c(1:19)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV3 <- datosV2[seq(0,-nrow(datosV2),-14),]
datosV3 <- datosV3[seq(-1,-nrow(datosV3),-13),c(-2,-8,-10,-12,-18,-17)]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")
