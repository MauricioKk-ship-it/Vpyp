#!/bin/bash
# tools.sh - Installer ou mettre à jour le SDK GoSpot

SDK_URL="https://gospot-sdk-host.onrender.com/gospot-sdk-1.0.0.tar.gz"
SDK_DIR="$HOME/gospot-sdk"

echo -e "\n${GREEN}Téléchargement du SDK GoSpot...${RESET}"

# Créer le répertoire si n'existe pas
mkdir -p "$SDK_DIR"

# Télécharger avec curl et jauge de progression
curl -# -L "$SDK_URL" -o "/tmp/gospot-sdk.tar.gz"

# Extraire le SDK
echo -e "${CYAN}Extraction du SDK...${RESET}"
tar -xzf "/tmp/gospot-sdk.tar.gz" -C "$SDK_DIR"
rm /tmp/gospot-sdk.tar.gz

# Rendre les scripts exécutables
chmod +x "$SDK_DIR/sdk/scripts/"*.sh

echo -e "${GREEN}SDK GoSpot installé/mis à jour avec succès ! 🎉${RESET}"
