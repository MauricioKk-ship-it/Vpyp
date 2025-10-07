   #!/usr/bin/env python3
import os, subprocess, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SDK = ROOT / "sdk"

def run_shell(script, *args):
    """Exécute un script shell du dossier sdk/"""
    cmd = f"bash {SDK/script.name} {' '.join(args)}"
    print(f"→ {cmd}")
    os.system(cmd)

def clear(): os.system("clear" if os.name == "posix" else "cls")

def menu():
    while True:
        clear()
        print("""
==============================
     🚀 GoSpot Hybrid CLI
==============================
1) Lancer le serveur
2) Lancer le client
3) Installer SDK (shell)
4) Scanner le réseau (Python)
5) Générer clé SSH
6) Quitter
""")
        ch = input("> ").strip()
        if ch == "1":
            run_shell(SDK / "gos.sh", "server")
        elif ch == "2":
            run_shell(SDK / "gos.sh", "client")
        elif ch == "3":
            run_shell(SDK / "tools.sh")
        elif ch == "4":
            from modules.network import detect_ip
            print(f"IP locale : {detect_ip()}")
            input("Entrée pour continuer...")
        elif ch == "5":
            from modules.ssh_utils import ensure_ssh_key
            ensure_ssh_key()
            input("Entrée pour continuer...")
        elif ch == "6":
            print("Bye 👋")
            sys.exit(0)
        else:
            print("Choix invalide.")
            input("Entrée pour continuer...")

if __name__ == "__main__":
    menu()             
