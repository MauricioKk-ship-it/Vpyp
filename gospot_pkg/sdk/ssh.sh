#!/bin/bash

# ==============================================================================
# GoSpot - ssh.sh
# Menu interactif pour la gestion des clés SSH.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# --- Fonctions du menu ---

function generate_keys() {
    echo -e "${C_YELLOW}Génération d'une nouvelle paire de clés SSH (RSA 4096 bits)...${C_RESET}"
    read -p "Entrez un email pour associer à la clé : " email
    if [ -z "$email" ]; then
        echo -e "${C_RED}L'email ne peut pas être vide. Annulation.${C_RESET}"
        return
    fi
    
    # Nom de fichier basé sur l'hostname pour éviter les conflits
    filename="id_rsa_$(hostname)_$(date +%Y%m%d)"
    filepath="$SSH_DIR/$filename"
    
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$filepath"
    
    echo -e "${C_GREEN}Clés générées avec succès !${C_RESET}"
    echo -e "Clé privée : ${C_CYAN}$filepath${C_RESET}"
    echo -e "Clé publique : ${C_CYAN}$filepath.pub${C_RESET}"
    echo -e "${C_YELLOW}N'oubliez pas d'ajouter la clé publique au serveur distant !${C_RESET}"
}

function list_keys() {
    echo -e "${C_B_BLUE}--- Clés SSH Publiques Trouvées dans $SSH_DIR ---${C_RESET}"
    if ls -l "$SSH_DIR"/*.pub &> /dev/null; then
        ls -l --color=auto "$SSH_DIR"/*.pub
    else
        echo -e "${C_RED}Aucune clé publique (.pub) trouvée.${C_RESET}"
    fi
}

function copy_key() {
    echo -e "${C_YELLOW}Sélectionnez la clé publique à copier sur un serveur distant :${C_RESET}"
    
    # Affiche les clés disponibles avec un numéro
    keys=("$SSH_DIR"/*.pub)
    if [ ${#keys[@]} -eq 0 ] || [ ! -e "${keys[0]}" ]; then
        echo -e "${C_RED}Aucune clé publique à copier. Veuillez en générer une d'abord.${C_RESET}"
        return
    fi
    
    select key_path in "${keys[@]}"; do
        if [ -n "$key_path" ]; then
            break
        else
            echo -e "${C_RED}Sélection invalide.${C_RESET}"
        fi
    done

    read -p "Entrez l'utilisateur et l'hôte distant (ex: user@192.168.1.50) : " remote_host
    if [ -z "$remote_host" ]; then
        echo -e "${C_RED}L'hôte distant ne peut pas être vide. Annulation.${C_RESET}"
        return
    fi

    echo -e "${C_CYAN}Copie de la clé $key_path vers $remote_host...${C_RESET}"
    if ssh-copy-id -i "$key_path" "$remote_host"; then
        echo -e "${C_GREEN}Clé copiée avec succès ! Vous devriez pouvoir vous connecter sans mot de passe.${C_RESET}"
    else
        echo -e "${C_RED}La copie de la clé a échoué.${C_RESET}"
    fi
}

# --- Menu Principal ---
while true; do
    echo -e "\n${C_B_BLUE} GESTIONNAIRE DE CLÉS SSH ${C_RESET}"
    echo -e "${C_CYAN}1.${C_RESET} Générer une nouvelle paire de clés"
    echo -e "${C_CYAN}2.${C_RESET} Lister les clés publiques existantes"
    echo -e "${C_CYAN}3.${C_RESET} Copier une clé publique vers un serveur (ssh-copy-id)"
    echo -e "${C_YELLOW}q.${C_RESET} Quitter"
    read -p "Choisissez une option : " choice

    case $choice in
        1) generate_keys ;;
        2) list_keys ;;
        3) copy_key ;;
        [qQ]) break ;;
        *) echo -e "${C_RED}Option invalide. Veuillez réessayer.${C_RESET}" ;;
    esac
    read -p "Appuyez sur Entrée pour continuer..."
    clear
done

echo -e "${C_GREEN}Au revoir !${C_RESET}"
