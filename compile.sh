#!/bin/bash
starttime=`date +'%Y-%m-%d %H:%M:%S'`

export ARCH=arm64
export SUBARCH=arm64

export KBUILD_BUILD_HOST=ArchLinux
export KBUILD_BUILD_USER="Violesec"

PATH="$BUILDER:$PATH"
# make -j$(nproc --all) O=out \
#     NM=llvm-nm \
#     OBJCOPY=llvm-objcopy \
#     LD=ld.lld \
#     CROSS_COMPILE=aarch64-linux-gnu- \
#     CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
#     CC=clang \
#     AR=llvm-ar \
#     OBJDUMP=llvm-objdump \
#     STRIP=llvm-strip \
#     2>&1 | tee error.log
# make -j$(nproc --all) O=out \
#     AR=llvm-ar \
#     CC=clang \
#     CLANG_TRIPLE=aarch64-linux-gnu- \
#     CROSS_COMPILE=aarch64-linux-gnu- \
#     CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
#     HOSTCC=clang \
#     HOSTLD=ld.lld \
#     HOSTAR=llvm-ar \
#     HOSTCXX=clang++ \
#     LD=ld.lld \
#     NM=llvm-nm \
#     OBJCOPY=llvm-objcopy \
#     OBJDUMP=llvm-objdump \
#     STRIP=llvm-strip \
#     2>&1 | tee error.log

make -kj$(nproc --all) O=out \
    ARCH=arm64 \
	CC=clang \
	CROSS_COMPILE=aarch64-linux-gnu- \
	CROSS_COMPILE_COMPAT=arm-linux-gnueabi- \
	V=$VERBOSE 2>&1 | tee error.log

endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date=" $starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);

echo Start: $starttime.
echo End: $endtime.
echo "Build Time: "$((end_seconds-start_seconds))"s."