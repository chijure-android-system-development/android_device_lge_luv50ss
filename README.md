# TWRP device tree - LG Optimus L50

**Device**: LG-D213
**Codename**: luv50ss
**SoC**: MediaTek MT6572 (ARMv7 Cortex-A7, 1 core visible en `/proc/cpuinfo` en esta unidad)
**RAM**: ~467MB
**Android base**: 4.4.2 (KOT49I)
**Stock product**: `lge/luv50ss_global_com/luv50ss`

**Status (2026-10-17): v4 arranca en hardware real** — TWRP 3.1.1-0.1, firmware
D21310c (V10c), LK parcheado. Pantalla 480x800 32bpp, /data, /cache y
almacenamiento interno montan; adb root funciona. Touch y "reboot system"
confirmados en hardware (con `BOARD_HAS_NO_MISC_PARTITION := true` vuelve a
Android, no entra en loop a recovery); los ajustes se guardan en
`/data/media/0/TWRP/.twrps`. Pendiente: microSD (sin tarjeta al probar).

### Por qué v1–v3 no arrancaban (logo LG → negro → reinicio)

El kernel LG de KitKat trae SELinux. El init de KitKat, si `/sys/fs/selinux`
existe y no hay `/sepolicy` en el ramdisk, hace
`android_reboot(ANDROID_RB_RESTART2, 0, "recovery")`
(`system/core/init/init.c`, `selinux_initialize`). El target `recoveryimage`
no construye la sepolicy, así que el ramdisk salía sin ella. vee4ss/vee5ss no
lo sufren porque el kernel JB del E440g/E450g no tiene SELinux.

Aislado con imágenes híbridas: kernel V10c + ramdisk del TWRP 2.8.1.0 de
alekcacko arranca; kernel de ese TWRP + nuestro ramdisk no arranca. El fix
está en `device.mk` (sepolicy y `*_contexts` en `PRODUCT_PACKAGES`) más
`setenforce 0` en `init.recovery.mt6572.rc`.

El kernel del árbol es ahora el del `boot.img` de D21310c (V10c, sin header MTK),
el firmware que corre esta unidad tras reflashear el KDZ.

Based on the already hardware-verified [`device/lge/vee4ss`](../vee4ss/) tree
(LG-E440g). Same MTK boot image format (kernel/ramdisk MTK headers, same
kernel load offsets), same overall device tree shape — differs in SoC
generation (MT6572 vs MT6575), screen density, partition sizes/numbers, and
lacks the RGB/button-backlight LED quirks that vee4ss/vee5ss needed
`postrecoveryboot.sh` for (this device only has `lcd-backlight`).

## Bootloader

