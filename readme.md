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
1. Define a `.vault_pass` at the root of the project with the vault password:
   ```bash
   echo "your-secure-password" > .vault_pass
   chmod 600 .vault_pass
   ```
2. Run `task apply`

   | Parameter | Description |
   |-----------|-------------|
   | `TARGET=router\|router_factory` | Target device. Inferred if not set |
   | `ROLE=<role>` | Single role to execute. All roles if omitted |

   Extra ansible args can be passed after `--`.

## Documentation
| Document | Description |
|----------|-------------|
| [Bootstrap](docs/bootstrap.md) | Initial device setup and provisioning |
| [Improvements](docs/improvements.md) | Planned enhancements |
