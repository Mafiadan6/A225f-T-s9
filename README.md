# KernelSU-Next with susfs for Samsung A22 (MT6768)

[![Kernel Version](https://img.shields.io/badge/Kernel-4.14.186-blue)]()
[![KernelSU Version](https://img.shields.io/badge/KernelSU-v3.1.0--legacy--susfs-green)]()
[![susfs Version](https://img.shields.io/badge/susfs-v2.0.0-orange)]()
[![Platform](https://img.shields.io/badge/Platform-MT6768-red)]()
[![Android Version](https://img.shields.io/badge/Android-11--13-lightgrey)]()

Custom kernel source for **Samsung Galaxy A22 (A225F/SM-A225M)** with **KernelSU-Next** and **susfs** integration for advanced root hiding and system modification capabilities.

---

## 📋 Features

### KernelSU-Next
- ✅ **Kernel-level root access** - Hidden from most detection methods
- ✅ **Allowlist management** - Grant root access per-app
- ✅ **KernelSU Manager support** - Official KSU Manager app compatible
- ✅ **Manual hook mode** - For kernels without KPROBES support
- ✅ **Module support** - Load KSU modules

### susfs v2.0.0 (Suspicious File System)
- ✅ **SUS_PATH** - Hide suspicious paths from system calls
- ✅ **SUS_MOUNT** - Hide mount entries from /proc/[mounts|mountinfo]
- ✅ **SUS_KSTAT** - Spoof file/directory statistics
- ✅ **TRY_UMOUNT** - Auto-umount KSU paths on app spawn
- ✅ **SPOOF_UNAME** - Spoof kernel version from uname syscall
- ✅ **HIDE_KSU_SUSFS_SYMBOLS** - Hide symbols from /proc/kallsyms
- ✅ **SPOOF_CMDLINE** - Spoof /proc/cmdline or /proc/bootconfig
- ✅ **OPEN_REDIRECT** - Redirect file opens to different paths
- ✅ **SUS_MAP** - Hide mmapped files from proc maps
- ✅ **AVC_LOG_SPOOFING** - Spoof SELinux AVC log messages

### Additional Features
- ✅ **kallsyms hiding** - Hide KSU/susfs symbols
- ✅ **Module hiding** - Hide modules from lsmod
- ✅ **uname spoofing** - Spoof kernel release/version
- ✅ **Custom kernel version** - `4.14.186-爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## 📱 Device Support

| Device | Codename | Chipset | Status |
|--------|----------|---------|--------|
| Samsung Galaxy A22 4G | a22 | MT6768 | ✅ Working |
| Samsung Galaxy A22 5G | a22x | Dimensity 700 | ❌ Not Supported |

**Firmware Base:** A225MUBSCCYE1 (Android 11/One UI 3.1)

---

## 🔧 Build Requirements

```bash
# Toolchain
- GCC: aarch64-linux-android-4.9
- Clang: r383902
- Linux: x86_64

# Dependencies
- bc
- bison
- flex
- libssl-dev
- python3
- make
- git
```

---

## 📦 How to Build

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/A225f-T-s9.git
cd A225f-T-s9

# Set up environment
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

# Build kernel
./build_kernel.sh

# Output
# - out/arch/arm64/boot/Image
# - out/arch/arm64/boot/Image.gz
```

---

## 📥 How to Flash

### Method 1: Using Kitchen Tool (Recommended)

```bash
# Unpack stock boot.img
cd Kitchen
bash kitchen unpack boot.img

# Replace kernel
cp /path/to/built/Image workspace/kernel

# Repack
bash kitchen repack

# Flash with Odin
# - Put boot.img in AP slot
# - Put vbmeta.img in USERDATA/VBMETA slot
```

### Method 2: Using MagiskBoot

```bash
# Unpack
magiskboot unpack boot.img

# Replace kernel
magiskboot split boot.img
cp Image kernel

# Repack
magiskboot repack boot.img

# Flash
fastboot flash boot new-boot.img
```

### Odin Flash Guide

| Odin Slot | File |
|-----------|------|
| BL | BL firmware |
| AP | AP firmware (or custom boot.img) |
| CP | CP firmware |
| CSC | CSC (or HOME_CSC) |
| USERDATA | vbmeta.img (disabled) |

⚠️ **Important:** Flash **disabled vbmeta.img** to avoid bootloop or "internal problem" error!

---

## 🎯 KernelSU Setup

1. **Flash the boot image** using Odin
2. **Install KernelSU Manager** from [GitHub Releases](https://github.com/KernelSU-Next/KernelSU-Next/releases)
3. **Open KSU Manager** - It should show "KernelSU is working"
4. **Configure allowlist** - Grant root access to apps that need it
5. **Enable Zygisk** (optional) - For LSPosed and modules

---

## 🔒 Security Notes

- **AVB (Android Verified Boot):** Enabled in kernel
- **dm-verity:** Enabled in kernel
- **SELinux:** Enforcing (can be set to permissive via cmdline)
- **Root hiding:** KernelSU + susfs provides advanced hiding

⚠️ **Warning:** This kernel modifies system behavior. Use at your own risk!

---

## 🐛 Known Issues

- [ ] "Internal problem" popup may appear (requires disabled vbmeta)
- [ ] Some banking apps may still detect root (use HideMyApplist + Shamiko)
- [ ] Google Pay may not work (use MagiskHide/Play Integrity Fix)

---

## 📝 Changelog

### v1.0 - Initial Release
- ✅ KernelSU-Next v3.1.0-legacy-susfs integrated
- ✅ susfs v2.0.0 fully integrated
- ✅ All susfs features enabled
- ✅ kallsyms hiding implemented
- ✅ Module hiding implemented
- ✅ uname spoofing implemented
- ✅ Custom kernel version: `爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## 🙏 Credits & Thanks

### Original Development
- **[@physwizz](https://t.me/physwizz)** - Original kernel backporting and base development
- **KernelSU-Next Team** - [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)
- **simonpunk** - [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)

### Special Thanks
- **topjohnwu** - [Magisk](https://github.com/topjohnwu/Magisk) for magiskboot
- **tiann** - Original [KernelSU](https://github.com/tiann/KernelSU)
- **ravindu644** - [Kitchen](https://github.com/ravindu644/Kitchen) tool

### Current Maintainer
- **[@Mastermind](https://t.me/bitcockiii)** - KernelSU-Next + susfs integration

---

## 📚 Sources

- **Kernel Source:** This repository
- **KernelSU-Next:** https://github.com/KernelSU-Next/KernelSU-Next (legacy_susfs branch)
- **susfs:** https://gitlab.com/simonpunk/susfs4ksu
- **Stock Firmware:** Samsung firmware repositories

---

## 📞 Support & Discussion

- **Telegram Channel:** [Your Channel Link]
- **Telegram Group:** [Your Group Link]
- **XDA Thread:** [XDA Thread Link]

---

## 📄 License

- **Kernel:** GPL-2.0
- **KernelSU-Next:** GPL-3.0
- **susfs:** GPL-3.0

---

## ⚠️ Disclaimer

This kernel is provided "as is" without any warranty. Flashing custom kernels may void your warranty and can potentially brick your device. Use at your own risk!

The developers are not responsible for any damage to your device, data loss, or any other issues that may occur from using this kernel.

---

**Made with ❤️ by Mastermind**
