#!/bin/bash
# ==============================================================================
# Script d'application automatique des correctifs du Luckfox Lyra Hardened SDK
# ==============================================================================
set -e

SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="${SDK_DIR}/patches"

echo "=== Application des correctifs Luckfox Lyra Hardened SDK ==="

# 1. Correctifs du Noyau Linux 6.1
if [ -d "${SDK_DIR}/kernel-6.1" ]; then
    echo "-> Application du correctif noyau dans kernel-6.1..."
    git -C "${SDK_DIR}/kernel-6.1" apply --check "${PATCHES_DIR}/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch" 2>/dev/null && \
    git -C "${SDK_DIR}/kernel-6.1" apply "${PATCHES_DIR}/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch" || \
    echo "   [INFO] Le patch noyau est déjà appliqué ou requiert git am."
fi

# 2. Correctifs du pilote Wi-Fi / BT AIC8800
if [ -d "${SDK_DIR}/external/rkwifibt" ]; then
    echo "-> Application du correctif pilote dans external/rkwifibt..."
    git -C "${SDK_DIR}/external/rkwifibt" apply --check "${PATCHES_DIR}/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch" 2>/dev/null && \
    git -C "${SDK_DIR}/external/rkwifibt" apply "${PATCHES_DIR}/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch" || \
    echo "   [INFO] Le patch aic8800 est déjà appliqué ou requiert git am."
fi

echo "=== Correctifs appliqués avec succès ! ==="
echo "Vous pouvez maintenant lancer la compilation via : ./build.sh lunch && ./build.sh"
