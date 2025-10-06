import subprocess
import threading
import sys
import time

def _spinner_task(stop_event):
    chars = "|/-\\"
    i = 0
    while not stop_event.is_set():
        sys.stdout.write("\r" + "Processing " + chars[i % len(chars)])
        sys.stdout.flush()
        i += 1
        time.sleep(0.12)
    sys.stdout.write("\r" + " " * 20 + "\r")
    sys.stdout.flush()

def run_shell_quiet(script_path, args=None):
    cmd = [str(script_path)]
    if args:
        cmd += list(args)
    # run subprocess but capture output to temp file
    import tempfile
    out = tempfile.TemporaryFile()
    p = subprocess.Popen(cmd, stdout=out, stderr=out)
    stop = threading.Event()
    th = threading.Thread(target=_spinner_task, args=(stop,))
    th.start()
    try:
        rc = p.wait()
    finally:
        stop.set()
        th.join()
    # optionally: show tail of output if rc!=0
    out.seek(0)
    data = out.read().decode('utf-8', errors='replace')
    if rc != 0:
        print("\n[!] Erreur pendant l'exécution. Détails (dernieres lignes):")
        print("\n".join(data.splitlines()[-20:]))
    return rc
