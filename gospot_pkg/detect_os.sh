#!/bin/sh
# detect_os.sh — détection multi-plateformes (iSH, Termux, WSL, macOS, Linux)
# POSIX-friendly : évite les fonctionnalités non-portables (bashisms)
# Auteur: Mauricio-100 & Gemini

# Fonction pour vérifier si un fichier contient une chaîne de caractères
file_contains() {
  [ -f "$1" ] && grep -q "$2" "$1"
}

# Fonction principale de détection
detect_environment() {
  PLATFORM="Inconnu"
  DISTRIB_ID=""
  REAL_OS_NAME=$(uname 2>/dev/null)

  # Détection basique via uname
  case "$REAL_OS_NAME" in
    Darwin)
      PLATFORM="macOS"
      ;;
    *Linux*)
      PLATFORM="Linux"
      ;;
    MINGW*|MSYS*|CYGWIN*)
      PLATFORM="Windows"
      ;;
    *)
      PLATFORM="$REAL_OS_NAME"
      ;;
  esac

  # Détection plus fine pour les environnements spécifiques
  # WSL (Windows Subsystem for Linux)
  if [ -f /proc/version ] && file_contains /proc/version "microsoft"; then
    PLATFORM="WSL"
  fi

  # Termux (Android)
  if [ -n "${PREFIX-}" ] && [ -d "${PREFIX}/bin" ]; then
    PLATFORM="Termux"
  fi

  # iSH (Alpine Linux on iOS)
  if [ -f /etc/alpine-release ] && [ -d /proc/ish ]; then
    PLATFORM="iSH-Alpine"
  fi

  # Si c'est du Linux générique ou WSL, essayons de trouver la distribution
  if [ "$PLATFORM" = "Linux" ] || [ "$PLATFORM" = "WSL" ]; then
    if [ -f /etc/os-release ]; then
      # Méthode moderne et fiable
      . /etc/os-release
      DISTRIB_ID="$NAME"
    elif command -v lsb_release >/dev/null; then
      # Méthode alternative
      DISTRIB_ID=$(lsb_release -si)
    else
      # Dernière tentative en lisant les fichiers *release
      DISTRIB_ID=$(cat /etc/*release 2>/dev/null | head -n1)
    fi
  fi

  # Formatage de la sortie finale
  if [ -n "$DISTRIB_ID" ]; then
    echo "$PLATFORM - $DISTRIB_ID"
  else
    echo "$PLATFORM"
  fi
}

# Exécute la fonction pour afficher le résultat
detect_environment
