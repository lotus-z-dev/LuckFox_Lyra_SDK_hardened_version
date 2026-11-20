# Luckfox Lyra Hardened SDK

[![GitHub Repository](https://img.shields.io/badge/GitHub-LuckFox__Lyra__SDK__hardened__version-blue?logo=github)](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)
[![License: GPL v2](https://img.shields.io/badge/License-GPL%20v2-green.svg)](LICENSE)
[![Amazon.ca](https://img.shields.io/badge/Amazon.ca-Buy%20Luckfox%20Lyra-orange?logo=amazon)](https://link.amazon/B016bDnRF)

A security-hardened, audited, and stabilized overlay for the **Luckfox Lyra (Rockchip RK3506 / RK3506B)** embedded Linux 6.1 LTS SDK. Designed for **100% local, sovereign, unattended deployments** such as encrypted security cameras, UVC vision sensors, smart-home gateways, and industrial edge nodes — with zero cloud dependency and minimal attack surface.

---

## Supported Hardware & Links

Support the project and obtain the official single-board computer and compatible accessories via our partner links:

<p align="center">
  <a href="https://link.amazon/B016bDnRF">
    <img src="https://m.media-amazon.com/images/I/61f7o0iEaKL._AC_SL1200_.jpg" width="400" alt="Luckfox Lyra W SBC" />
  </a>
  <br />
  <em><a href="https://link.amazon/B016bDnRF"><strong>Order Luckfox Lyra W on Amazon.ca</strong></a></em>
</p>

- **Direct Amazon.ca Link (Luckfox Lyra W Board):** [Buy Luckfox Lyra W](https://link.amazon/B016bDnRF)
- **Compatible Luckfox Hardware & Accessories:** [Browse Luckfox Lineup on Amazon](https://link.amazon/B00vZoO0E)
- **Project Repository:** [https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)

---

## Why Use a Hardened SDK?

Vendor Linux SDKs are built for quick factory bring-up, not hostile networks or physical exposure. Out of the box, the stock RK3506/Luckfox Lyra SDK ships with:

1. **Unauthenticated Root Shells:** USB `adbd` enabled by default, an interactive serial `getty`, and a Buildroot root account with login enabled.
2. **Local Privilege Escalation Paths:** `external/rkscript/usbdevice` honors world-writable `/tmp/.usb_config` before `/etc/.usb_config`, and Rockchip vendor storage ioctls omit capability checks and length bounds.
3. **Remotely Triggerable Wi-Fi Driver Memory Bugs:** The out-of-tree AIC8800 Wi-Fi/BT driver contains unchecked USB/SDIO frame lengths, integer truncations, 802.11 defragmentation use-after-free and SMP timer races, sleeping semaphore calls in IRQ context, and unvalidated firmware IPC indices.
4. **Missing Kernel Sandboxing Primitives:** Stock `rk3506_luckfox_defconfig` omits `CONFIG_SECCOMP`, `CONFIG_SECCOMP_FILTER`, `CONFIG_NAMESPACES`, `CONFIG_SECURITY_LANDLOCK`, `CONFIG_SECURITY_YAMA`, `CONFIG_HARDENED_USERCOPY`, `CONFIG_CPU_SW_DOMAIN_PAN`, and `CONFIG_BUG`, while booting with `user_debug=31`.
5. **Unneeded Radio & Filesystem Exposure:** Bluetooth (`aic_btusb`) auto-loads on boot, `/` is remounted read-write in `inittab`, and network initialization stalls boot for 8 seconds.

This hardened SDK closes every one of those gaps declaratively across five clean, auditable patches while preserving full hardware compatibility and sub-3-second boot performance.

---

## Security Architecture & Defense-in-Depth

```text
+-------------------------------------------------------------------+
|  Hardware: Rockchip RK3506 / RK3506B (ARMv7 Cortex-A7 + M0 AMP)   |
+-------------------------------------------------------------------+
|  Linux 6.1 LTS Hardened Kernel (Patch 0001)                       |
|  - CONFIG_BUG, SECCOMP_FILTER, NAMESPACES (UTS/IPC/PID/NET)       |
|  - Landlock LSM + Yama ptrace restriction (CONFIG_LSM)            |
|  - HARDENED_USERCOPY, CPU_SW_DOMAIN_PAN, HARDEN_BRANCH_*          |
|  - Hardened MTD/SDMMC/Flash vendor storage, AMP/RPMSG & RGA       |
|  - Cleared debug cmdline (no user_debug=31) & no USB FunctionFS   |
+-------------------------------------------------------------------+
|  Hardened Wireless Stack (Patch 0002)                             |
|  - AIC8800 RX/IPC/AMSDU/defrag/ioctl bounds & SMP race fixes      |
|  - Prealloc RX SKB pool disabled; IRQ-safe down_trylock()         |
|  - Bluetooth init skipped & aic_btusb blacklisted                 |
+-------------------------------------------------------------------+
|  Locked-Down Rootfs & User Isolation (Patches 0003, 0004, 0005)   |
|  - Read-only root filesystem (no remount,rw in inittab)           |
|  - No USB adbd, no serial TTY shell, root login disabled          |
|  - /tmp/.usb_config LPE removed (reads /etc/.usb_config only)     |
|  - Unprivileged daemon account: egyscam (UID/GID 1001, /bin/false)|
+-------------------------------------------------------------------+
```

### Verified Security Matrix

| Security Control | Status | Implementation Details |
| :--- | :--- | :--- |
| **Seccomp-BPF Process Sandboxing** | **Enforced** | `CONFIG_SECCOMP=y`, `CONFIG_SECCOMP_FILTER=y` enabled for syscall allowlisting ("bottle" isolation) |
| **Linux Namespaces** | **Enforced** | `CONFIG_NAMESPACES=y` (`UTS`, `IPC`, `PID`, `NET`) enabled for service compartmentalization |
| **Mandatory Access Control (LSM)** | **Enforced** | `CONFIG_SECURITY=y`, `CONFIG_SECURITY_LANDLOCK=y`, `CONFIG_SECURITY_YAMA=y`, `CONFIG_LSM="landlock,yama"` |
| **Kernel Memory & CPU Mitigations** | **Enforced** | `CONFIG_BUG=y`, `CONFIG_HARDENED_USERCOPY=y`, `CONFIG_CPU_SW_DOMAIN_PAN=y`, `CONFIG_HARDEN_BRANCH_PREDICTOR=y`, `CONFIG_HARDEN_BRANCH_HISTORY=y` |
| **Kernel ASLR (KASLR)** | **Not available on ARM32** | Linux 6.1 `arch/arm` (32-bit ARMv7) does not support `CONFIG_RANDOMIZE_BASE` (available on `arm64` only). Compensated by PAN, hardened usercopy, Landlock, seccomp, and strict driver bounds checking |
| **Debug & USB Shell Elimination** | **Enforced** | `CONFIG_CMDLINE=""` (no `user_debug=31`), `CONFIG_DEBUG_USER=n`, `CONFIG_USB_CONFIGFS_F_FS=n`, `RK_USB_ADBD=n`, `adb_prepare()` fails closed |
| **Bluetooth Attack Surface** | **Eliminated** | `aic_btusb` blacklisted in `/etc/modprobe.d/blacklist-bt.conf`, `wifibt-init.sh` skips `start_bt()` when blacklisted |
| **Read-Only Root Filesystem** | **Enforced** | Removed `mount -o remount,rw /` from `inittab`; `S45usbconfig` and `S60netdevice` operate without mutating `/` or `/etc` |
| **Root & Serial Console Lockdown** | **Enforced** | `BR2_TARGET_ENABLE_ROOT_LOGIN` disabled, `BR2_TARGET_SERIAL_SHELL_NONE=y`, serial `getty` removed from `inittab` |
| **Least-Privilege Service Account** | **Enforced** | Dedicated `egyscam` account (`UID 1001`, `GID 1001`, `/bin/false`, groups `video,audio`) provisioned via Buildroot `users.table` |
| **USB Gadget Config LPE Fix** | **Enforced** | `external/rkscript/usbdevice` ignores world-writable `/tmp/.usb_config` and reads `/etc/.usb_config` exclusively |
| **Build Host Tempfile Safety** | **Enforced** | Replaced `mktemp -u` symlink races in Rockchip `build.sh` with atomic `0600` tempfiles inside `output/` |

---

## What Each Patch Does

| Patch File | Target Subtree | Summary of Hardening & Bug Fixes |
| :--- | :--- | :--- |
| [`0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch`](patches/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch) | `kernel-6.1/` | Hardens `rk3506_luckfox_defconfig`; fixes MTD/SDMMC/Flash vendor storage TOCTOU double-fetch, `-ENOMEM`-to-`u16` 61 KiB heap leak, missing mutex & `CAP_SYS_ADMIN` check, overlapping `memcpy` -> `memmove`, integer overflows, and unbounded NAND retries; bounds-checks Rockchip AMP IRQ/GPIO parsing & fixes `remove()` drvdata NULL deref; fixes `iomux` leak; removes unused RGA helper & adds integer overflow guards. |
| [`0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch`](patches/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch) | `external/rkwifibt/` | Disables `CONFIG_PREALLOC_RX_SKB`; fixes USB/SDIO RX `u16` length truncation and heap over-reads with zero-padded `ipc_e2a_msg` allocations; eliminates 802.11 defragmentation UAF and SMP timer init/deletion races in `rwnx_rx.c`; rejects fragmented A-MSDUs; bounds-checks STA/VLAN/channel/TID indices; replaces sleeping `down()` in IRQ callbacks with `down_trylock()`; hardens private ioctl/vendor/firmware parsers; skips BT startup when blacklisted. |
| [`0003-device-rockchip-rootfs-hardening-and-fastboot.patch`](patches/0003-device-rockchip-rootfs-hardening-and-fastboot.patch) | `device/rockchip/` | Sets `RK_USB_ADBD` default `n`; strips `remount,rw /` and serial `getty` from `inittab`; makes `S45usbconfig` and `S60netdevice` read-only safe and removes the 8-second boot delay and `/tmp` DHCP logs; blacklists `aic_btusb` in `post-wifibt.sh`; eliminates `mktemp -u` TOCTOU races in `common/scripts/build.sh`. |
| [`0004-buildroot-rootfs-lockdown-and-test-cleanup.patch`](patches/0004-buildroot-rootfs-lockdown-and-test-cleanup.patch) | `buildroot/` | Disables Buildroot root login and serial shell (`BR2_TARGET_ENABLE_ROOT_LOGIN` unset, `BR2_TARGET_SERIAL_SHELL_NONE=y`), removes legacy vendor test packages, and adds `board/rockchip/rk3506/users.table` to provision the unprivileged `egyscam` (`1001:1001`) service user. |
| [`0005-rkscript-usbdevice-no-tmp-config.patch`](patches/0005-rkscript-usbdevice-no-tmp-config.patch) | `external/rkscript/` | Removes `/tmp/.usb_config` lookup from `usbdevice` (preventing local privilege escalation into USB gadget configuration) and ensures `adb_prepare()` fails closed if `/usr/bin/adbd` is absent. |

---

## Step-by-Step Build & Installation Guide

You do not need to be a Linux kernel expert to build a hardened image. Follow each step in order.

### Step 1: Install Host Build Dependencies

Tested on **Debian / Ubuntu / Crostini (x86_64)**:

```bash
sudo apt-get update
sudo apt-get install -y git build-essential gcc g++ make cmake python3 bc \
    bison flex libssl-dev libncurses5-dev u-boot-tools libusb-1.0-0-dev \
    device-tree-compiler cpio rsync unzip file
```

> **Cross-Compilation Toolchain:** The official Luckfox Lyra RK3506 SDK includes its own prebuilt toolchains under:
> - Linux userspace / kernel (ARMv7 glibc hard-float): `prebuilts/gcc/linux-x86/arm/gcc-arm-10.3-2021.07-x86_64-arm-none-linux-gnueabihf/`
> - Cortex-M0 AMP bare-metal core: `prebuilts/gcc/linux-x86/arm/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux/`

### Step 2: Obtain the Base Luckfox Lyra SDK & Overlay This Repository

1. Download or clone the official **Luckfox Lyra RK3506 Linux SDK** (containing `kernel-6.1/`, `buildroot/`, `device/rockchip/`, `external/rkwifibt/`, `external/rkscript/`, `prebuilts/`, `tools/`, `u-boot/`).
2. Clone this hardened repository and copy its overlay files (`patches/`, `apply-hardened-patches.sh`, `build.sh`, `Makefile`, `rkflash.sh`, `LICENSE`, `NOTICE.md`) into the root of your SDK directory:

```bash
git clone https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version.git /tmp/lyra-hardened
cp -a /tmp/lyra-hardened/{patches,apply-hardened-patches.sh,build.sh,Makefile,rkflash.sh,LICENSE,NOTICE.md} /path/to/luckfox-lyra-sdk/
cd /path/to/luckfox-lyra-sdk
```

### Step 3: Apply All 5 Hardening Patches

Run the fail-closed patch script from the SDK root:

```bash
./apply-hardened-patches.sh
```

The script verifies all 5 upstream subtrees exist and applies `0001` through `0005` cleanly. If any patch is already applied, it detects it cleanly via reverse-check; if any conflict or missing directory is encountered, it aborts immediately with a non-zero exit code.

### Step 4: Select Your Board & Build

1. Select your Luckfox Lyra hardware target (for example, **Luckfox Lyra W / Zero W - SPI NAND**):
   ```bash
   ./build.sh lunch
   ```
2. Build the full hardened firmware image (SPL, U-Boot, Linux 6.1 kernel, AIC8800 Wi-Fi module, and locked-down Buildroot rootfs):
   ```bash
   ./build.sh
   ```
   *(To rebuild only the hardened kernel quickly during testing, run `./build.sh kernel`.)*

Generated firmware images are written to `output/image/` and linked under `rockdev/`.

### Step 5: Flash the Board

Put your Luckfox Lyra into **Maskrom / Loader** mode over USB-C, then flash the unified update archive using the hardened root wrapper:

```bash
sudo ./rkflash.sh update output/image/update.img
```

You can also flash individual partitions (for example `sudo ./rkflash.sh boot` or `sudo ./rkflash.sh rootfs`). Run `./rkflash.sh --help` for all supported targets.

---

## Post-Flash Security Verification Checklist

Before deploying a board to production (for example, during staging verification before final root lockdown or via automated health telemetry), confirm every hardening invariant:

| Check | Command / Inspection | Expected Hardened Result |
| :--- | :--- | :--- |
| Kernel cmdline | `cat /proc/cmdline` | No `user_debug=31`, root mounted `ro` |
| Seccomp-BPF active | `grep Seccomp /proc/self/status` | `Seccomp_filters:` present (`CONFIG_SECCOMP_FILTER=y`) |
| Landlock & Yama LSMs | `cat /sys/kernel/security/lsm` | Contains `landlock,yama` |
| Rootfs read-only | `awk '$2=="/"{print $4}' /proc/mounts` | Contains `ro` |
| No ADB daemon | `pgrep -a adbd` | Empty (not installed / not running) |
| Bluetooth disabled | `lsmod \| grep -E 'bt\|bluetooth'` & `cat /etc/modprobe.d/blacklist-bt.conf` | Empty `lsmod`; `blacklist aic_btusb` present |
| Unprivileged user | `getent passwd egyscam` | `egyscam:*:1001:1001:...:bin/false` |
| Root login locked | `grep '^root:' /etc/shadow` | Locked password entry (`*` or `!`) and no serial `getty` |

---

## License & Credits

- **License:** GNU General Public License version 2.0 — see verbatim text in [LICENSE](LICENSE).
- **Component Attributions:** See [NOTICE.md](NOTICE.md) for upstream credits (Linux Kernel 6.1 LTS, AICSemi, Rockchip Electronics, Buildroot, Luckfox/Waveshare, and `lotus-z-dev`).

*(Need an additional board for test automation? [Order Luckfox Lyra W on Amazon.ca](https://link.amazon/B016bDnRF) or explore [compatible accessories](https://link.amazon/B00vZoO0E).)*
