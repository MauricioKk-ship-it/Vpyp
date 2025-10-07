#!/usr/bin/env python3
# ==============================================================
#  GoSpot CLI — Powered by GoSpot SDK
#  Author: Mauricio
#  Repository: https://github.com/Mauricio-100/Vpyp
# ==============================================================
#  Ce client télécharge automatiquement le SDK GoSpot depuis
#  le dépôt gospot-sdk-host, extrait les outils et permet
#  d'exécuter directement les utilitaires inclus.
# ==============================================================

import os
import sys
import tarfile
import tempfile
import urllib.request
import subprocess

SDK_URL = "https://github.com/Mauricio-100/gospot-sdk-host/raw/main/public/gospot-sdk-1.0.0.tar.gz"
LOCAL_CACHE = os.path.expanduser("~/.gospot-sdk")
TOOLS_DIR = os.path.join(LOCAL_CACHE, "gospot-sdk", "sdk", "scripts")

# --------------------------------------------------------------
# Téléchargement du SDK
# --------------------------------------------------------------
def download_sdk():
    os.makedirs(LOCAL_CACHE, exist_ok=True)
    tar_path = os.path.join(LOCAL_CACHE, "gospot-sdk.tar.gz")

    print(f"📥 Téléchargement du SDK depuis : {SDK_URL}")
    urllib.request.urlretrieve(SDK_URL, tar_path)
    print(f"✅ SDK téléchargé → {tar_path}")

    with tarfile.open(tar_path, "r:gz") as tar:
        tar.extractall(LOCAL_CACHE)
    print("📦 SDK extrait avec succès.")
    os.remove(tar_path)

# --------------------------------------------------------------
# Vérification ou téléchargement automatique
# --------------------------------------------------------------
def ensure_sdk_ready():
    if not os.path.exists(TOOLS_DIR):
        print("⚙️  SDK introuvable localement. Téléchargement en cours...")
        download_sdk()
    else:
        print("✅ SDK déjà présent localement.")

# --------------------------------------------------------------
# Exécution d’un outil shell du SDK
# --------------------------------------------------------------
def run_tool(tool_name, *args):
    ensure_sdk_ready()
    tool_path = os.path.join(TOOLS_DIR, f"{tool_name}.sh")

    if not os.path.isfile(tool_path):
        print(f"❌ Outil '{tool_name}' introuvable dans le SDK.")
        sys.exit(1)

    print(f"🚀 Exécution de {tool_name}.sh ...")
    subprocess.run(["sh", tool_path, *args])

# --------------------------------------------------------------
# Menu d’aide
# --------------------------------------------------------------
def show_help():
    print("""
GoSpot CLI — Contrôle des outils SDK
Usage :
    gospot <commande> [arguments]

Commandes disponibles :
    sysinfo     → Affiche les infos système
    nettools    → Outils réseau
    ssh         → Connexion SSH simplifiée
    speedtest   → Test de vitesse
    admin       → Commandes administratives
    monitor     → Surveillance système
    tools       → Outils utilitaires
    update      → Force la mise à jour du SDK
    help        → Affiche ce message
""")

# --------------------------------------------------------------
# Point d’entrée principal
# --------------------------------------------------------------
def main():
    if len(sys.argv) < 2:
        show_help()
        sys.exit(0)

    cmd = sys.argv[1]

    if cmd == "update":
        print("🔄 Mise à jour manuelle du SDK...")
        download_sdk()
        print("✅ Mise à jour terminée.")
    elif cmd == "help":
        show_help()
    else:
        args = sys.argv[2:]
        run_tool(cmd, *args)

if __name__ == "__main__":
    main()
