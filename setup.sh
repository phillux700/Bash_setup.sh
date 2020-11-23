#!/bin/bash
# Fichier de configuration hostname, user, ssh

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
		username="linuxien${lastNumbers}"
		clearpass="Formation${lastNumbers}"
	    	pass=$(perl -e 'print crypt($clearpass, "salt"),"\n"')
		useradd "$pass" "$username"
		[ $? -eq 0 ] && echo "Cet utilisateur a été ajouté au système!" || echo "Echec!"
		echo "utilisateur: $username"
		echo "mot de passe: $pass $clearpass"
		echo "$username" "$pass" >> logs.txt
	else
		read -n 1 -p "Voulez-vous supprimer l'utilisateur $1 : [Y/N] ?" reply;
		if [ "$reply" != "" ]; then echo; fi
		if [ "$reply" = "${reply#[Nn]}" ];then
		    userdel -rf $1
		    delgroup $1
		    echo "L'utilisateur $1 a bien été supprimé" >> logs.txt
		fi
	    	username="linuxien${lastNumbers}"
		clearpass="Formation${lastNumbers}"
	    	pass=$(perl -e 'print crypt($clearpass, "salt"),"\n"')
		useradd "$pass" "$username"
		[ $? -eq 0 ] && echo "Cet utilisateur a été ajouté au système!" || echo "Echec!"
		echo "$username" " : " "$clearpass" >> logs.txt
	fi
}

########################################################################

# Fonction pour le SSH
function setSsh
{
	# openssh-client est installé par défaut
	# je redémarre ssh par sécurité
	# systemctl restart ssh
	#ssh-keygen -t rsa
}

########################################################################
# Envoi des fonctions
#rootCondition
setHostname
setUser $1
#setSsh
