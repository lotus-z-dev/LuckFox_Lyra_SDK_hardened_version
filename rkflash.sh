#!/usr/bin/env bash
# ==============================================================================
# Luckfox Lyra Hardened SDK — Hardened USB Maskrom/Loader Flash Script
# ==============================================================================
set -euo pipefail

SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPGRADETOOL="${SDK_DIR}/tools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool"
ROCKDEV_DIR="${SDK_DIR}/rockdev"

LOADER="${ROCKDEV_DIR}/MiniLoaderAll.bin"
PARAMETER="${ROCKDEV_DIR}/parameter.txt"
UBOOT="${ROCKDEV_DIR}/uboot.img"
TRUST="${ROCKDEV_DIR}/trust.img"
BOOT="${ROCKDEV_DIR}/boot.img"
RECOVERY="${ROCKDEV_DIR}/recovery.img"
OEM="${ROCKDEV_DIR}/oem.img"
MISC="${ROCKDEV_DIR}/misc.img"
ROOTFS="${ROCKDEV_DIR}/rootfs.img"
USERDATA="${ROCKDEV_DIR}/userdata.img"
UPDATE="${ROCKDEV_DIR}/update.img"
RESOURCE="${ROCKDEV_DIR}/resource.img"

usage() {
    cat <<EOF
Usage: $(basename "$0") [TARGET] [IMAGE_PATH]

Targets:
  all         Flash complete image set and reboot (default)
  tb          Flash loader, parameter, uboot, and boot, then reboot
  norecovery  Flash all images except recovery and misc
  update      Flash unified update.img archive
  loader      Flash MiniLoaderAll.bin (optional custom path as arg 2)
  parameter   Flash parameter.txt (optional custom path as arg 2)
  resource    Flash resource.img (optional custom path as arg 2)
  uboot       Flash uboot.img (optional custom path as arg 2)
  trust       Flash trust.img (optional custom path as arg 2)
  boot        Flash boot.img (optional custom path as arg 2)
  recovery    Flash recovery.img (optional custom path as arg 2)
  misc        Flash misc.img (optional custom path as arg 2)
  oem         Flash oem.img (optional custom path as arg 2)
  userdata    Flash userdata.img (optional custom path as arg 2)
  rootfs      Flash rootfs.img (optional custom path as arg 2)
  rd          Reboot connected device
  erase       Erase flash using MiniLoaderAll.bin
  -h|--help   Show this help message
EOF
}

require_file() {
    local img="$1"
    if [ ! -f "${img}" ]; then
        echo "ERROR: Required image file not found: ${img}" >&2
        exit 1
    fi
}

FLASH_TYPE="${1:-all}"
CUSTOM_IMG="${2:-}"

case "${FLASH_TYPE}" in
    -h|--help|help)
        usage
        exit 0
        ;;
esac

if [ ! -x "${UPGRADETOOL}" ]; then
    echo "ERROR: Rockchip upgrade_tool not found or not executable at:" >&2
    echo "       ${UPGRADETOOL}" >&2
    exit 1
fi

