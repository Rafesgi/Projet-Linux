#!/bin/bash

current_list="/var/log/current_suid_sgid.txt"
previous_list="/var/log/previous_suid_sgid.txt"

# Générer la liste des fichiers SUID/SGID actuels
find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -print > "$current_list"

if [ -f "$previous_list" ]; then
    differences=$(diff "$previous_list" "$current_list")
    if [ ! -z "$differences" ]; then
        echo "Attention : Les listes de fichiers SUID/SGID ont changé !"
        echo "$differences"
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                echo "Fichier modifié : $file, date de modification : $(stat -c %y "$file")"
            fi
        done <<< "$differences"
    else
        echo "Aucune différence trouvée entre les deux listes."
    fi
else
    echo "Aucune liste précédente trouvée, création de la liste actuelle comme référence."
fi

# Sauvegarder la liste actuelle pour la prochaine exécution
cp "$current_list" "$previous_list"
