#!/usr/bin/env bash
# ============================================================================
# Technofetch v2.0 — VM-Focused System Info Display
# A powerful neofetch alternative for Ubuntu/Debian VM environments
# Detects hypervisors, containers, cloud metadata, and deep system info
# ============================================================================
set -euo pipefail

# ─── VERSION ────────────────────────────────────────────────────────────────
VERSION="2.0.0"

# ─── COLOR PALETTE ──────────────────────────────────────────────────────────
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_DIM=$'\033[2m'
C_UNDERLINE=$'\033[4m'

# Neofetch-style colors
C_RED=$'\033[1;31m'
C_GREEN=$'\033[1;32m'
C_YELLOW=$'\033[1;33m'
C_BLUE=$'\033[1;34m'
C_MAGENTA=$'\033[1;35m'
C_CYAN=$'\033[1;36m'
C_WHITE=$'\033[1;37m'
C_GRAY=$'\033[0;37m'

# Accent colors for labels
LABEL_COLOR="${C_CYAN}"
INFO_COLOR="${C_WHITE}"
SEPARATOR_COLOR="${C_DIM}"
VM_COLOR="${C_MAGENTA}"
DISTRO_COLOR="${C_YELLOW}"

# ─── CONFIGURATION ──────────────────────────────────────────────────────────
SHOW_ASCII=true
ASCII_STYLE="default"   # default, compact, box, minimal
SHOW_COLORS=true
SHOW_BLOCKS=true
COLOR_BLOCK="■ "
ASCII_ART=""

# ─── ASCII ART VARIANTS ────────────────────────────────────────────────────
read_ascii_art() {
    local style="${1:-default}"
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
    │  FETCH  v2   │
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
 ║         FETCH  v2         ║
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
  │         FETCH v2    │
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
                 │          FETCH             │
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

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_NAME="${PRETTY_NAME:-${NAME} ${VERSION}}"
        DISTRO_VERSION="${VERSION_ID:-}"
        DISTRO_CODENAME="${VERSION_CODENAME:-}"
    elif [[ -f /etc/lsb-release ]]; then
        # shellcheck disable=SC1091
        source /etc/lsb-release
        DISTRO_NAME="${DISTRIB_DESCRIPTION:-$DISTRIB_ID $DISTRIB_RELEASE}"
        DISTRO_VERSION="${DISTRIB_RELEASE:-}"
        DISTRO_CODENAME="${DISTRIB_CODENAME:-}"
    fi

    # Detect Debian derivative chain
    if [[ -f /etc/debian_version ]]; then
        DISTRO_FAMILY="Debian"
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

    # ── systemd-detect-virt (most reliable on modern systems)
    if has_cmd systemd-detect-virt; then
        local virt_type
        virt_type=$(systemd-detect-virt 2>/dev/null || true)
        if [[ -n "$virt_type" && "$virt_type" != "none" ]]; then
            IS_VM="true"
            VM_HYPERVISOR="$virt_type"
        fi
    fi

    # ── DMI / SMBIOS data (works even without tools)
    local dmi_vendor dmi_product dmi_family dmi_serial
    dmi_vendor=$(cat /sys/devices/virtual/dmi/id/sys_vendor 2>/dev/null || cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo "")
    dmi_product=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null || cat /sys/class/dmi/id/product_name 2>/dev/null || echo "")
    dmi_family=$(cat /sys/devices/virtual/dmi/id/product_family 2>/dev/null || echo "")
    dmi_serial=$(cat /sys/devices/virtual/dmi/id/product_serial 2>/dev/null || echo "")
    VM_MANUFACTURER="$dmi_vendor"
    VM_PRODUCT="$dmi_product"
    VM_NAME="$dmi_family"
    VM_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid 2>/dev/null || echo "Protected")

    # ── Detect specific hypervisors from DMI
    local dmi_lower
    dmi_lower=$(echo "${dmi_vendor}${dmi_product}${dmi_family}" | tr '[:upper:]' '[:lower:]')

    if [[ "$IS_VM" == "false" ]]; then
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
        fi
    fi

    # ── Check /proc/cpuinfo flags for hypervisor presence
    if [[ "$IS_VM" == "false" && -r /proc/cpuinfo ]]; then
        if grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
            IS_VM="true"
            VM_HYPERVISOR="Unknown Hypervisor"
        fi
    fi

    # ── Detect CPU virtualization features
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

    # ── Container detection
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

    # ── Cloud provider detection
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

print_color_blocks() {
    local blocks=()
    blocks+=($'\033[40m')   # Black
    blocks+=($'\033[41m')   # Red
    blocks+=($'\033[42m')   # Green
    blocks+=($'\033[43m')   # Yellow
    blocks+=($'\033[44m')   # Blue
    blocks+=($'\033[45m')   # Magenta
    blocks+=($'\033[46m')   # Cyan
    blocks+=($'\033[47m')   # White

    printf "  "
    for block in "${blocks[@]}"; do
        printf '%s   %s' "$block" "$C_RESET"
    done
    echo ""
}

