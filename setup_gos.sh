#!/usr/bin/env bash
# Script pour réorganiser GoSpot en vrai package Python

set -e

echo "[⚙️] Création du dossier gos/..."
mkdir -p gos

# Déplacer gos.py
if [ -f "gos.py" ]; then
    echo "[📄] Déplacement de gos.py → gos/cli.py"
    mv gos.py gos/cli.py
else
    echo "[⚠️] gos.py introuvable !"
fi

# Créer __init__.py
echo "[📄] Création de gos/__init__.py"
touch gos/__init__.py

# Déplacer modules et sdk si ce n'est pas déjà fait
echo "[📂] Vérification des dossiers modules/ et sdk/..."
mkdir -p modules sdk

# Permissions
echo "[🔧] Mise à jour des permissions..."
chmod +x gos/cli.py
chmod +x modules/* || true
chmod +x sdk/* || true

# Créer setup.py
echo "[📄] Création de setup.py..."
cat > setup.py << 'EOF'
from setuptools import setup, find_packages

setup(
    name="gos",
    version="1.0.0",
    author="Mauricio-100",
    description="GoSpot Hybrid - Python + Shell CLI",
    packages=find_packages(),
    include_package_data=True,
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "gos=gos.cli:main_menu",
        ],
    },
)
EOF

echo "[✅] Structure et setup.py créés avec succès !"
echo "Maintenant, installe le package avec :"
echo "pip install ."
echo "Puis exécute avec : gos"
