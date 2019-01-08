library(openxlsx)
meses <- c ("ENE","FEB","MAR","ABR","MAY","JUN","JUL", "AGO", "SEP","OCT","NOV","DIC")

# Setting variable
cod        <- "TIIB"
stardate   <- "1998/1/1"
informecsv <- "M-52.csv"
informexls <- "M-52 Tasas interbancarias.xlsx"
filas      <- c(8:553)
columnas   <- c(2:8)

# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = 1, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2 <- datosV1[filas,columnas]
datosV2 <- datosV2[rowSums(is.na(datosV2)) != ncol(datosV2),]
truerows<- substr( datosV2[,1], 1, 3) %in% toupper(meses)

datosV3 <- datosV2[truerows,]
datosV3 <- datosV3[,c(-2)]

# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv

write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
            sep = ",", row.names=FALSE, qmethod = "double",na = "")


