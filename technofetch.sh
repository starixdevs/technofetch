#!/usr/bin/env bash
# ============================================================================
# Technofetch v2.0 — VM-Focused System Info Display
# A powerful neofetch alternative for Ubuntu/Debian VM environments
# Detects hypervisors, containers, cloud metadata, and deep system info
# ============================================================================
set -u

# ─── VERSION ────────────────────────────────────────────────────────────────
VERSION="2.0.0"

# ─── COLOR PALETTE ──────────────────────────────────────────────────────────
# Clean 2-color theme: Blue + White
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_UNDERLINE=$'\033[4m'
C_ITALIC=$'\033[3m'

# ── Blue (labels, accents, ASCII art) ──
C_BLUE=$'\033[38;5;39m'

# ── White (values, text) ──
C_WHITE=$'\033[38;5;231m'

# Aliases for compatibility
C_RED=$C_WHITE
C_GREEN=$C_WHITE
C_YELLOW=$C_WHITE
C_MAGENTA=$C_BLUE
C_CYAN=$C_BLUE
C_GRAY=$C_DIM
C_ORANGE=$C_WHITE
C_PINK=$C_BLUE
C_LIME=$C_WHITE
C_LAVENDER=$C_BLUE
C_GOLD=$C_WHITE
C_TEAL=$C_BLUE
C_CORAL=$C_WHITE
C_SKY=$C_BLUE

# Section colors (all blue or white)
C_SEC_KERNEL=$C_BLUE
C_SEC_CPU=$C_BLUE
C_SEC_MEM=$C_BLUE
C_SEC_DISK=$C_BLUE
C_SEC_NET=$C_BLUE
C_SEC_GPU=$C_BLUE
C_SEC_PKG=$C_BLUE
C_SEC_SEC=$C_BLUE
C_SEC_CLOUD=$C_BLUE

# Semantic colors
C_LABEL=$C_BLUE
C_VALUE=$C_WHITE
C_HIGHLIGHT=$C_WHITE
C_GOOD=$C_WHITE
C_WARN=$C_WHITE
C_BAD=$C_WHITE

# Accent colors for labels
LABEL_COLOR="${C_BLUE}"
INFO_COLOR="${C_WHITE}"
SEPARATOR_COLOR="${C_DIM}"
VM_COLOR="${C_BLUE}"
DISTRO_COLOR="${C_WHITE}"

# ─── CONFIGURATION ──────────────────────────────────────────────────────────
SHOW_ASCII=true
ASCII_STYLE="default"   # default, compact, box, minimal
SHOW_COLORS=true
SHOW_BLOCKS=true
COLOR_BLOCK="■ "
ASCII_ART=""

# ─── ASCII ART VARIANTS ────────────────────────────────────────────────────
# Shows distro-specific logos (Ubuntu, Debian, etc.) with TECHNO fallback
read_ascii_art() {
    local style="${1:-default}"
    local distro_id="${2:-unknown}"
    local distro_version="${3:-}"

    # ── Ubuntu Logo (circle of friends) ──
    if [[ "$distro_id" == "ubuntu" ]]; then
        case "$style" in
            compact)
                cat << 'ART'
    ╭───────────╮
    │    _  _   │
    │   | \/ |  │
    │   |_/|/|  │
    │   / __ |  │
    │  /_/ \|   │
    │          │
    │  UBUNTU  │
    ╰───────────╯
ART
                ;;
            box)
                cat << 'ART'
 ╔═══════════════════════╗
 ║    _  _               ║
 ║   | \/ |              ║
 ║   |_/|/|              ║
 ║   / __ |              ║
 ║  /_/ \|               ║
 ║                       ║
 ║     UBUNTU            ║
 ╚═══════════════════════╝
ART
                ;;
            minimal)
                cat << 'ART'
  ┌─ UBUNTU ─────────┐
  │    _  _           │
  │   | \/ |          │
  │   |_/|/|          │
  │   / __ |          │
  │  /_/ \|           │
  └───────────────────┘
ART
                ;;
            *)
                cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │         _  _              │
                 │        | \/ |             │
                 │        |_/|/|             │
                 │        / __ |             │
                 │       /_/ \|              │
                 │                           │
                 │         UBUNTU            │
                 │        ── v2.0 ──         │
                 │                           │
                 ╰───────────────────────────╯
ART
                ;;
        esac
        return
    fi

    # ── Debian Logo (swirl) ──
    if [[ "$distro_id" == "debian" ]] || [[ "$distro_id" == "ubuntu" && "$distro_id" != "debian" ]] || [[ "$distro_id" == "kali" ]] || [[ "$distro_id" == "parrot" ]]; then
        if [[ "$distro_id" == "debian" ]]; then
            case "$style" in
                compact)
                    cat << 'ART'
    ╭───────────╮
    │    .--.   │
    │   /    \  │
    │  | .--. | │
    │  | |  | | │
    │  | \__/ | │
    │   \    /  │
    │    '--'   │
    │  DEBIAN   │
    ╰───────────╯
ART
                    ;;
                box)
                    cat << 'ART'
 ╔═══════════════════════╗
 ║    .--.               ║
 ║   /    \              ║
 ║  | .--. |             ║
 ║  | |  | |             ║
 ║  | \__/ |             ║
 ║   \    /              ║
 ║    '--'               ║
 ║      DEBIAN           ║
 ╚═══════════════════════╝
ART
                    ;;
                minimal)
                    cat << 'ART'
  ┌─ DEBIAN ─────────┐
  │    .--.           │
  │   /    \          │
  │  | .--. |         │
  │  | |  | |         │
  │  | \__/ |         │
  │   \    /          │
  │    '--'           │
  └───────────────────┘
ART
                    ;;
                *)
                    cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │         .--.              │
                 │        /    \             │
                 │       | .--. |            │
                 │       | |  | |            │
                 │       | \__/ |            │
                 │        \    /             │
                 │         '--'              │
                 │                           │
                 │         DEBIAN            │
                 │        ── v2.0 ──         │
                 │                           │
                 ╰───────────────────────────╯
ART
                    ;;
            esac
            return
        fi
    fi

    # ── Kali Linux Logo ──
    if [[ "$distro_id" == "kali" ]]; then
        case "$style" in
            compact)
                cat << 'ART'
    ╭───────────╮
    │    /\ /\  │
    │   / / \ \ │
    │  / /   \ \│
    │ / / /\ \ \│
    │/_/ /  \ \_│
    │   /    \ │
    │  / KALI \│
    ╰───────────╯
ART
                ;;
            *)
                cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │         /\ /\             │
                 │        / / \ \            │
                 │       / /   \ \           │
                 │      / / /\ \ \           │
                 │     /_/ /  \ \_           │
                 │        /    \             │
                 │       / KALI  \           │
                 │                           │
                 ╰───────────────────────────╯
ART
                ;;
        esac
        return
    fi

    # ── Linux Mint Logo ──
    if [[ "$distro_id" == "linuxmint" ]] || [[ "$distro_id" == "lmde" ]]; then
        case "$style" in
            compact)
                cat << 'ART'
    ╭───────────╮
    │     __    │
    │    /  |   │
    │   | __ |  │
    │    \__/   │
    │           │
    │    MINT   │
    ╰───────────╯
ART
                ;;
            *)
                cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │            __             │
                 │           /  |            │
                 │          | __ |           │
                 │           \__/            │
                 │                           │
                 │          MINT             │
                 │         ── v2.0 ──        │
                 │                           │
                 ╰───────────────────────────╯
ART
                ;;
        esac
        return
    fi

    # ── Pop!_OS Logo ──
    if [[ "$distro_id" == "pop" ]]; then
        case "$style" in
            compact)
                cat << 'ART'
    ╭───────────╮
    │   _____   │
    │  / ____|  │
    │ | (___    │
    │  \___ \   │
    │  ____) |  │
    │ |_____/   │
    │   POP_OS  │
    ╰───────────╯
ART
                ;;
            *)
                cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │        _____              │
                 │       / ____|             │
                 │      | (___               │
                 │       \___ \              │
                 │       ____) |             │
                 │      |_____/              │
                 │                           │
                 │        POP!_OS            │
                 │       ── v2.0 ──          │
                 │                           │
                 ╰───────────────────────────╯
