#!/bin/bash

# ==============================================================================
# GoSpot - speedtest.sh
# Lance un test de bande passante avec speedtest-cli.
# Propose de l'installer si l'outil est manquant.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'

# --- Vérification de la commande speedtest-cli ---
if ! command -v speedtest-cli &> /dev/null && ! command -v speedtest &> /dev/null; then
    echo -e "${C_RED}La commande 'speedtest-cli' ou 'speedtest' est introuvable.${C_RESET}"
    echo -e "${C_YELLOW}Ce script nécessite l'outil Speedtest CLI par Ookla ou la version Python.${C_RESET}"
    read -p "Voulez-vous tenter de l'installer maintenant ? (o/n) " choice
    
    if [[ "$choice" == "o" || "$choice" == "O" ]]; then
        # --- Logique d'installation ---
        echo -e "${C_B_BLUE}Tentative d'installation...${C_RESET}"
        if command -v apt-get &> /dev/null; then
            echo "Détection de APT (Debian/Ubuntu)..."
            sudo apt-get update
            sudo apt-get install -y speedtest-cli
        elif command -v yum &> /dev/null; then
            echo "Détection de YUM (CentOS/RHEL)..."
            sudo yum install -y speedtest-cli
        elif command -v brew &> /dev/null; then
            echo "Détection de Homebrew (macOS)..."
            brew install speedtest-cli
        elif command -v pkg &> /dev/null; then
             echo "Détection de PKG (Termux)..."
             pkg install -y speedtest-cli
        else
            echo -e "${C_RED}Gestionnaire de paquets non reconnu.${C_RESET}"
            echo "Veuillez installer 'speedtest-cli' manuellement."
            exit 1
        fi

        # Vérifier à nouveau après l'installation
        if ! command -v speedtest-cli &> /dev/null && ! command -v speedtest &> /dev/null; then
             echo -e "${C_RED}L'installation a échoué. Veuillez vérifier les erreurs ci-dessus.${C_RESET}"
             exit 1
        fi
        echo -e "${C_GREEN}Installation réussie !${C_RESET}"
    else
        echo "Annulation."
        exit 0
    fi
fi

# --- Lancement du test ---
echo -e "\n${C_B_BLUE}--- LANCEMENT DU TEST DE BANDE PASSANTE ---${C_RESET}"
echo -e "${C_YELLOW}Le test peut prendre quelques minutes...${C_RESET}"

# Utiliser la commande disponible
if command -v speedtest &> /dev/null; then
    # Version Ookla, plus moderne
    speedtest --accept-license --accept-gdpr
elif command -v speedtest-cli &> /dev/null; then
    # Version Python legacy
    speedtest-cli
fi

echo -e "\n${C_GREEN}Test terminé.${C_RESET}"
