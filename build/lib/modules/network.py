import socket, subprocess

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
