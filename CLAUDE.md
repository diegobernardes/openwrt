# Project
Personal Ansible project configuring a **NanoPi R6S** as an OpenWrt router. Single 1Gbps symmetrical WAN, 2.5Gbps LAN. Hardcoded for this specific deployment — not a template, do not generalize.

## Hardware
NanoPi R6S — `rockchip/armv8`, OpenWrt profile `friendlyarm_nanopi-r6s`.

## Entrypoints
All commands go through `task` (see `taskfile.yml`); the dev toolchain is pinned by Nix (`flake.nix` + `flake.lock`) and loaded via direnv (`.envrc` → `use flake`) or `nix develop`. Ansible collections are **not** in Nix — they're installed by `task setup` via `ansible-galaxy` (`requirements.yml`).

- `task apply` — full playbook; `detect` auto-picks `router` (172.31.10.1) vs `router_factory` (192.168.1.1).
- `ROLE=<name> task apply` — apply a single role.
- `TARGET=router|router_factory task apply` — skip auto-detection.
- `task lint` — yamllint + ansible-lint.
- `VERSION=<x.y.z> task firmware` — build a custom image via OpenWrt ASU.
- `task vault` — edit `group_vars/all/vault.yml`.

## Layout
- `playbooks/apply.yml` — phased orchestration (detect → bootstrap/storage → core network → system roles).
- `roles/<name>/` — one role per concern. `detect` runs on localhost; the rest run on the `target_router` group populated by `detect`.
- `group_vars/all/vars.yml` — single source of truth for VLANs, DHCP reservations, firewall rules, VPN, SQM, etc. **Most "config changes" mean editing this file, not a role.**
- `group_vars/all/vault.yml` — encrypted secrets, referenced as `vault_*` from vars.
- `firmware/` — pre-built OpenWrt sysupgrade images (`.img.gz`).
- `scripts/firmware-build.sh` — ASU build with the package list baked in.

## Adding a package
Packages are baked into the firmware image, **not installed at runtime**. To add one:
1. Add it to the `PACKAGES` array in `scripts/firmware-build.sh` under the matching role comment.
2. `VERSION=<x.y.z> task firmware` to rebuild, then flash or `sysupgrade`.

Do not introduce `package:` / `opkg` tasks in roles.

## Conventions
- Use FQCN (`ansible.builtin.*`, `community.general.*`).
- Config-file roles follow `template` → `notify: restart <svc>` → `service: enabled+started`.
- `changed_when: false` on service-start and similar idempotent-but-noisy tasks — match the existing style.
- Any task touching secrets sets `no_log: true`.
- `.ansible-lint` deliberately skips `command-instead-of-module`, `command-instead-of-shell`, `risky-shell-pipe`, `no-changed-when`, `partial-become` — don't try to "fix" violations of these.
- The router runs OpenWrt; configuration is UCI files under `/etc/config/*` plus service-specific files. Prefer rendering UCI via templates over `uci set` shell calls.

## Shell
User shell is **fish**. Documented snippets use fish syntax (e.g. `set -x VERSION 25.12.3`).
