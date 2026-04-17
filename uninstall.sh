#!/bin/sh
set -eu
BIN="${PREFIX:-$HOME/.local}/bin"
SNAP_DIR="$HOME/.ccswitch"

if [ "${1:-}" = "--purge" ]; then
  if [ -d "$SNAP_DIR" ]; then
    for f in "$SNAP_DIR"/*.json; do
      [ -e "$f" ] || continue
      name=$(basename "$f" .json)
      security delete-generic-password -s "ccswitch:$name" -a "$USER" \
        >/dev/null 2>&1 || true
      echo "purged keychain: ccswitch:$name"
    done
    rm -rf "$SNAP_DIR"
    echo "removed: $SNAP_DIR"
  fi
fi

rm -f "$BIN/ccswitch" "$BIN/ccswitch-keychain"
echo "removed: $BIN/ccswitch, $BIN/ccswitch-keychain"

if [ "${1:-}" != "--purge" ] && [ -d "$SNAP_DIR" ]; then
  echo ""
  echo "profile snapshots at $SNAP_DIR were left intact."
  echo "to wipe everything, re-run:  ./uninstall.sh --purge"
fi