ART
                ;;
        esac
        return
    fi

    # ── Default: TECHNO Logo (fallback for any unrecognized distro) ──
    case "$style" in
        compact)
            cat << 'ART'
    ┌──────────────┐
    │  TECH        │
    │  ████████    │
    │  █      █    │
    │  ████████    │
    │       █      │
    │  ████████    │
    │  TECHNO v2   │
    └──────────────┘
ART
            ;;
        box)
            cat << 'ART'
 ╔═══════════════════════════╗
 ║  ████████╗██████╗  ██████╗║
 ║  ██╔════╝██╔══██╗██╔════╝║
 ║  █████╗  ██████╔╝██║      ║
 ║  ██╔══╝  ██╔══██╗██║      ║
 ║  ██║     ██║  ██║╚██████╗ ║
 ║  ╚═╝     ╚═╝  ╚═╝ ╚═════╝║
 ║         TECHNO v2         ║
 ╚═══════════════════════════╝
ART
            ;;
        minimal)
            cat << 'ART'
  ┌─ TECH ──────────────┐
  │   ▓▓▓▓ ▓▓▓▓ ▓▓▓▓   │
  │   ▓    ▓▓▓  ▓▓▓▓   │
  │   ▓▓▓▓ ▓    ▓  ▓   │
  │   ▓    ▓▓▓▓ ▓▓▓▓   │
  │         TECHNO v2   │
  └─────────────────────┘
ART
            ;;
        *)
            cat << 'ART'
                 ╭───────────────────────────╮
                 │                           │
                 │  ████████╗██████╗  ██████╗│
                 │  ██╔════╝██╔══██╗██╔════╝│
                 │  █████╗  ██████╔╝██║      │
                 │  ██╔══╝  ██╔══██╗██║      │
                 │  ██║     ██║  ██║╚██████╗│
                 │  ╚═╝     ╚═╝  ╚═╝ ╚═════╝│
                 │          TECHNO            │
                 │        ── v2.0 ──          │
                 │                           │
                 ╰───────────────────────────╯
ART
            ;;
    esac
}

# ─── UTILITY FUNCTIONS ─────────────────────────────────────────────────────

# Print a label:info pair with color
print_info() {
    local label="$1"
    local value="$2"
    local color="${3:-$INFO_COLOR}"
    printf "  ${LABEL_COLOR}%-14s${C_RESET} ${color}%s${C_RESET}\n" "${label}:" "${value}"
}

# Print a separator line
print_separator() {
    printf "  ${SEPARATOR_COLOR}%.0s─${C_RESET}" {1..26}
    echo
}

# Print a section header
print_section() {
    local title="$1"
    local color="${2:-$C_CYAN}"
    echo ""
    printf "  ${color}${C_BOLD}── %s ──${C_RESET}\n" "${title}"
}

# Detect if a command exists
has_cmd() {
    command -v "$1" &>/dev/null
}

# Safe command execution with fallback
safe_cmd() {
    local fallback="${2:-N/A}"
    local result
    result=$("$1" 2>/dev/null) && echo "$result" || echo "$fallback"
}

# Read a sysfs file safely
read_sysfs() {
    local path="$1"
    local fallback="${2:-N/A}"
    if [[ -r "$path" ]]; then
        cat "$path" 2>/dev/null || echo "$fallback"
    else
        echo "$fallback"
    fi
}

# Convert bytes to human readable
human_size() {
    local bytes=$1
    if (( bytes >= 1073741824 )); then
        printf "%.1f GB" "$(echo "scale=1; $bytes/1073741824" | bc)"
    elif (( bytes >= 1048576 )); then
        printf "%.1f MB" "$(echo "scale=1; $bytes/1048576" | bc)"
    elif (( bytes >= 1024 )); then
        printf "%.1f KB" "$(echo "scale=1; $bytes/1024" | bc)"
    else
        printf "%d B" "$bytes"
    fi
}

# Duration in human readable
human_duration() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(( (seconds % 86400) / 3600 ))
    local mins=$(( (seconds % 3600) / 60 ))
    if (( days > 0 )); then
        printf "%dd %dh %dm" "$days" "$hours" "$mins"
    elif (( hours > 0 )); then
        printf "%dh %dm" "$hours" "$mins"
    else
        printf "%dm" "$mins"
    fi
}

# ─── OS / DISTRO DETECTION ─────────────────────────────────────────────────

detect_distro() {
    DISTRO_NAME="Unknown Linux"
    DISTRO_VERSION=""
    DISTRO_CODENAME=""
    DISTRO_FAMILY="Debian"
    DISTRO_ID=""

    # ── Primary: /etc/os-release (standard on all modern distros)
    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_NAME="${PRETTY_NAME:-${NAME} ${VERSION}}"
        DISTRO_VERSION="${VERSION_ID:-}"
        DISTRO_CODENAME="${VERSION_CODENAME:-}"
        DISTRO_ID="${ID:-}"
    # ── Fallback: /etc/lsb-release (older Ubuntu)
    elif [[ -f /etc/lsb-release ]]; then
        # shellcheck disable=SC1091
        source /etc/lsb-release
        DISTRO_NAME="${DISTRIB_DESCRIPTION:-$DISTRIB_ID $DISTRIB_RELEASE}"
        DISTRO_VERSION="${DISTRIB_RELEASE:-}"
        DISTRO_CODENAME="${DISTRIB_CODENAME:-}"
        DISTRO_ID="${DISTRIB_ID:-}"
    # ── Fallback: /etc/debian_version (pure Debian)
    elif [[ -f /etc/debian_version ]]; then
        local deb_ver
        deb_ver=$(cat /etc/debian_version 2>/dev/null || echo "")
        DISTRO_NAME="Debian ${deb_ver}"
        DISTRO_VERSION="${deb_ver}"
        DISTRO_ID="debian"
    # ── Fallback: parse /etc/issue (very old systems)
    elif [[ -f /etc/issue ]]; then
        DISTRO_NAME=$(head -1 /etc/issue 2>/dev/null | sed 's/\\[a-z]//gi' | xargs || echo "Unknown Linux")
    # ── Fallback: use lsb_release command
    elif has_cmd lsb_release; then
        DISTRO_NAME=$(lsb_release -ds 2>/dev/null || echo "Unknown Linux")
        DISTRO_VERSION=$(lsb_release -rs 2>/dev/null || echo "")
        DISTRO_CODENAME=$(lsb_release -cs 2>/dev/null || echo "")
        DISTRO_ID=$(lsb_release -is 2>/dev/null || echo "")
    fi

    # ── Detect Debian/Ubuntu family
    if [[ -f /etc/debian_version ]]; then
        DISTRO_FAMILY="Debian"
    elif [[ -n "$DISTRO_ID" ]]; then
        case "$DISTRO_ID" in
            ubuntu|debian|linuxmint|pop|elementary|zorin|kali|parrot|raspbian|armbian|devuan)
                DISTRO_FAMILY="Debian" ;;
            *)
                # Check if derivative info exists
                if [[ -n "${ID_LIKE:-}" ]] && echo "$ID_LIKE" | grep -qi debian; then
                    DISTRO_FAMILY="Debian"
                fi
                ;;
        esac
    fi
}

# ─── VM / HYPERVISOR DETECTION ─────────────────────────────────────────────