print_color_blocks_2() {
    local blocks=()
    blocks+=($'\033[100m')  # Bright Black
    blocks+=($'\033[101m')  # Bright Red
    blocks+=($'\033[102m')  # Bright Green
    blocks+=($'\033[103m')  # Bright Yellow
    blocks+=($'\033[104m')  # Bright Blue
    blocks+=($'\033[105m')  # Bright Magenta
    blocks+=($'\033[106m')  # Bright Cyan
    blocks+=($'\033[107m')  # Bright White

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
        done < <(read_ascii_art "$ASCII_STYLE")
    fi

    # ── Build info lines into array ──
    local info_lines=()

    # Header / System
    info_lines+=("$(printf "${DISTRO_COLOR}${C_BOLD}%s${C_RESET}" "$DISTRO_NAME")")

    # VM status line
    if [[ "$IS_VM" == "true" ]]; then
        info_lines+=("$(printf "${VM_COLOR}${C_BOLD}⚡ VM: %s${C_RESET}" "$VM_HYPERVISOR")")
    else
        info_lines+=("$(printf "${C_GREEN}⬥ Bare Metal${C_RESET}")")
    fi

    if [[ "$IS_CONTAINER" == "true" ]]; then
        info_lines+=("$(printf "${C_CYAN}📦 Container: %s${C_RESET}" "$CONTAINER_TYPE")")
    fi

    info_lines+=("")

    # Kernel
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Kernel" "$KERNEL_RELEASE ($KERNEL_ARCH)")")
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "OS" "$DISTRO_NAME")")
    if [[ -n "$DISTRO_CODENAME" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Codename" "$DISTRO_CODENAME")")
    fi

    # Host / VM
    if [[ "$IS_VM" == "true" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} ${VM_COLOR}%s${C_RESET}" "Hypervisor" "$VM_HYPERVISOR")")
        [[ -n "$VM_MANUFACTURER" && "$VM_MANUFACTURER" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Host/Brand" "$VM_MANUFACTURER $VM_PRODUCT")")
        [[ -n "$VM_NAME" && "$VM_NAME" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "VM Name" "$VM_NAME")")
        if [[ -n "$VIRT_FLAGS" ]]; then
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Virt Features" "$VIRT_FLAGS")")
        fi
    else
        local hw_vendor hw_product
        hw_vendor=$(read_sysfs "/sys/devices/virtual/dmi/id/board_vendor" "")
        hw_product=$(read_sysfs "/sys/devices/virtual/dmi/id/board_name" "")
        [[ -n "$hw_vendor" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Motherboard" "$hw_vendor $hw_product")")
    fi

    info_lines+=("")

    # CPU
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "CPU" "$CPU_MODEL")")
    local cpu_desc="${CPU_CORES_PHYSICAL}C / ${CPU_CORES_LOGICAL}T"
    [[ "$CPU_SOCKETS" -gt 1 ]] && cpu_desc="${CPU_SOCKETS} sockets, ${cpu_desc}"
    [[ "$CPU_MHZ" != "N/A" ]] && cpu_desc="${cpu_desc} @ ${CPU_MHZ} MHz"
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "CPU Config" "$cpu_desc")")
    [[ -n "$CPU_VIRT" ]] && \
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Virt Capable" "$CPU_VIRT")")
    [[ "$CPU_CACHE" != "N/A" ]] && \
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Cache" "$CPU_CACHE")")

    info_lines+=("")

    # Memory
    local mem_used_h mem_total_h mem_pct_str
    mem_total_h=$(awk "BEGIN {printf \"%.1f\", ${MEM_TOTAL}/1048576}")
    mem_used_h=$(awk "BEGIN {printf \"%.1f\", ${MEM_USED}/1048576}")
    mem_pct_str="${MEM_PERCENT}%"
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s ${C_DIM}│${C_RESET} %s / %s MiB" "Memory" "${mem_pct_str}" "$mem_used_h" "$mem_total_h")")

    # Memory bar
    local bar_len=20
    local filled
    filled=$(awk "BEGIN {printf \"%d\", (${MEM_PERCENT}/100)*${bar_len}}")
    local bar=""
    for ((i=0; i<bar_len; i++)); do
        if ((i < filled)); then
            if ((filled * 100 / bar_len > 80)); then
                bar="${bar}${C_RED}█${C_RESET}"
            elif ((filled * 100 / bar_len > 60)); then
                bar="${bar}${C_YELLOW}█${C_RESET}"
            else
                bar="${bar}${C_GREEN}█${C_RESET}"
            fi
        else
            bar="${bar}${C_DIM}░${C_RESET}"
        fi
    done
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET}" "")${bar}")

    if (( SWAP_TOTAL > 0 )); then
        local swap_h
        swap_h=$(awk "BEGIN {printf \"%.1f\", ${SWAP_USED}/1048576}")
        local swap_total_h
        swap_total_h=$(awk "BEGIN {printf \"%.1f\", ${SWAP_TOTAL}/1048576}")
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s / %s MiB" "Swap" "$swap_h" "$swap_total_h")")
    fi

    info_lines+=("")

    # Disk
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s / %s (${DISK_PERCENT}%% used)" "Disk (/)" "$DISK_USED" "$DISK_TOTAL")")
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Filesystem" "${ROOT_FS_TYPE}")")

    if [[ "$IS_VM" == "true" ]]; then
        [[ "$VIRT_DISK_DRIVER" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} ${VM_COLOR}%s${C_RESET}" "Disk Driver" "$VIRT_DISK_DRIVER")")
    fi

    info_lines+=("")

    # Network
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Network" "$PRIMARY_IFACE ($PRIMARY_IP)")")
    if [[ "$PRIMARY_MAC" != "N/A" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "MAC" "$PRIMARY_MAC")")
    fi
    if [[ "$PRIMARY_SPEED" != "N/A" && "$PRIMARY_SPEED" != "-1" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s Mbps" "Link Speed" "$PRIMARY_SPEED")")
    fi
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} ↑ %s  ↓ %s" "Traffic" \
        "$(human_size "$NET_TX_BYTES")" "$(human_size "$NET_RX_BYTES")")")
    if [[ "$DNS_SERVERS" != "N/A" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "DNS" "$DNS_SERVERS")")
    fi

    info_lines+=("")

    # GPU
    if [[ "$GPU_INFO" != "N/A" ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "GPU" "$GPU_INFO")")
        [[ "$GPU_DRIVER" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "GPU Driver" "$GPU_DRIVER")")
    fi

    # Packages
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s packages (%s)" "Packages" "$PKG_COUNT" "$PKG_MANAGER")")

    # Uptime / Load
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Uptime" "$UPTIME_HUMAN")")
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Load Avg" "$LOAD_AVG")")
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Processes" "${PROCS_RUNNING} active / ${PROCS_TOTAL} total")")

    # Security
    info_lines+=("")
    if [[ "$IS_ROOT" == "true" ]]; then
        info_lines+=("$(printf "${C_RED}${C_BOLD}%-14s${C_RESET} ${C_RED}ROOT${C_RESET}" "User")")
    else
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "User" "$(whoami)@$(hostname)")")
    fi
    [[ "$SSH_SESSION" == "true" ]] && \
        info_lines+=("$(printf "${C_GREEN}%-14s${C_RESET} ${C_GREEN}● SSH Session${C_RESET}" "")")
    [[ "$APPARMOR" != "N/A" ]] && \
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "AppArmor" "$APPARMOR")")
    [[ "$FIREWALL" != "N/A" ]] && \
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Firewall" "$FIREWALL")")

    if [[ "$AVAIL_UPDATES" -gt 0 ]]; then
        info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} ${C_YELLOW}%d updates available${C_RESET}" "Updates" "$AVAIL_UPDATES")")
    fi

    # Cloud info (if detected)
    if [[ "$CLOUD_PROVIDER" != "N/A" ]]; then
        info_lines+=("")
        info_lines+=("$(printf "${C_CYAN}${C_BOLD}%-14s${C_RESET} ${C_CYAN}%s${C_RESET}" "☁ Cloud" "$CLOUD_PROVIDER")")
        [[ "$CLOUD_INSTANCE" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Instance" "$CLOUD_INSTANCE")")
        [[ "$CLOUD_INSTANCE_TYPE" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Instance Type" "$CLOUD_INSTANCE_TYPE")")
        [[ "$CLOUD_REGION" != "N/A" ]] && \
            info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} %s" "Region" "$CLOUD_REGION")")
    fi

    # Boot time
    info_lines+=("")
    info_lines+=("$(printf "${LABEL_COLOR}%-14s${C_RESET} ${C_DIM}%s${C_RESET}" "Boot Time" "$BOOT_TIME")")

    # ── Render side by side (ASCII left, info right) ──
    local max_ascii=0
    for line in "${ascii_lines[@]}"; do
        # Strip ANSI for length calculation
        local stripped
        stripped=$(echo "$line" | sed 's/\x1b\[[0-9;]*m//g')
        local len=${#stripped}
        (( len > max_ascii )) && max_ascii=$len
    done

    local total_info=${#info_lines[@]}
    local total_ascii=${#ascii_lines[@]}
    local max_lines=$((total_info > total_ascii ? total_info : total_ascii))

    echo ""

    for ((i = 0; i < max_lines; i++)); do
        local ascii_part=""
        local info_part=""

        # ASCII side
        if (( i < total_ascii )); then
            ascii_part="${ascii_lines[$i]}"
        fi

        # Info side
        if (( i < total_info )); then
            info_part="${info_lines[$i]}"
        fi

        if (( i == 0 )); then
            # First line: print ASCII, then info right-aligned
            local stripped
            stripped=$(echo "$ascii_part" | sed 's/\x1b\[[0-9;]*m//g')
            local pad=$((max_ascii - ${#stripped} + 3))
            printf "%s%*s%s" "$ascii_part" "$pad" "" "$info_part"
        else
            printf "%s%*s%s" "$ascii_part" $((max_ascii + 3)) "" "$info_part"
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
