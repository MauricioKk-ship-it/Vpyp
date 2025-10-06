#!/bin/sh
# client.sh — recherche rapide de serveur GoSpot sur le réseau local
set -eu

echo "[GoSpot] Mode client — recherche d'un serveur local..."

# méthode simple : lister interfaces et tenter ping broadcast / 192.168.XX.1
ip_cmd=$(command -v ip || true)
if [ -n "$ip_cmd" ]; then
  echo "[*] Utilisation de 'ip' pour détecter interfaces..."
  # cherche adresses IPv4 non loopback
  for a in $(ip -4 -o addr show scope global | awk '{print $4}'); do
    echo "  → interface trouvée: $a"
  done
else
  echo "[!] 'ip' non trouvé — essaye ifconfig ..."
  if command -v ifconfig >/dev/null 2>&1; then
    ifconfig | sed -n 's/ .*inet /inet /p'
  fi
fi

# Exemple de tentative de connexion (il faut que serveur écoute)
read -p "Adresse serveur (ou ENTER pour ping 192.168.1.1): " srv
srv=${srv:-192.168.1.1}
echo "[*] Test ping vers $srv..."
ping -c 2 "$srv" || echo "[!] ping échoué ou hôte indisponible"

echo "[*] Client terminé."