detect_vm() {
    IS_VM="false"
    VM_HYPERVISOR="Bare Metal"
    VM_PRODUCT=""
    VM_MANUFACTURER=""
    VM_UUID=""
    VM_NAME=""
    IS_CONTAINER="false"
    CONTAINER_TYPE=""
    CLOUD_PROVIDER=""
    CLOUD_INSTANCE=""

    # ── Method 1: systemd-detect-virt (most reliable on modern systemd systems)
    if has_cmd systemd-detect-virt; then
        local virt_type
        virt_type=$(systemd-detect-virt 2>/dev/null || true)
        if [[ -n "$virt_type" && "$virt_type" != "none" ]]; then
            IS_VM="true"
            VM_HYPERVISOR="$virt_type"
        fi
    fi

    # ── Method 2: DMI / SMBIOS data from sysfs
    local dmi_vendor="" dmi_product="" dmi_family="" dmi_serial=""
    # Try multiple sysfs paths (differs between distros)
    for dmi_path in /sys/devices/virtual/dmi/id /sys/class/dmi/id; do
        if [[ -d "$dmi_path" ]]; then
            [[ -z "$dmi_vendor" ]] && dmi_vendor=$(cat "${dmi_path}/sys_vendor" 2>/dev/null || echo "")
            [[ -z "$dmi_product" ]] && dmi_product=$(cat "${dmi_path}/product_name" 2>/dev/null || echo "")
            [[ -z "$dmi_family" ]] && dmi_family=$(cat "${dmi_path}/product_family" 2>/dev/null || echo "")
            [[ -z "$dmi_serial" ]] && dmi_serial=$(cat "${dmi_path}/product_serial" 2>/dev/null || echo "")
            [[ -z "$VM_UUID" || "$VM_UUID" == "Protected" ]] && VM_UUID=$(cat "${dmi_path}/product_uuid" 2>/dev/null || echo "Protected")
        fi
    done
    VM_MANUFACTURER="$dmi_vendor"
    VM_PRODUCT="$dmi_product"
    VM_NAME="$dmi_family"

    # ── Method 3: dmidecode command (if available, works on bare metal and VMs)
    if has_cmd dmidecode && [[ "$IS_VM" == "false" ]]; then
        local dmi_out
        dmi_out=$(dmidecode -t system 2>/dev/null || echo "")
        if [[ -n "$dmi_out" ]]; then
            [[ -z "$VM_MANUFACTURER" ]] && VM_MANUFACTURER=$(echo "$dmi_out" | grep -i "Manufacturer:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
            [[ -z "$VM_PRODUCT" ]] && VM_PRODUCT=$(echo "$dmi_out" | grep -i "Product Name:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
            [[ -z "$VM_NAME" ]] && VM_NAME=$(echo "$dmi_out" | grep -i "Family:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
            [[ "$VM_UUID" == "Protected" ]] && VM_UUID=$(echo "$dmi_out" | grep -i "UUID:" | head -1 | awk -F: '{print $2}' | xargs || echo "Protected")
        fi
    fi

    # ── Method 4: lscpu hypervisor field
    if has_cmd lscpu && [[ "$IS_VM" == "false" ]]; then
        local lscpu_hyp
        lscpu_hyp=$(lscpu 2>/dev/null | grep -i "Hypervisor:" | awk -F: '{print $2}' | xargs || echo "")
        if [[ -n "$lscpu_hyp" ]]; then
            IS_VM="true"
            VM_HYPERVISOR="$lscpu_hyp"
        fi
    fi

    # ── Method 5: DMI string matching (when we have DMI data but no detection yet)
    local dmi_lower
    dmi_lower=$(echo "${dmi_vendor}${dmi_product}${dmi_family}" | tr '[:upper:]' '[:lower:]')

    if [[ "$IS_VM" == "false" && -n "$dmi_lower" ]]; then
        if echo "$dmi_lower" | grep -qi "vmware\|vmx"; then
            IS_VM="true"; VM_HYPERVISOR="VMware"
        elif echo "$dmi_lower" | grep -qi "virtualbox\|vbox"; then
            IS_VM="true"; VM_HYPERVISOR="VirtualBox"
        elif echo "$dmi_lower" | grep -qi "kvm\|qemu"; then
            IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$dmi_lower" | grep -qi "xen"; then
            IS_VM="true"; VM_HYPERVISOR="Xen"
        elif echo "$dmi_lower" | grep -qi "microsoft\|hyper-v"; then
            IS_VM="true"; VM_HYPERVISOR="Hyper-V"
        elif echo "$dmi_lower" | grep -qi "parallels"; then
            IS_VM="true"; VM_HYPERVISOR="Parallels"
        elif echo "$dmi_lower" | grep -qi "oracle\|virtual machine"; then
            IS_VM="true"; VM_HYPERVISOR="VirtualBox"
        elif echo "$dmi_lower" | grep -qi "digitalocean"; then
            IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$dmi_lower" | grep -qi "alibaba\|aliyun"; then
            IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$dmi_lower" | grep -qi "amazon\|amazon ec2"; then
            IS_VM="true"; VM_HYPERVISOR="KVM (Nitro)"
        elif echo "$dmi_lower" | grep -qi "google"; then
            IS_VM="true"; VM_HYPERVISOR="KVM (Google)"
        elif echo "$dmi_lower" | grep -qi "openstack"; then
            IS_VM="true"; VM_HYPERVISOR="KVM (OpenStack)"
        elif echo "$dmi_lower" | grep -qi "cloud"; then
            IS_VM="true"; VM_HYPERVISOR="Cloud VM"
        fi
    fi

    # ── Method 6: /proc/cpuinfo hypervisor flag (works on most VMs)
    if [[ "$IS_VM" == "false" && -r /proc/cpuinfo ]]; then
        if grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
            IS_VM="true"
            # Try to identify which hypervisor from CPU model
            local cpu_model_lower
            cpu_model_lower=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | awk -F: '{print tolower($2)}' || echo "")
            if echo "$cpu_model_lower" | grep -qi "qemu"; then
                VM_HYPERVISOR="KVM/QEMU"
            elif echo "$cpu_model_lower" | grep -qi "virtualbox"; then
                VM_HYPERVISOR="VirtualBox"
            elif echo "$cpu_model_lower" | grep -qi "vmware"; then
                VM_HYPERVISOR="VMware"
            else
                VM_HYPERVISOR="Unknown Hypervisor"
            fi
        fi
    fi

    # ── Method 7: /proc/version string (identifies VMware, KVM, Hyper-V)
    if [[ "$IS_VM" == "false" && -r /proc/version ]]; then
        local proc_ver
        proc_ver=$(cat /proc/version 2>/dev/null || echo "")
        local proc_ver_lower=$(echo "$proc_ver" | tr '[:upper:]' '[:lower:]')
        if echo "$proc_ver_lower" | grep -qi "microsoft"; then
            IS_VM="true"
            VM_HYPERVISOR="Hyper-V (WSL)"
        elif echo "$proc_ver_lower" | grep -qi "vmware"; then
            IS_VM="true"
            VM_HYPERVISOR="VMware"
        elif echo "$proc_ver_lower" | grep -qi "kvm"; then
            IS_VM="true"
            VM_HYPERVISOR="KVM"
        fi
    fi

    # ── Method 8: /sys/hypervisor/type (Xen, some KVM)
    if [[ "$IS_VM" == "false" && -r /sys/hypervisor/type ]]; then
        local hyp_type
        hyp_type=$(cat /sys/hypervisor/type 2>/dev/null || echo "")
        if [[ -n "$hyp_type" ]]; then
            IS_VM="true"
            case "$hyp_type" in
                xen)    VM_HYPERVISOR="Xen" ;;
                kvm)    VM_HYPERVISOR="KVM" ;;
                *)      VM_HYPERVISOR="$hyp_type" ;;
            esac
        fi
    fi

    # ── Method 9: /proc/xen directory presence (Xen)
    if [[ "$IS_VM" == "false" && -d /proc/xen ]]; then
        IS_VM="true"
        VM_HYPERVISOR="Xen"
    fi

    # ── Method 10: Virtio device presence (strong KVM/QEMU indicator)
    if [[ "$IS_VM" == "false" && -d /sys/bus/virtio ]]; then
        local virtio_count
        virtio_count=$(ls /sys/bus/virtio/devices/ 2>/dev/null | wc -l || echo "0")
        if (( virtio_count > 0 )); then
            IS_VM="true"
            VM_HYPERVISOR="KVM/QEMU (virtio)"
        fi
    fi

    # ── Method 11: Cloud-init presence (most cloud VMs have this)
    if [[ "$IS_VM" == "false" ]]; then
        if [[ -f /run/cloud-init/instance-data.json ]] || \
           [[ -f /var/lib/cloud/instance/instance-id ]] || \
           [[ -d /var/lib/cloud/data ]]; then
            IS_VM="true"
            VM_HYPERVISOR="Cloud VM"
        fi
    fi

    # ── Method 12: VMware tools / VirtualBox Guest Additions
    if [[ "$IS_VM" == "false" ]]; then
        if has_cmd vmware-toolbox-cmd || [[ -f /usr/bin/vmware-guestinfo ]] || \
           [[ -d /usr/lib/vmware-tools ]]; then
            IS_VM="true"; VM_HYPERVISOR="VMware"
        elif has_cmd VBoxClient || [[ -f /usr/bin/VBoxClient ]] || \
             [[ -d /usr/lib/VirtualBoxGuestAdditions ]]; then
            IS_VM="true"; VM_HYPERVISOR="VirtualBox"
        fi
    fi

    # ── Method 13: Check /sys/devices/virtual/dmi/id for ANY file content
    #    On some VPS (e.g., Vultr, Hetzner) DMI exists but has VM info
    if [[ "$IS_VM" == "false" && -d /sys/devices/virtual/dmi/id ]]; then
        local dmi_all
        dmi_all=$(cat /sys/devices/virtual/dmi/id/* 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "")
        if echo "$dmi_all" | grep -qi "kvm\|qemu\|vmware\|virtualbox\|xen\|hyper\|parallels\|openstack\|nitro"; then
            IS_VM="true"
            if echo "$dmi_all" | grep -qi "kvm\|qemu"; then VM_HYPERVISOR="KVM/QEMU"
            elif echo "$dmi_all" | grep -qi "vmware"; then VM_HYPERVISOR="VMware"
            elif echo "$dmi_all" | grep -qi "virtualbox"; then VM_HYPERVISOR="VirtualBox"
            elif echo "$dmi_all" | grep -qi "xen"; then VM_HYPERVISOR="Xen"
            elif echo "$dmi_all" | grep -qi "hyper"; then VM_HYPERVISOR="Hyper-V"
            elif echo "$dmi_all" | grep -qi "nitro"; then VM_HYPERVISOR="KVM (AWS Nitro)"
            else VM_HYPERVISOR="Cloud VM"
            fi
        fi
    fi

    # ── Method 14: Check systemd virtualization with broader patterns
    if [[ "$IS_VM" == "false" ]]; then
        if [[ -f /run/systemd/container ]]; then
            IS_CONTAINER="true"
            CONTAINER_TYPE=$(cat /run/systemd/container 2>/dev/null || echo "OCI")
        fi
    fi

    # ── Detect CPU virtualization features (informational, not detection)
    VIRT_FLAGS=""
    if [[ -r /proc/cpuinfo ]]; then
        local flags_line
        flags_line=$(grep -m1 "^flags" /proc/cpuinfo 2>/dev/null || echo "")
        local virt_features=""
        for flag in vmx svm hypervisor; do
            if echo "$flags_line" | grep -qw "$flag"; then
                virt_features="${virt_features:+$virt_features, }$flag"
            fi
        done
        VIRT_FLAGS="$virt_features"
    fi

    # ── Container detection (runs AFTER VM detection — a container can be inside a VM)
    if [[ -f /.dockerenv ]]; then
        IS_CONTAINER="true"
        CONTAINER_TYPE="Docker"
    elif grep -qE 'container=lxc|container=LXC' /proc/1/environ 2>/dev/null; then
        IS_CONTAINER="true"
        CONTAINER_TYPE="LXC/LXD"
    elif [[ -f /run/containerd/containerd.sock ]] || [[ -d /run/containerd ]]; then
        IS_CONTAINER="true"
        CONTAINER_TYPE="containerd"
    elif has_cmd podman && podman info 2>/dev/null | grep -q rootless; then
        IS_CONTAINER="true"
        CONTAINER_TYPE="Podman (rootless)"
    fi

    # ── cgroup-based container detection (Podman, Docker in cgroupv2)
    if [[ "$IS_CONTAINER" == "false" ]]; then
        if [[ -r /proc/1/cgroup ]]; then
            if grep -qE '(/docker-|/containerd-|/libpod-)' /proc/1/cgroup 2>/dev/null; then
                IS_CONTAINER="true"
                CONTAINER_TYPE="OCI Container"
            fi
        fi
    fi

    # ── Systemd-nspawn
    if [[ "$IS_CONTAINER" == "false" ]]; then
        if grep -qi "systemd-nspawn" /proc/1/cmdline 2>/dev/null; then
            IS_CONTAINER="true"
            CONTAINER_TYPE="systemd-nspawn"
        fi
    fi

    # ── Cloud provider detection (runs after VM detection)
    detect_cloud
}

detect_cloud() {
    CLOUD_PROVIDER="N/A"
    CLOUD_INSTANCE="N/A"
    CLOUD_REGION="N/A"
    CLOUD_ZONE="N/A"
    CLOUD_INSTANCE_TYPE="N/A"
    CLOUD_ACCOUNT_ID="N/A"

    # AWS
    if has_cmd curl; then
        local meta_url="http://169.254.169.254/latest/meta-data"
        if curl -sf --connect-timeout 1 --max-time 2 "$meta_url/instance-id" &>/dev/null; then
            CLOUD_PROVIDER="AWS (Amazon Web Services)"
            CLOUD_INSTANCE=$(curl -sf --connect-timeout 1 --max-time 2 "$meta_url/instance-id" 2>/dev/null || echo "N/A")
            CLOUD_REGION=$(curl -sf --connect-timeout 1 --max-time 2 "$meta-url/placement/region" 2>/dev/null || echo "N/A")
            CLOUD_ZONE=$(curl -sf --connect-timeout 1 --max-time 2 "$meta_url/placement/availability-zone" 2>/dev/null || echo "N/A")
            CLOUD_INSTANCE_TYPE=$(curl -sf --connect-timeout 1 --max-time 2 "$meta_url/instance-type" 2>/dev/null || echo "N/A")
            return
        fi
    fi

    # GCP
    if has_cmd curl; then
        if curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name" &>/dev/null; then
            CLOUD_PROVIDER="GCP (Google Cloud)"
            CLOUD_INSTANCE=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name" 2>/dev/null || echo "N/A")
            CLOUD_REGION=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/zone" 2>/dev/null | sed 's|.*/||' || echo "N/A")
            CLOUD_INSTANCE_TYPE=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/machine-type" 2>/dev/null | sed 's|.*/||' || echo "N/A")
            return
        fi
    fi

    # Azure
    if has_cmd curl; then
        if curl -sf --connect-timeout 1 --max-time 2 -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" &>/dev/null; then
            CLOUD_PROVIDER="Azure (Microsoft)"
            local azure_data
            azure_data=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" 2>/dev/null || echo "{}")
            CLOUD_INSTANCE=$(echo "$azure_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('compute',{}).get('name','N/A'))" 2>/dev/null || echo "N/A")
            CLOUD_REGION=$(echo "$azure_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('compute',{}).get('location','N/A'))" 2>/dev/null || echo "N/A")
            CLOUD_INSTANCE_TYPE=$(echo "$azure_data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('compute',{}).get('vmSize','N/A'))" 2>/dev/null || echo "N/A")
            return
        fi
    fi

    # DigitalOcean
    if [[ -r /etc/digitalocean ]]; then
        CLOUD_PROVIDER="DigitalOcean"
        return
    fi

    # Linode / Akamai
    if [[ -r /etc/linode ]]; then
        CLOUD_PROVIDER="Linode (Akamai)"
        return
    fi

    # Hetzner
    if has_cmd curl; then
        if curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/hetzner/v1/metadata" &>/dev/null; then
            CLOUD_PROVIDER="Hetzner Cloud"
            return
        fi
    fi

    # Oracle Cloud
    if has_cmd curl; then
        if curl -sf --connect-timeout 1 --max-time 2 -H "Authorization: Bearer oracle" "http://169.254.169.254/opc/v2/instance/" &>/dev/null; then
            CLOUD_PROVIDER="Oracle Cloud (OCI)"
            return
        fi
    fi
}

