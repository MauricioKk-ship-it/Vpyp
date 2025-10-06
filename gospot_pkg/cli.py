#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GoSpot CLI launcher (Python)
- main() is the console entry point (used by setup.py entry_points => "GoS")
- Calls shell scripts from bundled SDK (client.sh, server.sh, sdk/scripts/*.sh)
- Downloads SDK from GOSPOT_SDK_URL if not present
- Shows spinner while long operations run, hides verbose logs, prints tail on error
"""

from __future__ import annotations
import os
import sys
import shutil
import signal
import subprocess
import threading
import time
import tempfile
import urllib.request
from pathlib import Path

# -------------------------
# CONFIG
# -------------------------
DEFAULT_SDK_URL = "https://gospot-sdk-host.onrender.com/gospot-sdk-1.0.0.tar.gz"
SDK_ENV_VAR = "GOSPOT_SDK_URL"
SDK_DIR = Path(os.environ.get("GOSPOT_SDK_DIR", Path.home() / ".gospot-sdk")).expanduser()
SCRIPTS_REL = {
    "client": Path("client.sh"),
    "server": Path("server.sh"),
    "tools": Path("sdk/scripts/tools.sh"),
    "ssh": Path("sdk/scripts/ssh.sh"),
    "admin": Path("sdk/scripts/admin.sh"),
}

# -------------------------
# Styling
# -------------------------
class Style:
    RED = "\033[91m"
    GREEN = "\033[92m"
    CYAN = "\033[96m"
    YELLOW = "\033[93m"
    MAGENTA = "\033[95m"
    BOLD = "\033[1m"
    END = "\033[0m"

def print_boxed(title: str):
    w = max(40, len(title) + 4)
    print(Style.CYAN + "+" + "-" * w + "+")
    print("|" + " " * ((w - len(title)) // 2) + Style.BOLD + title + Style.END + Style.CYAN +
          " " * (w - len(title) - ((w - len(title)) // 2)) + "|")
    print("+" + "-" * w + "+" + Style.END)

# -------------------------
# Utilities
# -------------------------
def spinner_task(stop_event: threading.Event, message: str = "Processing"):
    chars = "|/-\\"
    i = 0
    while not stop_event.is_set():
        sys.stdout.write("\r" + message + " " + chars[i % len(chars)])
        sys.stdout.flush()
        i += 1
        time.sleep(0.12)
    sys.stdout.write("\r" + " " * (len(message) + 4) + "\r")
    sys.stdout.flush()

def run_subprocess_quiet(cmd: list[str], cwd: Path | None = None, env: dict | None = None, show_message: str = "Working"):
    """
    Runs a subprocess while capturing its output, displays a spinner.
    On success returns returncode 0.
    On error prints last lines of the output for debugging.
    """
    with tempfile.TemporaryFile() as out:
        try:
            p = subprocess.Popen(cmd, stdout=out, stderr=out, cwd=(str(cwd) if cwd else None), env=env)
        except FileNotFoundError as e:
            print(Style.RED + f"[!] Command not found: {cmd[0]}" + Style.END)
            return 127
        stop = threading.Event()
        th = threading.Thread(target=spinner_task, args=(stop, show_message))
        th.start()
        try:
            rc = p.wait()
        except KeyboardInterrupt:
            try:
                p.terminate()
            except Exception:
                pass
            stop.set()
            th.join()
            print("\n" + Style.RED + "[!] Cancelled by user" + Style.END)
            return 130
        finally:
            stop.set()
            th.join()
        out.seek(0)
        data = out.read().decode("utf-8", errors="replace")
        if rc != 0:
            print(Style.RED + f"\n[!] Command failed (rc={rc}). Last lines of output:" + Style.END)
            tail_lines = "\n".join(data.splitlines()[-40:])
            if tail_lines:
                print(tail_lines)
            else:
                print("(no output)")
        return rc

def ensure_executable(path: Path):
    try:
        mode = path.stat().st_mode
        path.chmod(mode | 0o111)
    except Exception:
        pass

# -------------------------
# SDK management
# -------------------------
def sdk_installed() -> bool:
    """Check if SDK is present on disk and minimum scripts are available."""
    base = SDK_DIR
    for rel in (SCRIPTS_REL["tools"], SCRIPTS_REL["ssh"]):
        if not (base / rel).exists():
            return False
    return True

def download_sdk(url: str, dest_dir: Path = SDK_DIR) -> int:
    """Download SDK tar.gz from url and extract into dest_dir. Returns rc."""
    dest_dir = dest_dir.expanduser()
    tmpdir = Path(tempfile.mkdtemp(prefix="gospot-sdk-"))
    archive = tmpdir / "gospot-sdk.tar.gz"
    print(Style.CYAN + f"[GoSpot] Téléchargement du SDK depuis: {url}" + Style.END)
    # Download (urllib will show no nice progress; we keep it simple)
    try:
        with urllib.request.urlopen(url) as resp, open(archive, "wb") as out_f:
            # try to show a simple progress if content-length present
            total = resp.getheader("Content-Length")
            if total and total.isdigit():
                total = int(total)
                chunk = 8192
                downloaded = 0
                while True:
                    data = resp.read(chunk)
                    if not data:
                        break
                    out_f.write(data)
                    downloaded += len(data)
                    pct = int((downloaded / total) * 100)
                    # progress bar
                    barw = 36
                    filled = (pct * barw) // 100
                    sys.stdout.write("\r[" + "#" * filled + "-" * (barw - filled) + f"] {pct:3d}%")
                    sys.stdout.flush()
                sys.stdout.write("\n")
            else:
                # unknown size: just read
                out_f.write(resp.read())
    except Exception as e:
        print(Style.RED + f"[!] Erreur téléchargement SDK: {e}" + Style.END)
        return 1

    # Extract
    try:
        dest_dir.mkdir(parents=True, exist_ok=True)
        rc = run_subprocess_quiet(["tar", "-xzf", str(archive), "-C", str(dest_dir)], show_message="Extraction")
        if rc != 0:
            return rc
    finally:
        try:
            archive.unlink()
        except Exception:
            pass
    # ensure scripts are executable
    for rel in SCRIPTS_REL.values():
        p = dest_dir / rel
        if p.exists():
            ensure_executable(p)
    print(Style.GREEN + "[GoSpot] SDK installé / mis à jour dans: " + str(dest_dir) + Style.END)
    return 0

# -------------------------
# Script locating + running
# -------------------------
def find_script(script_key: str) -> Path | None:
    """Return path to the requested script inside SDK_DIR or local package (development)."""
    # 1) Check SDK_DIR
    candidate = SDK_DIR / SCRIPTS_REL[script_key]
    if candidate.exists():
        return candidate
    # 2) Check repository local install (developer mode)
    repo_candidate = Path(__file__).resolve().parent / SCRIPTS_REL[script_key]
    if repo_candidate.exists():
        return repo_candidate
    # 3) Check package-installed location (site-packages/gospot_pkg/...)
    pkg_candidate = Path(sys.executable).resolve().parent
    # fallback: we simply return None
    return None

def run_script_key(script_key: str, args: list[str] | None = None) -> int:
    script = find_script(script_key)
    if not script:
        print(Style.YELLOW + f"[!] Script {script_key} introuvable localement. Tentative d'installation du SDK..." + Style.END)
        url = os.environ.get(SDK_ENV_VAR, DEFAULT_SDK_URL)
        rc = download_sdk(url)
        if rc != 0:
            return rc
        script = find_script(script_key)
        if not script:
            print(Style.RED + "[!] Impossible de trouver le script même après téléchargement du SDK." + Style.END)
            return 2
    ensure_executable(script)
    cmd = [str(script)]
    if args:
        cmd += args
    # Run quietly with spinner
    return run_subprocess_quiet(cmd, cwd=script.parent, show_message=f"Running {script.name}")

# -------------------------
# High level commands
# -------------------------
def start_client() -> int:
    print(Style.CYAN + "[GoSpot] Lancement du client..." + Style.END)
    return run_script_key("client")

def start_server() -> int:
    print(Style.CYAN + "[GoSpot] Lancement du serveur..." + Style.END)
    return run_script_key("server")

def install_sdk_and_tools() -> int:
    url = os.environ.get(SDK_ENV_VAR, DEFAULT_SDK_URL)
    return download_sdk(url)

def create_ssh_key() -> int:
    return run_script_key("ssh")

def admin_tools() -> int:
    return run_script_key("admin")

# -------------------------
# CLI / Menu
# -------------------------
def cli_menu_once():
    print_boxed("GoSpot CLI — Python launcher")
    print()
    print(Style.CYAN + "--- Connexion ---" + Style.END)
    print("  1. Client (Rejoindre)")
    print("  2. Serveur (Partager)")
    print(Style.YELLOW + "\n--- Outils & SDK ---" + Style.END)
    print("  3. Installer / Mettre à jour SDK & outils")
    print("  4. Créer / Afficher clé SSH")
    print("  5. Administration du Serveur")
    print("\n  6. Quitter\n")
    try:
        choice = input(Style.CYAN + "Votre choix (1-6) : " + Style.END).strip()
    except (EOFError, KeyboardInterrupt):
        print("\n" + Style.RED + "Interrompu. Au revoir." + Style.END)
        sys.exit(0)
    return choice

def main_menu_loop():
    while True:
        choice = cli_menu_once()
        if choice == "1":
            start_client()
        elif choice == "2":
            start_server()
        elif choice == "3":
            install_sdk_and_tools()
        elif choice == "4":
            create_ssh_key()
        elif choice == "5":
            admin_tools()
        elif choice == "6":
            print(Style.GREEN + "Au revoir !" + Style.END)
            sys.exit(0)
        else:
            print(Style.RED + "Choix invalide." + Style.END)
        print("\nAppuyez Entrée pour revenir au menu...")
        try:
            input()
        except (EOFError, KeyboardInterrupt):
            sys.exit(0)

# -------------------------
# Signal handling
# -------------------------
def _signal_handler(sig, frame):
    print("\n" + Style.RED + f"Reçu signal {sig}. Arrêt." + Style.END)
    sys.exit(0)

signal.signal(signal.SIGINT, _signal_handler)
signal.signal(signal.SIGTERM, _signal_handler)

# -------------------------
# Command line entrypoint
# -------------------------
def main(argv: list[str] | None = None) -> int:
    """
    Entry point for console_scripts.
    Accepts optional argv (for tests). Returns exit code (int).
    """
    argv = argv if argv is not None else sys.argv[1:]
    # quick flags
    if "--version" in argv or "-v" in argv:
        print("GoSpot CLI (Python) 1.0.3")
        return 0
    # direct commands for automated use
    if len(argv) >= 1:
        cmd = argv[0]
        if cmd in ("serve", "server"):
            return start_server()
        if cmd in ("connect", "client"):
            return start_client()
        if cmd in ("install-sdk", "install"):
            return install_sdk_and_tools()
        if cmd in ("ssh", "key"):
            return create_ssh_key()
        if cmd in ("admin",):
            return admin_tools()
        if cmd in ("menu",):
            main_menu_loop()
            return 0
        # unknown argument: show help
        print("Usage: GoS [serve|connect|install-sdk|ssh|admin|menu]")
        return 2

    # interactive menu by default
    main_menu_loop()
    return 0

# Allow direct module execution: python -m gospot_pkg.cli
if __name__ == "__main__":
    try:
        rc = main()
        sys.exit(rc)
    except KeyboardInterrupt:
        print("\n" + Style.RED + "Arrêt CLI" + Style.END)
        sys.exit(130)
