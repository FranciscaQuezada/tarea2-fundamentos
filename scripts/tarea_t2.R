
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

# 3. Usa los cinco verbos 
base <- casen |> 
  filter (!is.na(ingreso) & edad >= 18) |> 
  select (region, sector, educ, edad, ingreso, genero) |> 
  mutate(
    experiencia = pmax(edad - educ - 6,0),
    nivel_educ = if_else(educ >= 13, "Superior", "No Superior")) |> 
  arrange(desc(ingreso))
# Se construyo "base" que contiene los datos de personas mayores de edad con ingreso
# no nulo, dos columnas nuevas "experiencia" y "nivel_educ", ordenadas de mayor a 
# menor ingreso. Al filtrar los NA "base" quedo con 55 filas en vez de 60.

# 3b. Clasifica con `case_when()`
base <- base |>
  mutate(
    tramo_exp = case_when(
      experiencia < 10                     ~ "Junior",
      experiencia >= 10 & experiencia < 25 ~ "Medio",
      TRUE                                 ~ "Senior"
    )
  )
# Verificar que no quedo ningun NA:
table(base$tramo_exp, useNA = "ifany")

# 4. Agrega con `group_by()`
# (a) Dos agregaciones con `summarise()`
# Un grupo:
por_nivel <- base |>
  group_by(nivel_educ) |>
  summarise(ingreso_prom = mean(ingreso, na.rm = TRUE), 
  n = n())

print(por_nivel)
# Un ingreso promedio de $537.037 para "No Superior" (28 personas) y $777.926
# para "Superior" (27 personas)

# Dos grupos cruzados:
por_nivel_tramo <- base |>
  group_by (nivel_educ, tramo_exp) |>
  summarise(ingreso_prom = mean(ingreso, na.rm =TRUE), 
  n = n()) |>
  arrange(tramo_exp, nivel_educ)

print(por_nivel_tramo)
# 6 combinacions de nivel educacional por tramo de experiencia, con promedios que 
# van desde $518.059 (No Superior/Senior, 17 personas) como el ingreso mas bajo, 
# hasta $791.857 (Superior/Junior, 7 personas)como el ingreso mas alto. 

# (b) Una comparación con `group_by()` + `mutate()`
base <- base |>
  group_by(nivel_educ) |>
  mutate(brecha_vs_grupo = ingreso - mean(ingreso, na.rm = TRUE)) |>
  ungroup()
# "summarise" entrega una tabla de grupos o promedio por nivel_educ.
# "mutate" agrupado entrega una tabla de personas y cuanto se aleja cada una 
# del promedio de su propio nivel educativo, lo cual es util para identificar
# personas muy por debajo del promedio de su grupo.

# 5. Trata los `NA` explícitamente
mean(casen$ingreso)                  # NA -> hay valores faltantes sin tratar
mean(casen$ingreso, na.rm = TRUE)    # Ignora esos casos al calcular
# Se pierden 5 de 60 personas (8,3% aprox) en cualquier calculo con na.rm = TRUE.
# Es aceptable para una exploracion descriptiva como esta, pero seria un problema
# si esos faltantes no fueran aleatorios. Por ejemplo, si las personas de mayores
# ingresos tienden a no reportarlo.

