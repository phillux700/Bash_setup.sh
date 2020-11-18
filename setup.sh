#!/bin/bash
# Fichier de configuration du hostname, du pseudo et du password

# If faut être connecté en tant que root
if [ $EUID -ne 0 ]; then
    echo "This script should be run as root." > /dev/stderr
    exit 1
fi

# Récupération du nom de l'interface réseau
eth=`ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'`
echo $eth
# Récupération adresse IP du poste
ip=`ifconfig $eth | awk '/inet / {print $2}' | cut -d  ':' -f2`
#echo $ip
# Récupération des 2 derniers chiffres de l'IP
lastNumbers=`echo -n $ip | tail -c 2`

# Hostname

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
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
sudo sed -i "s/$CUR_HOSTNAME/$NEW_HOSTNAME/g" /etc/hostname
echo "The new hostname is $NEW_HOSTNAME"
