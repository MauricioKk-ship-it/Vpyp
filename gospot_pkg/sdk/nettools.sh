#!/bin/bash

# ==============================================================================
# GoSpot - nettools.sh
# Menu interactif pour les diagnostics réseau de base.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

# --- Fonctions du menu ---

function show_ip_info() {
    echo -e "${C_B_BLUE}--- Informations IP ---${C_RESET}"
    # IP Locale
    if command -v ip &> /dev/null; then
        IP_LOCAL=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
    else
        IP_LOCAL=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
    fi
    echo -e "${C_CYAN}IP Locale :${C_RESET} ${C_GREEN}${IP_LOCAL}${C_RESET}"

    # IP Publique
    echo -e "${C_YELLOW}Récupération de l'IP publique...${C_RESET}"
    IP_PUBLIQUE=$(curl -s --max-time 5 ifconfig.me)
    if [ -n "$IP_PUBLIQUE" ]; then
        echo -e "${C_CYAN}IP Publique :${C_RESET} ${C_GREEN}${IP_PUBLIQUE}${C_RESET}"
    else
        echo -e "${C_RED}Impossible de récupérer l'IP publique (timeout ou pas de connexion).${C_RESET}"
    fi
}

function ping_test() {
    echo -e "${C_B_BLUE}--- Test de connectivité (Ping) ---${C_RESET}"
    read -p "Entrez une adresse à pinger [google.com] : " target
    target=${target:-google.com} # Valeur par défaut si vide

    echo -e "${C_YELLOW}Ping de ${target} (5 paquets)...${C_RESET}"
    ping -c 5 "$target"
}

function check_ports() {
    echo -e "${C_B_BLUE}--- Vérification des ports ouverts (locaux) ---${C_RESET}"
    echo -e "${C_YELLOW}Liste des ports en écoute (TCP/UDP)...${C_RESET}"
    if command -v ss &> /dev/null; then
        # Méthode moderne (Linux)
        ss -tuln
    elif command -v netstat &> /dev/null; then
        # Méthode classique
        netstat -tuln
    else
        echo -e "${C_RED}Ni 'ss' ni 'netstat' n'ont été trouvés pour vérifier les ports.${C_RESET}"
    fi
}

# --- Menu Principal ---
while true; do
    echo -e "\n${C_B_BLUE} OUTILS DE DIAGNOSTIC RÉSEAU ${C_RESET}"
    echo -e "${C_CYAN}1.${C_RESET} Afficher les informations IP (Locale & Publique)"
    echo -e "${C_CYAN}2.${C_RESET} Lancer un test de Ping"
    echo -e "${C_CYAN}3.${C_RESET} Lister les ports en écoute sur la machine"
    echo -e "${C_YELLOW}q.${C_RESET} Quitter"
    read -p "Choisissez une option : " choice

    case $choice in
        1) show_ip_info ;;
        2) ping_test ;;
        3) check_ports ;;
        [qQ]) break ;;
        *) echo -e "${C_RED}Option invalide.${C_RESET}" ;;
    esac
    read -p "Appuyez sur Entrée pour continuer..."
    clear
done

echo -e "${C_GREEN}Au revoir !${C_RESET}"