# ─── KERNEL INFO ────────────────────────────────────────────────────────────

get_kernel_info() {
    KERNEL_RELEASE=$(uname -r)
    KERNEL_NAME=$(uname -s)
    KERNEL_ARCH=$(uname -m)
    KERNEL_VERSION=$(uname -v)

    # Kernel config features
    KERNEL_MODULES_LOADED=""
    if has_cmd lsmod; then
        KERNEL_MODULES_LOADED=$(lsmod 2>/dev/null | wc -l)
    fi

    # Kernel command line
    KERNEL_CMDLINE=""
    if [[ -r /proc/cmdline ]]; then
        KERNEL_CMDLINE=$(cat /proc/cmdline 2>/dev/null | head -c 120)
        [[ ${#KERNEL_CMDLINE} -ge 117 ]] && KERNEL_CMDLINE="${KERNEL_CMDLINE}..."
    fi
}

# ─── CPU INFO ──────────────────────────────────────────────────────────────

get_cpu_info() {
    CPU_MODEL="N/A"
    CPU_CORES_PHYSICAL=0
    CPU_CORES_LOGICAL=0
    CPU_SOCKETS=0
    CPU_THREADS=0
    CPU_MHZ="N/A"
    CPU_MAX_MHZ="N/A"
    CPU_MIN_MHZ="N/A"
    CPU_CACHE="N/A"
    CPU_ARCH="N/A"
    CPU_VIRT=""

    if [[ -r /proc/cpuinfo ]]; then
        # Model name
        CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "N/A")

        # Physical cores
        CPU_CORES_PHYSICAL=$(grep -c "^physical id" /proc/cpuinfo 2>/dev/null || echo "0")
        local cores_per_socket
        cores_per_socket=$(grep -m1 "cpu cores" /proc/cpuinfo 2>/dev/null | awk '{print $4}' || echo "0")
        if (( CPU_CORES_PHYSICAL == 0 )); then
            CPU_CORES_PHYSICAL="$cores_per_socket"
        else
            CPU_CORES_PHYSICAL=$(( CPU_CORES_PHYSICAL * cores_per_socket ))
        fi

        # Logical processors
        CPU_CORES_LOGICAL=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "0")
        CPU_SOCKETS=$(grep -c "^physical id" /proc/cpuinfo 2>/dev/null || echo "0")
        [[ "$CPU_SOCKETS" -eq 0 ]] && CPU_SOCKETS=1

        # Current frequency
        CPU_MHZ=$(grep -m1 "cpu MHz" /proc/cpuinfo 2>/dev/null | awk -F: '{printf "%.0f", $2}' | xargs || echo "N/A")

        # Max/Min from cpufreq
        if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]]; then
            local max_khz min_khz
            max_khz=$(read_sysfs "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" "0")
            min_khz=$(read_sysfs "/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq" "0")
            CPU_MAX_MHZ="$((max_khz / 1000))"
            CPU_MIN_MHZ="$((min_khz / 1000))"
        fi

        # Cache
        CPU_CACHE=$(grep -m1 "cache size" /proc/cpuinfo 2>/dev/null | awk -F: '{print $2}' | xargs || echo "N/A")

        # Architecture
        CPU_ARCH=$(uname -m)
    fi

    # Virtualization capability
    if has_cmd lscpu; then
        local virt
        virt=$(lscpu 2>/dev/null | grep "Virtualization:" | awk -F: '{print $2}' | xargs || echo "")
        if [[ -n "$virt" ]]; then
            CPU_VIRT="$virt"
        fi
    fi
}

