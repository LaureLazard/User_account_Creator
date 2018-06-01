#!/bin/bash
while IFS='' read line || [ -n "$line" ]; do
	#lis les lignes du fichier texte dans un tableau
	#ceci permet une meilleure manipulation des données
	array=("${array[@]}" $line)	
	
done < "$1"

echo ${array[@]}
