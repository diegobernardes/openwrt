# Firmware
Set the version once and reuse it across all commands:
```fish
set -x VERSION 25.12.3
```

## Build
Build a custom image with all required packages pre-installed:
```fish
task firmware
```

The image is saved to `firmware/`.

## Bootstrap
Flash the image to a MicroSD card (the image is gzipped, pipe through `zcat`):
```fish
zcat firmware/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img.gz \
  | sudo dd of=/dev/mmcblk0 bs=4M status=progress conv=fsync
```

Insert the MicroSD card, boot the router, then run `task apply`.

## Upgrade
Copy the image to the router and run sysupgrade:
```fish
scp firmware/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img.gz \
  root@router:/tmp/
ssh root@router "sysupgrade /tmp/openwrt-$VERSION-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img.gz"
```

The router reboots and restores its configuration automatically. Run `task apply` afterwards to verify no drift.