# ─── MEMORY INFO ───────────────────────────────────────────────────────────

get_memory_info() {
    MEM_TOTAL=0
    MEM_USED=0
    MEM_FREE=0
    MEM_AVAILABLE=0
    MEM_BUFFERS=0
    MEM_CACHED=0
    SWAP_TOTAL=0
    SWAP_USED=0
    SWAP_FREE=0
    MEM_PERCENT="0"

    if [[ -r /proc/meminfo ]]; then
        MEM_TOTAL=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
        MEM_AVAILABLE=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
        MEM_BUFFERS=$(awk '/^Buffers:/ {print $2}' /proc/meminfo)
        MEM_CACHED=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
        SWAP_TOTAL=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
        SWAP_FREE=$(awk '/^SwapFree:/ {print $2}' /proc/meminfo)

        MEM_FREE=$(awk '/^MemFree:/ {print $2}' /proc/meminfo)
        MEM_USED=$((MEM_TOTAL - MEM_FREE - MEM_BUFFERS - MEM_CACHED))
        [[ "$MEM_USED" -lt 0 ]] && MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
        SWAP_USED=$((SWAP_TOTAL - SWAP_FREE))

        if (( MEM_TOTAL > 0 )); then
            MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$MEM_TOTAL)*100}")
        fi
    fi
}

# ─── DISK INFO ─────────────────────────────────────────────────────────────

get_disk_info() {
    DISK_TOTAL="0"
    DISK_USED="0"
    DISK_FREE="0"
    DISK_PERCENT="0"
    ROOT_FS_TYPE="N/A"
    ROOT_MOUNT_OPTS="N/A"

    if has_cmd df; then
        local df_out
        df_out=$(df -h --output=size,used,avail,pcent / 2>/dev/null | tail -1)
        DISK_TOTAL=$(echo "$df_out" | awk '{print $1}')
        DISK_USED=$(echo "$df_out" | awk '{print $2}')
        DISK_FREE=$(echo "$df_out" | awk '{print $3}')
        DISK_PERCENT=$(echo "$df_out" | awk '{print $4}' | tr -d '%')
    fi

    ROOT_FS_TYPE=$(stat -f -c %T / 2>/dev/null || echo "N/A")
    ROOT_MOUNT_OPTS=$(findmnt -n -o OPTIONS / 2>/dev/null || echo "N/A")
}

# ─── NETWORK INFO ──────────────────────────────────────────────────────────

get_network_info() {
    PRIMARY_IFACE="N/A"
    PRIMARY_IP="N/A"
    PRIMARY_MAC="N/A"
    PRIMARY_SPEED="N/A"
    NET_RX_BYTES="0"
    NET_TX_BYTES="0"
    WIFI_SSID="N/A"
    PUBLIC_IP="N/A"

    # Find primary interface (default route)
    PRIMARY_IFACE=$(ip route 2>/dev/null | grep default | head -1 | awk '{print $5}' || echo "")
    [[ -z "$PRIMARY_IFACE" ]] && PRIMARY_IFACE="N/A"

    if [[ "$PRIMARY_IFACE" != "N/A" ]]; then
        PRIMARY_IP=$(ip -4 addr show "$PRIMARY_IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1 || echo "N/A")
        PRIMARY_MAC=$(ip link show "$PRIMARY_IFACE" 2>/dev/null | grep -oP 'link/ether \K[\da-f:]+' | head -1 || echo "N/A")
        PRIMARY_SPEED=$(cat "/sys/class/net/${PRIMARY_IFACE}/speed" 2>/dev/null || echo "N/A")

        # Traffic stats
        local rx_file="/sys/class/net/${PRIMARY_IFACE}/statistics/rx_bytes"
        local tx_file="/sys/class/net/${PRIMARY_IFACE}/statistics/tx_bytes"
        NET_RX_BYTES=$(read_sysfs "$rx_file" "0")
        NET_TX_BYTES=$(read_sysfs "$tx_file" "0")
    fi

    # WiFi SSID
    if has_cmd iwgetid; then
        WIFI_SSID=$(iwgetid -r 2>/dev/null || echo "N/A")
    fi

    # DNS servers
    DNS_SERVERS=""
    if [[ -r /etc/resolv.conf ]]; then
        DNS_SERVERS=$(grep "^nameserver" /etc/resolv.conf 2>/dev/null | awk '{print $2}' | head -3 | tr '\n' ', ' | sed 's/,$//')
    fi
    [[ -z "$DNS_SERVERS" ]] && DNS_SERVERS="N/A"
}

# ─── GPU INFO ──────────────────────────────────────────────────────────────

get_gpu_info() {
    GPU_INFO="N/A"
    GPU_DRIVER="N/A"

    if has_cmd lspci; then
        local gpu_line
        gpu_line=$(lspci 2>/dev/null | grep -iE "vga|3d|display" | head -1 || echo "")
        if [[ -n "$gpu_line" ]]; then
            GPU_INFO=$(echo "$gpu_line" | sed 's/^[0-9]*:[0-9]*.[0-9]* //' || echo "N/A")
        fi
    fi

    # If VM, check for virtio-gpu or similar
    if [[ "$IS_VM" == "true" ]]; then
        case "$VM_HYPERVISOR" in
            *KVM*|*QEMU*)
                if echo "$GPU_INFO" | grep -qi "virtio"; then
                    GPU_DRIVER="virtio-gpu"
                elif echo "$GPU_INFO" | grep -qi "qxl"; then
                    GPU_DRIVER="qxl"
                elif echo "$GPU_INFO" | grep -qi "ramd"; then
                    GPU_DRIVER="ramd"
                fi
                ;;
            VMware*)
                GPU_DRIVER="vmwgfx"
                ;;
            VirtualBox*)
                GPU_DRIVER="vboxvideo"
                ;;
            Hyper-V*)
                GPU_DRIVER="hyperv_drm"
                ;;
        esac
    fi
}

