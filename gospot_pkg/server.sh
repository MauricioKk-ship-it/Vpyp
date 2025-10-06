#!/bin/sh
# server.sh — mode partage / préparation d'un serveur SSH simple
set -eu

echo "[GoSpot] Mode serveur — préparation..."
# Vérifie si sshd est présent
if command -v sshd >/dev/null 2>&1; then
  echo "[*] sshd trouvé."
else
  echo "[!] sshd non trouvé. Installez openssh-server (apk add openssh) ou utilisez npm sdk."
fi

# Crée un utilisateur temporaire gospot si besoin (non root check)
if [ "$(id -u)" -ne 0 ]; then
  echo "[!] Pour certaines opérations (ajout d'user, lancement sshd) root est requis."
  echo "[*] Vous pouvez configurer manuellement votre serveur SSH."
else
  echo "[*] (Optionnel) création d'un utilisateur 'gospot' pour partager:"
  if ! id gospot >/dev/null 2>&1; then
    adduser -D gospot && echo "gospot:gospot" | chpasswd || true
    echo "[*] Utilisateur gospot créé."
  else
    echo "[*] Utilisateur gospot déjà présent."
  fi
fi

echo "[*] Serveur prêt (manuellement vérifier sshd / hotspot)."
