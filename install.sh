#!/bin/sh
# ccswitch installer
set -eu

REPO_URL="https://github.com/rayzhux/ccswitch"
PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

[ "$(uname)" = "Darwin" ] || { echo "ccswitch is macOS-only"; exit 1; }
command -v swiftc >/dev/null 2>&1 || {
  echo "need Xcode Command Line Tools: xcode-select --install"; exit 1; }
command -v jq >/dev/null 2>&1 || {
  echo "need jq: brew install jq"; exit 1; }

if [ -f bin/ccswitch ] && [ -f src/ccswitch-keychain.swift ]; then
  SRC="$PWD"
else
  echo "→ fetching ccswitch…"
  git clone --depth 1 "$REPO_URL" "$TMP/ccswitch"
  SRC="$TMP/ccswitch"
fi

mkdir -p "$BIN"

echo "→ building Keychain helper…"
swiftc -O "$SRC/src/ccswitch-keychain.swift" -o "$BIN/ccswitch-keychain"

echo "→ installing CLI…"
install -m 0755 "$SRC/bin/ccswitch" "$BIN/ccswitch"

echo ""
echo "✓ installed to $BIN"

case ":$PATH:" in
  *":$BIN:"*) ;;
  *)
    echo ""
    echo "⚠ $BIN is not on PATH. Add to ~/.zshrc:"
    echo "    export PATH=\"$BIN:\$PATH\""
    ;;
esac

cat <<EOF

next steps:
  1. run 'claude' and log in as the first account
  2. ccswitch save <name>
  3. repeat for each account, then:   ccswitch use <name> && claude
EOF
