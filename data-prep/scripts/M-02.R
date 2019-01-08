# Setting variable
cod        <- "AMBD"
stardate   <- "2005/1/1"
informecsv <- "M-02.csv"
informexls <- "M-02 Base monetaria determinantes y componentes.xlsx"
filas      <- c(9:140)
columnas   <- c(3:38)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/',informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 2, startRow = 1, 
                     colNames =  FALSE, skipEmptyRows = FALSE)
datosV1 <- datosV1[rowSums(is.na(datosV1)) != ncol(datosV1),]
datosV1 <- datosV1[rowSums(is.na(datosV1)) != ncol(datosV1),]
datosV2 <- as.data.frame(t(datosV1))
datosV2 <- datosV2[filas,columnas]
datosV3 <- datosV2[,colSums(is.na(datosV2)) != nrow(datosV2)]
#datosV3 <- datosV2[seq(-1,-nrow(datosV2),-13),]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
