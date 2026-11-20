#!/usr/bin/env bash
# ==============================================================================
# Luckfox Lyra Hardened SDK — Root Build Entrypoint
# Delegates safely to device/rockchip/common/scripts/build.sh so upstream
# SDK_DIR path resolution works cleanly without brittle root symlinks.
# ==============================================================================
set -euo pipefail

SDK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_BUILD="${SDK_DIR}/device/rockchip/common/scripts/build.sh"

if [ ! -x "${UPSTREAM_BUILD}" ]; then
    echo "ERROR: Upstream Rockchip build script not found at:" >&2
    echo "       ${UPSTREAM_BUILD}" >&2
    echo "Please clone/extract the official Luckfox Lyra SDK into this directory," >&2
    echo "then run ./apply-hardened-patches.sh before building." >&2
    exit 1
fi

exec "${UPSTREAM_BUILD}" "$@"
