# GoSpot CLI (Vpyp)

GoSpot est une interface en ligne de commande (CLI) intelligente pour exécuter des outils réseau et d'administration système.

## Installation

1. Clonez ce dépôt.
2. Rendez le script d'installation exécutable :
   ```sh
   chmod +x install.sh
   ```
   lance
   ```sh
   ./install..sh
Le script vous demandera les droits administrateur (sudo) si nécessaire pour créer la commande globale gospot.
Utilisation
Une fois installé, vous pouvez utiliser la commande gospot de n'importe où :

code
Sh
# Obtenir des informations système
```sh
gospot sysinfo
```

# Gérer les clés SSH
```sh
gospot ssh
```
# Télécharger et exécuter les outils distants
```sh
gospot tools
