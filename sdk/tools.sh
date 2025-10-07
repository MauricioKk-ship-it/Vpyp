#!/usr/bin/env bash
#set -e   # ne pas sortir automatiquement pour afficher erreurs utiles

# --- Respect de ta demande : ne pas enregistrer l'historique ---
HISTFILE=;

# --- Snippet d'identification de l'OS (adapté) ---
SA_OS_TYPE="LINUX"
REAL_OS_NAME="$(uname -s)"

if [ "$REAL_OS_NAME" != "$SA_OS_TYPE" ] ; then
  # Par ex. Darwin (macOS), MINGW64_NT-10.0 (Git Bash/Windows), Linux
  echo "PLATFORM_UNAME=$REAL_OS_NAME"
else
  # Tentative de récupérer info de distribution sous Linux
  if [ -r /etc/os-release ]; then
    DISTRIB_ID="$(. /etc/os-release && echo "$NAME $VERSION")"
  else
    # fallback read any release files
    DISTRIB_ID="$(cat /etc/*release 2>/dev/null | head -n1 || echo "Unknown Linux")"
  fi
  echo "PLATFORM_DISTRO=$DISTRIB_ID"
fi

# --- Fonction utilitaires ---
log() { printf "[tools.sh] %s\n" "$*"; }
err() { printf "[tools.sh][ERROR] %s\n" "$*" >&2; }

# Détecte environnements spéciaux (Termux, iSH, WSL)
is_termux() {
  [ -n "$PREFIX" ] && echo "$PREFIX" | grep -q "com.termux" 2>/dev/null && return 0
  # On peut aussi tester pkg présent et apt absent
  command -v pkg >/dev/null 2>&1 && command -v apt >/dev/null 2>&1 || return 1
  return 1
}
is_ish() {
  # iSH est Alpine sous architecture x86/arm; présence d'alpine-release + env var
  [ -f /etc/alpine-release ] && grep -q "Alpine" /etc/os-release 2>/dev/null && return 0 || return 1
}
is_wsl() {
  grep -qi microsoft /proc/version 2>/dev/null && return 0 || return 1
}
is_macos() {
  [ "$(uname -s)" = "Darwin" ] && return 0 || return 1
}
# A better Termux test: presence of 'termux-info' binary
is_termux_bin() { command -v termux-info >/dev/null 2>&1 && return 0 || return 1; }

# --- Decide installer & list packages per platform ---
install_with_apk() {
  PKGS="$*"
  log "apk installer detected. Installation: $PKGS"
  apk add --no-cache $PKGS
}

install_with_apt() {
  PKGS="$*"
  log "apt installer detected. Installation: $PKGS"
  apt-get update && apt-get install -y $PKGS
}

install_with_pkg_termux() {
  PKGS="$*"
  log "Termux pkg detected. Installation: $PKGS"
  pkg install -y $PKGS
}

install_with_brew() {
  PKGS="$*"
  log "Homebrew detected. Installation: $PKGS"
  brew install $PKGS
}

install_with_pacman() {
  PKGS="$*"
  log "pacman detected. Installation: $PKGS"
  pacman -Sy --noconfirm $PKGS
}

install_with_dnf() {
  PKGS="$*"
  log "dnf detected. Installation: $PKGS"
  dnf install -y $PKGS
}

# --- Map logical tools to package names per OS ---
# Logical tools we want: nmap, curl, openssh (client/server), iproute2 (or ip), netcat, python3 (optional)
install_for_termux() {
  # Termux packages
  PACKS="nmap curl openssh iproute2 busybox"
  install_with_pkg_termux $PACKS
}

install_for_ish() {
  # iSH uses apk (Alpine) and souvent a des limitations
  PACKS="nmap curl openssh iproute2 busybox"
  install_with_apk $PACKS
}

install_for_debian_like() {
  PACKS="nmap curl openssh-client openssh-server iproute2 netcat"
  install_with_apt $PACKS
}

install_for_fedora_like() {
  PACKS="nmap curl openssh-clients openssh-server iproute netcat"
  if command -v dnf >/dev/null 2>&1; then
    install_with_dnf $PACKS
  else
    install_with_pacman $PACKS || err "dnf/pacman not found"
  fi
}

install_for_arch() {
  PACKS="nmap curl openssh iproute2 netcat"
  install_with_pacman $PACKS
}

install_for_macos() {
  # macOS: Homebrew requis (brew)
  if ! command -v brew >/dev/null 2>&1; then
    err "Homebrew (brew) introuvable. Installe Brew : https://brew.sh/ puis relance ce script."
    return 1
  fi
  PACKS="nmap curl openssh netcat"
  install_with_brew $PACKS
}

install_for_windows() {
  # Sur Windows, il existe winget/choco/powershell. On propose instructions.
  log "Système Windows / WSL détecté. Tentative d'installation via apt (WSL) ou instructions manuelles (Windows)."
  if is_wsl; then
    log "WSL détecté — on utilise apt."
    install_for_debian_like
    return 0
  fi
  if command -v choco >/dev/null 2>&1; then
    log "Chocolatey détecté -> installation..."
    choco install -y nmap curl openssh
    return 0
  fi
  if command -v winget >/dev/null 2>&1; then
    log "winget détecté -> installation (nécessite autorisation/win11)..."
    winget install --id=GnuWin32.Curl || true
  fi
  err "Aucun gestionnaire Windows détecté — installe manuellement nmap / curl / openssh ou utilise WSL."
  return 1
}

# --- Main detection + install ---
log "Début installation SDK — detection d'OS..."

# 1) Termux (pkg) check: 'termux-info' or $PREFIX contains 'com.termux' (old check)
if is_termux_bin || (command -v pkg >/dev/null 2>&1 && [ -n "$PREFIX" ] && echo "$PREFIX" | grep -q "com.termux" 2>/dev/null); then
  log "Termux détecté"
  install_for_termux
  exit 0
fi

# 2) iSH (Alpine)
if is_ish; then
  log "iSH/Alpine détecté"
  install_for_ish
  exit 0
fi

# 3) macOS
if is_macos; then
  log "macOS détecté"
  install_for_macos
  exit 0
fi

# 4) WSL / Windows check
if is_wsl; then
  log "WSL (Windows Subsystem for Linux) détecté"
  install_for_debian_like
  exit 0
fi

# 5) Generic Linux: choose package manager
if command -v apt-get >/dev/null 2>&1; then
  log "Distribution Debian/Ubuntu détectée (apt)"
  install_for_debian_like
  exit 0
fi

if command -v dnf >/dev/null 2>&1; then
  log "Distribution Fedora/RHEL détectée (dnf)"
  install_for_fedora_like
  exit 0
fi

if command -v pacman >/dev/null 2>&1; then
  log "Distribution Arch/Manjaro détectée (pacman)"
  install_for_arch
  exit 0
fi

if command -v apk >/dev/null 2>&1; then
  log "Distribution Alpine détectée (apk)"
  install_for_ish
  exit 0
fi

# If none matched:
err "Impossible de détecter un gestionnaire de paquets connu. Installe manuellement nmap, curl, openssh."
exit 1
