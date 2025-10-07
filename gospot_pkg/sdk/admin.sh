#!/bin/bash

# ==============================================================================
# GoSpot - admin.sh
# Menu interactif pour les tâches d'administration système courantes.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

# --- Vérification des droits ---
if [ "$(id -u)" != "0" ]; then
    echo -e "${C_RED}ERREUR : Ce script doit être lancé en tant que root ou avec sudo.${C_RESET}"
    echo -e "${C_YELLOW}Essayez : sudo gospot admin${C_RESET}"
    exit 1
fi

# --- Détection du gestionnaire de paquets ---
PKG_MANAGER=""
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
fi

# --- Fonctions du menu ---

function update_system() {
    echo -e "${C_B_BLUE}--- Mise à jour du système ---${C_RESET}"
    case $PKG_MANAGER in
        "apt")
            echo "Lancement de 'apt update && apt upgrade'..."
            apt-get update && apt-get upgrade -y
            ;;
        "yum"|"dnf")
            echo "Lancement de '$PKG_MANAGER update'..."
            $PKG_MANAGER update -y
            ;;
        "pacman")
            echo "Lancement de 'pacman -Syu'..."
            pacman -Syu --noconfirm
            ;;
        *)
            echo -e "${C_RED}Gestionnaire de paquets non supporté pour la mise à jour automatique.${C_RESET}"
            ;;
    esac
    echo -e "${C_GREEN}Mise à jour terminée.${C_RESET}"
}

function check_services() {
    echo -e "${C_B_BLUE}--- Statut des services (systemd) ---${C_RESET}"
    if ! command -v systemctl &> /dev/null; then
        echo -e "${C_RED}'systemctl' n'est pas disponible sur ce système.${C_RESET}"
        return
    fi
    echo -e "${C_YELLOW}Liste des services qui ont échoué :${C_RESET}"
    systemctl --failed
}

function view_logs() {
    echo -e "${C_B_BLUE}--- Consultation des logs système (journalctl) ---${C_RESET}"
    if ! command -v journalctl &> /dev/null; then
        echo -e "${C_RED}'journalctl' n'est pas disponible. Consultation de /var/log/syslog...${C_RESET}"
        if [ -f "/var/log/syslog" ]; then
            tail -n 50 /var/log/syslog
        else
            echo -e "${C_RED}Aucun fichier de log standard trouvé.${C_RESET}"
        fi
        return
    fi
    echo -e "${C_YELLOW}Affichage des 50 dernières lignes de logs (tous niveaux). Utilisez les flèches pour naviguer, 'q' pour quitter.${C_RESET}"
    sleep 2 # Laisse le temps à l'utilisateur de lire
    journalctl -n 50 --no-pager
}

# --- Menu Principal ---
while true; do
    echo -e "\n${C_B_BLUE} MENU D'ADMINISTRATION SYSTÈME ${C_RESET}"
    echo -e "${C_CYAN}1.${C_RESET} Mettre à jour tous les paquets du système"
    echo -e "${C_CYAN}2.${C_RESET} Vérifier le statut des services (systemd)"
    echo -e "${C_CYAN}3.${C_RESET} Consulter les 50 derniers logs système"
    echo -e "${C_YELLOW}q.${C_RESET} Quitter"
    read -p "Choisissez une option : " choice

    case $choice in
        1) update_system ;;
        2) check_services ;;
        3) view_logs ;;
        [qQ]) break ;;
        *) echo -e "${C_RED}Option invalide.${C_RESET}" ;;
    esac
    read -p "Appuyez sur Entrée pour continuer..."
    clear
done

echo -e "${C_GREEN}Retour au terminal.${C_RESET}"
