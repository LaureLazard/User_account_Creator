#!/bin/bash
#Auteur: PETIT Laurent		Date: 02/28/2018
#Description: Ce scripte automatise la création d'utilisateurs pour une université

displayerr="`tput setaf 1`\033[1m" # format d'affichage des messages d'erreur 
defaut="\033[0m" #format de défaut du terminal

#Verifie que le programme est lancé par le superuser
run=`whoami`
if ! [ $run = "root" ]; then
	echo "passez en mode root afin de lancer le scripte"
	sudo su
fi

#Verifie que le fichier à lire est bien passé en argument
if [ $# -ne 1 ] || [ ! -f $1 ]; then #si non, affiche un message d'erreur
	>&2 echo -e $displayerr"erreur: r'ajoutez un fichier existant contenant la liste des étudiants"$defaut
	exit 0 #et quitte le programme
fi

#Créer un repertoire qui va contenir tous les logs
if [ ! -d "useracclogs" ]; then
	mkdir -m 600 useracclogs
fi

#Gère la céation des groupes
if [ -f /home/laurentpetit/departements.txt ]; then
	while IFS='' read d || [ -n "$d" ]; do
		addgroup $d &>> useracclogs/grouplog.txt
	done < /home/laurentpetit/departements.txt
else
	>&2 echo -e $displayerr"le fichier departements.txt à été déplacé ou éffacé"$defaut
	exit 0
fi

#Recupère les informations depuis le fichier texte
while IFS='' read line || [ -n "$line" ]; do
	#lis les lignes du fichier texte dans un tableau
	#ceci permet une meilleure manipulation des données
	array=("${array[@]}" $line)	
done < "$1"

size=`echo ${array[@]} | wc -w`
size=`echo $(($size / 3))` #calcul le nombre d'étudiants

#créer les bornes pour chaque 'groupe' de donées
i=0
n=`expr $i + 2`

echo -e "$size nouveaux utilisateurs détectés\ncréation en cours...\n"
for a in `seq 1 $size` 
do
	nom="${array[i]}"; prenom="${array[i+1]}"; dep="${array[n]}"
	pseudo="${prenom,,}${nom,,}"; pseudo="${pseudo:0:15}"
	mdp="${nom:0:2}${prenom:0:2}$dep"; mdp="${mdp,,}"

	useradd $pseudo -c "$nom $prenom" -G $dep -N 2>>useracclogs/errlog.txt
	echo -e "$mdp\n$mdp\n" | sudo passwd $pseudo 2>>/dev/null

	user=`egrep $pseudo /etc/passwd` #infos sur l'utilisateur
	case $user in #verifie que l'utilisateur à bien été créé
		"") echo -e "Utilisateur non créé $nom $prenom \n$dep \n\n";;
		 *) echo -ne "$a/$size Créé \033[0K\r"; sleep 1s
		    echo -e "$user créé\nMot de passe: $mdp\n\n" 1>>useracclogs/userlog.txt
		    echo "$pseudo" 1>>useracclogs/pseudolog.txt
	esac
	
	i=`expr $n + 1`
	n=`expr $i + 2`
done

#options de fin de programme
echo -e "Opération terminée!!\n[E] ouvrire le log des erreurs\n[U] ouvrirele log des utilisateurs\n[G] ouvrire le log des groupes\n[Q] quitter"
read -n 1 key
clear
case $key in 
[Ee]) vim useracclogs/errlog.txt ;;
[Uu]) vim useracclogs/userlog.txt ;;
[Gg]) vim useracclogs/grouplog.txt ;;
[Qq]) exit 0 ;;
   *) >&2 echo -e $displayerr"entrée invalide, le programme va clore"$defaut
      exit 1
esac
