library(openxlsx)

# Setting variable
cod        <- "FOGC"
stardate   <- "2002/01/1"
informecsv <- "M-59.csv"
informexls <- "M-59 Operaciones consolidades del gobierno.xlsx"
filas      <- c(4:45)
columnas   <- c(6:185)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
#datosV2 <- datosV2[c(-26,-32),]
datosV3 <- as.data.frame(t(datosV2))
datosV3 <- datosV3[seq(0,-nrow(datosV3),-13),]


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