# ─── UPTIME / LOAD ─────────────────────────────────────────────────────────

get_uptime_load() {
    UPTIME_SECONDS="0"
    UPTIME_HUMAN="N/A"
    LOAD_AVG="N/A"
    PROCS_TOTAL=0
    PROCS_RUNNING=0
    BOOT_TIME="N/A"

    if [[ -r /proc/uptime ]]; then
        UPTIME_SECONDS=$(awk '{print int($1)}' /proc/uptime)
        UPTIME_HUMAN=$(human_duration "$UPTIME_SECONDS")
    fi

    LOAD_AVG=$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "N/A")
    PROCS_TOTAL=$(awk '{print $4}' /proc/loadavg 2>/dev/null | cut -d/ -f2 || echo "0")
    PROCS_RUNNING=$(awk '{print $4}' /proc/loadavg 2>/dev/null | cut -d/ -f1 || echo "0")

    # Boot time
    if has_cmd uptime; then
        BOOT_TIME=$(uptime -s 2>/dev/null || echo "N/A")
    fi
}

# ─── PACKAGE COUNT ─────────────────────────────────────────────────────────

get_packages() {
    PKG_COUNT=0
    PKG_MANAGER="N/A"

    # dpkg (Debian/Ubuntu)
    if has_cmd dpkg-query; then
        PKG_COUNT=$(dpkg-query -f '.' -W 2>/dev/null | wc -c)
        PKG_MANAGER="apt/dpkg"
    fi

    # apt packages (installed, not auto)
    APT_INSTALLED=$(dpkg-query -f '.' -W 2>/dev/null | wc -c || echo "0")
    APT_UPGRADABLE=""
    if has_cmd apt; then
        APT_UPGRADABLE=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
    fi
}

# ─── PROCESS / SERVICE INFO ────────────────────────────────────────────────

get_process_info() {
    TOTAL_PROCS=0
    TOTAL_THREADS=0
    ZOMBIE_PROCS=0

    TOTAL_PROCS=$(ls -d /proc/[0-9]* 2>/dev/null | wc -l)

    if [[ -r /proc/stat ]]; then
        TOTAL_THREADS=$(grep "^processes" /proc/stat 2>/dev/null | awk '{print $2}' || echo "0")
    fi

    ZOMBIE_PROCS=$(ps aux 2>/dev/null | awk '$8 ~ /Z/ {count++} END {print count+0}' || echo "0")

    # Key services
    SERVICES_RUNNING=""
    if has_cmd systemctl; then
        local svc_list
        svc_list=$(systemctl list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | awk '{print $1}' | head -8 | sed 's/\.service$//' || echo "")
        SERVICES_RUNNING="$svc_list"
    fi
}

# ─── SECURITY INFO ─────────────────────────────────────────────────────────

get_security_info() {
    IS_ROOT="false"
    SSH_SESSION="false"
    FIREWALL="N/A"
    SELINUX="N/A"
    APPARMOR="N/A"
    AVAIL_UPDATES=0
    SECURITY_UPDATES=0

    [[ $EUID -eq 0 ]] && IS_ROOT="true"
    [[ -n "${SSH_CLIENT:-}" ]] && SSH_SESSION="true"

    # Firewall
    if has_cmd ufw; then
        FIREWALL=$(ufw status 2>/dev/null | head -1 || echo "N/A")
    elif has_cmd iptables; then
        local rules
        rules=$(iptables -L -n 2>/dev/null | grep -c "^Chain" || echo "0")
        if (( rules > 3 )); then
            FIREWALL="iptables ($rules chains)"
        fi
    fi

    # AppArmor
    if [[ -r /sys/module/apparmor/parameters/enabled ]]; then
        local aa_enabled
        aa_enabled=$(read_sysfs "/sys/module/apparmor/parameters/enabled" "N/A")
        if [[ "$aa_enabled" == "Y" ]]; then
            APPARMOR="Active"
        else
            APPARMOR="Inactive"
        fi
    fi

    # Security updates
    if has_cmd apt; then
        AVAIL_UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo "0")
    fi
}

# ─── STORAGE DEVICES ───────────────────────────────────────────────────────

get_storage_info() {
    STORAGE_LIST=""
    if has_cmd lsblk; then
        STORAGE_LIST=$(lsblk -d -n -o NAME,SIZE,TYPE,MODEL 2>/dev/null | head -5 || echo "N/A")
    fi

    # Virtual disk info (if VM)
    VIRT_DISK_TYPE="N/A"
    VIRT_DISK_DRIVER="N/A"
    if [[ "$IS_VM" == "true" ]]; then
        local root_dev
        root_dev=$(findmnt -n -o SOURCE / 2>/dev/null | sed 's/[0-9]*$//' || echo "")
        root_dev=$(basename "$root_dev" 2>/dev/null || echo "")
        if [[ -n "$root_dev" ]]; then
            VIRT_DISK_TYPE=$(read_sysfs "/sys/block/${root_dev}/device/type" "N/A" 2>/dev/null)
            VIRT_DISK_DRIVER=$(read_sysfs "/sys/block/${root_dev}/device/vendor" "N/A" 2>/dev/null)
            # Try to get the driver from modinfo
            local dev_path="/sys/block/${root_dev}"
            if [[ -d "$dev_path" ]]; then
                local subsystem
                subsystem=$(readlink -f "$dev_path" 2>/dev/null | grep -oE "(virtio|sd|nvme|vd|xvd)" | head -1 || echo "")
                [[ -n "$subsystem" ]] && VIRT_DISK_DRIVER="$subsystem"
            fi
        fi
    fi
}

# ─── DISPLAY FUNCTIONS ─────────────────────────────────────────────────────

# Row 1: Blue and white blocks
print_color_blocks() {
    local blocks=()
    blocks+=($'\033[48;5;16m')   # Dark gray (black)
    blocks+=($'\033[48;5;235m')  # Dark blue-black
    blocks+=($'\033[48;5;236m')  # Darker blue
    blocks+=($'\033[48;5;237m')  # Dark blue
    blocks+=($'\033[48;5;39m')   # Vivid blue
    blocks+=($'\033[48;5;75m')   # Medium blue
    blocks+=($'\033[48;5;111m')  # Light blue
    blocks+=($'\033[48;5;231m')  # Pure white

    printf "  "
    for block in "${blocks[@]}"; do
        printf '%s   %s' "$block" "$C_RESET"
    done
    echo ""
}

# Row 2: Blue gradient
print_color_blocks_2() {
    local blocks=()
    blocks+=($'\033[48;5;17m')   # Black-blue
    blocks+=($'\033[48;5;18m')   # Dark navy
    blocks+=($'\033[48;5;19m')   # Navy
    blocks+=($'\033[48;5;20m')   # Blue
    blocks+=($'\033[48;5;21m')   # Royal blue
    blocks+=($'\033[48;5;27m')   # Bright blue
    blocks+=($'\033[48;5;63m')   # Periwinkle
    blocks+=($'\033[48;5;159m')  # Light periwinkle

    printf "  "
    for block in "${blocks[@]}"; do
        printf '%s   %s' "$block" "$C_RESET"
    done
    echo ""
}

