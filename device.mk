PRODUCT_DEVICE := luv50ss
PRODUCT_NAME := omni_luv50ss
PRODUCT_BRAND := lge
PRODUCT_MODEL := LG-D213
PRODUCT_MANUFACTURER := LGE

PRODUCT_COPY_FILES += \
    device/lge/luv50ss/ramdisk/init.recovery.mt6572.rc:root/init.recovery.mt6572.rc

PRODUCT_PACKAGES += \
    adbd

# El kernel LG V10c trae SELinux (/sys/fs/selinux existe), así que el init de
# KitKat exige /sepolicy en el ramdisk: si no puede cargarla hace
# android_reboot(..., "recovery") y el equipo queda en logo → negro → reinicio.
# El ramdisk de recovery es una copia de out/.../root, así que estos módulos
# tienen que existir ahí antes de armar recoveryimage.
# vee4ss/vee5ss no los necesitan porque el kernel JB del E440g/E450g no trae SELinux.
PRODUCT_PACKAGES += \
    sepolicy \
    file_contexts \
    seapp_contexts \
    property_contexts

# Recovery ADB defaults. ro.secure=0 y ro.debuggable=1 ya vienen del
# build omni_luv50ss-eng; esto son los defaults de USB/ADB específicos del device.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    persist.service.adb.enable=1 \
    service.adb.root=1
