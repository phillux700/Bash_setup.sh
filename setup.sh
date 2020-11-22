#!/bin/bash
# Fichier de configuration hostname, user, ssh

# Récupération du nom de l'interface réseau
eth=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'`
echo $eth
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
	echo "The new hostname is $NEW_HOSTNAME"
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
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && echo "Cet utilisateur a été ajouté au système!" || echo "Echec!"
	else
	    deluser --remove-home *
	    username="linuxien${lastNumbers}"
		clearpass="Formation${lastNumbers}"
	    pass=$(perl -e 'print crypt($clearpass, "salt"),"\n"')
		useradd -m -p "$pass" "$username"
		[ $? -eq 0 ] && echo "Cet utilisateur a été ajouté au système!" || echo "Echec!"
	fi
}

########################################################################

# Fonction pour le SSH
function setSsh
{
	# openssh-client est installé par défaut
	# je redémarre ssh par sécurité
	systemctl restart ssh
	#ssh-keygen -t rsa
}

########################################################################
# Envoi des fonctions
rootCondition
setHostname
setUser
setSsh