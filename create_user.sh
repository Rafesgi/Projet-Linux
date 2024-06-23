#!/bin/bash

if [ $# -ne 1 ]
then 
    echo "Nombre Invalide d'arguments"
    echo "usage: ./create_user.sh <Source file>"
else 
    if [ -f "$1" ]
    then 
        for line in $(cat "$1")
        do
            if [[ ! "$line" =~ ^[a-zA-Z]+:[a-zA-Z]+:[a-zA-Z0-9,]+:(oui|non):[a-zA-Z0-9]+$ ]]
            then
                echo "Ligne invalide: $line"
                exit 1
            fi
        done
        echo "Format de <$1> valide..."
	echo "Création des utilisateurs..."
    else 
        echo "Le fichier <$1> ne semble pas exister"
    fi
fi
