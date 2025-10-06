#!/bin/sh
# admin.sh — petits outils d'administration (simulation)
set -eu

echo "[Admin] Informations système:"
uname -a
echo
echo "[Admin] Espace disque:"
df -h
echo
echo "[Admin] Processus SSH (si présent):"
ps aux | grep sshd || true
