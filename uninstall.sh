#!/bin/sh
set -eu
BIN="${PREFIX:-$HOME/.local}/bin"
rm -f "$BIN/ccswitch" "$BIN/ccswitch-keychain"
echo "removed: $BIN/ccswitch, $BIN/ccswitch-keychain"
echo ""
echo "profile snapshots at ~/.ccswitch/ were left intact."
echo "to wipe everything:"
echo "  rm -rf ~/.ccswitch"
echo "  # then delete per-profile keychain items manually via Keychain Access"
echo "  # (search for 'ccswitch:' entries)"
