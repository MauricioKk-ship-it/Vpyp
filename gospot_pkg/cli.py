#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# ==============================================================================
# GoSpot CLI - Point d'entrée principal
# Rôle : Analyse les commandes de l'utilisateur, exécute les scripts locaux
#        ou télécharge et exécute les scripts distants.
# Auteur: Mauricio-100 & Gemini
# ==============================================================================

import os
import sys
import subprocess
from gospot_pkg.modules import system, network
# Essayer d'importer la librairie 'requests'. Si elle n'existe pas,
# afficher un message d'aide clair à l'utilisateur.
try:
    import requests
except ImportError:
    print("\033[1;31mERREUR : La librairie 'requests' est nécessaire mais n'est pas installée.\033[0m")
    print("\033[1;33mVeuillez l'installer avec la commande : pip3 install requests\033[0m")
    sys.exit(1)

# --- Définition des chemins et constantes ---
# Répertoire de base du package (où se trouve ce fichier cli.py)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
# Chemin vers le dossier contenant tous nos scripts Shell locaux
LOCAL_SDK_DIR = os.path.join(BASE_DIR, "sdk")
# URL du script distant 'tools.sh' (maintenu sur gospot-sdk-host)
REMOTE_TOOLS_URL = "https://raw.githubusercontent.com/Mauricio-100/gospot-sdk-host/main/scripts/tools.sh"


def run_command(command_name, args):
    """
    Exécute une commande en déterminant si elle est locale ou distante.
    """
    # --- Cas Spécial 1 : Le script 'tools' est toujours distant ---
    if command_name == "tools":
        print("🔧 \033[0;36mTéléchargement et exécution du script distant 'tools.sh'...\033[0m")
        try:
            # Télécharger le contenu avec un timeout pour éviter les blocages
            response = requests.get(REMOTE_TOOLS_URL, timeout=10)
            response.raise_for_status()  # Lève une erreur si le téléchargement échoue (ex: 404)

            # Chemin vers un fichier temporaire où stocker le script téléchargé
            temp_script_path = os.path.join("/tmp", "gospot_tools.sh")
            with open(temp_script_path, "w", encoding="utf-8") as f:
                f.write(response.text)

            # Rendre le script temporaire exécutable
            os.chmod(temp_script_path, 0o755)
            # Exécuter le script avec ses arguments
            subprocess.run([temp_script_path] + args, check=False)

        except requests.exceptions.RequestException as e:
            print(f"❌ \033[1;31mErreur de réseau : Impossible de télécharger le script. {e}\033[0m")
        except Exception as e:
            print(f"❌ \033[1;31mUne erreur inattendue est survenue : {e}\033[0m")

    # --- Cas 2 : Toutes les autres commandes sont locales ---
    else:
        script_path = os.path.join(LOCAL_SDK_DIR, f"{command_name}.sh")

        if os.path.exists(script_path):
            print(f"🚀 \033[0;32mExécution du script local : '{command_name}.sh'\033[0m")
            try:
                # S'assurer que le script est exécutable
                os.chmod(script_path, 0o755)
                # Exécuter le script avec ses arguments
                subprocess.run([script_path] + args, check=False)
            except Exception as e:
                print(f"❌ \033[1;31mErreur lors de l'exécution du script local : {e}\033[0m")
        else:
            # Si la commande ne correspond à rien, afficher une aide
            print(f"❌ \033[1;31mErreur : La commande '{command_name}' est inconnue.\033[0m")
            list_available_commands()


def list_available_commands():
    """Affiche la liste des commandes locales et distantes disponibles."""
    print("\n\033[1;33mEssayez l'une des commandes suivantes :\033[0m")
    try:
        # Lister les scripts locaux en scannant le dossier sdk/
        local_scripts = [f.replace('.sh', '') for f in os.listdir(LOCAL_SDK_DIR) if f.endswith('.sh')]
        if local_scripts:
            print(f"  \033[0;36mCommandes locales :\033[0m {', '.join(sorted(local_scripts))}")
    except FileNotFoundError:
        print("  (Le dossier des scripts locaux 'sdk/' est introuvable)")
    
    print("  \033[0;36mCommande distante :\033[0m tools")


def show_main_help():
    """Affiche le message d'aide principal quand aucune commande n'est donnée."""
    print("\n\033[1;32mBienvenue sur GoSpot CLI (Dragon Edition) 🐉\033[0m")
    print("\nUsage: gospot <commande> [arguments...]")
    print("\nExemples :")
    print("  gospot sysinfo")
    print("  gospot ssh")
    print("  gospot setup-net-tools")
    list_available_commands()


# --- Point d'entrée du programme ---
if __name__ == "__main__":
    # Vérifie si au moins une commande a été passée en argument
    if len(sys.argv) > 1:
        command_to_run = sys.argv[1]
        arguments_for_script = sys.argv[2:]  # Tout ce qui suit la commande
        run_command(command_to_run, arguments_for_script)
    else:
        # Si on lance juste "gospot", afficher l'aide
        show_main_help()
