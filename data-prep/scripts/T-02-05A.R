library(openxlsx)

# Setting variable
cod        <- "BCPA"
stardate   <- "1998/01/1"
informecsv <- "T-02-05A.csv"
informexls <- "T-02-05A Balance consolidado de bancos comerciales, activo.xlsx"
hoja       <-  2
filas      <- c(13:261)
columnas   <- c(1:16)


# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = hoja, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]

datosV3 <- datosV2[seq(-1,-26,-13),]
rownames(datosV3) <- seq(1:nrow(datosV3))
datosV3 <- datosV3[seq(-37,-nrow(datosV3),-13),]
#datosV3 <- datosV3[seq(0,-nrow(datosV2),-13),]


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
