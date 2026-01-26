# Bootstrap
Download the [Ext4 image](https://firmware-selector.openwrt.org/?version=25.12.0&target=rockchip%2Farmv8&id=friendlyarm_nanopi-r6s).

Put it at the MicroSD: 
```bash
sudo dd if=openwrt-25.12.0-rockchip-armv8-friendlyarm_nanopi-r6s-ext4-sysupgrade.img of=/dev/mmcblk0 bs=4M status=progress conv=fsync
```
