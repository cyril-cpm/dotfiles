#!/bin/bash

# CONFIGURATION : "nom_fichier:mode:couleur_fond"
# Modes disponibles pour swaybg : stretch, fill, fit, center, tile
WALLPAPERS=(
    "pip.jpg:stretch:#000000"
    "wallpaper.jpg:fill:#000000"
)

# Dossier où se trouvent les images
DIR="$HOME/.config/sway"

# Intervalle en secondes (ex: 300 pour 5 min)
INTERVAL=300

while true; do
    # Sélectionner une ligne au hasard dans le tableau
    SELECTED=${WALLPAPERS[$RANDOM % ${#WALLPAPERS[@]}]}

    # Découper la ligne pour extraire les variables
    IFS=":" read -r FILE MODE BGCOLOR <<< "$SELECTED"

    # Vérifier si le fichier existe avant d'appliquer
    if [ -f "$DIR/$FILE" ]; then
        # On tue l'ancien processus et on lance le nouveau
        pkill swaybg
        swaybg -i "$DIR/$FILE" -m "$MODE" -c "$BGCOLOR" &
    else
        notify-send "Erreur : Le fichier $DIR/$FILE est introuvable."
    fi

    sleep $INTERVAL
done
