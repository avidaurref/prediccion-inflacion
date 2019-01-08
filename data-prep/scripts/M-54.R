library(openxlsx)
#meses <- c ("ENE","FEB","MAR","ABR","MAY","JUN","JUL", "AGO", "SEP","OCT","NOV","DIC")

# Setting variable
cod        <- "TIEL"
stardate   <- "1998/1/1"
informecsv <- "M-55.csv"
informexls <- "M-54 Tasa de encaje legal.xlsx"
filas      <- c(15:269)
columnas   <- c(1:10)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2 <- datosV1[filas,columnas]
#datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV2 <- datosV2[!is.na(datosV2[,3]),]
rownames(datosV2) <- c(1:nrow(datosV2))

datosV3 <- datosV2[c(-1,-26,-63,-112),c(-2)]
#datosV3 <- datosV2[seq(-1,-nrow(datosV2),-13),c(-2)]


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")


