{
  description = "NanoPi R6S OpenWrt router — dev toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.jq
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
    };
}
