#!/bin/bash

# ==============================================================================
# GoSpot - setup-net-tools.sh
# Installe une suite d'outils réseau essentiels en détectant la plateforme
# et en utilisant le gestionnaire de paquets approprié.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_CYAN='\033[0;36m'

# --- Liste des outils à installer ---
# Noms génériques, ils seront adaptés par plateforme
TOOLS_LIST=(nmap curl wget traceroute whois dnsutils)

# --- Exécuter le script de détection ---
# On suppose qu'il est dans le même répertoire que cli.py, donc un niveau au-dessus
DETECT_SCRIPT="$(dirname "$0")/../detect_os.sh"

if [ ! -f "$DETECT_SCRIPT" ]; then
    echo -e "${C_RED}ERREUR : Le script de détection 'detect_os.sh' est introuvable.${C_RESET}"
    exit 1
fi

# Récupère l'identifiant principal de la plateforme (ex: Termux, macOS, Linux)
PLATFORM_INFO=$(sh "$DETECT_SCRIPT")
PLATFORM=$(echo "$PLATFORM_INFO" | awk '{print $1}')

echo -e "${C_B_BLUE}--- Installateur d'Outils Réseau pour GoSpot ---${C_RESET}"
echo -e "${C_CYAN}Plateforme détectée :${C_RESET} ${C_GREEN}${PLATFORM_INFO}${C_RESET}"

# --- Définition des commandes et noms de paquets par plateforme ---
SUDO_CMD=""
INSTALL_CMD=""
PACKAGES=()

# Vérifier si sudo est nécessaire
if [ "$(id -u)" != "0" ] && [ "$PLATFORM" != "Termux" ]; then
    SUDO_CMD="sudo"
fi

case "$PLATFORM" in
    Termux)
        INSTALL_CMD="pkg install -y"
        PACKAGES=(nmap curl wget traceroute whois dnsutils)
        ;;
    macOS)
        if ! command -v brew &>/dev/null; then
            echo -e "${C_RED}Homebrew (brew) n'est pas installé.${C_RESET}"
            echo -e "${C_YELLOW}Veuillez l'installer depuis https://brew.sh pour continuer.${C_RESET}"
            exit 1
        fi
        INSTALL_CMD="brew install"
        PACKAGES=(nmap curl wget traceroute whois bind) # 'bind' fournit dig sur brew
        ;;
    iSH-Alpine)
        INSTALL_CMD="apk add"
        PACKAGES=(nmap curl wget traceroute whois bind-tools) # 'bind-tools' pour Alpine
        ;;
    Linux|WSL)
        # Détection plus fine de la distribution Linux
        if command -v apt-get &>/dev/null; then # Debian, Ubuntu, etc.
            INSTALL_CMD="apt-get install -y"
            PACKAGES=(nmap curl wget traceroute whois dnsutils)
        elif command -v dnf &>/dev/null; then # Fedora, CentOS 8+
            INSTALL_CMD="dnf install -y"
            PACKAGES=(nmap curl wget traceroute whois bind-utils)
        elif command -v yum &>/dev/null; then # CentOS 7
            INSTALL_CMD="yum install -y"
            PACKAGES=(nmap curl wget traceroute whois bind-utils)
        elif command -v pacman &>/dev/null; then # Arch Linux
            INSTALL_CMD="pacman -S --noconfirm"
            PACKAGES=(nmap curl wget traceroute whois dnsutils)
        else
            echo -e "${C_RED}Gestionnaire de paquets Linux non reconnu (apt, dnf, yum, pacman).${C_RESET}"
            exit 1
        fi
        ;;
    *)
        echo -e "${C_RED}Plateforme '$PLATFORM' non supportée par cet installateur automatique.${C_RESET}"
        exit 1
        ;;
esac

# --- Confirmation et Installation ---
echo -e "\n${C_YELLOW}Ce script va tenter d'installer les paquets suivants :${C_RESET}"
echo -e "${C_GREEN}${PACKAGES[*]}${C_RESET}"
echo -e "La commande utilisée sera : ${C_CYAN}${SUDO_CMD} ${INSTALL_CMD} [paquet]${C_RESET}"

read -p "Voulez-vous continuer ? (o/n) " choice
if [[ "$choice" != "o" && "$choice" != "O" ]]; then
    echo "Annulation."
    exit 0
fi

# Mise à jour des dépôts (bonne pratique avant d'installer)
echo -e "\n${C_B_BLUE}Mise à jour des listes de paquets...${C_RESET}"
case "$PLATFORM" in
    Termux) pkg update ;;
    macOS) brew update ;;
    iSH-Alpine) ${SUDO_CMD} apk update ;;
    Linux|WSL)
        if command -v apt-get &>/dev/null; then ${SUDO_CMD} apt-get update; fi
        ;;
esac

# Boucle d'installation
echo -e "\n${C_B_BLUE}Lancement de l'installation...${C_RESET}"
for pkg in "${PACKAGES[@]}"; do
    echo -e "\n${C_YELLOW}--- Installation de : $pkg ---${C_RESET}"
    if ${SUDO_CMD} ${INSTALL_CMD} "$pkg"; then
        echo -e "${C_GREEN}✅ $pkg installé avec succès.${C_RESET}"
    else
        echo -e "${C_RED}❌ L'installation de $pkg a échoué. Veuillez vérifier les erreurs ci-dessus.${C_RESET}"
    fi
done

echo -e "\n${C_GREEN}🎉 Installation des outils terminée !${C_RESET}"
