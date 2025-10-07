import os
from pathlib import Path
import subprocess

def ensure_ssh_key():
    home = Path.home()
    ssh_dir = home / ".ssh"
    ssh_dir.mkdir(mode=0o700, exist_ok=True)
    key_path = ssh_dir / "id_rsa"
    if key_path.exists():
        print(f"[✅] Clé SSH déjà existante : {key_path}")
        return
    print("[🔐] Génération d'une nouvelle paire de clés SSH (RSA 4096 bits)...")
    subprocess.run(f'ssh-keygen -t rsa -b 4096 -f "{key_path}" -N ""', shell=True, check=False)
    print(f"[✔️] Clé générée : {key_path}")
