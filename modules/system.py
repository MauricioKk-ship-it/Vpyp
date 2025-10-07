# modules/system.py
import platform
import os
# modules/system.py
import subprocess

def check_package(pkg_name):
    """
    Vérifie si un paquet est installé sur le système.
    Retourne True si installé, False sinon.
    Compatible Linux / Termux / macOS.
    """
    try:
        result = subprocess.run(
            ["which", pkg_name],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )
        return result.returncode == 0
    except Exception:
        return False
        
def detect_os():
    """
    Retourne une string parmi :
    TERMUX, ISH, MACOS, WSL, DEBIAN, FEDORA, ARCH, ALPINE, WINDOWS, UNKNOWN
    """
    uname = platform.system()
    if uname == "Darwin":
        return "MACOS"
    if uname == "Linux":
        # check Termux (PREFIX env or termux-info)
        if os.getenv("PREFIX", "").find("com.termux") != -1 or os.path.exists("/data/data/com.termux"):
            return "TERMUX"
        # check WSL
        try:
            with open("/proc/version", "r") as f:
                v = f.read().lower()
                if "microsoft" in v:
                    return "WSL"
        except Exception:
            pass
        # check alpine
        if os.path.exists("/etc/alpine-release"):
            return "ALPINE"
        # check package managers
        if os.path.exists("/usr/bin/apt") or os.path.exists("/bin/apt"):
            return "DEBIAN"
        if os.path.exists("/usr/bin/dnf") or os.path.exists("/bin/dnf"):
            return "FEDORA"
        if os.path.exists("/usr/bin/pacman") or os.path.exists("/bin/pacman"):
            return "ARCH"
        return "LINUX"
    if uname.startswith("MINGW") or uname.startswith("CYGWIN") or "Windows" in uname:
        return "WINDOWS"
    return "UNKNOWN"
