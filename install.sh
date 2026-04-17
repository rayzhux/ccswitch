#!/bin/sh
# ccswitch installer
set -eu

REPO_URL="https://github.com/rayzhux/ccswitch"
PREFIX="${PREFIX:-$HOME/.local}"
BIN="$PREFIX/bin"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

[ "$(uname)" = "Darwin" ] || { echo "ccswitch is macOS-only"; exit 1; }
command -v jq >/dev/null 2>&1 || {
  echo "need jq: brew install jq"; exit 1; }

if [ -f bin/ccswitch ]; then
  SRC="$PWD"
else
  TAG=$(git ls-remote --tags --refs --sort=-v:refname "$REPO_URL" 2>/dev/null \
    | awk -F/ 'NR==1{print $NF}')
  [ -n "$TAG" ] || { echo "could not resolve latest tag"; exit 1; }
  echo "→ fetching ccswitch $TAG…"
  git clone --depth 1 --branch "$TAG" "$REPO_URL" "$TMP/ccswitch"
  SRC="$TMP/ccswitch"
fi

mkdir -p "$BIN"
install -m 0755 "$SRC/bin/ccswitch" "$BIN/ccswitch"

# Clean up legacy Swift helper from pre-0.2 installs.
rm -f "$BIN/ccswitch-keychain"

echo ""
echo "✓ installed to $BIN/ccswitch"

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
