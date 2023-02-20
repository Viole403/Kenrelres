#!/bin/bash
starttime=`date +'%Y-%m-%d %H:%M:%S'`

# Export ARCH and SUBARCH
export ARCH=arm64
export SUBARCH=arm64
export DTC_EXT=dtc

# KBUILD HOST and USER
export KBUILD_BUILD_HOST=ArchLinux
export KBUILD_BUILD_USER="Viole403"

PATH="$BUILDER:$PATH"
# DEVICE_CONFIG=lancelot_defconfig

# PATH="/home/circleci/project/toolchain:$PATH"

make -kj$(nproc --all) O=out $DEVICE_FULL \
    ARCH=arm64 \
    AR=llvm-ar \
    AS=llvm-as \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    CC=clang \
    LD=ld.lld \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    READELF=llvm-readelf \
    STRIP=llvm-strip \
    # ARCH=arm64 \
    # AR=llvm-ar \
    # CC=clang \
    # CROSS_COMPILE=aarch64-linux-gnu- \
    # CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
    2>&1 | tee error.log
endtime=`date +'%Y-%m-%d %H:%M:%S'`

start_seconds=$(date --date=" $starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);

echo Start: $starttime.
echo End: $endtime.
echo "Build Time: "$((end_seconds-start_seconds))"s."
