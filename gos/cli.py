#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GoSpot Hybrid CLI - Python + Shell version
Auteur : Mauricio-100
"""

import os
import subprocess
from modules import ui, system, ssh_utils, network

# =====================================================
# 🔍 Détection automatique du système d’exploitation
# =====================================================
def detect_os():
    """Détecte le type de système d’exploitation"""
    histfile = ""
    os_type = "LINUX"
    try:
        real_os = subprocess.check_output("uname", shell=True, text=True).strip()
    except subprocess.CalledProcessError:
        real_os = "UNKNOWN"

    if real_os != os_type:
        print(f"[🧩] OS détecté : {real_os}")
    else:
        try:
            distrib = subprocess.check_output("cat /etc/*release", shell=True, text=True)
            print("[🧩] Détail système :", distrib.splitlines()[0])
        except Exception:
            print("[🧩] OS Linux générique détecté.")

    return real_os.upper()


# =====================================================
# 🧰 Installation automatique selon l’OS
# =====================================================
def setup_env():
    real_os = detect_os()

    print("\n[⚙️] Vérification des outils essentiels...")
    if "TERMUX" in os.getenv("PREFIX", ""):
        print("[📱] Environnement Termux détecté")
        pkgs = ["openssh", "nmap", "curl", "git"]
        for p in pkgs:
            if not system.check_package(p):
                print(f"→ Installation de {p} ...")
                os.system(f"pkg install -y {p}")

    elif "DARWIN" in real_os or "MAC" in real_os:
        print("[🍏] macOS ou iSH détecté")
        pkgs = ["nmap", "curl", "git", "openssh"]
        for p in pkgs:
            if not system.check_package(p):
                os.system(f"apk add {p} || brew install {p}")

    elif "LINUX" in real_os:
        print("[🐧] Linux (Debian/Ubuntu/Arch...) détecté")
        pkgs = ["nmap", "curl", "git", "openssh-client"]
        for p in pkgs:
            if not system.check_package(p):
                os.system(f"sudo apt install -y {p} || sudo pacman -S --noconfirm {p}")

    elif "NT" in os.name:
        print("[🪟] Windows détecté")
        print("⚠️ Certains modules shell ne sont pas disponibles sous Windows.")
    else:
        print("[❓] Système inconnu – exécution en mode basique.")

    print("\n[✅] Configuration terminée.\n")


# =====================================================
# 🎛️ Menu principal
# =====================================================
def main_menu():
    while True:
        ui.banner()
        print("""
[1] 🌐 Scanner le réseau local
[2] 🔐 Gérer les clés SSH
[3] 🧰 Installer/Mettre à jour les outils SDK
[4] ⚙️ Vérifier le système et l’environnement
[5] 🚪 Quitter
""")
        choice = input("Choisis une option ➤ ")

        if choice == "1":
            network.scan_network()
            ui.pause()

        elif choice == "2":
            ssh_utils.ensure_ssh_key()
            ui.pause()

        elif choice == "3":
            setup_env()
            ui.pause()

        elif choice == "4":
            detect_os()
            ui.pause()

        elif choice == "5":
            print("\n👋 Au revoir Mauricio-100 !")
            break

        else:
            print("[⚠️] Choix invalide.")
            ui.pause()


# =====================================================
# 🚀 Exécution
# =====================================================
if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        print("\n\n🛑 Interruption par l'utilisateur.")
