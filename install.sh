#!/usr/bin/env bash
# ============================================================================
# Technofetch Installer
# Installs technofetch system-wide or locally
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="technofetch"
INSTALL_DIR="/usr/local/bin"
VERSION="2.0.0"

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BOLD='\033[1m'
RESET='\033[0m'

print_banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    cat << 'BANNER'
  ████████╗██████╗  ██████╗ ███████╗██████╗ ██╗  ██╗ █████╗ ████████╗
  ██╔════╝██╔══██╗██╔════╝ ██╔════╝██╔══██╗██║  ██║██╔══██╗╚══██╔══╝
  █████╗  ██████╔╝██║  ███╗█████╗  ██████╔╝███████║███████║   ██║
  ██╔══╝  ██╔══██╗██║   ██║██╔══╝  ██╔══██╗██╔══██║██╔══██║   ██║
  ███████╗██║  ██║╚██████╔╝███████╗██║  ██║██║  ██║██║  ██║   ██║
  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝
BANNER
    echo -e "${RESET}"
    echo -e "  ${CYAN}Version ${VERSION}${RESET} — VM-Focused System Info Display"
    echo ""
}

print_step() {
    echo -e "  ${GREEN}✓${RESET} $1"
}

print_warn() {
    echo -e "  ${YELLOW}⚠${RESET} $1"
}

print_error() {
    echo -e "  ${RED}✗${RESET} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --local       Install to ~/.local/bin instead of /usr/local/bin"
    echo "  --uninstall   Remove Technofetch"
    echo "  --help        Show this help"
    echo ""
}

do_install() {
    local target_dir="$1"

    echo -e "${BOLD}Installing Technofetch to ${target_dir}...${RESET}"
    echo ""

    # Check for script
    if [[ ! -f "${SCRIPT_DIR}/technofetch.sh" ]]; then
        print_error "technofetch.sh not found in ${SCRIPT_DIR}"
        exit 1
    fi

    # Create target directory if needed
    if [[ ! -d "$target_dir" ]]; then
        mkdir -p "$target_dir" 2>/dev/null || {
            print_error "Cannot create ${target_dir}. Try with sudo or use --local"
            exit 1
        }
    fi

    # Copy and set permissions
    cp "${SCRIPT_DIR}/technofetch.sh" "${target_dir}/${SCRIPT_NAME}"
    chmod +x "${target_dir}/${SCRIPT_NAME}"

    print_step "Installed ${SCRIPT_NAME} to ${target_dir}/${SCRIPT_NAME}"

    # Create symlink
    if [[ "$target_dir" != "$SCRIPT_DIR" ]]; then
        ln -sf "${target_dir}/${SCRIPT_NAME}" "${target_dir}/tf" 2>/dev/null || true
        print_step "Created 'tf' shortcut symlink"
    fi

    # Check if in PATH
    if [[ ":$PATH:" != *":${target_dir}:"* ]]; then
        print_warn "${target_dir} is not in your PATH"
        echo ""
        echo -e "  Add to your shell config:"
        echo -e "    ${CYAN}export PATH=\"${target_dir}:\$PATH\"${RESET}"
        echo ""

        # Auto-add to shell config
        local shell_config=""
        if [[ -f "$HOME/.bashrc" ]]; then
            shell_config="$HOME/.bashrc"
        elif [[ -f "$HOME/.zshrc" ]]; then
            shell_config="$HOME/.zshrc"
        fi

        if [[ -n "$shell_config" ]]; then
            if ! grep -q "${target_dir}" "$shell_config" 2>/dev/null; then
                echo "export PATH=\"${target_dir}:\$PATH\"" >> "$shell_config"
                print_step "Added ${target_dir} to PATH in ${shell_config}"
            fi
        fi
    fi

    echo ""
    echo -e "  ${GREEN}${BOLD}Installation complete!${RESET}"
    echo ""
    echo -e "  Run it now:"
    echo -e "    ${CYAN}technofetch${RESET}      # Full display"
    echo -e "    ${CYAN}technofetch --help${RESET}   # All options"
    echo ""
    echo -e "  Quick aliases you can add to your shell config:"
    echo -e "    ${CYAN}alias tf='technofetch'${RESET}"
    echo -e "    ${CYAN}alias tfcompact='technofetch --style compact'${RESET}"
    echo -e "    ${CYAN}alias tfminimal='technofetch --style minimal --no-blocks'${RESET}"
    echo ""
}

do_uninstall() {
    echo -e "${BOLD}Uninstalling Technofetch...${RESET}"
    echo ""

    local found=false

    for dir in /usr/local/bin /usr/bin "$HOME/.local/bin"; do
        if [[ -f "${dir}/${SCRIPT_NAME}" ]]; then
            rm -f "${dir}/${SCRIPT_NAME}"
            rm -f "${dir}/tf"
            print_step "Removed from ${dir}"
            found=true
        fi
    done

    if [[ "$found" == "false" ]]; then
        print_warn "Technofetch not found in any install directory"
    else
        echo ""
        echo -e "  ${GREEN}${BOLD}Technofetch uninstalled.${RESET}"
    fi
    echo ""
}

# ── MAIN ──
print_banner

INSTALL_LOCAL=false
DO_UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --local)     INSTALL_LOCAL=true; shift ;;
        --uninstall) DO_UNINSTALL=true; shift ;;
        --help|-h)   usage; exit 0 ;;
        *)           echo "Unknown option: $1"; usage; exit 1 ;;
    esac
done

if [[ "$DO_UNINSTALL" == "true" ]]; then
    do_uninstall
else
    if [[ "$INSTALL_LOCAL" == "true" ]]; then
        do_install "$HOME/.local/bin"
    else
        do_install "$INSTALL_DIR"
    fi
fi
