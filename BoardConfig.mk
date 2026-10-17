# ---- SoC / CPU (MediaTek MT6572) ----
TARGET_BOARD_PLATFORM := mt6572
TARGET_BOOTLOADER_BOARD_NAME := luv50ss
BOARD_VENDOR := lge

TARGET_ARCH := arm
# La toolchain de este árbol no reconoce 'cortex-a7' (la ignora con un warning
# por archivo), así que se usa el mismo tuning que vee4ss. El Cortex-A7 del
# MT6572 ejecuta código ARMv7-A/cortex-a9 sin problema.
TARGET_ARCH_VARIANT := armv7-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a9
TARGET_ARCH_LOWMEM := true

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

# ---- Kernel prebuilt ----
TARGET_PREBUILT_KERNEL := device/lge/luv50ss/kernel

# MTK boot image: base=0x10000000 → kernel@0x10008000, ramdisk@0x11000000
# (offsets confirmados con abootimg -i sobre boot_raw.img real, idénticos a vee4ss/vee5ss)
BOARD_KERNEL_BASE := 0x10000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_CMDLINE := androidboot.hardware=mt6572
BOARD_MKBOOTIMG_ARGS := --ramdisk_offset 0x01000000 --tags_offset 0x00000100

# mtkbootimg: custom mkbootimg que añade headers MTK al kernel y ramdisk
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_MKBOOTIMG := $(HOST_OUT_EXECUTABLES)/mtkbootimg$(HOST_EXECUTABLE_SUFFIX)
BOARD_CUSTOM_BOOTIMG_MK := device/lge/luv50ss/bootimg.mk

# Partition sizes (de /proc/dumchar_info y /proc/partitions del dispositivo real, 2026-07-24)
BOARD_BOOTIMAGE_PARTITION_SIZE     := 10485760
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 10485760
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 1572864000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 1677721600
BOARD_FLASH_BLOCK_SIZE := 131072

TARGET_USERIMAGES_USE_EXT4 := true

# Recovery
BOARD_HAS_NO_SELECT_BUTTON := true
# Con esto "reboot system" vuelve a Android y no entra en loop a recovery
# (verificado en hardware, igual que en vee4ss/vee5ss).
BOARD_HAS_NO_MISC_PARTITION := true
BOARD_SUPPRESS_SECURE_ERASE := true
BOARD_SUPPRESS_EMMC_WIPE := true
BOARD_USES_MMCUTILS := true
BOARD_RECOVERY_SWIPE := true
TARGET_RECOVERY_FSTAB := device/lge/luv50ss/ramdisk/recovery/twrp.fstab

# El campo Serial de /proc/cpuinfo da puros ceros en este MT6572 (igual que en el
# e440g/e450g), así que el device_id por defecto de TWRP saldría "0000000000000000".
# Usar el modelo del producto en su lugar (-> "LG-D213").
TW_USE_MODEL_HARDWARE_ID_FOR_DEVICE_ID := true

# TWRP UI: pantalla 480x800 WVGA (hx8379a_wvga_dsi_vdo). En TWRP 3.x
# portrait_mdpi es 480x800 nativo; portrait_hdpi es 1080x1920 y se escalaba 0.44x.
TW_THEME := portrait_mdpi
TARGET_RECOVERY_PIXEL_FORMAT := "RGBA_8888"

# Almacenamiento interno via datamedia (/data/media) — la partición "fat" real
# (mmcblk0p11, vista en /proc/dumchar_info) es de solo ~30MB, inservible como
# storage principal; /data tiene ~1.5GB libres, mismo patrón que vee4ss/vee5ss.
RECOVERY_SDCARD_ON_DATA := true
TW_INTERNAL_STORAGE_PATH := "/data/media"
TW_INTERNAL_STORAGE_MOUNT_POINT := "data"
TW_EXTERNAL_STORAGE_PATH := "/external_sd"
TW_EXTERNAL_STORAGE_MOUNT_POINT := "external_sd"

TARGET_USE_CUSTOM_LUN_FILE_PATH := /sys/devices/virtual/android_usb/android0/f_mass_storage/lun/file
TW_HAS_MTP := true
TW_MTP_DEVICE := /dev/mtp_usb

TW_NO_EXFAT := true
TW_BUILD_AUTHOR := chijure
TW_DEVICE_VERSION := 0.1
TW_INCLUDE_CRYPTO := false
TW_EXCLUDE_SUPERSU := true
TW_NO_REBOOT_BOOTLOADER := true

TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128
TW_NO_CPU_TEMP := true

BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_VOLD_MAX_PARTITIONS := 30

# Charger mode: MTK power-off charging detectado via androidboot.mode=charger
BOARD_GLOBAL_CFLAGS += -DCHARGERMODE_CMDLINE_NAME='"androidboot.mode"' -DCHARGERMODE_CMDLINE_VALUE='"charger"'
