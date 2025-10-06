#!/bin/sh
# tools.sh — installe outils utiles (iSH/Alpine)
set -eu

echo "[*] Installation outils réseau pour Alpine/iSH (require root)"
PKGS="curl wget openssh-client openssh tcpdump iputils nmap"
if [ "$(id -u)" -ne 0 ]; then
  echo "[!] Root requis pour installer paquets : apk add $PKGS"
  exit 1
fi

echo "[*] apk update && apk add $PKGS"
apk update
apk add $PKGS
echo "[*] Installation terminée."
