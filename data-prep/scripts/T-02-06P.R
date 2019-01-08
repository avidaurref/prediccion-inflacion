library(openxlsx)

# Setting variable
cod        <- "BCYP"
stardate   <- "2014/07/1"
informecsv <- "T-02-06P.csv"
informexls <- "T-02-06P Balance consolidado de bancos PYME, pasivo.xlsx"
hoja       <-  1
filasA     <- c(10:29)
columnasA  <- c(1:20)
filasB     <- c(40:59)
columnasB  <- c(1:13)


# Formatear datos
dirxls  <- paste('data-prep/raw-data/', informexls,sep = "")
datosV1 <- read.xlsx(dirxls, sheet = hoja, startRow = 1, detectDates = TRUE,
                     colNames =  FALSE, skipEmptyRows = FALSE)

datosV2A <- datosV1[filasA,columnasA]
datosV2A <- datosV2A[rowSums(is.na(datosV2A)) != ncol(datosV2A),]
datosV3A <- datosV2A[seq(-7,-nrow(datosV2A),-13),]

datosV2B <- datosV1[filasB,columnasB]
datosV2B <- datosV2B[rowSums(is.na(datosV2B)) != ncol(datosV2B),]
datosV3B <- datosV2B[seq(-7,-nrow(datosV2B),-13),-1]

datosV3<- as.data.frame(append(datosV3A,datosV3B))


# Colocar nombres
datosV3[,1]<-seq(as.Date(stardate), by = "month", length.out = nrow(datosV3))
x <- paste(cod, formatC(seq(1:(ncol(datosV3)-1)), width=2, flag="0"), sep="")
colnames(datosV3) <- append(c("MES"),x)

# Guardar archivo csv
write.table(datosV3, paste("data-prep/clean-data/",informecsv,sep=""),
           sep = ",", row.names=FALSE, qmethod = "double",na = "")
