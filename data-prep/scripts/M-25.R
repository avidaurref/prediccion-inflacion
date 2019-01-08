library(openxlsx)

# Setting variable
cod        <- "SEEP"
stardate   <- "2003/1/1"
informecod <- "M-25"
informexls <- "M-25 Exportaciones.xlsx"
filas      <- c(25:202)
columnas   <- c(1:20)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/',informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, 
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
datosV3 <- datosV2[seq(-1,-176,-13),]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, "data-prep/clean-data/M-25.csv", sep = ","
            ,row.names=FALSE, qmethod = "double",na = "")
