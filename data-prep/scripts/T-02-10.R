# Setting variable
cod        <- "BCDA"
stardate   <- "1998/01/1"
informecsv <- "T-02-10.csv"
informexls <- "T-02-10 Balance consolidado del banco de desarrollo productivo, activo y pasivo.xlsx"
filasA     <- c(11:258)
columnasA  <- c(1:10)
filasB     <- c(13:260)
columnasB  <- c(1,23:27)


# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")

datosV1A <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2A <- datosV1A[filasA,columnasA]
datosV2A <- datosV2A[rowSums(is.na(datosV2A)) != ncol(datosV2A),]
datosV3A <- datosV2A[seq(-1,-nrow(datosV2A),-13),-2]

datosV1B <- read.xlsx(dirxls, sheet = 2, startRow = 1, detectDates = TRUE,
                      colNames =  FALSE, skipEmptyRows = FALSE)

datosV2B <- datosV1B[filasB,columnasB]
datosV2B <- datosV2B[rowSums(is.na(datosV2B)) != ncol(datosV2B),]
datosV3B <- datosV2B[seq(-1,-nrow(datosV2B),-13),-1]

datosV3<- as.data.frame(append(datosV3A,datosV3B))


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
