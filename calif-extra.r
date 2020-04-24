suppressMessages(library(gdata))
suppressMessages(library(gridExtra))
suppressMessages(library(readxl))
options("width"=1000)

args <- commandArgs(trailingOnly = TRUE)

#sest = read.xls(args[1], sheet = "sesiones", fileEncoding="latin1")
#falt = read.xls(args[1], sheet = "faltas", fileEncoding="latin1")
#xtrat = read.xls(args[1], sheet = "extra", fileEncoding="latin1")

sest = read_excel(args[1], sheet = "sesiones")
falt = read_excel(args[1], sheet = "faltas")
xtrat = read_excel(args[1], sheet = "extra")

con <- file("file.txt", open = "wt", encoding = "UTF-8")
sink(con, split = T)
#sink("file.txt")

nom <- sest[1]
s_val <- sest[-1]
f_val <- falt[-1]
xtra_val <- xtrat[-1]

pextra <- round(rowMeans(xtra_val, na.rm = TRUE), 2)
puntos_extra <- 1
ppx <- pextra * (puntos_extra/10.0)

p <- round(rowMeans(s_val, na.rm=TRUE), 2)
pa <- p + ppx
pa[pa >= 10] <- 10 

r <- pa
r[r >= 6.0] <- round(r[r >= 6.0], 0)
r[r < 6.0] <- floor(r[r < 6.0])

ret <- rowSums(f_val == 'r', na.rm = TRUE)
fal <- rowSums(f_val == 'f', na.rm = TRUE)
ret_mas_fal <- fal + floor(ret/3)

#sna <- sum(apply(f_val, 2, anyNA))
#t.ses <- length(f_val) - sna
# total de sesiones
# z <- sapply(s_val, function(y) sum(length(which(is.na(y))))) != nrow(s_val)
# t.ses <- table(z)["TRUE"]
# cat("\nTotal de sesiones: ", t.ses)
t.ses <- apply(s_val, 1, function(x) length(which(!is.na(x))))
#cat("\nFaltas permitidas:", fp <- 0.2*t.ses,"\n")
fp <- 0.2 * t.ses

promses <- data.frame(nom, ret, fal ,ret_mas_fal, p, ppx, pa, r, t.ses, fp)
sesprom <- data.frame(sest, p, ppx, pa, r)
falprom <- data.frame(falt, ret, fal, ret_mas_fal, t.ses, fp)
extraprom <- data.frame(xtrat, pextra, ppx)

cat("Sesiones","\n")
print(sesprom)
cat('\nNA significa que no hubo sesión de manera oficial')
cat('\np es el promedio de las sesiones, r es el promedio redondeado, pa es el promedio de las sesiones + la calificación extra ppx.')

cat("\fFaltas y Retardos","\n")
print(falprom)
cat("\nr son los retardos y f las faltas. Tres retardos equivalen a una falta.")
cat('\nret_mas_fal es la suma de retardos y faltas')
cat('\nt.ses es el número total de sesiones del alumno')
cat('\nfp son las faltas permitidas, si el estudiante pasa ese número estará en E.P.F.')

cat("\fCalificación Extra","\n")
print(extraprom)
cat("\nLos e son cada uno de los trabajos extra. El promedio de estos es pextra. El promedio por el número de puntos extra es ppx.")
cat("\nSe pudo obtener hasta ",puntos_extra," puntos extra")

cat("\fResumen\n")
cat("\n\nCalificación máxima: \n")
print(promses[promses['r'] == max(promses['r']), c(1,5,6,7,8)])

cat('\nAlumnos en E.P.F.: ', tepf <- sum(promses['ret_mas_fal'] > promses['fp']), '\n')
print(promses[promses['ret_mas_fal'] > fp, c('alumno', 'p','pa', 'ppx', 'r', 'ret', 'fal','ret_mas_fal', 't.ses', 'fp')])

cat('\nAlumnos en E.P.P.: ', tepp <- sum(promses['r'] < 6 & promses['ret_mas_fal'] <= fp), '\n')
print(promses[promses['r'] < 6 & promses['ret_mas_fal'] <= fp, c('alumno', 'p', 'ppx','pa', 'r')])
# print(r)
cat("\nPromedio del grupo: ", round(mean(r),2))
cat("\nPorcentaje de alumnos aprobados: ", round(((nrow(nom)-tepf-tepp)/nrow(nom))*100,2), "%")

cat("\n\nClasificación de Promedios:\n")
rango = range(promses['r'])
#breaks = seq(floor(rango[1]),ceiling(rango[2]), by=1)
breaks = seq(0, 11, by=1)
#breaks = seq(ceiling(rango[1]),ceiling(rango[2]), by=1)
Intervalos = cut(promses$r, breaks, right = F)#, include.lowest = T)

frecuencia <- table(Intervalos)
porcentaje <-round(frecuencia/sum(frecuencia)*100,2)
t <- as.data.frame(frecuencia)
t['Porcentaje'] = porcentaje
hist <- c()
for (i in 1:length(frecuencia)){hist[i]=paste(rep("*",frecuencia[i]),collapse = "")}
t['Histograma'] = hist
print(t)
sink()
