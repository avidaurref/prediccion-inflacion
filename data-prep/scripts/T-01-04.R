library(openxlsx)

# Setting variable
cod        <- "AMMC"
stardate   <- "1998/1/1"
informecsv <- "T-01-04.csv"
informexls <- "T-01-04 Destino del medio circulante y de la liquidez total.xlsx"
filas      <- c(21:268)
columnas   <- c(1:19)
filasB     <- c(290:537)
columnasB  <- c(1:19)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV3A <- datosV2[seq(0,-nrow(datosV2),-13),]

datosV2B <- datosV1[filas,columnas]
datosV2B <- datosV2B[rowSums(is.na(datosV2B)) != ncol(datosV2B),]
datosV3B <- datosV2B[seq(0,-nrow(datosV2B),-13),-1]

datosV3<- as.data.frame(append(datosV3A,datosV3B))

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")
