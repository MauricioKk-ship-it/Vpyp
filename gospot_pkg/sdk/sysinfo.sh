#!/bin/bash

# ==============================================================================
# GoSpot - sysinfo.sh
# Affiche un rapport complet sur l'état du système.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

# --- Couleurs ---
C_RESET='\033[0m'
C_B_BLUE='\033[1;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'

# --- Fonctions d'aide ---
print_header() {
    echo -e "\n${C_B_BLUE}--- $1 ---${C_RESET}"
}

# --- Détection de l'OS ---
OS=""
if [[ "$(uname)" == "Linux" ]]; then
    OS="Linux"
elif [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
fi

# =======================
# --- INFOS GÉNÉRALES ---
# =======================
print_header "🖥️  INFORMATIONS SYSTÈME"
HOSTNAME=$(hostname)
UPTIME=$(uptime -p | sed 's/up //')
KERNEL=$(uname -a)
echo -e "${C_CYAN}Hostname:${C_RESET}\t${C_GREEN}${HOSTNAME}${C_RESET}"
echo -e "${C_CYAN}Uptime:${C_RESET}\t\t${C_GREEN}${UPTIME}${C_RESET}"
echo -e "${C_CYAN}Noyau:${C_RESET}\t\t${C_GREEN}${KERNEL}${C_RESET}"

# =======================
# --- CPU & RAM ---
# =======================
print_header "⚙️  CPU ET MÉMOIRE"
if [[ "$OS" == "Linux" ]]; then
    CPU_INFO=$(grep "model name" /proc/cpuinfo | uniq | cut -d ':' -f2 | sed 's/ //')
    CPU_CORES=$(nproc)
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{printf "%.2f", $2/1024/1024}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{printf "%.2f", $2/1024/1024}')
    MEM_USED=$(echo "$MEM_TOTAL - $MEM_FREE" | bc)
elif [[ "$OS" == "macOS" ]]; then
    CPU_INFO=$(sysctl -n machdep.cpu.brand_string)
    CPU_CORES=$(sysctl -n hw.ncpu)
    MEM_TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.2f", $1/1024/1024/1024}')
    # macOS gère la RAM différemment, le "libre" est moins significatif
    MEM_USED=$(top -l 1 | grep "PhysMem" | awk '{print $2}')
fi
echo -e "${C_CYAN}Modèle CPU:${C_RESET}\t${C_YELLOW}${CPU_INFO}${C_RESET}"
echo -e "${C_CYAN}Cœurs CPU:${C_RESET}\t${C_YELLOW}${CPU_CORES}${C_RESET}"
echo -e "${C_CYAN}RAM Utilisée:${C_RESET}\t${C_YELLOW}${MEM_USED} Go${C_RESET}"
echo -e "${C_CYAN}RAM Totale:${C_RESET}\t${C_YELLOW}${MEM_TOTAL} Go${C_RESET}"

# =======================
# --- ESPACE DISQUE ---
# =======================
print_header "💾  UTILISATION DU DISQUE"
df -h | grep -E '^/dev/' | awk '{ printf "%-30s %10s %10s %10s %10s\n", $1, $2, $3, $4, $5 }' | \
while read -r line; do
    echo -e "${C_GREEN}$line${C_RESET}"
done

# =======================
# --- INFOS RÉSEAU ---
# =======================
print_header "🌐  INFORMATIONS RÉSEAU"
if command -v ip &> /dev/null; then
    # Pour les systèmes Linux modernes
    IP_LOCAL=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1 | head -n 1)
else
    # Pour macOS et autres systèmes
    IP_LOCAL=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
fi
IP_PUBLIQUE=$(curl -s ifconfig.me || echo "Non trouvée")
echo -e "${C_CYAN}IP Locale:${C_RESET}\t\t${C_GREEN}${IP_LOCAL}${C_RESET}"
echo -e "${C_CYAN}IP Publique:${C_RESET}\t${C_GREEN}${IP_PUBLIQUE}${C_RESET}"

echo "" # Ligne vide pour finir
