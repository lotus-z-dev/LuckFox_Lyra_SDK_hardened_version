# Luckfox Lyra Hardened SDK

[![Dépôt GitHub](https://img.shields.io/badge/GitHub-LuckFox__Lyra__SDK__updated__version-blue?logo=github)](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)
[![Licence GPL-2.0](https://img.shields.io/badge/License-GPL%202.0-green.svg)](LICENSE)
[![Amazon.ca](https://img.shields.io/badge/Amazon.ca-Acheter%20Luckfox%20Lyra-orange?logo=amazon)](https://link.amazon/B016bDnRF)

Ce projet fournit une version stabilisée, durcie et fiabilisée du SDK officiel pour la plateforme **Luckfox Lyra (Rockchip RK3506 / RK3506B)**, spécifiquement optimisée pour les déploiements embarqués critiques (vision nocturne, caméras UVC, passerelles domotiques et capteurs industriels).

---

## 🛒 Matériel Supporté & Liens d'Achat

Retrouvez et soutenez le projet en vous procurant la carte officielle et ses accessoires via nos liens partenaires :

<p align="center">
  <a href="https://link.amazon/B016bDnRF">
    <img src="https://m.media-amazon.com/images/I/61f7o0iEaKL._AC_SL1200_.jpg" width="400" alt="Luckfox Lyra W SBC" />
  </a>
  <br />
  <em>👉 <a href="https://link.amazon/B016bDnRF"><strong>Commander la carte Luckfox Lyra W sur Amazon.ca</strong></a></em>
</p>

- 🔗 **Lien direct Amazon.ca (Carte Luckfox Lyra W) :** [Acheter le Luckfox Lyra W](https://link.amazon/B016bDnRF)
- 🔍 **Tous les produits et accessoires Luckfox sur Amazon :** [Parcourir la gamme Luckfox sur Amazon](https://link.amazon/B00vZoO0E)
- 📂 **Dépôt officiel du projet :** [https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)

---

## 1. Pourquoi ce nouveau SDK ?

Le SDK officiel fourni pour les cartes Luckfox Lyra présente plusieurs limitations techniques, régressions de stabilité et choix de configuration qui compliquent son exploitation en environnement autonome ou continu.

### Problèmes identifiés dans le SDK d'origine :
1. **Instabilité des pilotes Wi-Fi / Bluetooth (AIC8800) :**
   - Plantages intermittents et fuites de ressources lors de déconnexions/reconnexions réseau fréquentes.
   - Gestion défaillante de la mémoire dans les couches de transport USB et les commandes propriétaires du pilote.
   - Manque de robustesse lors de la réception de paquets malformés ou de messages asynchrones.

2. **Défauts de robustesse dans le sous-système de stockage constructeur (Vendor Storage) :**
   - Risque de corruption de mémoire lors d'appels répétés sur les partitions MTD, Flash et SDMMC.
   - Absence de validation stricte des bornes d'index et des tailles de tampons mémoire lors des transferts de blocs.

3. **Incohérences de synchronisation inter-cœurs (RPMSG / AMP) :**
   - Vulnérabilités de type course critique (*race conditions*) lors de transferts intensifs entre le processeur principal et le cœur temps réel.
   - Risques de déréférencement de pointeurs nuls ou d'écrasement de données partagées en cas de défaillance transitoire.

4. **Surface d'exposition excessive du noyau Linux :**
   - Modules de test de débogage et fonctions de diagnostics laissés actifs en production, augmentant inutilement l'empreinte mémoire et les points d'entrée instables.
   - Traitement non sécurisé des opérations graphiques et des calculs géométriques (moteur 2D RGA).

---

## 2. Améliorations et Correctifs Apportés

Notre SDK apporte une refonte complète de ces composants critiques sans briser la compatibilité avec l'écosystème Luckfox :

- **Durcissement et assainissement des pilotes réseau (`aic8800`) :**
  - Validation exhaustive de la taille de chaque trame reçue et transmise.
  - Élimination des débordements de tampons et vérification systématique des codes de retour de l'allocation mémoire.
  - Sécurisation du mécanisme de chargement du microprogramme (*firmware*).

- **Fiabilisation du stockage Flash / MTD :**
  - Contrôle strict des bornes sur toutes les opérations d'accès au stockage constructeur.
  - Prévention des corruptions mémoire silencieuses lors des sauvegardes de variables d'environnement.

- **Stabilisation du canal IPC RPMSG :**
  - Verrouillage synchronisé des accès concurrents pour éliminer les blocages du bus inter-cœurs.
  - Nettoyage des buffers et libération garantie des ressources en cas d'erreur de communication.

- **Optimisation de la configuration noyau (`rk3506_luckfox_defconfig`) :**
  - Réduction de la surface d'attaque par désactivation des modules de test obsolètes.
  - Renforcement des mécanismes de protection mémoire du noyau Linux 6.1 LTS.

---

## 3. Prérequis et Environnement de Compilation

### Dépendances de l'hôte (Debian / Ubuntu / Crostini) :
```bash
sudo apt-get update
sudo apt-get install -y git build-essential gcc g++ make cmake python3 bc \
    bison flex libssl-dev libncurses5-dev u-boot-tools libusb-1.0-0-dev device-tree-compiler
```

### Chaîne de compilation croisée :
Le SDK utilise la chaîne de compilation croisée ARM officielle intégrée dans le répertoire `tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/`.

---

## 4. Instructions de Compilation

### A. Initialisation de la cible
Exécutez le script interactif de sélection de cible matérielle :
```bash
./build.sh lunch
```
Choisissez la configuration correspondant à votre modèle (ex. : `Luckfox Lyra Zero W - SPI NAND`).

### B. Compilation complète de l'image
Pour générer l'ensemble des composants (SPL, U-Boot, Noyau Linux 6.1, Rootfs) :
```bash
./build.sh
```

### C. Compilation ciblée du noyau uniquement
Pour tester et compiler uniquement le noyau modifié :
```bash
./build.sh kernel
```

Les images générées prêtes au flashage sont situées dans le sous-répertoire `output/image/`.

---

## 5. Flashage sur la carte Luckfox

Connectez la carte Luckfox en mode Maskrom/Download via USB-C, puis utilisez l'outil de flashage officiel :
```bash
sudo ./tools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool uf output/image/update.img
```

*(Besoin d'une carte supplémentaire pour vos tests ? [Achetez le Luckfox Lyra W sur Amazon.ca](https://link.amazon/B016bDnRF) ou explorez les [accessoires compatibles](https://link.amazon/B00vZoO0E).)*

---

## 6. Crédits & Licence

- **Projet et Maintenance :** [lotus-z-dev](https://github.com/lotus-z-dev)
- **Noyau Linux 6.1 :** Linus Torvalds, contributeurs Linux & Rockchip Electronics Co., Ltd.
- **Pilotes Wi-Fi/BT :** AICSemi Inc. & Rockchip Electronics Co., Ltd.
- **Outils & Build System :** Luckfox / Waveshare & Rockchip Electronics Co., Ltd.

Tous les détails de licences et mentions légales sont décrits dans le fichier [LICENSE](LICENSE).

---

## 7. Bonnes Pratiques & Contribution

- Ne committez **jamais** de secrets, jetons d'accès ou clés privées dans ce dépôt.
- Toute modification apportée au noyau doit compiler sans avertissement avec `-Werror`.

---

## 🛠️ Utilisation des Patches Durcis (Hardened Patches)

Si vous disposez déjà d'une arborescence SDK Luckfox officielle, vous pouvez appliquer l'ensemble de nos correctifs de sécurité et de robustesse en une seule commande grâce au script fourni :

```bash
./apply-hardened-patches.sh
```

Ce script applique automatiquement :
- `patches/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch` : Sécurisation du stockage constructeur (Flash/MTD/SDMMC), assainissement de la communication RPMSG, et renforcement de la configuration mémoire noyau.
- `patches/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch` : Validation stricte des tampons de réception USB et des requêtes privées du pilote AIC8800.
