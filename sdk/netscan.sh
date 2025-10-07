#!/usr/bin/env bash
echo "[🌐] Scan du réseau local avec nmap..."
if ! command -v nmap >/dev/null 2>&1; then
  echo "⚠️ nmap n'est pas installé. Installation..."
  if command -v pkg >/dev/null 2>&1; then
    pkg install -y nmap
  elif command -v apt >/dev/null 2>&1; then
    sudo apt install -y nmap
  fi
fi

ip=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '^127\.' | head -n1)
if [ -z "$ip" ]; then
  echo "Impossible de détecter ton IP locale."
  exit 1
fi
prefix=$(echo "$ip" | cut -d. -f1-3)
echo "[🔍] Scan du réseau ${prefix}.0/24 ..."
nmap -sn "${prefix}.0/24"