case "${FLASH_TYPE}" in
    all)
        echo "Flashing all images..."
        for f in "${LOADER}" "${PARAMETER}" "${UBOOT}" "${TRUST}" "${BOOT}" \
                 "${RECOVERY}" "${MISC}" "${OEM}" "${USERDATA}" "${ROOTFS}"; do
            require_file "${f}"
        done
        "${UPGRADETOOL}" ul -noreset "${LOADER}"
        "${UPGRADETOOL}" di -p "${PARAMETER}"
        "${UPGRADETOOL}" di -uboot "${UBOOT}"
        "${UPGRADETOOL}" di -trust "${TRUST}"
        "${UPGRADETOOL}" di -b "${BOOT}"
        "${UPGRADETOOL}" di -r "${RECOVERY}"
        "${UPGRADETOOL}" di -m "${MISC}"
        "${UPGRADETOOL}" di -oem "${OEM}"
        "${UPGRADETOOL}" di -userdata "${USERDATA}"
        "${UPGRADETOOL}" di -rootfs "${ROOTFS}"
        "${UPGRADETOOL}" rd
        ;;
    tb)
        for f in "${LOADER}" "${PARAMETER}" "${UBOOT}" "${BOOT}"; do
            require_file "${f}"
        done
        "${UPGRADETOOL}" ul -noreset "${LOADER}"
        "${UPGRADETOOL}" di -p "${PARAMETER}"
        "${UPGRADETOOL}" di -uboot "${UBOOT}"
        "${UPGRADETOOL}" di -b "${BOOT}"
        "${UPGRADETOOL}" rd
        ;;
    norecovery)
        for f in "${LOADER}" "${PARAMETER}" "${UBOOT}" "${TRUST}" "${BOOT}" \
                 "${OEM}" "${USERDATA}" "${ROOTFS}"; do
            require_file "${f}"
        done
        "${UPGRADETOOL}" ul -noreset "${LOADER}"
        "${UPGRADETOOL}" di -p "${PARAMETER}"
        "${UPGRADETOOL}" di -uboot "${UBOOT}"
        "${UPGRADETOOL}" di -trust "${TRUST}"
        "${UPGRADETOOL}" di -b "${BOOT}"
        "${UPGRADETOOL}" di -oem "${OEM}"
        "${UPGRADETOOL}" di -userdata "${USERDATA}"
        "${UPGRADETOOL}" di -rootfs "${ROOTFS}"
        ;;
    loader)
        [ -n "${CUSTOM_IMG}" ] && LOADER="${CUSTOM_IMG}"
        require_file "${LOADER}"
        echo "Flashing loader: ${LOADER}"
        "${UPGRADETOOL}" ul "${LOADER}"
        ;;
    parameter)
        [ -n "${CUSTOM_IMG}" ] && PARAMETER="${CUSTOM_IMG}"
        require_file "${PARAMETER}"
        echo "Flashing parameter: ${PARAMETER}"
        "${UPGRADETOOL}" di -p "${PARAMETER}"
        ;;
    resource)
        [ -n "${CUSTOM_IMG}" ] && RESOURCE="${CUSTOM_IMG}"
        require_file "${RESOURCE}"
        echo "Flashing resource: ${RESOURCE}"
        "${UPGRADETOOL}" di -resource "${RESOURCE}"
        ;;
    uboot)
        [ -n "${CUSTOM_IMG}" ] && UBOOT="${CUSTOM_IMG}"
        require_file "${UBOOT}"
        echo "Flashing uboot: ${UBOOT}"
        "${UPGRADETOOL}" di -uboot "${UBOOT}"
        ;;
    trust)
        [ -n "${CUSTOM_IMG}" ] && TRUST="${CUSTOM_IMG}"
        require_file "${TRUST}"
        echo "Flashing trust: ${TRUST}"
        "${UPGRADETOOL}" di -trust "${TRUST}"
        ;;
    boot)
        [ -n "${CUSTOM_IMG}" ] && BOOT="${CUSTOM_IMG}"
        require_file "${BOOT}"
        echo "Flashing boot: ${BOOT}"
        "${UPGRADETOOL}" di -b "${BOOT}"
        ;;
    recovery)
        [ -n "${CUSTOM_IMG}" ] && RECOVERY="${CUSTOM_IMG}"
        require_file "${RECOVERY}"
        echo "Flashing recovery: ${RECOVERY}"
        "${UPGRADETOOL}" di -r "${RECOVERY}"
        ;;
    misc)
        [ -n "${CUSTOM_IMG}" ] && MISC="${CUSTOM_IMG}"
        require_file "${MISC}"
        echo "Flashing misc: ${MISC}"
        "${UPGRADETOOL}" di -misc "${MISC}"
        ;;
    oem)
        [ -n "${CUSTOM_IMG}" ] && OEM="${CUSTOM_IMG}"
        require_file "${OEM}"
        echo "Flashing oem: ${OEM}"
        "${UPGRADETOOL}" di -oem "${OEM}"
        ;;
    userdata)
        [ -n "${CUSTOM_IMG}" ] && USERDATA="${CUSTOM_IMG}"
        require_file "${USERDATA}"
        echo "Flashing userdata: ${USERDATA}"
        "${UPGRADETOOL}" di -userdata "${USERDATA}"
        ;;
    rootfs)
        [ -n "${CUSTOM_IMG}" ] && ROOTFS="${CUSTOM_IMG}"
        require_file "${ROOTFS}"
        echo "Flashing rootfs: ${ROOTFS}"
        "${UPGRADETOOL}" di -rootfs "${ROOTFS}"
        ;;
    update)
        [ -n "${CUSTOM_IMG}" ] && UPDATE="${CUSTOM_IMG}"
        require_file "${UPDATE}"
        echo "Flashing update image: ${UPDATE}"
        "${UPGRADETOOL}" uf "${UPDATE}"
        ;;
    rd)
        "${UPGRADETOOL}" rd
        ;;
    erase)
        [ -n "${CUSTOM_IMG}" ] && LOADER="${CUSTOM_IMG}"
        require_file "${LOADER}"
        echo "Erasing flash using loader: ${LOADER}"
        "${UPGRADETOOL}" EF "${LOADER}"
        ;;
    *)
        echo "ERROR: Unknown flash target '${FLASH_TYPE}'." >&2
        usage >&2
        exit 1
        ;;
esac