Unlocked and verified on this unit with
[lg-e450g-lk-patch/d213](https://github.com/chijure-android-system-development/lg-e450g-lk-patch/tree/main/d213):
an LK patch shared on 4pda.ru for firmware `LGD213AT V10f` (2 four-byte
patches bypassing signature verification) was byte-for-byte matched against
this device's own `uboot_raw.bin` dump, flashed to `/dev/uboot`, and
confirmed on real hardware — stock ROM still boots normally, and an existing
TWRP 2.8.1.0 (ported from the LG L60) boots without "Security Error" when
flashed to `/dev/recovery`. That donor TWRP is known to have internal storage
problems (per the 4pda author's notes) — this device tree is meant to
replace it with a proper, hardware-verified build.

## Partitions

Taken from `/proc/dumchar_info` and `/proc/partitions` on the real device
(2026-07-24).

| Partition | Device | Size |
|-----------|--------|------|
| bootimg | `/dev/bootimg` | 10 MiB |
| recovery | `/dev/recovery` | 10 MiB |
| system (`android`) | `/dev/block/mmcblk0p8` | ~1.46 GiB |
| cache | `/dev/block/mmcblk0p9` | ~342 MiB |
| usrdata | `/dev/block/mmcblk0p10` | ~1.56 GiB |
| fat | `/dev/block/mmcblk0p11` | ~30 MiB (unused by TWRP — too small, see below) |
| external SD | `/dev/block/mmcblk1p1` | variable, no card inserted when dumping specs |

Total eMMC is only ~3.9GB (`/proc/partitions`, `mmcblk0` = 3,809,792 blocks)
— a genuinely small-storage budget device. `misc`/`misc2` also exist as MTK
virtual partitions but are not referenced in the fstab (see Known issues).

## Notes

- The prebuilt kernel (`kernel`, no MTK header) was extracted from
  `backups-originales/boot_raw.img` using `abootimg -x`, then stripped of its
  512-byte MTK header (`tail -c +513`) — `mtkbootimg --mtk 1` adds it back at
  build time. **This is the original LG boot kernel, not the kernel bundled
  inside the donor `TWRP_2.8.1.0_LG_L50.img`** (confirmed by `cmp` that the
  two differ) — following the standing lesson from e450g/c660h/vee4ss: always
  use the manufacturer's own kernel, not one bundled in a ported/donor
  recovery, to keep the correct charging/hardware drivers.
- Boot image layout (confirmed with `abootimg -i` on `boot_raw.img`):
  `base=0x10000000`, `pagesize=2048`, `kernel_offset=0x00008000` (AOSP
  default, so not set explicitly), `ramdisk_offset=0x01000000`,
  `tags_offset=0x00000100` — identical to e450g/vee4ss despite the different
  SoC generation.
- Screen: **480x800 WVGA** (`lcm=1-hx8379a_wvga_dsi_vdo` in `/proc/cmdline`,
  `ro.sf.lcd_density=240`), 32bpp framebuffer (`fb0/bits_per_pixel=32`).
  `TW_THEME := portrait_hdpi`.
- Touch: generic MediaTek `mtk-tpd` driver (no separate vendor touch driver
  to reference, unlike vee4ss's `ist30xx`).
- USB gadget PID: `idVendor 1004` / `idProduct 631F`, confirmed live on the
  device — coincidentally the same PID as vee4ss's E440g, but don't assume
  this holds for other models; it was re-read from this device directly.
- Internal storage is handled as `/data/media` with
  `RECOVERY_SDCARD_ON_DATA := true`, same as vee4ss/vee5ss — the real `fat`
  partition (mmcblk0p11) is only ~30MB, useless as primary storage.
- `TW_NO_REBOOT_BOOTLOADER := true` — MTK device, no real fastboot/bootloader
  reboot target.
- No RGB/button-backlight LED cleanup needed in a `postrecoveryboot.sh` — this
  device only exposes `/sys/class/leds/lcd-backlight` (checked live), unlike
  vee4ss/vee5ss which needed one for their LP5521 RGB LED.

## Known issues / unverified

- **`BOARD_HAS_NO_MISC_PARTITION := true`** is set by analogy with
  vee4ss/vee5ss (same LG/MTK family), but **not yet confirmed on this
  specific MT6572 LK** — needs a real "reboot system" test after first boot
  to check whether it loops back into recovery (see
  `twrp-vee4ss-build` / `twrp-c660h-build` memories for why this matters and
  differs by SoC/bootloader).
- `TW_EXCLUDE_DEFAULT_USB_INIT` should **not** be set without testing — on
  vee4ss, setting it broke ADB entirely. Left unset here by default; if ADB
  has issues, check the generic `bootable/recovery/etc/init.recovery.usb.rc`
  interaction before touching this flag.
- No microSD was inserted while gathering specs, so `/dev/block/mmcblk1p1`
  for `/external_sd` is the conventional guess from sibling devices, not
  device-confirmed.
- adbd se anuncia como `device` (no `recovery`) en `adb devices`; usar
  `getprop ro.twrp.boot` para distinguirlo de Android.

## Build

```bash
# inside the Docker container (~/android-build-docker/twrp-4.4-docker,
# LOCAL_UID=$(id -u) LOCAL_GID=$(id -g) docker compose up -d)
source build/envsetup.sh
lunch omni_luv50ss-eng
# La sepolicy tiene que estar en out/.../root ANTES de armar el ramdisk:
mka sepolicy file_contexts seapp_contexts property_contexts
mka recoveryimage
```

## Flashing (no fastboot — MTK, root already obtained)

```bash
adb push recovery-luv50ss.img /sdcard/recovery_twrp.img
adb shell "su -c 'dd if=/dev/recovery of=/sdcard/recovery_backup_before_our_twrp.img bs=4096; sync'"
adb shell "su -c 'dd if=/sdcard/recovery_twrp.img of=/dev/recovery bs=4096; sync'"
adb reboot recovery
```
