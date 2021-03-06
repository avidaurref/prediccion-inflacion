library(openxlsx)

# Setting variable
cod        <- "AMOL"
stardate   <- "1998/1/1"
informecsv <- "T-01-02.csv"
informexls <- "T-01-02 Origen de liquidez total.xlsx"
filas      <- c(22:271)
columnas   <- c(1:13)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 2, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV2[,1]<-ifelse(is.na(datosV2[,1]),datosV2[,2],datosV2[,1])
datosV2 <- datosV2[!is.na(datosV2[,1]),]

datosV3 <- datosV2[seq(0,-nrow(datosV2),-13),c(-1)]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")
