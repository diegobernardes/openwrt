---
name: pre-update
description: Research an OpenWrt version upgrade for this router before any build or flash. Detects the running OpenWrt version, identifies a target release, gathers breaking changes from release notes, and audits this repo's roles, packages, and defaults against the new release. Output is a written report — does not modify any files. Use the `update` skill to actually build and flash.
---

# Pre-Update
`sysupgrade` preserves `/etc/config/*` across the upgrade. After the router reboots on the new version, `task apply` should be a no-op — zero changed tasks. The goal of this audit is to find everything that *would* cause `task apply` to report changes (renamed options, removed packages, configs we set that are now upstream defaults, breaking semantics) and surface it so the user can fix it before running `task firmware`.

Output is a written report. **Do not edit** roles, the package list, or config files at this stage — surface findings so the user decides what to change.

## 1. Detect the current version
The router is reachable on one of two IPs (per CLAUDE.md): `172.31.10.1` (configured) or `192.168.1.1` (factory). Try the configured IP first; fall back to factory.

- `ssh root@172.31.10.1 'ubus call system board'` → read `release.version` and `release.revision`
- `ssh root@192.168.1.1 'ubus call system board'` if the first fails
- Fallback: same hosts with `cat /etc/openwrt_release`
- If neither responds, ask the user

If the router answers on `192.168.1.1`, it's at factory settings — this is a bootstrap, not an upgrade. Stop and surface that to the user before continuing the audit.

## 2. Identify the target version
- List candidates from https://downloads.openwrt.org/releases/ (latest patch in current series, latest stable in next series).
- Default recommendation: latest patch in the current series.
- Confirm the target with the user before continuing.

## 3. Fetch release notes
- https://openwrt.org/releases/<series>/notes-<version> (notes are per minor release; patch versions roll up).
- For multi-version jumps, fetch notes for every intermediate version.
- Also skim https://github.com/openwrt/openwrt/releases/tag/v<version> for items not in the wiki notes.

## 4. Audit this repo against the notes
- **Roles** (`roles/*/`): uci paths, option names, and semantics that changed, were renamed, or removed. Start with the roles whose upstream packages are most active: `dns` (Unbound), `adblock` (adblock-fast), `firewall`, `network`, `sqm`, `vpn` (Tailscale).
- **Packages** (`scripts/firmware-build.sh` → `PACKAGES`): renames, splits, removals, items absorbed into base.
- **Defaults** — for each role's UCI template, compare option-by-option against the target version's stock config. Sources, in order of preference:
  1. Package source at the `v<version>` tag — `openwrt/openwrt` for base packages, `openwrt/packages` or the relevant feed repo for the rest. Look at `package/.../files/etc/config/<name>` and any `uci-defaults` script that mutates it at first boot.
  2. Boot a fresh image of the target version and run `ssh root@192.168.1.1 'uci export <pkg>'` — most reliable for packages whose defaults are computed at first boot (and catches uci-defaults scripts you'd miss in step 1).

  Any option we set whose value equals the new stock value goes in the **Cleanup** bucket of the report, with the exact line to drop (e.g. ``roles/dns/templates/unbound.conf.j2 — `option foo 'bar'` matches new default``).
- **Hardware**: any rockchip/armv8 or NanoPi R6S notes (profile changes, kernel module renames, sysupgrade format changes).

## 5. Report
Group findings into:

- **Breaking** — must fix before `task firmware` or `task apply` will succeed.
- **Cleanup** — now redundant against new defaults; safe to remove.
- **Packages** — adds/removes/renames needed in `scripts/firmware-build.sh`.
- **New** — release features worth considering (one line each, no advocacy).

Hand the report back. The user invokes `update` when ready.
