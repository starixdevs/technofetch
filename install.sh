#!/usr/bin/env bash
# ============================================================================
# Technofetch — Simple Installer
# ============================================================================
set -u

SRC="$(dirname "$(readlink -f "$0")")/technofetch.sh"
DEST="/usr/local/bin/technofetch"

# Check script exists
if [[ ! -f "$SRC" ]]; then
    echo "Error: technofetch.sh not found in $SRC"
    exit 1
fi

# Install
cp "$SRC" "$DEST"
chmod +x "$DEST"

echo ""
echo "  ✓ Technofetch installed to $DEST"
echo ""
echo "  Run it:  technofetch"
echo "  Options: technofetch --help"
echo ""
