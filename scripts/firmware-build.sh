#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:?required}"
TARGET="rockchip/armv8"
PROFILE="friendlyarm_nanopi-r6s"
ASU_API="https://sysupgrade.openwrt.org/api/v1/build"
OUTPUT_DIR="$(cd "$(dirname "$0")/.." && pwd)/firmware"
PACKAGES=(
    # bootstrap
    "python3"

    # storage
    "parted" "losetup" "resize2fs"

    # dns
    "unbound-daemon" "unbound-control" "unbound-anchor" "luci-app-unbound"

    # adblock
    "adblock-fast" "luci-app-adblock-fast" "gawk" "grep" "sed" "coreutils-sort"

    # watchdog
    "watchcat" "luci-app-watchcat"

    # ntp
    "chrony" "luci-app-chrony"

    # mdns
    "avahi-dbus-daemon" "avahi-utils"

    # vpn
    "tailscale"

    # webui
    "uhttpd" "uhttpd-mod-ubus"

    # sqm
    "sqm-scripts" "luci-app-sqm"

    # system
    "kmod-tcp-bbr" "luci-app-statistics" "luci-app-nlbwmon" "btop"
)
mkdir -p "$OUTPUT_DIR"

PAYLOAD=$(jq -n \
  --arg target "$TARGET" \
  --arg profile "$PROFILE" \
  --arg version "$VERSION" \
  --argjson packages "$(printf '%s\n' "${PACKAGES[@]}" | jq -R . | jq -s .)" \
  '{target: $target, profile: $profile, version: $version, packages: $packages}')

echo "Requesting build for OpenWrt $VERSION ($TARGET / $PROFILE)..."

HTTP_CODE=$(curl -s -X POST "$ASU_API" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  -o /tmp/asu_response.json \
  -w "%{http_code}")

if [ "$HTTP_CODE" = "200" ]; then
  echo "Image already cached!"
elif [ "$HTTP_CODE" = "202" ]; then
  HASH=$(jq -r '.request_hash' /tmp/asu_response.json)
  echo "Build queued (hash: $HASH), waiting..."
  while true; do
    sleep 15
    HTTP_CODE=$(curl -s "$ASU_API/$HASH" \
      -o /tmp/asu_response.json \
      -w "%{http_code}")
    STATUS=$(jq -r '.status' /tmp/asu_response.json)
    echo "  Status: $STATUS"
    [ "$HTTP_CODE" = "200" ] && break
    if [ "$HTTP_CODE" != "202" ]; then
      echo "Build failed: $(jq -r '.detail // .' /tmp/asu_response.json)"
      exit 1
    fi
  done
else
  echo "Request failed (HTTP $HTTP_CODE): $(cat /tmp/asu_response.json)"
  exit 1
fi

HASH=$(jq -r '.request_hash' /tmp/asu_response.json)
URL_PREFIX="https://sysupgrade.openwrt.org/store/$HASH"

while IFS=$'\t' read -r FILENAME SHA256; do
  echo "Downloading $FILENAME..."
  curl -L --progress-bar -o "$OUTPUT_DIR/$FILENAME" "$URL_PREFIX/$FILENAME"
  echo "$SHA256  $OUTPUT_DIR/$FILENAME" | sha256sum --check --quiet
  echo "Saved to firmware/$FILENAME"
done < <(jq -r '.images[] | select(.filesystem == "ext4") | [.name, .sha256] | @tsv' /tmp/asu_response.json)
