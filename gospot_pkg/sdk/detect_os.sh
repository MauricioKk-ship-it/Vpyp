#!/bin/sh
# detect_os.sh — détection multi-plateformes (iSH, Termux, WSL, macOS, Linux)
# POSIX-friendly : évite features non-portables

SA_OS_TYPE="LINUX"
REAL_OS_NAME=$(uname 2>/dev/null || echo "unknown")
DETECT_INFO=""
IS_TERMINAL_IOSISH=0

# Disable history inside scripts where needed
: "${HISTFILE:=}"
export HISTFILE=""

# Helper helpers
file_contains() {
  [ -f "$1" ] && grep -qi "$2" "$1"
}

detect_environment() {
  # Basic uname detection
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

  # WSL detection
  if [ -f /proc/version ] && grep -qi microsoft /proc/version 2>/dev/null; then
    PLATFORM="WSL"
  fi

  # Termux detection (environment variables present in Termux)
  if [ -n "${PREFIX:-}" ] && [ -d "${PREFIX}/bin" ] && [ -f /data/data/com.termux/files/usr/bin/bash ] 2>/dev/null; then
    PLATFORM="Termux"
  fi

  # iSH detection (presence of /etc/alpine-release and uname Linux on iOS)
  if [ -f /etc/alpine-release ] && file_contains /proc/self/cgroup "iSH" 2>/dev/null || file_contains /system/build.prop "android" 2>/dev/null; then
    # Note: iSH may not always mark itself; rely on alpine release presence & environment
    PLATFORM="iSH-Alpine"
  fi

  # Fallback: try reading /etc/*release for distro name
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ -n "${NAME:-}" ]; then
      DISTRIB_ID="$NAME"
    fi
  else
    DISTRIB_ID=$(cat /etc/*release 2>/dev/null | head -n1 || echo "$PLATFORM")
  fi

  DETECT_INFO="${PLATFORM}${DISTRIB_ID:+ - $DISTRIB_ID}"
  echo "$DETECT_INFO"
}

# Usage: call detect_environment and it prints result.
