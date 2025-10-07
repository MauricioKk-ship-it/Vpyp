#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
try:
    import requests
except ImportError:
    print("La librairie 'requests' n'est pas installée. Veuillez l'installer avec : pip3 install requests")
    sys.exit(1)

# Définition des chemins
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
LOCAL_SDK_DIR = os.path.join(BASE_DIR, "sdk")

def run_command(command_name, args):
    """ Exécute une commande, qu'elle soit locale ou distante. """

    # --- Commande pour script distant ---
    if command_name == "tools":
        print("🔧 Téléchargement et exécution du script distant 'tools.sh'...")
        script_url = "https://raw.githubusercontent.com/Mauricio-100/gospot-sdk-host/main/scripts/tools.sh"
        
        try:
            response = requests.get(script_url, timeout=10)
            response.raise_for_status() # Lève une erreur si le téléchargement échoue (ex: 404)
            
            # Utiliser un chemin temporaire fiable
            temp_script_path = os.path.join("/tmp", "gospot_tools.sh")
            with open(temp_script_path, "w", encoding="utf-8") as f:
                f.write(response.text)
            
            os.chmod(temp_script_path, 0o755)
            subprocess.run([temp_script_path] + args, check=False)

        except requests.exceptions.RequestException as e:
            print(f"❌ Erreur de réseau : Impossible de télécharger le script. {e}")
        except Exception as e:
            print(f"❌ Une erreur est survenue : {e}")

    # --- Commande pour script local ---
    else:
        script_path = os.path.join(LOCAL_SDK_DIR, f"{command_name}.sh")
        
        if os.path.exists(script_path):
            print(f"🚀 Exécution du script local : '{command_name}.sh'")
            try:
                os.chmod(script_path, 0o755)
                subprocess.run([script_path] + args, check=False)
            except Exception as e:
                print(f"❌ Erreur lors de l'exécution du script local : {e}")
        else:
            print(f"❌ Erreur : La commande '{command_name}' est inconnue.")
            print("\nEssayez l'une des commandes disponibles :")
            try:
                # Lister les scripts locaux disponibles
                scripts = [f.replace('.sh', '') for f in os.listdir(LOCAL_SDK_DIR) if f.endswith('.sh')]
                print(f"  Locales : {', '.join(scripts)}")
            except FileNotFoundError:
                print("  (Le dossier des scripts locaux est introuvable)")
            print("  Distante : tools")

def show_help():
    print("Bienvenue sur GoSpot CLI !")
    print("\nUsage: gospot <commande> [arguments...]")
    print("\nExemples :")
    print("  gospot sysinfo")
    print("  gospot ssh")
    print("  gospot tools")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        command = sys.argv
        arguments = sys.argv[2:]
        run_command(command, arguments)
    else:
        show_help()
