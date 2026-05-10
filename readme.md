# OpenWrt
Ansible project to configure a device as an OpenWrt router.

This project has no objective on becoming a template to be used by others. There is hardcoded information in most
files. Use as example for your own OpenWrt installations.

The router configured by this repository is a NanoPi R6S. It handles a single 1Gbps symmetrical internet connection,
and a 2.5gbps lan connection.

## Why?
Do I need all this for my network? No.<br>
It's overkill? Yes.<br>
Would I do it again? Yes!<br>

## Prerequisites
- [mise](https://mise.jdx.dev) - At the first run execute `mise install` to bring all dependencies into scope.

## Quick Start
1. Flash the router — see [Firmware](docs/firmware.md) for building and flashing the image.
2. Create a `.vault_pass` file at the root containing the vault password, with permissions `600`.
3. Run `task setup` (once, to install Ansible collections)
4. Run `task apply`

## Documentation
| Document | Description |
|----------|-------------|
| [Firmware](docs/firmware.md) | Building, flashing, and upgrading the firmware |
| [Improvements](docs/improvements.md) | Planned enhancements |
