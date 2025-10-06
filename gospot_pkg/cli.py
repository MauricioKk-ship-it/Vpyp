#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import subprocess
from time import sleep
from pathlib import Path

PKG_DIR = Path(__file__).resolve().parent
SCRIPTS = {
    "client": PKG_DIR / "client.sh",
    "server": PKG_DIR / "server.sh",
    "ssh": PKG_DIR / "sdk" / "ssh.sh",
    "tools": PKG_DIR / "sdk" / "tools.sh",
    "admin": PKG_DIR / "sdk" / "admin.sh",
}

# =======================
# Styles et couleurs
# =======================
class Style:
    RED = '\033[91m'
    GREEN = '\033[92m'
    CYAN = '\033[96m'
    YELLOW = '\033[93m'
    MAGENTA = '\033[95m'
    BOLD = '\033[1m'
    END = '\033[0m'

def print_boxed(title, subtitle=None):
    text = title if subtitle is None else f"{title} — {subtitle}"
    width = max(40, len(text) + 4)
    print(Style.CYAN + "+" + "-" * width + "+")
    print("|" + " " * ((width - len(text)) // 2) + Style.BOLD + text + Style.END + Style.CYAN +
          " " * (width - len(text) - ((width - len(text)) // 2)) + "|")
    print("+" + "-" * width + "+" + Style.END)

def run_shell(script_path, args=None, env=None):
    script = Path(script_path)
    if not script.exists():
        print(Style.RED + f"[!] Script introuvable: {script}" + Style.END)
        return 1
    if not os.access(script, os.X_OK):
        # rendre exécutable si possible
        try:
            script.chmod(script.stat().st_mode | 0o111)
        except Exception:
            pass
    cmd = [str(script)]
    if args:
        cmd += list(args)
    try:
        p = subprocess.run(cmd, check=False)
        return p.returncode
    except KeyboardInterrupt:
        print("\n" + Style.RED + "Annulé par l'utilisateur" + Style.END)
        return 130
    except Exception as e:
        print(Style.RED + f"Erreur d'exécution: {e}" + Style.END)
        return 1

def start_client():
    print(Style.GREEN + "[*] Démarrage du client..." + Style.END)
    return run_shell(SCRIPTS["client"])

def start_server():
    print(Style.GREEN + "[*] Démarrage du serveur..." + Style.END)
    return run_shell(SCRIPTS["server"])

def install_tools():
    print(Style.YELLOW + "[*] Installation des outils SDK..." + Style.END)
    return run_shell(SCRIPTS["tools"])

def create_ssh_key():
    print(Style.YELLOW + "[*] Création / affichage clé SSH..." + Style.END)
    return run_shell(SCRIPTS["ssh"])

def admin_tools():
    print(Style.MAGENTA + "[*] Outils d'administration..." + Style.END)
    return run_shell(SCRIPTS["admin"])

def clear_term():
    os.system("clear" if os.name != "nt" else "cls")

def main_menu():
    while True:
        clear_term()
        print_boxed("GoSpot CLI", "Hacker Edition — Python launcher")
        print(Style.CYAN + "\n--- Connexion ---" + Style.END)
        print("  1. Client (Rejoindre)")
        print("  2. Serveur (Partager)")
        print(Style.YELLOW + "\n--- Outils & SDK ---" + Style.END)
        print("  3. Installer les outils")
        print("  4. Créer / afficher la clé SSH")
        print("  5. Administration du Serveur")
        print("\n  6. Quitter\n")

        choice = input(Style.CYAN + "Votre choix (1-6) : " + Style.END).strip()
        if choice == "1":
            start_client()
        elif choice == "2":
            start_server()
        elif choice == "3":
            install_tools()
        elif choice == "4":
            create_ssh_key()
        elif choice == "5":
            admin_tools()
        elif choice == "6":
            print(Style.RED + "Au revoir !" + Style.END)
            sys.exit(0)
        else:
            print(Style.RED + "Choix invalide." + Style.END)
        print("\nAppuyez sur Entrée pour revenir au menu...")
        try:
            input()
        except KeyboardInterrupt:
            sys.exit(0)

def main():
    try:
        main_menu()
    except KeyboardInterrupt:
        print("\n" + Style.RED + "Arrêt CLI" + Style.END)
        sys.exit(0)

if __name__ == "__main__":
    main()
