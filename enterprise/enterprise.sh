# NVIDIA Tegra3 "Enterprise" development system
OUTDIR=$(get_build_var PRODUCT_OUT)
echo "DEBUG: PRODUCT_OUT = $OUTDIR"

# setup FASTBOOT VENDOR ID
export FASTBOOT_VID=0x955

# Set ODM_DATA for 2GB SDRAM
export NVFLASH_ODM_DATA=0x20098105

echo "Setting up NvFlash BCT for Enterprise with 512MB 533MHz DDR3 SDRAM......"
cp $TEGRA_ROOT/../customers/nvidia-partner/enterprise/nvflash/E1205_Hynix_512MB_KMMLL0000QM-B503_300MHz_20110408.bct $TOP/$OUTDIR/flash.bct
cp $TEGRA_ROOT/../customers/nvidia-partner/enterprise/nvflash/android_fastboot_emmc_full.cfg $TOP/$OUTDIR/flash.cfg
cp $TOP/$OUTDIR/obj/EXECUTABLES/bootloader_intermediates/bootloader.bin $TOP/$OUTDIR/bootloader.bin

