# NVIDIA Tegra3 "Cardhu" development system
echo "DEBUG: Entering $TOP/vendor/nvidia/build/cardhu/cardhu.sh"

local OUTDIR=$(get_build_var PRODUCT_OUT)
echo "DEBUG: PRODUCT_OUT = $OUTDIR"

# setup FASTBOOT VENDOR ID
export FASTBOOT_VID=0x955

echo "Setting up NvFlash BCT for Cardhu with DDR3 SDRAM......"
cp $TEGRA_ROOT/../customers/nvidia/cardhu/nvflash/cardhu_12Mhz_H5TC2G83BFR_333Mhz_1GB_emmc_SDIN5C2-16G_x8.bct $TOP/$OUTDIR/flash.bct
cp $TEGRA_ROOT/../customers/nvidia/cardhu/nvflash/android_fastboot_emmc_full.cfg $TOP/$OUTDIR/flash.cfg
export NVFLASH_ODM_DATA=0x40080105

cp $TOP/$OUTDIR/obj/EXECUTABLES/bootloader_intermediates/bootloader.bin $TOP/$OUTDIR/bootloader.bin

echo "DEBUG: Leaving $TOP/vendor/nvidia/build/cardhu/cardhu.sh"
