#!/usr/bin/env sh
# =========================================================
#  detect_os.sh — Détection automatique du système
#  Auteur : Mauricio
#  Projet : GoSpot CLI (Vpyp)
# =========================================================

OS="unknown"
ARCH=$(uname -m 2>/dev/null || echo "unknown")

case "$(uname | tr '[:upper:]' '[:lower:]')" in
    linux*)
        if [ -f "/proc/version" ] && grep -qi "android" /proc/version; then
            OS="android"
        else
            OS="linux"
        fi
        ;;
    darwin*)
        OS="macos"
        ;;
    msys*|mingw*|cygwin*|nt*)
        OS="windows"
        ;;
    ios*)
        OS="ios"
        ;;
    *)
        OS="unknown"
        ;;
esac

echo "$OS:$ARCH"