# ─── MAIN OUTPUT ───────────────────────────────────────────────────────────

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-ascii)    SHOW_ASCII=false; shift ;;
            --style)       ASCII_STYLE="$2"; shift 2 ;;
            --no-color)    SHOW_COLORS=false; shift ;;
            --no-blocks)   SHOW_BLOCKS=false; shift ;;
            --version|-v)  echo "Technofetch v${VERSION}"; exit 0 ;;
            --help|-h)
                echo "Technofetch v${VERSION} — VM-Focused System Info"
                echo ""
                echo "Usage: technofetch [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --no-ascii      Hide ASCII art"
                echo "  --style STYLE   ASCII style: default, compact, box, minimal"
                echo "  --no-color      Disable colors"
                echo "  --no-blocks     Hide color blocks"
                echo "  --version, -v   Show version"
                echo "  --help, -h      Show this help"
                echo ""
                echo "Runs on: Ubuntu, Debian, and derivatives"
                echo "Detects: KVM, VMware, VirtualBox, Hyper-V, Xen, Parallels"
                echo "Clouds:  AWS, GCP, Azure, DigitalOcean, Linode, Hetzner, OCI"
                exit 0
                ;;
            *)
                echo "Unknown option: $1 (use --help)"
                exit 1
                ;;
        esac
    done

    # ── Gather all information ──
    detect_distro
    detect_vm
    get_kernel_info
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    get_gpu_info
    get_uptime_load
    get_packages
    get_process_info
    get_security_info
    get_storage_info

    # ── Build ASCII lines into array ──
    local ascii_lines=()
    if [[ "$SHOW_ASCII" == "true" ]]; then
        while IFS= read -r line; do
            ascii_lines+=("$line")
        done < <(read_ascii_art "$ASCII_STYLE" "$DISTRO_ID" "$DISTRO_VERSION")
    fi

    # ── Build info lines into array ──
    local info_lines=()

    # Detect shell info
    local shell_name="${SHELL:-N/A}"
    local shell_version=""
    if [[ -n "$shell_name" && "$shell_name" != "N/A" ]]; then
        shell_version=$("$shell_name" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "")
        shell_name=$(basename "$shell_name")
    fi

    # Detect terminal
    local term_name="${TERM_PROGRAM:-${TERM:-N/A}}"
    # Check if running in a known terminal
    if [[ -t 1 ]]; then
        if [[ -n "${SSH_CONNECTION:-}" ]] || [[ -n "${SSH_CLIENT:-}" ]]; then
            term_name="ssh"
        elif [[ -n "${TMUX:-}" ]]; then
            term_name="tmux"
        elif [[ -n "${STY:-}" ]]; then
            term_name="screen"
        fi
    fi

    # Detect resolution
    local resolution="N/A"
    if has_cmd xrandr; then
        resolution=$(xrandr 2>/dev/null | grep '*' | head -1 | awk '{print $1}' || echo "")
    fi
    # For VPS/headless, show terminal size
    if [[ -z "$resolution" || "$resolution" == "N/A" ]]; then
        if [[ -t 1 ]]; then
            local rows cols
            rows=$(tput lines 2>/dev/null || echo "")
            cols=$(tput cols 2>/dev/null || echo "")
            if [[ -n "$rows" && -n "$cols" ]]; then
                resolution="${cols}x${rows}"
            fi
        fi
    fi

    # Snap package count
    local snap_count=0
    if has_cmd snap; then
        snap_count=$(snap list 2>/dev/null | tail -n +2 | wc -l || echo "0")
    fi

    # ── HEADER ──
    local user_color="$C_LIME"
    [[ "$IS_ROOT" == "true" ]] && user_color="$C_BAD"
    info_lines+=("$(printf "${user_color}${C_BOLD}%s@%s${C_RESET}" "$(whoami 2>/dev/null || echo root)" "$(hostname 2>/dev/null || echo unknown)")")
    info_lines+=("$(printf "${C_DIM}──────────────────${C_RESET}")")

    # ── OS ──
    info_lines+=("$(printf "${C_LABEL}OS${C_RESET}        ${C_VALUE}%s${C_RESET}" "$DISTRO_NAME")")

    # Host / VM info
    if [[ "$IS_VM" == "true" ]]; then
        info_lines+=("$(printf "${C_LABEL}Host${C_RESET}      ${C_PINK}${C_BOLD}%s${C_RESET}" "${VM_MANUFACTURER:-N/A} ${VM_PRODUCT:-}")")
        info_lines+=("$(printf "${C_LABEL}Hypervisor${C_RESET} ${C_ORANGE}${C_BOLD}%s${C_RESET}" "$VM_HYPERVISOR")")
    else
        local hw_vendor hw_product
        hw_vendor=$(read_sysfs "/sys/devices/virtual/dmi/id/board_vendor" "")
        hw_product=$(read_sysfs "/sys/devices/virtual/dmi/id/board_name" "")
        [[ -n "$hw_vendor" ]] && \
            info_lines+=("$(printf "${C_LABEL}Host${C_RESET}      ${C_VALUE}%s${C_RESET}" "$hw_vendor $hw_product")")
    fi

    if [[ "$IS_CONTAINER" == "true" ]]; then
        info_lines+=("$(printf "${C_LABEL}Container${C_RESET} ${C_TEAL}${C_BOLD}%s${C_RESET}" "$CONTAINER_TYPE")")
    fi

    # ── KERNEL ──
    info_lines+=("$(printf "${C_LABEL}Kernel${C_RESET}    ${C_VALUE}%s${C_RESET}" "$KERNEL_RELEASE")")

    # ── UPTIME ──
    info_lines+=("$(printf "${C_LABEL}Uptime${C_RESET}    ${C_LIME}%s${C_RESET}" "$UPTIME_HUMAN")")

    # ── PACKAGES ──
    local pkg_str="${PKG_COUNT} (dpkg)"
    if (( snap_count > 0 )); then
        pkg_str="${pkg_str}, ${snap_count} (snap)"
    fi
    info_lines+=("$(printf "${C_LABEL}Packages${C_RESET}  ${C_GOLD}%s${C_RESET}" "$pkg_str")")

    # ── SHELL ──
    if [[ -n "$shell_version" ]]; then
        info_lines+=("$(printf "${C_LABEL}Shell${C_RESET}     ${C_SKY}%s %s${C_RESET}" "$shell_name" "$shell_version")")
    else
        info_lines+=("$(printf "${C_LABEL}Shell${C_RESET}     ${C_SKY}%s${C_RESET}" "$shell_name")")
    fi

    # ── RESOLUTION ──
    info_lines+=("$(printf "${C_LABEL}Resolution${C_RESET} ${C_VALUE}%s${C_RESET}" "$resolution")")

    # ── TERMINAL ──
    info_lines+=("$(printf "${C_LABEL}Terminal${C_RESET}  ${C_LAVENDER}%s${C_RESET}" "$term_name")")

    # ── CPU ──
    local cpu_short
    cpu_short=$(echo "$CPU_MODEL" | sed 's/(R)//g; s/(TM)//g; s/CPU //g; s/  */ /g' | xargs 2>/dev/null || echo "$CPU_MODEL")
    # Remove trailing @ speed from model if present
    cpu_short=$(echo "$cpu_short" | sed 's/ @ [0-9.]*GHz//; s/ @ [0-9.]*MHz//; s/  */ /g' | xargs 2>/dev/null || echo "$cpu_short")
    local cpu_threads="$CPU_CORES_LOGICAL"
    local cpu_freq=""
    if [[ "$CPU_MHZ" != "N/A" ]]; then
        if (( CPU_MHZ > 1000 )); then
            cpu_freq=$(awk "BEGIN {printf \" @ %.2fGHz\", ${CPU_MHZ}/1000}")
        else
            cpu_freq=" @ ${CPU_MHZ}MHz"
        fi
    fi
    info_lines+=("$(printf "${C_LABEL}CPU${C_RESET}        ${C_SEC_CPU}%s${C_RESET} (${C_ORANGE}%s${C_RESET})" "$cpu_short" "${cpu_threads}${cpu_freq}")")

    # ── GPU ──
    if [[ "$GPU_INFO" != "N/A" ]]; then
        local gpu_short
        gpu_short=$(echo "$GPU_INFO" | sed 's/^[0-9]*:[0-9]*.[0-9]* //' | xargs 2>/dev/null || echo "$GPU_INFO")
        info_lines+=("$(printf "${C_LABEL}GPU${C_RESET}        ${C_SEC_GPU}%s${C_RESET}" "$gpu_short")")
    fi

    # ── MEMORY ──
    local mem_used_h mem_total_h
    mem_total_h=$(awk "BEGIN {printf \"%d\", ${MEM_TOTAL}/1024}")
    mem_used_h=$(awk "BEGIN {printf \"%d\", ${MEM_USED}/1024}")
    local mem_color="$C_GOOD"
    local mem_pct_int=${MEM_PERCENT%.*}
    (( mem_pct_int > 80 )) && mem_color="$C_BAD"
    (( mem_pct_int > 60 && mem_pct_int <= 80 )) && mem_color="$C_WARN"
    info_lines+=("$(printf "${C_LABEL}Memory${C_RESET}     ${mem_color}%sMiB${C_RESET} / %sMiB" "$mem_used_h" "$mem_total_h")")

    # Memory bar — vivid gradient
    local bar_len=20
    local filled
    filled=$(awk "BEGIN {printf \"%d\", (${MEM_PERCENT}/100)*${bar_len}}")
    local bar=""
    local bar_pct=$(( filled * 100 / bar_len ))
    for ((i=0; i<bar_len; i++)); do
        if ((i < filled)); then
            if ((bar_pct > 80)); then
                bar="${bar}${C_BAD}${C_BOLD}█${C_RESET}"
            elif ((bar_pct > 60)); then
                bar="${bar}${C_WARN}${C_BOLD}█${C_RESET}"
            elif ((bar_pct > 40)); then
                bar="${bar}${C_LIME}${C_BOLD}█${C_RESET}"
            else
                bar="${bar}${C_GOOD}${C_BOLD}█${C_RESET}"
            fi
        else
            bar="${bar}${C_DIM}░${C_RESET}"
        fi
    done
    info_lines+=("$(printf "${C_LABEL}            ${C_RESET}")${bar}")

    # ── DISK ──
    info_lines+=("$(printf "${C_LABEL}Disk${C_RESET}      ${C_VALUE}%s / %s (${DISK_PERCENT}%%)${C_RESET}" "$DISK_USED" "$DISK_TOTAL")")

    # ── NETWORK ──
    info_lines+=("$(printf "${C_LABEL}Network${C_RESET}   ${C_VALUE}%s${C_RESET} (${C_SKY}%s${C_RESET})" "$PRIMARY_IFACE" "$PRIMARY_IP")")

    # ── SECURITY LINE ──
    local sec_parts=""
    [[ "$SSH_SESSION" == "true" ]] && sec_parts="${sec_parts}${C_GOOD}SSH${C_RESET} "
    [[ "$IS_ROOT" == "true" ]] && sec_parts="${sec_parts}${C_BAD}ROOT${C_RESET} "
    [[ "$APPARMOR" == "Active" ]] && sec_parts="${sec_parts}${C_GOOD}AppArmor${C_RESET} "
    [[ "$FIREWALL" != "N/A" ]] && sec_parts="${sec_parts}${C_GOOD}Firewall${C_RESET} "
    if [[ -n "$sec_parts" ]]; then
        info_lines+=("$(printf "${C_LABEL}Security${C_RESET}  ${sec_parts}")")
    fi

    # ── VM EXTENDED INFO (shown below standard info) ──
    if [[ "$IS_VM" == "true" ]]; then
        if [[ -n "$VIRT_FLAGS" ]]; then
            info_lines+=("$(printf "${C_LABEL}Virt Flags${C_RESET} ${C_TEAL}%s${C_RESET}" "$VIRT_FLAGS")")
        fi
        if [[ -n "$VM_NAME" && "$VM_NAME" != "N/A" ]]; then
            info_lines+=("$(printf "${C_LABEL}VM Name${C_RESET}   ${C_LAVENDER}%s${C_RESET}" "$VM_NAME")")
        fi
        if [[ "$VIRT_DISK_DRIVER" != "N/A" ]]; then
            info_lines+=("$(printf "${C_LABEL}Disk I/O${C_RESET}   ${C_ORANGE}%s${C_RESET}" "$VIRT_DISK_DRIVER")")
        fi
        if [[ "$GPU_DRIVER" != "N/A" ]]; then
            info_lines+=("$(printf "${C_LABEL}GPU Driver${C_RESET} ${C_LAVENDER}%s${C_RESET}" "$GPU_DRIVER")")
        fi
    fi

    # ── CLOUD EXTENDED INFO ──
    if [[ "$CLOUD_PROVIDER" != "N/A" ]]; then
        info_lines+=("$(printf "${C_LABEL}☁ Cloud${C_RESET}     ${C_CYAN}${C_BOLD}%s${C_RESET}" "$CLOUD_PROVIDER")")
        [[ "$CLOUD_INSTANCE" != "N/A" ]] && \
            info_lines+=("$(printf "${C_LABEL}Instance${C_RESET}  ${C_VALUE}%s${C_RESET}" "$CLOUD_INSTANCE")")
        [[ "$CLOUD_INSTANCE_TYPE" != "N/A" ]] && \
            info_lines+=("$(printf "${C_LABEL}VM Type${C_RESET}    ${C_ORANGE}%s${C_RESET}" "$CLOUD_INSTANCE_TYPE")")
        [[ "$CLOUD_REGION" != "N/A" ]] && \
            info_lines+=("$(printf "${C_LABEL}Region${C_RESET}    ${C_TEAL}%s${C_RESET}" "$CLOUD_REGION")")
    fi

    # ── LOAD / PROCESSES ──
    info_lines+=("$(printf "${C_LABEL}Load${C_RESET}      ${C_ORANGE}%s${C_RESET}" "$LOAD_AVG")")
    info_lines+=("$(printf "${C_LABEL}Processes${C_RESET} ${C_TEAL}%s${C_RESET}" "$PROCS_RUNNING running / $PROCS_TOTAL total")")

    # Boot time
    info_lines+=("$(printf "${C_DIM}Boot: %s${C_RESET}" "$BOOT_TIME")")

    # ── Render side by side (ASCII left, info right) ──
    #
    # Strip ANSI escape codes and count display columns (not bytes!)
    # Uses python3 if available, falls back to wc -m (characters)
    visible_len() {
        local s="$1"
        if has_cmd python3; then
            # Python handles ANSI stripping + Unicode display width correctly
            python3 -c "
import sys, re
s = sys.argv[1]
s = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s)
# Approximate: box-drawing chars = 1 col, CJK = 2 col, rest = 1 col
total = 0
for ch in s:
    cp = ord(ch)
    if cp > 0xFFFF: total += 2      # surrogate pair
    elif (0x1100 <= cp <= 0x115F or
          0x2E80 <= cp <= 0x303E or
          0x3040 <= cp <= 0x9FFF or
          0xAC00 <= cp <= 0xD7AF or
          0xF900 <= cp <= 0xFAFF or
          0xFE30 <= cp <= 0xFE4F or
          0xFF01 <= cp <= 0xFF60 or
          0xFFE0 <= cp <= 0xFFE6):
        total += 2
    else:
        total += 1
