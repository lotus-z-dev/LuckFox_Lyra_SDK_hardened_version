#!/usr/bin/env bash
# ==============================================================================
# Automated Patch Application Script for Luckfox Lyra Hardened SDK
# Fails closed on missing upstream subtrees or patch conflicts.
# ==============================================================================
set -euo pipefail

SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="${SDK_DIR}/patches"

apply_patch_strict() {
    local target_rel="$1"
    local patch_name="$2"
    local description="$3"
    local target_dir="${SDK_DIR}/${target_rel}"
    local patch_file="${PATCHES_DIR}/${patch_name}"

    if [ ! -d "${target_dir}" ]; then
        echo "ERROR: Required upstream SDK directory missing: ${target_rel}" >&2
        echo "       Clone/extract the official Luckfox Lyra SDK before running this script." >&2
        exit 1
    fi

    if [ ! -f "${patch_file}" ]; then
        echo "ERROR: Patch file missing: ${patch_file}" >&2
        exit 1
    fi

    echo "-> [${target_rel}] ${description}..."

    if git -C "${target_dir}" apply --check "${patch_file}" 2>/dev/null; then
        git -C "${target_dir}" apply "${patch_file}"
        echo "   [PASS] Applied ${patch_name}"
    elif git -C "${target_dir}" apply --reverse --check "${patch_file}" 2>/dev/null; then
        echo "   [INFO] Already applied cleanly: ${patch_name}"
    else
        echo "   [FAIL] Patch ${patch_name} cannot be applied cleanly to ${target_rel}!" >&2
        echo "   Diagnostic output:" >&2
        git -C "${target_dir}" apply --check "${patch_file}" || true
        exit 1
    fi
}

echo "=== Applying Luckfox Lyra Hardened SDK Patches ==="

apply_patch_strict \
    "kernel-6.1" \
    "0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch" \
    "Linux 6.1 kernel hardening (defconfig, vendor storage, AMP/RPMSG, RGA)"

apply_patch_strict \
    "external/rkwifibt" \
    "0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch" \
    "AIC8800 Wi-Fi driver security fixes and Bluetooth init bypass"

apply_patch_strict \
    "device/rockchip" \
    "0003-device-rockchip-rootfs-hardening-and-fastboot.patch" \
    "Rootfs lockdown, ADB removal, BT blacklist, RO boot, and build script hardening"

apply_patch_strict \
    "buildroot" \
    "0004-buildroot-rootfs-lockdown-and-test-cleanup.patch" \
    "Buildroot root login lockdown, serial shell disablement, and unprivileged egyscam user"

apply_patch_strict \
    "external/rkscript" \
    "0005-rkscript-usbdevice-no-tmp-config.patch" \
    "Eliminate /tmp/.usb_config privilege escalation and fail-closed ADB handler"

echo "=== All 5 hardened SDK patches verified and applied! ==="
echo "You can now start the build process via: ./build.sh lunch && ./build.sh"
