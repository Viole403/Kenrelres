#!/usr/bin/env bash
#
# Copyright (C) 2021 a xyzprjkt property
#

echo "Downloading few Dependecies . . ."
# Toolchain
git clone --depth=1 https://github.com/CincauEXE/CincauTC
git clone --depth=1 https://github.com/ZyCromerZ/aarch64-zyc-linux-gnu -b 12 gcc
git clone --depth=1 https://github.com/ZyCromerZ/arm-zyc-linux-gnueabi -b 12 gcc32

# Kernel Sources
git clone --depth=1 https://github.com/mt6768-dev/android_kernel_xiaomi_mt6768.git base -b lineage-20

# Main Declaration
# export KERNEL_NAME=$(cat "arch/arm64/configs/$DEVICE_DEFCONFIG" | grep "CONFIG_LOCALVERSION=" | sed 's/CONFIG_LOCALVERSION="-*//g' | sed 's/"*//g' )
KERNEL_ROOTDIR=$(pwd)/base # IMPORTANT ! Fill with your kernel source root directory.
DEVICE_CODENAME=lacelot
DEVICE_DEFCONFIG=lancelot_defconfig # IMPORTANT ! Declare your kernel source defconfig file here.
CLANG_ROOTDIR=$(pwd)/CincauTC # IMPORTANT! Put your clang directory here.
export KBUILD_BUILD_USER=Violesec # Change with your own name or else.
export KBUILD_BUILD_HOST=Tevyat # Change with your own hostname.
CLANG_VER="$("$CLANG_ROOTDIR"/bin/clang --version)"
LLD_VER="$("$CLANG_ROOTDIR"/bin/ld.lld --version)"
export KBUILD_COMPILER_STRING="$CLANG_VER with $LLD_VER"
IMAGE=$(pwd)/base/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%F-%S")
DATE2=$(date +"%m%d")
START=$(date +"%s")
PATH="${PATH}:${CLANG_ROOTDIR}/bin:$(pwd)/gcc/bin:$(pwd)/gcc32/bin:${PATH}"
DTB=$(pwd)/kernel/out/arch/arm64/boot/dts/mediatek/mt6768.dtb
DTBO=$(pwd)/kernel/out/arch/arm64/boot/dtbo.img

TG_TOKEN="5949789016:AAELlNju5cK57v5gqMc29COUGgcT8lVdFh4"
TG_CHAT_ID="468268008"

#Check Kernel Version
KERVER=$LINUXVER

# Checking environtment
# Warning !! Dont Change anything there without known reason.
function check() {
echo ================================================
echo xKernelCompiler
echo version : rev1.5 - gaspoll
echo ================================================
echo BUILDER NAME = ${KBUILD_BUILD_USER}
echo BUILDER HOSTNAME = ${KBUILD_BUILD_HOST}
echo DEVICE_DEFCONFIG = ${DEVICE_DEFCONFIG}
echo TOOLCHAIN_VERSION = ${KBUILD_COMPILER_STRING}
echo CLANG_ROOTDIR = ${CLANG_ROOTDIR}
echo KERNEL_ROOTDIR = ${KERNEL_ROOTDIR}
echo ================================================
}

# Telegram
export BOT_MSG_URL="https://api.telegram.org/bot$TG_TOKEN/sendMessage"

tg_post_msg() {
  curl -s -X POST "$BOT_MSG_URL" -d chat_id="$TG_CHAT_ID" \
  -d "disable_web_page_preview=true" \
  -d "parse_mode=html" \
  -d text="$1"

}

# Post Main Information
tg_post_msg "<b>KernelCompiler</b>%0AKernel Name : <code>${KERNEL_NAME}</code>%0AKernel Version : <code>${LINUXVER}</code>%0ABuild Date : <code>${DATE}</code>%0ABuilder Name : <code>${KBUILD_BUILD_USER}</code>%0ABuilder Host : <code>${KBUILD_BUILD_HOST}</code>%0ADevice Defconfig: <code>${DEVICE_DEFCONFIG}</code>%0AClang Version : <code>${KBUILD_COMPILER_STRING}</code>%0AClang Rootdir : <code>${CLANG_ROOTDIR}</code>%0AKernel Rootdir : <code>${KERNEL_ROOTDIR}</code>"

# Compile
compile(){
tg_post_msg "<b>KernelCompiler:</b><code>Compilation has started</code>"
cd ${KERNEL_ROOTDIR}
make -j$(nproc) O=out ARCH=arm64 ${DEVICE_DEFCONFIG}
make -j$(nproc) ARCH=arm64 O=out \
    LD_LIBRARY_PATH="${CLANG_ROOTDIR}/lib64:${LD_LIBRARY_PATH}" \
    CC=${CLANG_ROOTDIR}/bin/clang \
    AR=${CLANG_ROOTDIR}/bin/llvm-ar \
    NM=${CLANG_ROOTDIR}/bin/llvm-nm \
    OBJCOPY=${CLANG_ROOTDIR}/bin/llvm-objcopy \
    OBJDUMP=${CLANG_ROOTDIR}/bin/llvm-objdump \
    STRIP=${CLANG_ROOTDIR}/bin/llvm-strip \
    LD=${CLANG_ROOTDIR}/bin/ld.lld \
    CLANG_TRIPLE=aarch64-linux-gnu- \
    CROSS_COMPILE=aarch64-zyc-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-zyc-linux-gnueabi-

  if ! [ -a "$IMAGE" ]; then
    finerr
  fi

  git clone --depth=1 https://github.com/CincauEXE/AnyKernel3 AnyKernel
	cp $IMAGE AnyKernel
#        cp $DTBO AnyKernel
#        mv $DTB AnyKernel/dtb
}

# Push kernel to channel
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$TG_TOKEN/sendDocument" \
        -F chat_id="$TG_CHAT_ID" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="✅ Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>$DEVICE_CODENAME</b> | <b>${KBUILD_COMPILER_STRING}</b>"
}
# Fin Error
function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$TG_TOKEN/sendMessage" \
        -d chat_id="$TG_CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="❌ Build failed to compile after $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds</b>"
    exit 1
}

# Zipping
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 [$DATE2][CLANG][$LINUXVER][R-OSS]$KERNEL_NAME[$DEVICE_CODENAME]$HEADCOMMITID.zip *
    cd ..
}

check
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push