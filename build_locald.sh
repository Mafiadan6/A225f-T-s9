#!/bin/bash
# Samsung Galaxy A22 4G (A225F / SM-A225F) - MT6768
# Kernel 4.14.186 "Petit Gorille" + KernelSU-Next + susfs
#
# Native aarch64 host toolchain:
#   CC       : clang 22 (system /usr/bin/clang)
#   binutils : native aarch64 GNU as/ld/nm/ar/objcopy/... in /usr/bin
#
# toolchain/ in this tree is linux-x86_64 only and CANNOT execute on this
# aarch64 host ("cannot execute binary file"), so nothing below touches it.
#
# CC/CROSS_COMPILE and friends are passed as make COMMAND-LINE variables on
# purpose: Makefile:378 hardcodes CC to the bundled x86 clang, and only a
# command-line assignment outranks it (exported env vars do not).
# CROSS_COMPILE stays EMPTY so Kbuild picks up the native aarch64 binutils and
# the Makefile's clang branch skips its x86 --prefix/--gcc-toolchain probing.

set -euo pipefail

SRCTREE="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"
OUT="$SRCTREE/out"
LOG="$OUT/build.log"

DEFCONFIG="${DEFCONFIG:-a22_defconfig}"
TARGETS="${TARGETS:-Image Image.gz}"
JOBS="${JOBS:-6}"          # raise/lower to taste; ~155 MB peak per clang
CLEAN="${CLEAN:-0}"

# -w silences the vendor tree; --target pins clang to arm64 explicitly.
# -integrated-as overrides the Makefile's -no-integrated-as (KCFLAGS lands last).
# It is required: clang emits the bounds.c "#pragma message" .ascii payloads
# inside .text, and binutils 2.47 as rejects that with
# "unaligned opcodes detected in executable segment".
KCFLAGS_VALUE="-w --target=aarch64-linux-gnu -integrated-as"

CC_BIN="$(command -v clang || true)"
if [ -z "$CC_BIN" ]; then
	echo "error: clang not found in PATH" >&2
	exit 1
fi

for t in as ld ar nm objcopy objdump strip; do
	command -v "$t" >/dev/null 2>&1 || {
		echo "error: required binutils tool '$t' not found in PATH" >&2
		exit 1
	}
done

# Fail fast instead of dying inside Kconfig on a broken kernelsu symlink.
if [ ! -e "$SRCTREE/drivers/kernelsu/Kconfig" ]; then
	echo "error: drivers/kernelsu is a broken link - KernelSU-Next/kernel is missing." >&2
	echo "       Fix: git submodule update --init --recursive" >&2
	echo "       (repo has no .gitmodules, so clone KernelSU-Next into place manually)." >&2
	exit 1
fi

# kernel/gen_kheaders.sh hardcodes $KBUILD_SRC/tools/build/cpio, which ships as
# an x86-64 blob and cannot run here. Swap in the native cpio, keeping the
# original once. Runs every build but is a no-op after the first time.
CPIO="$SRCTREE/tools/build/cpio"
if [ -f "$CPIO" ] && ! "$CPIO" --version >/dev/null 2>&1; then
	if [ ! -e "$CPIO.x86_64.bak" ]; then
		mv "$CPIO" "$CPIO.x86_64.bak"
		echo ">>> stashed x86-64 tools/build/cpio -> cpio.x86_64.bak"
	fi
	cat >"$CPIO" <<-'EOF'
		#!/bin/sh
		exec /usr/bin/cpio "$@"
	EOF
	chmod +x "$CPIO"
	echo ">>> installed native tools/build/cpio -> $(/usr/bin/cpio --version 2>&1 | head -1)"
fi

mkdir -p "$OUT"

MAKE_VARS=(
	"O=$OUT"
	"CC=clang"
	"CROSS_COMPILE="
	"HOSTCC=gcc"
	"HOSTCXX=g++"
	"AS=as" "LD=ld" "AR=ar" "NM=nm" "STRIP=strip"
	"OBJCOPY=objcopy" "OBJDUMP=objdump"
	"KCFLAGS=$KCFLAGS_VALUE"
)

run_make() {
	make -C "$SRCTREE" "${MAKE_VARS[@]}" "$@"
}

if [ "$CLEAN" = "1" ]; then
	echo ">>> mrproper"
	run_make mrproper || true
fi

echo ">>> [$DEFCONFIG]"
run_make "$DEFCONFIG" 2>&1 | tee "$LOG"

echo ">>> building [$TARGETS] with -j$JOBS  (CC=$(clang --version | head -1))"
# shellcheck disable=SC2086
run_make -j"$JOBS" $TARGETS 2>&1 | tee -a "$LOG"

echo
echo ">>> artifacts"
for img in Image Image.gz; do
	if [ -f "$OUT/arch/arm64/boot/$img" ]; then
		printf '    %s  (%s)\n' \
			"$OUT/arch/arm64/boot/$img" \
			"$(du -h "$OUT/arch/arm64/boot/$img" | cut -f1)"
	fi
done

file "$OUT/arch/arm64/boot/Image" 2>/dev/null || true
echo ">>> log: $LOG"