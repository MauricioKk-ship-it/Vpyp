#!/bin/sh
# ssh.sh — création clé SSH et affichage
set -eu

KEY="$HOME/.ssh/gospot_key"
if [ -f "$KEY" ]; then
  echo "[*] Clé existante : $KEY"
  echo "Public:"
  cat "${KEY}.pub" || true
else
  echo "[*] Création d'une nouvelle paire SSH (sans passphrase)..."
  mkdir -p "$(dirname "$KEY")"
  ssh-keygen -t ed25519 -f "$KEY" -N "" || ssh-keygen -t rsa -b 4096 -f "$KEY" -N ""
  echo "[*] Clé créée : $KEY"
  echo "Public:"
  cat "${KEY}.pub"
fi
