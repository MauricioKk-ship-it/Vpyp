#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import subprocess
import sys
from modules import system, network  # assure-toi que ces modules existent avec les fonctions correspondantes

# ----------------------------
# Détection de l'OS
# ----------------------------
def detect_os():
    """
    Détecte le système d'exploitation.
    Retourne 'TERMUX', 'LINUX', 'MAC' ou 'UNKNOWN'.
    """
    prefix = os.getenv("PREFIX", "")
    uname_sys = os.uname().sysname.upper()

    if "com.termux" in prefix:
        return "TERMUX"
    elif "DARWIN" in uname_sys:
        return "MAC"
    elif "LINUX" in uname_sys:
        return "LINUX"
    else:
        return "UNKNOWN"


# ----------------------------
# Installation et configuration des outils essentiels
# ----------------------------
def setup_env():
    real_os = detect_os()
    print("\n[⚙️] Vérification des outils essentiels...")

    pkgs = ["openssh", "nmap", "curl", "git"]

    if real_os == "TERMUX":
        print("[📱] Environnement Termux détecté")
        for p in pkgs:
            if not system.check_package(p):
                os.system(f"pkg install -y {p}")  # Termux n'utilise pas sudo

    elif real_os == "MAC":
        print("[🍏] macOS détecté")
        for p in pkgs:
            if not system.check_package(p):
                os.system(f"brew install {p} || echo '{p} manquant'")

    elif real_os == "LINUX":
        print("[🐧] Linux détecté")
        for p in pkgs:
            if not system.check_package(p):
                os.system(f"sudo apt install -y {p} || sudo pacman -S --noconfirm {p}")

    else:
        print("[❓] OS inconnu, installation des outils ignorée.")

    print("\n[✅] Configuration terminée.\n")
    input("[⏸] Appuie sur Entrée pour continuer.")


# ----------------------------
# Menu principal
# ----------------------------
def main_menu():
    while True:
        os.system("clear" if detect_os() != "TERMUX" else "clear")
        print(r"""
  ____       _____             _
 / ___| ___ | ____|_ __   ___ | |_
 \___ \/ _ \|  _| | '_ \ / _ \| __|
  ___) | (_) | |___| | | | (_) | |_
 |____/ \___/|_____|_| |_|\___/ \__|
    Hybrid Python + Shell CLI
   by Mauricio-100 (GoSpot)
        """)
        print("""
[1] 🌐 Scanner le réseau local
[2] 🔐 Gérer les clés SSH
[3] 🧰 Installer/Mettre à jour les outils SDK
[4] ⚙️ Vérifier le système et l’environnement
[5] 🚪 Quitter
""")
        choice = input("Choisis une option ➤ ").strip()

        if choice == "1":
            hosts = network.scan_network()
            if hosts:
                print("\n[🌐] Hôtes détectés :")
                for h in hosts:
                    print(f" - {h}")
            else:
                print("[⚠️] Aucun hôte détecté.")
            input("\n[⏸] Appuie sur Entrée pour continuer.")

        elif choice == "2":
            from modules import ssh_utils
            ssh_utils.manage_ssh_keys()
            input("\n[⏸] Appuie sur Entrée pour continuer.")

        elif choice == "3":
            setup_env()

        elif choice == "4":
            print("\n[⚙️] Vérification de l'environnement...")
            print(f"[💻] OS détecté : {detect_os()}")
            input("\n[⏸] Appuie sur Entrée pour continuer.")

        elif choice == "5":
            print("[🚪] Au revoir !")
            sys.exit(0)
        else:
            print("[❌] Option invalide.")
            input("\n[⏸] Appuie sur Entrée pour continuer.")


# ----------------------------
# Lancement du menu si ce fichier est exécuté
# ----------------------------
if __name__ == "__main__":
    main_menu()