print(total)" "$s" 2>/dev/null
        else
            # Fallback: count characters (close enough for ASCII art)
            echo "$s" | sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' | wc -m | tr -d ' '
        fi
    }

    # Calculate the widest ASCII art line (display columns)
    local max_ascii=0
    for line in "${ascii_lines[@]}"; do
        local vlen
        vlen=$(visible_len "$line")
        (( vlen > max_ascii )) && max_ascii=$vlen
    done
    # Fixed column width: widest ASCII line + 3 char gap
    local col_width=$(( max_ascii + 3 ))
    (( col_width < 33 )) && col_width=33

    local total_info=${#info_lines[@]}
    local total_ascii=${#ascii_lines[@]}
    local max_lines=$((total_info > total_ascii ? total_info : total_ascii))

    echo ""

    for ((i = 0; i < max_lines; i++)); do
        local ascii_part=""
        local info_part=""

        if (( i < total_ascii )); then
            ascii_part="${ascii_lines[$i]}"
        fi

        if (( i < total_info )); then
            info_part="${info_lines[$i]}"
        fi

        # Build each line: ASCII art → calculated spaces → info text
        if [[ -n "$ascii_part" ]]; then
            local vlen
            vlen=$(visible_len "$ascii_part")
            local spaces=$(( col_width - vlen ))
            (( spaces < 1 )) && spaces=1
            printf '%s%*s%s' "$ascii_part" "$spaces" '' "$info_part"
        else
            # No ASCII art — pad to info column start
            printf '%*s%s' "$col_width" '' "$info_part"
        fi
        echo ""
    done

    # Color blocks at bottom
    if [[ "$SHOW_BLOCKS" == "true" ]]; then
        echo ""
        print_color_blocks
        print_color_blocks_2
    fi

    echo ""
}

# ── RUN ──
main "$@"
