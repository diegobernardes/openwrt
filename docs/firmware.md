# Firmware

The image is built locally by the OpenWrt ImageBuilder wrapped in a pinned Nix
derivation — no remote build service. The OpenWrt **release** and the baked-in
**package list** live in `flake.nix` (`openwrtRelease` / `openwrtPackages`); the
imagebuilder itself is pinned in `flake.lock`. Binaries are fetched from
downloads.openwrt.org and verified against pinned hashes.

## Build

```fish
task firmware
```

This runs `nix build .#packages.x86_64-linux.firmware` and copies the ext4
sysupgrade image into `firmware/`. To change the OpenWrt version, edit
`openwrtRelease` in `flake.nix` (must be a release the imagebuilder input
carries — bump the `openwrt-imagebuilder` input if you need a newer one).

Note: the build only runs on `x86_64-linux` — the ImageBuilder ships prebuilt
Linux-x86_64 host binaries.

## Bootstrap

Flash the image to a MicroSD card (the image is gzipped, pipe through `zcat`):

```fish
zcat firmware/openwrt-*-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img.gz \
  | sudo dd of=/dev/mmcblk0 bs=4M status=progress conv=fsync
```

Insert the MicroSD card, boot the router, then run `task apply`.

## Upgrade

Copy the image to the router and run sysupgrade:

```fish
set -x IMG (basename firmware/openwrt-*-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img.gz)
scp firmware/$IMG root@router:/tmp/
ssh root@router "sysupgrade /tmp/$IMG"
```

The router reboots and restores its configuration automatically. Run `task apply`
afterwards to verify no drift.
