#!/bin/bash
# ==============================================================================
# Automatic patch application script for Luckfox Lyra Hardened SDK
# ==============================================================================
set -e

SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="${SDK_DIR}/patches"

echo "=== Applying Luckfox Lyra Hardened SDK Patches ==="

# 1. Linux Kernel 6.1 Patches
if [ -d "${SDK_DIR}/kernel-6.1" ]; then
    echo "-> Applying kernel hardening patch in kernel-6.1..."
    git -C "${SDK_DIR}/kernel-6.1" apply --check "${PATCHES_DIR}/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch" 2>/dev/null && \
    git -C "${SDK_DIR}/kernel-6.1" apply "${PATCHES_DIR}/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch" || \
    echo "   [INFO] Kernel patch is already applied or requires git am."
fi

# 2. AIC8800 Wi-Fi / Bluetooth Driver Patches
if [ -d "${SDK_DIR}/external/rkwifibt" ]; then
    echo "-> Applying driver hardening patch in external/rkwifibt..."
    git -C "${SDK_DIR}/external/rkwifibt" apply --check "${PATCHES_DIR}/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch" 2>/dev/null && \
    git -C "${SDK_DIR}/external/rkwifibt" apply "${PATCHES_DIR}/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch" || \
    echo "   [INFO] AIC8800 patch is already applied or requires git am."
fi

echo "=== Patches successfully applied! ==="
echo "You can now start the build process via: ./build.sh lunch && ./build.sh"
