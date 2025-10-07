# modules/network.py
import subprocess

def scan_network():
    """
    Scanne le réseau local pour détecter les hôtes actifs.
    Retourne une liste d'adresses IP des hôtes trouvés.
    """
    try:
        result = subprocess.run(
            ["nmap", "-sn", "192.168.1.0/24"],  # Remplace par ton réseau local
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        # Analyse la sortie pour extraire les adresses IP
        hosts = []
        for line in result.stdout.splitlines():
            if "Nmap scan report for" in line:
                ip = line.split()[-1]
                hosts.append(ip)
        return hosts
    except Exception as e:
        print(f"Erreur lors du scan réseau : {e}")
        return []

def detect_ip():
    try:
        out = subprocess.check_output(
            "ip -4 addr show | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}' | grep -v '^127\\.' || true",
            shell=True, text=True
        )
        lines = [l.strip() for l in out.splitlines() if l.strip()]
        if lines: return lines[0]
    except Exception:
        pass
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"
