#!/usr/bin/env bash
echo "[⚙️] Installation des outils SDK..."
if command -v pkg >/dev/null 2>&1; then
  pkg install -y nmap curl openssh
elif command -v apt >/dev/null 2>&1; then
  sudo apt update && sudo apt install -y nmap curl openssh-client
else
  echo "Gestionnaire non reconnu. Installe manuellement nmap/curl/openssh."
fi
