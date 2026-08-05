{
  description = "NanoPi R6S OpenWrt router — dev toolchain + firmware image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Builds the OpenWrt image locally & deterministically via the official
    # ImageBuilder, replacing the ASU remote build service. Binaries still come
    # from downloads.openwrt.org (hash-pinned); this flake only provides the
    # build glue. Pinned via flake.lock — audit/bump deliberately.
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, openwrt-imagebuilder }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # OpenWrt release to build. Must be present in the imagebuilder cache
      # (currently: 25.12.5, 24.10.8). Bump alongside `openwrt-imagebuilder`.
      openwrtRelease = "25.12.5";

      # Extra packages baked into the image, on top of the profile's defaults
      # (which the builder includes automatically). Was the PACKAGES array in
      # scripts/firmware-build.sh — keep grouped by the role that needs each.
      openwrtPackages = [
        "python3" # bootstrap
        "parted"
        "losetup"
        "resize2fs" # storage
        "unbound-daemon"
        "unbound-control"
        "unbound-anchor"
        "luci-app-unbound" # dns
        "adblock-fast"
        "luci-app-adblock-fast"
        "gawk"
        "grep"
        "sed"
        "coreutils-sort" # adblock
        "watchcat"
        "luci-app-watchcat" # watchdog
        "chrony"
        "luci-app-chrony" # ntp
        "avahi-dbus-daemon"
        "avahi-utils" # mdns
        "tailscale" # vpn
        "uhttpd"
        "uhttpd-mod-ubus" # webui
        "sqm-scripts"
        "luci-app-sqm" # sqm
        "kmod-tcp-bbr"
        "luci-app-statistics"
        "luci-app-nlbwmon"
        "btop" # system
      ];
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.go-task
            pkgs.ansible-lint
            (pkgs.python3.withPackages (ps: [
              ps.ansible-core # ansible / ansible-playbook / ansible-galaxy
              ps.netaddr # required by ansible.utils ipaddr filters
              ps.yamllint
            ]))
          ];
        };
      });

      # The custom sysupgrade image. x86_64-linux only — the ImageBuilder ships
      # prebuilt Linux-x86_64 host binaries. `$out` holds every image variant;
      # flash the `*-ext4-sysupgrade.img.gz` one. Build with `task firmware`.
      packages.x86_64-linux.firmware = openwrt-imagebuilder.lib.build {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        release = openwrtRelease;
        target = "rockchip";
        variant = "armv8";
        profile = "friendlyarm_nanopi-r6s";
        packages = openwrtPackages;
      };
    };
}
