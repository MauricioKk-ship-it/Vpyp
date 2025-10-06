#!/bin/sh
# tools.sh — Installe les paquets du SDK silencieusement et affiche une jauge propre.
# Compatible: Alpine (apk), Debian/Ubuntu (apt), Termux (pkg/apt), macOS (brew), Fedora (dnf), Arch (pacman)
set -eu

# Load detect function (assuming detect_os.sh in same dir)
THIS_DIR=$(cd "$(dirname "$0")" && pwd)
if [ -f "${THIS_DIR}/../detect_os.sh" ]; then
  # shellcheck source=/dev/null
  . "${THIS_DIR}/../detect_os.sh"
else
  # embed minimal detection
  REAL_OS_NAME=$(uname 2>/dev/null || echo "unknown")
  DISTRIB_ID=""
fi

platform=$(detect_environment 2>/dev/null || echo "${REAL_OS_NAME}")

# Packages to install — customise
PKGS="curl wget openssh-client openssh tcpdump iputils nmap"

# Determine package manager and install command template
detect_pkg_manager() {
  if command -v apk >/dev/null 2>&1; then
    echo "apk"
  elif command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v pkg >/dev/null 2>&1 && [ "$(uname -o 2>/dev/null)" = "Android" ] || [ -n "${PREFIX-}" ] && command -v pkg >/dev/null 2>&1; then
    # Termux 'pkg' wrapper (falls back to apt)
    echo "pkg"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  elif command -v brew >/dev/null 2>&1; then
    echo "brew"
  else
    echo "unknown"
  fi
}

PKG_MANAGER=$(detect_pkg_manager)

# Progress bar helpers
print_progress() {
  # $1 = current, $2 = total
  cur=$1; tot=$2
  width=40
  filled=$(( (cur * width) / tot ))
  empty=$(( width - filled ))
  percent=$(( (cur * 100) / tot ))
  printf "\r["
  i=0
  while [ $i -lt "$filled" ]; do printf "#"; i=$((i+1)); done
  j=0
  while [ $j -lt "$empty" ]; do printf "-"; j=$((j+1)); done
  printf "] %3d%% (%d/%d)" "$percent" "$cur" "$tot"
  if [ "$cur" -ge "$tot" ]; then
    printf "\n"
  fi
}

# Quiet install wrapper that installs packages one-by-one and updates progress
install_packages_quiet() {
  pkgs_list=$1
  # split into array (POSIX portable loop)
  set -f
  IFS=' '
  # count packages
  count=0
  for p in $pkgs_list; do count=$((count+1)); done

  idx=0
  for p in $pkgs_list; do
    idx=$((idx+1))
    print_progress "$idx" "$count"
    case "$PKG_MANAGER" in
      apk)
        # update once before first install
        if [ "$idx" -eq 1 ]; then apk update >/dev/null 2>&1 || true; fi
        apk add --no-progress --no-cache -q "$p" >/dev/null 2>&1 || \
          apk add -q "$p" >/dev/null 2>&1 || echo "[!] échec installation $p"
        ;;
      apt)
        if [ "$idx" -eq 1 ]; then DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1 || true; fi
        DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$p" >/dev/null 2>&1 || echo "[!] échec installation $p"
        ;;
      pkg)
        # Termux 'pkg' (wrapper)
        pkg install -y "$p" >/dev/null 2>&1 || apt install -y -qq "$p" >/dev/null 2>&1 || echo "[!] échec $p"
        ;;
      dnf)
        dnf install -y -q "$p" >/dev/null 2>&1 || echo "[!] échec $p"
        ;;
      pacman)
        pacman -Sy --noconfirm --quiet "$p" >/dev/null 2>&1 || echo "[!] échec $p"
        ;;
      brew)
        brew install "$p" >/dev/null 2>&1 || echo "[!] échec $p"
        ;;
      *)
        echo "[!] Gestionnaire de paquets non supporté. Installez manuellement: $p"
        ;;
    esac
    sleep 0.15 # lissage de la progress bar visuelle
  done
  set +f
  echo "[*] Installation terminée."
}

# Download with progress: prefer curl --progress-bar, fallback to wget
download_with_progress() {
  url="$1"; out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -L --progress-bar -o "$out" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget --progress=bar:force -O "$out" "$url"
  else
    echo "[!] ni curl ni wget disponibles; impossible de télécharger $url"
    return 1
  fi
}

# Entrée : exécution
main() {
  echo "[GoSpot] Détection plateforme: $platform"
  echo "[GoSpot] Gestionnaire de paquets détecté: $PKG_MANAGER"
  echo "[GoSpot] Préparation de l'installation des outils SDK..."

  # Example: only try to install network utils that make sense on each platform
  install_packages_quiet "$PKGS"

  # Example: download a SDK tarball silently and show progress (if you host one)
  # URL_EXAMPLE="https://example.com/gospot-sdk.tar.gz"
  # TMP=/tmp/gospot-sdk.tar.gz
  # echo "[*] Téléchargement SDK..."
  # download_with_progress "$URL_EXAMPLE" "$TMP"
  # echo "[*] Extraction..."
  # tar -xzf "$TMP" -C /opt/gospot-sdk || true

  echo "[GoSpot] SDK prêt."
}

main "$@"
