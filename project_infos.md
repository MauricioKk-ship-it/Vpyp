# 🧱 Projet GoSpot — SDK & CLI (Architecture Hybride)

## Objectif
Créer un CLI modulaire permettant d’exécuter des outils réseau et d’administration. La plupart des outils sont intégrés localement, et certains peuvent être téléchargés dynamiquement.

## 📦 Composants

### 1️⃣ Dépôt Client & Scripts Locaux (Vpyp)
**Repo :** [Mauricio-100/Vpyp](https://github.com/Mauricio-100/Vpyp)

Contient :
- `cli.py` → Le cœur du CLI qui gère la logique d'exécution.
- `gospot_pkg/sdk/` → Contient la majorité des scripts (`sysinfo.sh`, `ssh.sh`, etc.) pour un accès instantané.
- `install.sh` → Script d'installation de la commande `gospot`.

### 2️⃣ Dépôt Serveur (Outils Distants)
**Repo :** [Mauricio-100/gospot-sdk-host](https://github.com/Mauricio-100/gospot-sdk-host)

Rôle :
- Héberge des scripts spécifiques qui sont téléchargés à la demande.
- Exemple : `scripts/tools.sh`

## ⚙️ Fonctionnement

1.  L'utilisateur installe le CLI avec `./install.sh`, ce qui rend la commande `gospot` disponible.
2.  Quand l'utilisateur lance une commande comme `gospot sysinfo`:
    *   Le `cli.py` cherche `sysinfo.sh` dans son dossier local `gospot_pkg/sdk/`.
    *   Il exécute le script trouvé.
3.  Quand l'utilisateur lance une commande distante comme `gospot tools`:
    *   Le `cli.py` télécharge le script depuis le dépôt `gospot-sdk-host`.
    *   Il le sauvegarde temporairement et l'exécute.

## 🔗 Liens Scripts Distants

- **Tools Script:** `https://raw.githubusercontent.com/Mauricio-100/gospot-sdk-host/main/scripts/tools.sh`
