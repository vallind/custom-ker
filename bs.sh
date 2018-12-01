# Copyright ? 2016, Hani Kirkire "kirkirehani93" <kirkirehani93@gmail.com>
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it

# Init Script
KERNEL_DIR=$PWD
KERNEL="Image.gz-dtb"
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
EXFAT_MOD=$KERNEL_DIR/out/

BUILD_START=$(date +"%s")
ANYKERNEL_DIR=/root/kernel/any
EXPORT_DIR=/root/kernel/flashablezips

# Make Changes to this before release
ZIP_NAME="Derp-MIUI-v3.7"

# Tweakable Options Below
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER="WSL"
export KBUILD_BUILD_HOST="OS"
export KBUILD_COMPILER_STRING=$(/root/kernel/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')

TOOLCHAIN=/root/kernel/gcc/bin/aarch64-linux-android-
CLANG_PATH=/root/kernel/clang/bin/clang
CLANG_TRIPLE=aarch64-linux-gnu-
MAKE_OPTS="ARCH=arm64 O=out CC=${CLANG_PATH} CLANG_TRIPLE=${CLANG_TRIPLE} CROSS_COMPILE=${TOOLCHAIN}"

echo "  Initializing build to compile Ver: $ZIP_NAME    "

echo "         Creating Output Directory: out      "

mkdir -p out

echo "          Cleaning Up Before Compile          "

#make O=out clean 
#make O=out mrproper


echo "          Initialising DEFCONFIG        "

make O=out ARCH=arm64 whyred_defconfig

echo "          Cooking Derp....        "


make -j$(nproc --all) O=out ${MAKE_OPTS}

# If the above was successful
if [ -a $KERN_IMG ]; then
   BUILD_RESULT_STRING="BUILD SUCCESSFUL"

echo "       Making Flashable Zip       "

   # Make the zip file
   echo "MAKING FLASHABLE ZIP"


#adding modules for exfat

 rm -f ${ANYKERNEL_DIR}/Image.gz*                 
 rm -f ${ANYKERNEL_DIR}/zImage*                    
 rm -f ${ANYKERNEL_DIR}/dtb*                  

*/
cp -vr ${KERN_IMG} ${ANYKERNEL_DIR}/Image.gz-dtb  

#since modules are compiled inline with kernel , we dont need this  
#rm -rf ${ANYKERNEL_DIR}/modules/system/vendor/lib/modules

#mkdir -p ${ANYKERNEL_DIR}/modules/system/vendor/lib/modules


#cp ${EXFAT_MOD}fs/exfat/exfat.ko ${ANYKERNEL_DIR}/modules/system/vendor/lib/modules/exfat.ko


#adding modules for exfat

   cd ${ANYKERNEL_DIR}


   rm *.zip 

   zip -r9 ${ZIP_NAME}.zip * -x README ${ZIP_NAME}.zip

else
   BUILD_RESULT_STRING="BUILD FAILED"
fi

NOW=$(date +"%m-%d-%H-%M")
ZIP_LOCATION=${ANYKERNEL_DIR}/${ZIP_NAME}.zip
ZIP_EXPORT=${EXPORT_DIR}/${NOW}
ZIP_EXPORT_LOCATION=${EXPORT_DIR}/${NOW}/${ZIP_NAME}.zip

rm -rf ${ZIP_EXPORT}
mkdir ${ZIP_EXPORT}
cp ${ZIP_LOCATION} ${ZIP_EXPORT}
cd ${HOME}

# End the script
echo "${BUILD_RESULT_STRING}!"

# BUILD TIME
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$Yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"