library(openxlsx)

# Setting variable
cod        <- "SECM"
stardate   <- "1998/01/1"
informecsv <- "T-12-06.csv"
informexls <- "T-12-06 Cotización oficial de los principales mineros.xlsx"
hoja       <-  1
filas      <- c(51:318)
columnas   <- c(1:10)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = hoja, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2 <- datosV1[filas,columnas]
datosV2[datosV2 == 0] <- NA
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
rownames(datosV2)<-seq(1:nrow(datosV2))
colnames(datosV2)<-seq(1:ncol(datosV2))

datosV3 <- datosV2[c(-53:-55,-69:-74,-127:-128,-142,-169:-171),]
#datosV3 <- datosV2[seq(-1,-nrow(datosV2),-13),]
datosV3 <- datosV3[seq(-1,-nrow(datosV3),-13),]


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
