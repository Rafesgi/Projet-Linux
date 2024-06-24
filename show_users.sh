#!/bin/bash

# Fonction pour afficher les informations d'un utilisateur
show_user_info() {
    login=$1
    user_info=$(getent passwd "$login")
    IFS=: read -r login passwd uid gid info home shell <<< "$user_info"
    IFS=' ' read -r prenom nom <<< "$info"
    groups=$(id -Gn "$login")
    primary_group=$(id -gn "$login")
    secondary_groups=$(echo "$groups" | sed "s/$primary_group //")
    home_size=$(du -sh "$home" | cut -f1)
    sudo_status=$(groups "$login" | grep -qw "sudo" && echo "OUI" || echo "NON")

    echo "Utilisateur : $login"
    echo "Prénom : $prenom"
    echo "Nom : $nom"
    echo "Groupe primaire : $primary_group"
    echo "Groupes secondaires : $secondary_groups"
    echo "Répertoire personnel : $home_size"
    echo "Sudoer : $sudo_status"
}

# Options du script
while getopts "G:g:s:u:" opt; do
    case $opt in
        G) primary_group_filter=$OPTARG ;;
        g) secondary_group_filter=$OPTARG ;;
        s) sudo_filter=$OPTARG ;;
        u) user_filter=$OPTARG ;;
        *) echo "Option invalide : -$OPTARG" >&2; exit 1 ;;
    esac
done

# Affichage des informations de l'utilisateur spécifié
if [[ ! -z "$user_filter" ]]; then
    show_user_info "$user_filter"
    exit 0
fi

# Parcours des utilisateurs
for login in $(getent passwd {1000..60000} | cut -d: -f1); do
    user_info=$(getent passwd "$login")
    primary_group=$(id -gn "$login")
    secondary_groups=$(id -Gn "$login" | sed "s/$primary_group //")
    sudo_status=$(groups "$login" | grep -qw "sudo" && echo "1" || echo "0")

    if [[ ! -z "$primary_group_filter" && "$primary_group" != "$primary_group_filter" ]]; then
        continue
    fi
    if [[ ! -z "$secondary_group_filter" && ! $(echo "$secondary_groups" | grep -qw "$secondary_group_filter") ]]; then
        continue
    fi
    if [[ ! -z "$sudo_filter" && "$sudo_status" != "$sudo_filter" ]]; then
        continue
    fi

    show_user_info "$login"
done
