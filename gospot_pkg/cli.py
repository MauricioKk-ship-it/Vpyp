#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import platform
import subprocess
import urllib.request
import tarfile
import shutil
from time import sleep

SDK_URL = "https://github.com/Mauricio-100/gospot-sdk-host/raw/main/public/gospot-sdk-1.0.0.tar.gz"
SDK_PATH = "/tmp/gospot-sdk"

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def print_banner():
    clear()
    print("+----------------------------------------+")
    print("|      GoSpot CLI — Python ( by Dragon ) |")
    print("+----------------------------------------+")
    print(f"[Appareil] {platform.system()} {platform.machine()}")
    print("")

def show_menu():
    print("--- Connexion ---")
    print("  1. Client (Rejoindre)")
    print("  2. Serveur (Partager)")
    print("\n--- Outils & SDK ---")
    print("  3. Installer / Mettre à jour SDK & outils")
    print("  4. Créer / Afficher clé SSH")
    print("  5. Administration du Serveur")
    print("\n  6. Quitter\n")

def run_shell(script_path):
    if not os.path.exists(script_path):
        print(f"[!] Script introuvable: {script_path}")
        input("Appuyez Entrée pour revenir au menu...")
        return
    try:
        subprocess.run(["bash", script_path], check=True)
    except KeyboardInterrupt:
        print("\n[!] Reçu signal Ctrl+C. Arrêt.")
        sleep(1)
    except Exception as e:
        print(f"[!] Erreur: {e}")
        input("Appuyez Entrée pour revenir au menu...")

def install_sdk():
    print(f"[GoSpot] Téléchargement du SDK depuis: {SDK_URL}")
    tmp_tar = "/tmp/gospot-sdk.tar.gz"
    try:
        urllib.request.urlretrieve(SDK_URL, tmp_tar, reporthook=progress_hook)
    except Exception as e:
        print(f"[!] Erreur téléchargement SDK: {e}")
        input("Appuyez Entrée pour revenir au menu...")
        return

    if os.path.exists(SDK_PATH):
        shutil.rmtree(SDK_PATH)
    os.makedirs(SDK_PATH, exist_ok=True)

    with tarfile.open(tmp_tar) as tar:
        tar.extractall(path=SDK_PATH)
    os.remove(tmp_tar)
    print("\n[✔] SDK installé avec succès!")
    input("Appuyez Entrée pour revenir au menu...")

def progress_hook(count, block_size, total_size):
    progress = int(count * block_size * 100 / total_size)
    progress = min(progress, 100)
    bar = '#' * (progress // 2) + '-' * (50 - progress // 2)
    print(f"\r[{bar}] {progress}% ", end='', flush=True)

def main():
    while True:
        print_banner()
        show_menu()
        choice = input("Votre choix (1-6) : ").strip()
        if choice == "1":
            print("[GoSpot] Lancement du client...")
            run_shell(os.path.join(SDK_PATH, "sdk/scripts/client.sh"))
        elif choice == "2":
            print("[GoSpot] Lancement du serveur...")
            run_shell(os.path.join(SDK_PATH, "sdk/scripts/server.sh"))
        elif choice == "3":
            install_sdk()
        elif choice == "4":
            run_shell(os.path.join(SDK_PATH, "sdk/scripts/ssh.sh"))
        elif choice == "5":
            run_shell(os.path.join(SDK_PATH, "sdk/scripts/admin.sh"))
        elif choice == "6":
            print("[GoSpot] Bye 👋")
            sys.exit(0)
        else:
            print("[!] Choix invalide. Réessayez.")
            sleep(1)

if __name__ == "__main__":
    main()
