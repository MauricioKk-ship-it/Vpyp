#!/bin/bash

# ==============================================================================
# GoSpot - monitor.sh
# Affiche les ressources système clés en temps réel.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

# Intercepter CTRL+C pour quitter proprement
trap "echo -e '\n${C_GREEN}Moniteur arrêté. Au revoir !${C_RESET}'; exit 0" SIGINT SIGTERM

# Détection de l'OS
OS=""
if [[ "$(uname)" == "Linux" ]]; then
    OS="Linux"
elif [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
fi

echo -e "${C_B_BLUE}--- MONITEUR DE RESSOURCES SYSTÈME (rafraîchissement toutes les 2s) ---${C_RESET}"
echo -e "${C_YELLOW}Appuyez sur CTRL+C pour quitter.${C_RESET}"
sleep 2

while true; do
    # Effacer l'écran pour le rafraîchissement
    clear
    
    echo -e "${C_B_BLUE}Dernière mise à jour : $(date)${C_RESET}"
    
    # --- Charge CPU (Load Average) ---
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | sed 's/ //g')
    echo -e "\n${C_CYAN}Charge CPU (1m, 5m, 15m):${C_RESET} ${C_GREEN}$LOAD_AVG${C_RESET}"

    # --- Utilisation Mémoire ---
    echo -e "\n${C_B_BLUE}--- Utilisation Mémoire ---${C_RESET}"
    if [[ "$OS" == "Linux" ]]; then
        free -h
    elif [[ "$OS" == "macOS" ]]; then
        # Commande plus complexe pour un output similaire à 'free'
        top -l 1 | grep "PhysMem"
    fi

    # --- Utilisation Disque ---
    echo -e "\n${C_B_BLUE}--- Utilisation Disque (Système de fichiers racine) ---${C_RESET}"
    df -h / | tail -n 1

    # --- Top 5 Processus (CPU) ---
    echo -e "\n${C_B_BLUE}--- Top 5 Processus (par utilisation CPU) ---${C_RESET}"
    if [[ "$OS" == "Linux" ]]; then
        ps -eo %cpu,%mem,user,comm --sort=-%cpu | head -n 6
    elif [[ "$OS" == "macOS" ]]; then
        ps -arcx -o %cpu,%mem,user,comm | head -n 6
    fi
    
    sleep 2
done
