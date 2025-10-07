#!/usr/bin/env bash

mode="$1"

if [ "$mode" = "server" ]; then
  echo "[🛰] Démarrage du serveur SSH local..."
  if command -v sshd >/dev/null 2>&1; then
    sshd
  else
    echo "⚠️  openssh-server n'est pas installé."
  fi
elif [ "$mode" = "client" ]; then
  read -p "IP du serveur : " ip
  read -p "Utilisateur : " user
  ssh "$user@$ip"
else
  echo "Usage: $0 {server|client}"
fi
