# Improvements
## SSH Key Authentication
Use a SSH key to authenticate and disable the SSH password access.

## Public Domain
Setup a public domain to get a recognized HTTPS certificate from Let's Encrypt using the DNS-01 challenge.

## External Logs and Metrics
Prometheus + Loki + Grafana with `prometheus-node-exporter-lua` on the router and syslog forwarding to the server VLAN.

## Disable Auto-Upgrades
```bash
uci set attendedsysupgrade.client.login_check_for_upgrades='0'
```
Prevents OpenWrt from automatically checking for and applying upgrades.
