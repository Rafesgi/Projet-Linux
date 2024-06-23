#!/bin/bash

# Fonction de vérification du format du fichier source
check_format() {
    if [ -f "$1" ]; then 
        awk -f verify_format.awk "$1"
    else 
        echo "Le fichier <$1> ne semble pas exister"
        echo "Usage: $0 <fichier_source>"
        exit 1
    fi
}

# Fonction de création des utilisateurs
create_users() {
	echo "Créations des utilisateurs"
    	awk -F: '{print $1 ":" $2 ":" $3 ":" $4 ":" $5}' "$1" | while read line; do
        prenom=$(echo "$line" | cut -d: -f1)
        nom=$(echo "$line" | cut -d: -f2)
        groupes=$(echo "$line" | cut -d: -f3)
        sudo=$(echo "$line" | cut -d: -f4)
        pass=$(echo "$line" | cut -d: -f5)

        login="${prenom:0:1}$nom"
        if id "$login" &>/dev/null; then
            i=1
            while id "${login}$i" &>/dev/null; do
                ((i++))
            done
            login="${login}$i"
        fi

        group_primary=$(echo "$groupes" | cut -d, -f1)
        groups_secondary=$(echo "$groupes" | cut -d, -f2- | tr ',' ' ')

        # Création des groupes si nécessaires
        if [[ ! -z "$group_primary" ]]; then
            if ! getent group "$group_primary" &>/dev/null; then
                groupadd "$group_primary"
            fi
        else
            group_primary="$login"
            groupadd "$group_primary"
        fi

        if [[ ! -z "$groups_secondary" ]]; then
            for group in $groups_secondary; do
                if ! getent group "$group" &>/dev/null; then
                    groupadd "$group"
                fi
            done
        fi

        useradd -m -c "$prenom $nom" -G "$groups_secondary" -g "$group_primary" -s /bin/bash "$login"
        echo "$login:$pass" | chpasswd
        passwd -e "$login"

        # Gestion du sudo
        if [ "$sudo" == "oui" ]; then
            usermod -aG sudo "$login"
        fi

        # Création de fichiers aléatoires
        for i in {1..10}; do
            dd if=/dev/urandom of="/home/$login/file$i" bs=1M count=$((RANDOM % 46 + 5))
        done
    done
}

# Vérification des arguments
if [ $# -ne 1 ]; then
    echo "Nombre invalide d'argument"
    echo "Usage: $0 <fichier_source>"
    exit 1
fi

# Exécution des fonctions
check_format "$1" 
create_users "$1"
