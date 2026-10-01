# KernelSU-Next + susfs + NoMount for Samsung A22 4G (MT6768)

[![Kernel Version](https://img.shields.io/badge/Kernel-4.14.186-blue)]()
[![KernelSU Version](https://img.shields.io/badge/KernelSU-33227-green)]()
[![susfs Version](https://img.shields.io/badge/susfs-v2.0.0-orange)]()
[![NoMount](https://img.shields.io/badge/NoMount-v2.0.0-purple)]()
[![Platform](https://img.shields.io/badge/Platform-MT6768-red)]()
[![Android Version](https://img.shields.io/badge/Android-11--13-lightgrey)]()

Custom kernel source for **Samsung Galaxy A22 4G (SM-A225F / SM-A225M)** with
**KernelSU-Next**, **susfs** and **NoMount** — built and published automatically
through GitHub Actions as a ready-to-flash AnyKernel3 zip.

Report builds in the [Releases](../../releases) page; every push gets its own
tagged release, so previous builds stay downloadable.

---

## 📋 Features

### KernelSU-Next (version 33227)
- ✅ **Kernel-level root access** — hidden from most detection methods
- ✅ **Allowlist management** — grant root access per-app
- ✅ **Manual hook mode** — for kernels without reliable KPROBES
- ✅ **Module support** — load KSU modules
- ✅ **ksud bundled** — userspace helper shipped with the kernel

### susfs v2.0.0 (Suspicious File System)
- ✅ **SUS_PATH** — hide suspicious paths from system calls
- ✅ **SUS_MOUNT** — hide mount entries from `/proc/[mounts|mountinfo]`
- ✅ **SUS_KSTAT** — spoof file/directory statistics
- ✅ **TRY_UMOUNT** — auto-umount KSU paths on app spawn
- ✅ **SPOOF_UNAME** — spoof kernel version from the `uname` syscall
- ✅ **HIDE_KSU_SUSFS_SYMBOLS** — hide symbols from `/proc/kallsyms`
- ✅ **SPOOF_CMDLINE** — spoof `/proc/cmdline` and `/proc/bootconfig`
- ✅ **OPEN_REDIRECT** — redirect file opens to different paths
- ✅ **SUS_MAP** — hide mmapped files from proc maps
- ✅ **AVC_LOG_SPOOFING** — spoof SELinux AVC log messages

> `include/linux/susfs.h` sets `SUSFS_VERSION` to `v2.2.0`. That string is a
> **label only** — the susfs code in this tree is upstream v2.0.0. Use v2.0.0
> when comparing against upstream releases.

### NoMount (VFS path redirection)
- ✅ **In-RAM module injection** — overlay files served from memory, no mounts
- ✅ **`/proc/mounts` untouched** — nothing to detect in the mount table
- ✅ **No `/dev` nodes, no IOCTL** — communicates with userspace via the keyring
- ✅ **Built in** as `CONFIG_NOMOUNT=y` (required on 4.14, see below)
- ✅ **Full VFS coverage** — path resolution *and* directory iteration

NoMount lets you inject and overlay files without mounting anything. It is a
drop-in alternative to Magic Mount and OverlayFS-based module loaders.

**The kernel side ships in this zip. The WebUI does not.** NoMount's module
management interface is a separate KernelSU metamodule — see
[NoMount setup](#-nomount-setup).

### KPM (Kernel Package Manager)
- ✅ **KPM module loader** — load `.kpm` modules at boot
- ✅ **KPatch-Next compatible** — full kernel patching support
- ✅ **KALLSYMS_ALL** — all kernel symbols exported for patching

### Additional
- ✅ **kallsyms hiding** — KSU/susfs symbols removed from `/proc/kallsyms`
- ✅ **Module hiding** — modules hidden from `lsmod`
- ✅ **uname spoofing** — spoofs kernel release and version
- ✅ **Custom version string** — `4.14.186-爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## 📱 Device Support

| Device | Codename | SoC | Status |
|--------|----------|-----|--------|
| Samsung Galaxy A22 4G | `a22` | MT6768 (Helio G80) | ✅ Working |
| Samsung Galaxy A22 5G | `a22x` | Dimensity 700 | ❌ Not supported |

All MT6768 A22 4G variants are covered by the same kernel: SM-A225F, SM-A225M,
SM-A225G, SM-A225N, SM-A225B.

**Firmware base:** A225MUBSCCYE1 (Android 11 / One UI 3.1)

> This is a **MediaTek** device. Despite the `a22` codename, it does not share
> code with the Exynos `a22`/`a22s` 5G models.

---

## 🚀 Quick Start

1. Download the latest `KSUN_SUSFS_A22_Kernel_build<N>.zip` from
   [Releases](../../releases)
2. Boot to **stock recovery** (Volume Up + Bixby + Power)
3. Select **Apply update / Install** → pick the zip
4. Reboot, then install the KernelSU manager (below)

If KSU reports "not working" after boot, your `boot` partition was not flashed
or was flashed from a different slot. Re-flash and confirm the active slot.

---

## 📥 Flashing

### Method 1: AnyKernel3 recovery (recommended)

Every release zip is a complete AnyKernel3 package containing
`Image.gz` plus the installer shell. No repacking needed.

```bash
# From stock recovery
adb push KSUN_SUSFS_A22_Kernel_build<N>.zip /sdcard/
# then Apply update / Install from recovery, or:
adb reboot recovery
# Recovery sideload:
adb sideload KSUN_SUSFS_A22_Kernel_build<N>.zip
```

Targets `SM-A225F`, `SM-A225M` and writes to
`/dev/block/platform/bootdevice/by-name/boot`.

### Method 2: Kitchen + Odin

```bash
cd Kitchen
bash kitchen unpack boot.img
cp /path/to/out/arch/arm64/boot/Image workspace/kernel
bash kitchen repack
```

| Odin slot | File |
|-----------|------|
| BL | BL firmware |
| AP | AP firmware + your repacked `boot.img` |
| CP | CP firmware |
| CSC | CSC (or HOME_CSC to keep data) |
| USERDATA | disabled `vbmeta.img` |

⚠️ **Flash a disabled `vbmeta.img`**, otherwise Android will bootloop or show
an "internal problem" dialog.

### Method 3: MagiskBoot / fastboot

```bash
magiskboot unpack boot.img
magiskboot split boot.img
cp out/arch/arm64/boot/Image kernel
magiskboot repack boot.img
fastboot flash boot new-boot.img
```

---

## 🧰 KernelSU Setup

1. Flash the kernel (above)
2. Install `KernelSU_Next_v3.4.0_33294-release.apk` from the
   [KernelSU-Next v3.4.0 release](../../releases/tag/v3.4.0) — the manager
   version must be **≥ the kernel version** (this kernel reports 33227)
3. Open the manager; it should show **KernelSU is working**
4. Configure the **allowlist** — grant root only to apps that need it
5. Enable **Zygisk** (optional) — needed for LSPosed-style modules

A `-spoofed_` manager variant is also published if you want the manager itself
to hide its traces.

---

## 🗄 NoMount Setup

The kernel-side subsystem is already built in. To get the WebUI and module
management:

1. Download `NoMount-v2.0.0-release.zip` from
   [maxsteeel/nomount releases](https://github.com/maxsteeel/nomount/releases)
2. Import it through the **KernelSU manager** as a module
3. Reboot

**Why it is built in rather than a loadable module:** upstream NoMount ships a
pre-compiled LKM, but that path only works on Linux **5.10 and newer**. This
kernel is 4.14.186, so the only options were source integration or a custom
LKM. It is vendored as a built-in subsystem instead — see
[NoMount integration](#-nomount-integration-details).

---

## 🔧 Building

### Option A: GitHub Actions (recommended)

Push to `main` and CI does the rest. No toolchain setup required.

| Step | What it does |
|------|--------------|
| Checkout | Fetches the tree plus the KernelSU-Next submodule |
| Install build dependencies | apt packages needed by the build |
| Verify toolchain + submodule | Fails fast if the toolchain or submodule is missing |
| Report free disk space | Prints free space |
| Build | `make` + `Image` → `Image.gz` |
| Package zip | AnyKernel3 tree + `Image.gz` → `KSUN_SUSFS_A22_Kernel_build<N>.zip` |
| Publish zip | Creates release `v2.0.1-build.<N>` |
| Upload Image | Raw `Image` + `Image.gz` as a build artifact |
| Upload build log | Attach `build.log` on failure |
| Remove build output | Deletes `out/` |

Each successful build gets its own tag, so nothing is overwritten:

```
tag:  v2.0.1-build.<run_number>
zip:  KSUN_SUSFS_A22_Kernel_build<run_number>.zip
```

Run numbers are monotonic, so tags never collide and older builds stay
available. To trigger a build without changing anything, re-run a workflow from
the Actions tab.

Artifacts (raw `Image`) live on the run page for **90 days**; release zips are
permanent.

### Option B: Local build

Requires substantial disk (~100 GB) and RAM. The CI runner is the practical
option for this tree.

```bash
git clone --recurse-submodules https://github.com/Mafiadan6/A225f-T-s9.git
cd A225f-T-s9

export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64

./build_kernel.sh
```

Dependencies: `bc`, `bison`, `flex`, `libssl-dev`, `python3`, `make`, `git`,
and `llvm-nm` (for the image-size report).

Output:

```
out/arch/arm64/boot/Image
out/arch/arm64/boot/Image.gz
```

> `.gitignore` excludes `/out/` and `build.log`, so local output is never
> committed.

---

## 🧩 Component Versions

| Component | Version | Source |
|-----------|---------|--------|
| Kernel | 4.14.186 | This repository |
| KernelSU-Next | 33227 | [`Mafiadan6/KernelSU-Next`](https://github.com/Mafiadan6/KernelSU-Next) @ `legacy-susfs-v2-nosusfsextra` |
| KernelSU manager | v3.4.0 (33294) | [KernelSU-Next releases](https://github.com/KernelSU-Next/KernelSU-Next/releases/tag/v3.4.0) |
| susfs | v2.0.0 | [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) |
| NoMount | v2.0.0 (vendored `c5fad9d`) | [maxsteeel/nomount](https://github.com/maxsteeel/nomount) |
| Toolchain | clang r383902 + GCC 4.9 | `toolchain/` |

`KernelSU-Next/` is a **git submodule** pinned to our fork. Use
`--recurse-submodules`, or run `git submodule update --init --recursive`
inside an existing clone.

---

## 🩺 Local KSU Compatibility Fixes

Two patches are applied on top of `legacy-susfs-v2`, needed for this 4.14 tree:

1. **`susfs_run_sus_path_loop(new_uid)` is called directly** instead of being
   handed to a `susfs_extra_works` workqueue — this kernel does not define that
   symbol, so the deferred path failed to link.
2. **`strscpy_pad()` routes through the `__strscpy_pad()` compat wrapper** —
   `strscpy_pad` only exists from Linux 5.8, and this tree is 4.14.186.

Without these the kernel does not link at all.

---

## 🧪 NoMount Integration Details

Vendored rather than symlinked, so CI stays reproducible and the tree does not
depend on a build-time `git clone`.

| File | Purpose |
|------|---------|
| `fs/nomount/nomount.c` | VFS path redirection implementation |
| `fs/nomount/nomount.h` | Shared declarations |
| `fs/nomount/Kconfig` | Defines `CONFIG_NOMOUNT` (tristate, default `y`) |
| `fs/nomount/Makefile` | Kbuild file |

Wiring:

- `fs/Makefile` — `obj-$(CONFIG_NOMOUNT) += nomount/`
- `fs/Kconfig` — `source "fs/nomount/Kconfig"`
- `arch/arm64/configs/a22_defconfig` — `CONFIG_NOMOUNT=y`

The source carries `LINUX_VERSION_CODE` guards back to **Linux 4.11**, so it
handles the older VFS APIs this kernel uses.

To disable it, comment out `CONFIG_NOMOUNT=y` in `a22_defconfig` and drop the
two lines from `fs/Makefile` and `fs/Kconfig`. To update to a newer NoMount,
replace the four files in `fs/nomount/` with the upstream `kernel/src/` contents.

Upstream's `setup.sh` does this automatically and is the reference if you want
to follow it instead — but it clones at build time, which is why it is not used
here.

---

## 🔒 Security Notes

- **AVB (Android Verified Boot):** enabled — flash disabled `vbmeta.img`
- **dm-verity:** enabled
- **SELinux:** enforcing (permissive via kernel cmdline if you must)
- **Root hiding:** KernelSU-Next + susfs
- **Module injection:** NoMount serves overlay files from RAM

⚠️ This kernel changes system behaviour. Use it at your own risk.

---

## 🐛 Known Issues

Observed on this device:

- [ ] **One-time reboot into safe mode** on first boot of a new build. `vold`
      received a `SIGKILL` during startup, which triggers Android's controlled
      shutdown. Not fatal — reboot and it goes away. Predates NoMount.
- [ ] **Mali GPU teardown warning** —
      `mali_kbase_context.c:295 kbase_context_common_term` in
      `/proc/last_kmsg` as apps exit. Cosmetic; graphics work normally.

Expected on this device generally:

- [ ] **"Internal problem"** after flashing unless `vbmeta` is disabled
- [ ] **Some banking apps still detect root** — pair susfs with HideMyApplist
      and Shamiko
- [ ] **Play Integrity fails** — use Play Integrity Fix

Debugging:

```bash
adb shell su -c 'dmesg | grep -iE "nomount|ksu|susfs"'
adb pull /system-root/proc/last_kmsg
adb shell uname -a    # should read 4.14.186-爪卂丂ㄒ乇尺爪工刀ᗪ丂
```

---

## 📝 Changelog

### Build 9 — NoMount
- ✅ **NoMount VFS path redirection** built in as `CONFIG_NOMOUNT=y`, with
      support for kernels below 5.10
- ✅ **Per-build releases** — each CI run publishes its own tag and asset
      instead of overwriting the last one
- ✅ **Expanded release notes** — generated automatically for every build

### v2.0.1 — AnyKernel3 packaging + release automation
- ✅ **Complete AnyKernel3 release zips** — `Image.gz` plus the installer
      shell, flashable straight from recovery
- ✅ **GitHub Actions pipeline** — builds, packages, and publishes on push
- ✅ **Module hiding** routed through the wrapper so it stops calling an
      undefined symbol
- ✅ **Clean release step** — `out/` removed after upload

### v2.0.0 — KPM support
- ✅ **KPM module loader** — Kernel Package Manager support
- ✅ **KALLSYMS_ALL** — required for KPatch-Next and KPM modules
- ✅ **All susfs v2.0.0 features** functional
- ✅ **KernelSU-Next legacy-susfs** integration

### v1.0 — Initial release
- ✅ KernelSU-Next integrated
- ✅ susfs v2.0.0 fully integrated, all features enabled
- ✅ kallsyms hiding, module hiding, uname spoofing
- ✅ Custom version string `爪卂丂ㄒ乇尺爪工刀ᗪ丂`

---

## 🙏 Credits

### Original development
- **[@physwizz](https://t.me/physwizz)** — kernel backporting and base
  development
- **KernelSU-Next** — [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next)
- **simonpunk** — [susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu)
- **maxsteeel** — [nomount](https://github.com/maxsteeel/nomount)

### Tools
- **topjohnwu** — [Magisk](https://github.com/topjohnwu/Magisk) for `magiskboot`
- **tiann** — [KernelSU](https://github.com/tiann/KernelSU)
- **ravindu644** — [Kitchen](https://github.com/ravindu644/Kitchen)

### Maintainer
- **[@Mastermind](https://t.me/bitcockiii)** — KernelSU-Next, susfs and
  NoMount integration

---

## 📄 License

| Component | License |
|-----------|---------|
| Kernel | GPL-2.0 |
| KernelSU-Next | GPL-3.0 |
| susfs | GPL-3.0 |
| NoMount (`fs/nomount/`) | GPL-3.0 |

---

## ⚠️ Disclaimer

This kernel is provided **as is**, without warranty. Flashing custom kernels may
void your warranty and can brick your device. You are responsible for any damage
to your device, data loss, or other issues arising from use of this kernel.

---

**Made with ❤️ by Mastermind**