import os

def banner():
    os.system("clear" if os.name == "posix" else "cls")
    print(r"""
  ____       _____             _   
 / ___| ___ | ____|_ __   ___ | |_ 
 \___ \/ _ \|  _| | '_ \ / _ \| __|
  ___) | (_) | |___| | | | (_) | |_ 
 |____/ \___/|_____|_| |_|\___/ \__|
    Hybrid Python + Shell CLI
   by Mauricio-100 (GoSpot)
""")

def pause():
    input("\n[⏸] Appuie sur Entrée pour continuer...")
