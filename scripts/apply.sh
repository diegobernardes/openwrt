#!/usr/bin/env bash
set -euo pipefail

TARGET="${TARGET:-auto}"
ROLE="${ROLE:-}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

case "$TARGET" in
  auto|router|router_factory) ;;
  *) echo "Error: TARGET must be one of: auto, router, router_factory" >&2; exit 1 ;;
esac

TMPFILE=""
cleanup() {
  if [[ -n "$TMPFILE" ]]; then
    rm -f "$TMPFILE"
  fi
}
trap cleanup EXIT

if [[ -n "$ROLE" ]]; then
  TMPFILE=$(mktemp "$ROOT_DIR/playbooks/role-XXXXXX.yml")
  cat > "$TMPFILE" <<EOF
---
- name: Detect router
  hosts: localhost
  roles: [detect]
- name: $ROLE
  hosts: target_router
  roles: [$ROLE]
EOF
  PLAYBOOK="$TMPFILE"
else
  PLAYBOOK="$ROOT_DIR/playbooks/apply.yml"
fi

EXTRA_ARGS=()
if [[ "$TARGET" != "auto" ]]; then
  EXTRA_ARGS+=(-e "target=$TARGET")
fi

ansible-playbook "$PLAYBOOK" "${EXTRA_ARGS[@]}" "$@"
