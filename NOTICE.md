# Legal Notices & Component Attributions

This repository (`LuckFox_Lyra_SDK_hardened_version`) distributes security hardening patches, build wrappers, and documentation for the **Luckfox Lyra (Rockchip RK3506 / RK3506B)** Linux SDK.

The full text of the **GNU General Public License version 2.0 (GPL-2.0)** is provided verbatim in [LICENSE](LICENSE).

---

## Component Attribution

### 1. Linux Kernel 6.1 LTS (`patches/0001-*.patch`)
* **License:** GNU General Public License version 2.0 (GPL-2.0)
* **Upstream Authors:** Linus Torvalds, Linux kernel contributors, and Rockchip Electronics Co., Ltd.
* **Hardening Contributions (`lotus-z-dev`):** Hardened `rk3506_luckfox_defconfig` (seccomp, namespaces, Landlock, Yama, hardened usercopy, SW PAN, branch hardening, cleared debug cmdline), bounds/TOCTOU/concurrency/memory-leak fixes across MTD/SDMMC/Flash vendor storage, Rockchip AMP IRQ/GPIO parsing, RPMSG/iomux cleanup, and RGA integer overflow guards.

### 2. AIC8800 Wi-Fi Driver & Init Scripts (`patches/0002-*.patch`)
* **License:** GNU General Public License version 2.0 (GPL-2.0)
* **Upstream Authors:** AICSemi Inc. and Rockchip Electronics Co., Ltd.
* **Hardening Contributions (`lotus-z-dev`):** Elimination of USB/SDIO RX integer overflows and heap over-reads (`aicwf_txrxif.c`), AMSDU and 802.11 defragmentation UAF/SMP race fixes (`rwnx_rx.c`), IRQ sleeping semaphore removal (`aicwf_usb.c`), IPC/ioctl/vendor command bounds validation (`rwnx_msg_rx.c`, `aic_priv_cmd.c`, `aic_vendor.c`, `rwnx_platform.c`, `aicbluetooth.c`), disabled preallocated RX SKB pool, and conditional Bluetooth startup bypass (`scripts/wifibt-init.sh`).

### 3. Rockchip Device Overlay & Build Scripts (`patches/0003-*.patch`, `patches/0005-*.patch`)
* **License:** GNU General Public License version 2.0 (GPL-2.0) / Apache-2.0 / BSD (per upstream Rockchip component headers)
* **Upstream Authors:** Rockchip Electronics Co., Ltd. and Luckfox / Waveshare
* **Hardening Contributions (`lotus-z-dev`):** Disabled unauthenticated USB ADB (`RK_USB_ADBD=n`), removed serial TTY `getty` and `remount,rw /` from `inittab`, blacklisted `aic_btusb` via `/etc/modprobe.d/blacklist-bt.conf`, hardened `S45usbconfig`, `S60netdevice`, `device/rockchip/common/scripts/build.sh` (removed `mktemp -u` races), and eliminated `/tmp/.usb_config` local privilege escalation in `external/rkscript/usbdevice`.

### 4. Buildroot Target Configuration (`patches/0004-*.patch`)
* **License:** GNU General Public License version 2.0 or later (GPL-2.0-or-later)
* **Upstream Authors:** The Buildroot developers and Rockchip Electronics Co., Ltd.
* **Hardening Contributions (`lotus-z-dev`):** Disabled root login (`BR2_TARGET_ENABLE_ROOT_LOGIN` unset), disabled serial console shell (`BR2_TARGET_SERIAL_SHELL_NONE=y`), pruned vendor test packages, and provisioned the unprivileged `egyscam` (`UID 1001` / `GID 1001`, `/bin/false`, `video,audio`) service account via `board/rockchip/rk3506/users.table`.

### 5. Root Entrypoint Wrappers (`build.sh`, `Makefile`, `rkflash.sh`, `apply-hardened-patches.sh`)
* **License:** GNU General Public License version 2.0 (GPL-2.0)
* **Authors:** `lotus-z-dev` (derived from Rockchip Electronics Co., Ltd. SDK scripts)
