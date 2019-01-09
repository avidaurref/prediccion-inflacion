# Predicción de la inflación
Trabajo realizado para predecir la inflación de Bolivia mediante algoritmos de machine learning. Se obtiene la predicción de la inflación mensual y la inflación acumulada anual para la gestión 2016 con el objetivo de compararlo con las predicciones realizadas con modelos económicos.

Con información hasta Diciembre 2015 se predice la inflación hasta Diciembre de 2016

## Requisitos
* [R](https://www.r-project.org/)
* Tener las siguientes librerías instaladas
	* openxlsx
	* Metrics
	* caret
	* glmnet
	* nnet
	* lubridate
	* forecast
	* outliers
	* elasticnet
	* data.table
	* ggplot2
	* scales
	* pracma
	* e1071
	* gbm
	* randomForest
	* glmnet
	* moments
	* tseries
	* rpart
	* nnet
	* corrplot

## Instalación
1. Descargar este repositorio a tu computadora
2. Cambiar el directorio de trabajo para los siguientes archivos:
	 * data-prep/data-prep.R
	 * machine-learning/machine-learning.R
	 * prediction/prediction.R
	 * transform-data/transform-data.R

## Uso 
El proyecto tiene el siguiente orden:
1. Obtención y preparación del conjunto de datos. Directorio: "data-prep"
2. Tratamiento del conjunto de datos. Directorio: "transform-data"
3. Modelado del conjunto de datos. Directorio: "machine-learning"
4. Predicción de la inflación. Directorio: "prediction"

En cada directorio se encuentra su ejecutable donde se puede obtener los archivos que serán necesarios para cada paso del trabajo
