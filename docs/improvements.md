# Improvements

## SSH Key Authentication

Use a SSH key to authenticate and disable the SSH password access.

## External Logs and Metrics

Prometheus + Loki + Grafana with `prometheus-node-exporter-lua` on the router and syslog forwarding to the server VLAN.

## Disable Auto-Upgrades

```bash
uci set attendedsysupgrade.client.login_check_for_upgrades='0'
```

Prevents OpenWrt from automatically checking for and applying upgrades.

## Reproducible Firmware Build

The dev toolchain is now pinned by Nix (`flake.nix`), but the firmware image is
still produced by OpenWrt's **ASU remote build service** (`scripts/firmware-build.sh`),
which depends on OpenWrt's build queue and the package-feed state at request time —
the least reproducible part of the repo.

Goal: build the image locally and deterministically by wrapping the OpenWrt
**ImageBuilder** in a Nix derivation instead of calling ASU:

- Fetch the ImageBuilder tarball for `rockchip/armv8` with a pinned `sha256`.
- Feed it the `PACKAGES` list currently baked into `scripts/firmware-build.sh`.
- Emit the `friendlyarm_nanopi-r6s` ext4 `.img.gz` as a build output.
- Expose it as a flake output / `task firmware` target; drop the `curl`-to-ASU flow.

This is a self-contained follow-up to the Nix migration; larger than the toolchain
change, so tracked separately here.
