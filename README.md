# Luckfox Lyra Hardened SDK

[![GitHub Repository](https://img.shields.io/badge/GitHub-LuckFox__Lyra__SDK__hardened__version-blue?logo=github)](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)
[![License GPL-2.0](https://img.shields.io/badge/License-GPL%202.0-green.svg)](LICENSE)
[![Amazon.ca](https://img.shields.io/badge/Amazon.ca-Buy%20Luckfox%20Lyra-orange?logo=amazon)](https://link.amazon/B016bDnRF)

This project provides a stabilized, hardened, and reliable SDK for the **Luckfox Lyra (Rockchip RK3506 / RK3506B)** embedded platform, specifically optimized for mission-critical deployments (night-vision systems, UVC cameras, home automation gateways, and industrial edge sensors).

---

## 🛒 Supported Hardware & Purchase Links

Support the project and obtain the official single-board computer and compatible accessories via our partner links:

<p align="center">
  <a href="https://link.amazon/B016bDnRF">
    <img src="https://m.media-amazon.com/images/I/61f7o0iEaKL._AC_SL1200_.jpg" width="400" alt="Luckfox Lyra W SBC" />
  </a>
  <br />
  <em>👉 <a href="https://link.amazon/B016bDnRF"><strong>Order Luckfox Lyra W on Amazon.ca</strong></a></em>
</p>

- 🔗 **Direct Amazon.ca Purchase Link (Luckfox Lyra W Board):** [Buy Luckfox Lyra W](https://link.amazon/B016bDnRF)
- 🔍 **All Luckfox Products and Compatible Hardware on Amazon:** [Browse Luckfox Lineup on Amazon](https://link.amazon/B00vZoO0E)
- 📂 **Official Project Repository:** [https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version](https://github.com/lotus-z-dev/LuckFox_Lyra_SDK_hardened_version)

---

## 1. Why This Hardened SDK?

The stock vendor SDK provided for Luckfox Lyra boards exhibits several technical limitations, stability regressions, and legacy configuration choices that hinder continuous, unattended operation in production environments.

### Key Issues in the Stock SDK:
1. **Instability in Wi-Fi / Bluetooth Drivers (AIC8800):**
   - Intermittent kernel panics and resource leaks during frequent network disconnect/reconnect cycles.
   - Faulty memory boundary management within USB transport layers and vendor private ioctl commands.
   - Fragility when handling malformed packets or asynchronous RX messaging.

2. **Robustness Defects in Vendor Storage Subsystems:**
   - Memory corruption risks during repetitive read/write operations on MTD, Flash, and SDMMC vendor partitions.
   - Missing strict boundary and buffer length validations during block transfers.

3. **Inter-Core Synchronization Inconsistencies (RPMSG / AMP):**
   - Critical race conditions during intensive bidirectional communication between the application processor and the real-time core.
   - Potential NULL pointer dereferences and shared-memory state corruptions under transient faults.

4. **Excessive Kernel Attack Surface:**
   - Obsolete debug test modules and diagnostic hooks left enabled in production configurations, consuming unnecessary memory and exposing fragile entry points.
   - Unchecked geometric calculations and scaling boundary handling in 2D hardware accelerators.

---

## 2. Hardening and Improvements

This SDK provides a comprehensive overhaul of these critical components while maintaining 100% full compatibility with the Luckfox software ecosystem:

- **Wi-Fi / Bluetooth Driver Hardening (`aic8800`):**
  - Exhaustive length and sanity checks on every incoming and outgoing network frame.
  - Complete elimination of buffer overruns and rigorous verification of memory allocation return codes.
  - Hardened Bluetooth firmware loading routine.

- **Resilient Flash / MTD Vendor Storage:**
  - Strict boundary controls on all vendor partition operations.
  - Prevention of silent memory corruption during environment variable persistence.

- **RPMSG IPC Channel Stabilization:**
  - Synchronized locking on concurrent access paths, eliminating bus deadlocks between asymmetric cores.
  - Guaranteed resource cleanup and buffer reclamation on communication aborts.

- **Optimized Kernel Configuration (`rk3506_luckfox_defconfig`):**
  - Reduced attack surface via removal of obsolete test modules.
  - Enforced Linux 6.1 LTS kernel memory protections and hardening flags.

---

## 3. Prerequisites & Build Environment

### Host Dependencies (Debian / Ubuntu / Crostini):
```bash
sudo apt-get update
sudo apt-get install -y git build-essential gcc g++ make cmake python3 bc \
    bison flex libssl-dev libncurses5-dev u-boot-tools libusb-1.0-0-dev device-tree-compiler
```

### Cross-Compilation Toolchain:
The SDK relies on the official ARM cross-compiler toolchain integrated under `tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/`.

---

## 4. Building from Source

### A. Target Initialization
Run the interactive hardware target selection menu:
```bash
./build.sh lunch
```
Select the configuration corresponding to your board (e.g., `Luckfox Lyra Zero W - SPI NAND`).

### B. Complete System Build
To generate all system components (SPL, U-Boot, Linux 6.1 Kernel, Rootfs):
```bash
./build.sh
```

### C. Building the Kernel Only
To quickly compile and test the hardened kernel:
```bash
./build.sh kernel
```

Generated flashable firmware images are placed in `output/image/`.

---

## 5. Applying Hardened Patches to an Existing SDK

If you already maintain an existing official Luckfox SDK tree, you can apply all hardening patches with a single command using the provided script:

```bash
./apply-hardened-patches.sh
```

This applies:
- `patches/0001-kernel-6.1-security-hardening-storage-amp-rpmsg-rga.patch`: Hardened vendor storage, verified RPMSG IPC, and locked-down kernel defconfig.
- `patches/0002-rkwifibt-aic8800-driver-robustness-and-usb-sanitization.patch`: Sanitized USB RX buffers, boundary-checked private ioctls, and hardened AIC8800 Wi-Fi/BT drivers.

---

## 6. Flashing the Board

Connect the Luckfox board in Maskrom/Download mode via USB-C, then invoke the upgrade utility:
```bash
sudo ./tools/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool uf output/image/update.img
```

*(Need an additional board for test automation? [Order Luckfox Lyra W on Amazon.ca](https://link.amazon/B016bDnRF) or explore [compatible accessories](https://link.amazon/B00vZoO0E).)*

---

## 7. Credits & License

- **Project Maintenance:** [lotus-z-dev](https://github.com/lotus-z-dev)
- **Linux Kernel 6.1:** Linus Torvalds, Linux community contributors & Rockchip Electronics Co., Ltd.
- **Wi-Fi / BT Drivers:** AICSemi Inc. & Rockchip Electronics Co., Ltd.
- **Build System & Tooling:** Luckfox / Waveshare & Rockchip Electronics Co., Ltd.

Full licensing details and legal disclaimers are documented in [LICENSE](LICENSE).

---

## 8. Security & Contributions

- Never commit secrets, authentication tokens, private keys, or passwords.
- All kernel and driver modifications must compile cleanly with `-Werror`.
