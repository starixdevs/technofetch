#!/usr/bin/env bash
# ============================================================================
# Technofetch Uninstaller
# ============================================================================
set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}Technofetch Uninstaller${RESET}"
echo ""

removed=0

for dir in /usr/local/bin /usr/bin "$HOME/.local/bin"; do
    for bin in technofetch tf; do
        if [[ -f "${dir}/${bin}" ]]; then
            rm -f "${dir}/${bin}"
            echo -e "  ${GREEN}✓${RESET} Removed ${dir}/${bin}"
            ((removed++))
        fi
    done
done

if [[ $removed -eq 0 ]]; then
    echo -e "  ${YELLOW}⚠${RESET} Technofetch not found in any install directory"
else
    echo ""
    echo -e "  ${GREEN}${BOLD}Technofetch removed successfully.${RESET}"
fi

echo ""
