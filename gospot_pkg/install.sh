#!/bin/bash
# Script d'installation INTELLIGENT pour GoSpot (Vpyp CLI) - v2.0
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
echo -e "${GREEN}🚀 Lancement de l'installation de GoSpot CLI...${NC}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_SCRIPT_PATH="${PROJECT_DIR}/gospot_pkg/cli.py"
COMMAND_NAME="gospot"
INSTALL_DIR="/usr/local/bin"
RUN_CMD=""
if [ -d "$HOME/../usr/bin" ] && [[ "$(uname -o)" == "Android" ]]; then
    echo -e "${YELLOW}Environnement Termux détecté.${NC}"; INSTALL_DIR="$HOME/../usr/bin"
elif [ "$(id -u)" != "0" ]; then
    if ! command -v sudo &> /dev/null; then
        echo -e "${RED}❌ ERREUR : Vous n'êtes pas root et 'sudo' est introuvable.${NC}"; exit 1
    fi
    echo "🔑 L'installation nécessite les droits administrateur."; RUN_CMD="sudo"
else
    echo "👑 Script exécuté en tant que root. 'sudo' n'est pas nécessaire."
fi
INSTALL_PATH="${INSTALL_DIR}/${COMMAND_NAME}"
if [ ! -f "$CLI_SCRIPT_PATH" ]; then echo -e "${RED}❌ ERREUR : 'gospot_pkg/cli.py' est introuvable.${NC}"; exit 1; fi
if ! command -v python3 &> /dev/null; then echo -e "${RED}❌ ERREUR : Python 3 n'est pas installé.${NC}"; exit 1; fi
echo "✅ Prérequis validés."
read -r -d '' GOSPOT_WRAPPER << EOM
#!/bin/sh
# Wrapper pour exécuter le CLI GoSpot
python3 "${CLI_SCRIPT_PATH}" "\$@"
EOM
echo "⚙️  Préparation de la commande '${COMMAND_NAME}' dans ${INSTALL_DIR}..."
if echo "$GOSPOT_WRAPPER" | ${RUN_CMD} tee "$INSTALL_PATH" > /dev/null; then
    if ${RUN_CMD} chmod +x "$INSTALL_PATH"; then
        echo -e "${GREEN}✅ Installation réussie !${NC}"
        echo -e "🎉 Vous pouvez maintenant utiliser la commande '${GREEN}gospot${NC}'."
    else
        echo -e "${RED}❌ ERREUR : Impossible de rendre la commande exécutable.${NC}"; exit 1
    fi
else
    echo -e "${RED}❌ ERREUR : Impossible d'écrire la commande dans ${INSTALL_PATH}.${NC}"; exit 1
fi
exit 0
