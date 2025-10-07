import subprocess, os

def run(cmd, capture=False):
    """Exécute une commande shell"""
    print(f"$ {cmd}")
    if capture:
        return subprocess.check_output(cmd, shell=True, text=True)
    return subprocess.call(cmd, shell=True)

def clear():
    os.system('clear' if os.name == 'posix' else 'cls')

def check_package(pkg):
    """Vérifie si un paquet est installé"""
    try:
        subprocess.check_output(f"command -v {pkg}", shell=True)
        return True
    except subprocess.CalledProcessError:
        return False
