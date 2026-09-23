
# Autor: Francisca Quezada
# Fecha: 2026-09-22
# Que hace: Explora la base de datos CASEN y responde a la pregunta economica

install.packages("dplyr")
library(dplyr)

# 1. Pregunta economica: ¿La brecha de ingreso entr personas con educacion superior
# y sin educacion superior crece o se achica a medida que aumenta la experiencia
# potencial?

# 2.Carga y explora
casen    <- read.csv("data/raw/casen_reducido.csv") 
ingresos <- read.csv("data/raw/casen_ingresos.csv") 

str(casen)      # Indica el tipo de columna
head(casen)     # Primeras 6 filas
dim(casen)      # Filas, Columnas
summary(casen)  # Indica min, max, media, cuartiles y deteccion de "NA"
summary(ingresos)

# Reporta dimensiones: 60 filas, 6 columnas (60,6)
# Tipos: "region, sector y genero" -> caracter; "educ, edad e ingreso" -> numerico
# ¿Cuántos NA hay en "ingreso"? 5 NAs (valores faltantes en ingreso)

# 2b. Elige columnas por patrón
names(select(ingresos, starts_with("ing")))   # por el NOMBRE  -> 4 columnas
names(select(ingresos, where(is.numeric)))    # por el TIPO    -> 7 columnas

# Explica en un comentario por qué no devuelven lo mismo: porque responden a 
# preguntas distintas, el primero pide nombres que empiecen con ing, en cambio
# el de abajo solo preguntas si la columna es numerica, por lo que arrastra a 
# los ingresos e incluye tambien educ, edad y horas sin avisar que es error.

