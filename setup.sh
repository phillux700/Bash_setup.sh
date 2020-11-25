#!/bin/bash
# Fichier de configuration hostname, user

# Récupération du nom de l'interface réseau
eth=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'`
# Récupération adresse IP du poste
ip=`ifconfig $eth | awk '/inet / {print $2}' | cut -d  ':' -f2`
# Récupération des 2 derniers chiffres de l'IP
lastNumbers=`echo -n $ip | tail -c 2`

##########################################################################
# Fonction pour forcer le script en mode root
function rootCondition
{
	if [ $EUID -ne 0 ]; then
    		echo "This script should be run as root." > /dev/stderr
    		exit 1
	fi
}
#########################################################################

function setHostname
{
	CUR_HOSTNAME=$(cat /etc/hostname)

	if [[ $ip == *"100"* ]]; then
		NEW_HOSTNAME="Abeille$lastNumbers"
	elif [[ $ip == *"101"* ]]; then
		NEW_HOSTNAME="Baobab$lastNumbers"
	else
		echo "Adresse IP inconnue"
	fi

	hostname ctl set-hostname $NEW_HOSTNAME
	hostname $NEW_HOSTNAME
	sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
	sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
	echo "__________________________________________" >> logs.txt
	echo `date` >> logs.txt
	echo "The new hostname is $NEW_HOSTNAME" >> logs.txt
}
########################################################################

# Fonction pour ajouter un utilisateur
function setUser
{
	exists=$(grep -c "^linuxien" /etc/passwd)
	if [ $exists -eq 0 ]; then
	    	user="linuxien"$lastNumbers
	    	pass=`openssl rand -hex 4`
		useradd -p "$pass" -m "$user"
		echo "$user:$pass" | chpasswd
		[ $? -eq 0 ] && echo "L'utilisateur $user a été ajouté au système!" || echo "Echec"
		echo "$user : " "$pass" >> logs.txt
	else
		user=$(grep linuxien /etc/passwd | cut -c1-10 )
		read -n 1 -p "Voulez-vous supprimer l'utilisateur $user : [Y/N] ?" reply;
		if [ "$reply" != "" ]; then echo; fi
		if [ "$reply" = "${reply#[Nn]}" ]; then
		    deluser --remove-home $user
		    echo "L'utilisateur $user a bien été supprimé"
		    echo "L'utilisateur $user a bien été supprimé" >> logs.txt
		fi
	    	user="linuxien"$lastNumbers
	    	pass=`openssl rand -hex 4`
		useradd -p "$pass" -m "$user"
		echo "$user:$pass" | chpasswd
		[ $? -eq 0 ] && echo "L'utilisateur $user a été ajouté au système!" || echo "Echec!"
		echo "$user" " : " "$pass" >> logs.txt
	fi
}

########################################################################

# Résumé
function sumUp
{
	echo "############ RESUME ##################"
	echo `date`
	echo "The new hostname is $NEW_HOSTNAME"
	echo "Utilisateur : $user"
	echo "Mot de passe : $pass"
	echo "######################################"
}

########################################################################

# Reboot
function rebootSystem
{
	# Press any key to reboot
	read -s -n 1 -p "Appuyez sur n'importe quelle touche pour redémarrer"
	reboot
}
########################################################################
# Envoi des fonctions
rootCondition
setHostname
setUser
sumUp
rebootSystem
