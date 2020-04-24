#!/bin/bash
#Script para calificar sesiones by Amed A. Leones Viloria

read -r -p "Asignatura: " a
read -r -p "Grupo: " g 
read -r -p "Nombre del archivo: " f
eval f=$f
fecha=$(date +%d%m%Y)
mat="${a//[[:space:]]/}"
Rscript calif-extra.r $f
iconv file.txt -f utf-8 -t iso-8859-1 "$1" \ | enscript -r -f Courier7 --margins=72:72:30:30 --header='E.P.O. 55- %D{%H:%M %d/%m/%y}|Asignatura: '"$a"', Profesor: Amed A. Leones Viloria|Grupo: '"$g"', Page $%'  -p file.ps $1
ps2pdf file.ps $mat-$g-$fecha.pdf
rm file.ps file.txt  
