#!/bin/bash
#Auteur: PETIT Laurent		Date: 02/28/2018
#Description: Ce scripte nettoye les effets du scripte useracc.sh

while IFS='' read u || [ -n "$u" ]; do
	deluser $u
done < /home/laurentpetit/useracclogs/pseudolog.txt

while IFS='' read d || [ -n "$d" ]; do
	delgroup $d 
done < /home/laurentpetit/departements.txt

echo "Deleting useracclogs ..."
rm -r useracclogs
echo "Done."
