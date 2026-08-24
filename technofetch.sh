#!/usr/bin/env bash
# ============================================================================
# Technofetch v2.0 — VM-Focused System Info Display
# A powerful neofetch alternative for Ubuntu/Debian/Proxmox VM environments
# Detects hypervisors, containers, cloud metadata, and deep system info
# ============================================================================
set -u

VERSION="2.0.0"

# ─── COLORS (Blue + White theme) ────────────────────────────────────────────
RST=$'\033[0m'
BLD=$'\033[1m'
DIM=$'\033[2m'
BLU=$'\033[38;5;39m'
WHT=$'\033[38;5;231m'

# ─── CONFIGURATION ──────────────────────────────────────────────────────────
SHOW_ASCII=true
ASCII_STYLE="default"
SHOW_BLOCKS=true
FORCE_LOGO=""
DEBUG_MODE=false

# ─── UTILITY ────────────────────────────────────────────────────────────────
has_cmd() { command -v "$1" &>/dev/null; }

safe_cmd() {
    local result
    result=$("$1" 2>/dev/null) && echo "$result" || echo "${2:-N/A}"
}

read_sysfs() {
    [[ -r "$1" ]] && cat "$1" 2>/dev/null || echo "${2:-N/A}"
}

human_duration() {
    local s=${1:-0}
    local d=$((s/86400)) h=$(((s%86400)/3600)) m=$(((s%3600)/60))
    ((d>0)) && printf "%dd %dh %dm" "$d" "$h" "$m" && return
    ((h>0)) && printf "%dh %dm" "$h" "$m" && return
    printf "%dm" "$m"
}

# ─── ASCII ART (Real neofetch logos) ────────────────────────────────────────
read_ascii_art() {
    local style="${1:-default}"
    local did="${2:-unknown}"

    local c1="$BLU"
    local c2="$WHT"
    local r="$RST"

    # ── Ubuntu ──
    if [[ "$did" == "ubuntu" ]]; then
        case "$style" in
            compact|small)
                cat << 'EOF'
         _ 
     ---(_)
 _/  ---  \
(_) |   |
  \  --- _/
     ---(_)
EOF
                ;;
            box)
                cat << EOF
 ╔════════════════════════════════════════════════════════════╗
 ║                                                            ║
 ║              ${c1}        .-/+oossssoo+/-.${r}                   ║
 ║              ${c1}    \`\:+ssssssssssssssssss+:\`${r}               ║
 ║              ${c1}  -+ssssssssssssssssssyyssss+-${r}             ║
 ║              ${c1}.ossssssssssssssssss${c2}dMMMNy${c1}sssso.${r}            ║
 ║              ${c1}/sssssssssss${c2}hdmmNNmmyNMMMMh${c1}ssssss\\${r}           ║
 ║              ${c1}+sssssssss${c2}hm${c1}yd${c2}MMMMMMMNddddy${c1}ssssssss+${r}       ║
 ║              ${c1}/ssssssss${c2}hNMMM${c1}yh${c2}hyyyyhmNMMMNh${c1}ssssssss\\${r}     ║
 ║              ${c1}.ssssssss${c2}dMMMNh${c1}ssssssssss${c2}hNMMMd${c1}ssssssss.${r}    ║
 ║              ${c1}+ssss${c2}hhhyNMMNy${c1}ssssssssssss${c2}yNMMMy${c1}sssssss+${r}   ║
 ║              ${c1}oss${c2}yNMMMNyMMh${c1}ssssssssssssss${c2}hmmmh${c1}ssssssso${r}   ║
 ║              ${c1}+ssss${c2}hhhyNMMNy${c1}ssssssssssss${c2}yNMMMy${c1}sssssss+${r}   ║
 ║              ${c1}.ssssssss${c2}dMMMNh${c1}ssssssssss${c2}hNMMMd${c1}ssssssss.${r}    ║
 ║              ${c1} \\ssssssss${c2}hNMMM${c1}yh${c2}hyyyyhdNMMMNh${c1}ssssssss/${r}     ║
 ║              ${c1}  +sssssssss${c2}dm${c1}yd${c2}MMMMMMMMddddy${c1}ssssssss+${r}       ║
 ║              ${c1}   \\sssssssssss${c2}hdmNNNNmyNMMMMh${c1}ssssss/${r}          ║
 ║              ${c1}    .ossssssssssssssssss${c2}dMMMNy${c1}sssso.${r}            ║
 ║              ${c1}      -+sssssssssssssssss${c2}yyy${c1}ssss+-${r}             ║
 ║              ${c1}        \`\:+ssssssssssssssssss+:\`${r}               ║
 ║              ${c1}            .-\\+oossssoo+/-.${r}                   ║
 ║                                                            ║
 ╚════════════════════════════════════════════════════════════╝
EOF
                ;;
            minimal)
                cat << EOF
  ┌─ UBUNTU ────────────────────────────────────────────┐
  │  ${c1}        .-/+oossssoo+/-.${r}                          │
  │  ${c1}    \`\:+ssssssssssssssssss+:\`${r}                     │
  │  ${c1}  -+ssssssssssssssssssyyssss+-${r}                   │
  │  ${c1}.ossssssssssssssssss${c2}dMMMNy${c1}sssso.${r}                  │
  │  ${c1}/sssssssssss${c2}hdmmNNmmyNMMMMh${c1}ssssss\\${r}                 │
  │  ${c1}+sssssssss${c2}hm${c1}yd${c2}MMMMMMMNddddy${c1}ssssssss+${r}             │
  │  ${c1}/ssssssss${c2}hNMMM${c1}yh${c2}hyyyyhmNMMMNh${c1}ssssssss\\${r}           │
  │  ${c1}.ssssssss${c2}dMMMNh${c1}ssssssssss${c2}hNMMMd${c1}ssssssss.${r}          │
  │  ${c1}+ssss${c2}hhhyNMMNy${c1}ssssssssssss${c2}yNMMMy${c1}sssssss+${r}         │
  │  ${c1}oss${c2}yNMMMNyMMh${c1}ssssssssssssss${c2}hmmmh${c1}ssssssso${r}         │
  └──────────────────────────────────────────────────────┘
EOF
                ;;
            *)
                cat << EOF

  ${c1}        .-/+oossssoo+/-.${r}
  ${c1}    \`\:+ssssssssssssssssss+:\`${r}
  ${c1}  -+ssssssssssssssssssyyssss+-${r}
  ${c1}.ossssssssssssssssss${c2}dMMMNy${c1}sssso.${r}
  ${c1}/sssssssssss${c2}hdmmNNmmyNMMMMh${c1}ssssss\\${r}
  ${c1}+sssssssss${c2}hm${c1}yd${c2}MMMMMMMNddddy${c1}ssssssss+${r}
  ${c1}/ssssssss${c2}hNMMM${c1}yh${c2}hyyyyhmNMMMNh${c1}ssssssss\\${r}
  ${c1}.ssssssss${c2}dMMMNh${c1}ssssssssss${c2}hNMMMd${c1}ssssssss.${r}
  ${c1}+ssss${c2}hhhyNMMNy${c1}ssssssssssss${c2}yNMMMy${c1}sssssss+${r}
  ${c1}oss${c2}yNMMMNyMMh${c1}ssssssssssssss${c2}hmmmh${c1}ssssssso${r}
  ${c1}oss${c2}yNMMMNyMMh${c1}sssssssssssshmmmmh${c1}ssssssso${r}
  ${c1}+ssss${c2}hhhyNMMNy${c1}ssssssssssss${c2}yNMMMy${c1}sssssss+${r}
  ${c1}.ssssssss${c2}dMMMNh${c1}ssssssssss${c2}hNMMMd${c1}ssssssss.${r}
  ${c1} \\ssssssss${c2}hNMMM${c1}yh${c2}hyyyyhdNMMMNh${c1}ssssssss/${r}
  ${c1}  +sssssssss${c2}dm${c1}yd${c2}MMMMMMMMddddy${c1}ssssssss+${r}
  ${c1}   \\sssssssssss${c2}hdmNNNNmyNMMMMh${c1}ssssss/${r}
  ${c1}    .ossssssssssssssssss${c2}dMMMNy${c1}sssso.${r}
  ${c1}      -+ssssssssssssssss${c2}yyy${c1}ssss+-${r}
  ${c1}        \`\:+ssssssssssssssssss+:\`${r}
  ${c1}            .-\\+oossssoo+/-.${r}
EOF
                ;;
        esac
        return
    fi

    # ── Debian ──
    if [[ "$did" == "debian" ]]; then
        case "$style" in
            compact|small)
                cat << EOF
${c2}       _,met\$\$\$\$gg.${r}
${c2}    ,g\$\$\$\$\$\$\$\$\$\$\$P.${r}
${c2}  ,g\$\$P"        ""Y\$\$.".${r}
${c2} ,\$\$P'              \`\$\$\$.${r}
${c2}',\$\$P       ,ggs.     \`\$\$b:${r}
${c2}\`d\$\$'     ,\$\$P'   ${c1}.${c2}    \$\$\$${r}
${c2} \$\$\$P      d\$\$'     ${c1},${c2}    \$\$\$P${r}
${c2} \$\$\$:      \$\$.   ${c1}-${c2}    ,d\$\$'${r}
${c2} \$\$\$;      Y\$\$b._   _,d\$\$P'${r}
${c2} Y\$\$\$.    ${c1}\`.${c2}.\`"Y\$\$\$P"'${r}
${c2} \`\$\$\$b      ${c1}"-.__${r}
${c2}  \`Y\$\$\$${r}
${c2}   \`Y\$\$\$.${r}
${c2}     \`\$\$b.${r}
${c2}       \`Y\$\$b.${r}
${c2}          \`"Y\$\$b._${r}
${c2}              \`"""\`${r}
EOF
                ;;
            *)
                cat << EOF

${c2}       _,met\$\$\$\$gg.${r}
${c2}    ,g\$\$\$\$\$\$\$\$\$\$\$P.${r}
${c2}  ,g\$\$P"        ""Y\$\$.".${r}
${c2} ,\$\$P'              \`\$\$\$.${r}
${c2}',\$\$P       ,ggs.     \`\$\$b:${r}
${c2}\`d\$\$'     ,\$\$P'   ${c1}.${c2}    \$\$\$${r}
${c2} \$\$\$P      d\$\$'     ${c1},${c2}    \$\$\$P${r}
${c2} \$\$\$:      \$\$.   ${c1}-${c2}    ,d\$\$'${r}
${c2} \$\$\$;      Y\$\$b._   _,d\$\$P'${r}
${c2} Y\$\$\$.    ${c1}\`.${c2}.\`"Y\$\$\$P"'${r}
${c2} \`\$\$\$b      ${c1}"-.__${r}
${c2}  \`Y\$\$\$${r}
${c2}   \`Y\$\$\$.${r}
${c2}     \`\$\$b.${r}
${c2}       \`Y\$\$b.${r}
${c2}          \`"Y\$\$b._${r}
${c2}              \`"""\`${r}
EOF
                ;;
        esac
        return
    fi

    # ── Proxmox VE ──
    if [[ "$did" == "proxmox" || "$did" == "proxmox-ve" ]]; then
        case "$style" in
            compact|small)
                cat << 'EOF'
    ___
   /   \
  / /| | \
 / / | |  \
/_/  | |___\
  |  |
  |__|
EOF
                ;;
            *)
                cat << EOF

${c1}           .://:\`              \`:://:${r}
${c1}         \`hMMMMMMd/          /dMMMMMMh\`${r}
${c1}          \`sMMMMMMMd:      :mMMMMMMMs\`${r}
${c2}\`-/+oo+/:${c1}\`.yMMMMMMMh-  -hMMMMMMMy.\`${c2}:/+oo+/-\`${r}
${c2}\`:oooooooo/${c1}\`-hMMMMMMMyyMMMMMMMh-\`${c2}/oooooooo:\`${r}
${c2}  \`/oooooooo:${c1}\`:mMMMMMMMMMMMMm:\`${c2}:oooooooo/\`${r}
${c2}    ./ooooooo+-${c1} +NMMMMMMMMN+ ${c2}-+ooooooo/.${r}
${c2}      .+ooooooo+-${c1}\`oNMMMMNo\`${c2}-+ooooooo+.${r}
${c2}        -+ooooooo/.${c1}\`sMMs\`${c2}./ooooooo+-${r}
${c2}          :oooooooo/${c1}\`..\`${c2}/oooooooo:${r}
${c2}        -+ooooooo/.${c1}\`sMMs\`${c2}./ooooooo+-${r}
${c2}      .+ooooooo+-${c1}\`oNMMMMNo\`${c2}-+ooooooo+.${r}
${c2}    ./ooooooo+-${c1} +NMMMMMMMMN+ ${c2}-+ooooooo/.${r}
${c2}  \`/oooooooo:${c1}:mMMMMMMMMMMMMm:\`${c2}\`:oooooooo/\`${r}
${c2}\`:oooooooo/${c1}-hMMMMMMMyyMMMMMMMh-\`${c2}\`/oooooooo:\`${r}
${c2}\`-/+oo+/:${c1}\`.yMMMMMMMh-  -hMMMMMMMy.${c2}\`:/+oo+/-\`${r}
${c1}          \`sMMMMMMm:      :dMMMMMMMs\`${r}
${c1}         \`hMMMMMMd/          /dMMMMMMh\`${r}
${c1}           \`://:\`              \`:://:\`${r}
EOF
                ;;
        esac
        return
    fi

    # ── Kali Linux ──
    if [[ "$did" == "kali" ]]; then
        cat << 'EOF'

            .-/+oossssoo+/-.
        `:+ssssssssssssssssss+:`
      -+ssssssssssssssssssyyssss+-
    .ossssssssssssssssssdMMMNysssso.
   /ssssssssssshdmmNNmmyNMMMMhssssss\
  +ssssssssshmhmMMMMMMMNddddyssssssss+
 /sssssssshNMMMyhhhmNMMMNhssssssss\
.sssssssssdMMMNhssssssssssshNMMMdssssss.
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
ossyNMMMNyMMhssssssssssssshmmmhssssssso
+sssshhhyNMMNyssssssssssssyNMMMysssssss+
.sssssssssdMMMNhssssssssssshNMMMdssssss.
 \sssssssshNMMMMyhyyyyhdNMMMNhssssssss/
  +ssssssssdmymMMMMMMMMddddyssssssss+
   \ssssssssssshdmNNNNmyNMMMMhssssss/
    .ossssssssssssssssssdMMMNysssso.
      -+sssssssssssssssssyuuyssss+-
        `:+ssssssssssssssssss+:`
            .-/+oossssoo+/-.
EOF
        return
    fi

    # ── Linux Mint ──
    if [[ "$did" == "linuxmint" || "$did" == "lmde" ]]; then
        cat << 'EOF'

         __
    ____/ /___  __  ______
   / __  / __ \/ / / / _ \
  / /_/ / /_/ / /_/ /  __/
  \__,_/\____/\__,_/\___/
EOF
        return
    fi

    # ── Pop!_OS ──
    if [[ "$did" == "pop" ]]; then
        cat << 'EOF'

         ______
        / ____/___  _________
       / /   / __ \/ ___/ __ \
      / /___/ /_/ / /  / / / /
      \____/\____/_/  /_/ /_/
EOF
        return
    fi

    # ── Default: TECHNO ──
    cat << 'EOF'

   ████████
   ██    ██
   ████████
        ██
   ████████

      TECHNO
     ─ v2.0 ─
EOF
}

# ─── DETECTION: DISTRO ──────────────────────────────────────────────────────
detect_distro() {
    DISTRO_NAME="Unknown Linux"
    DISTRO_VERSION=""
    DISTRO_ID=""

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        DISTRO_NAME="${PRETTY_NAME:-${NAME:-unknown} ${VERSION:-}}"
        DISTRO_VERSION="${VERSION_ID:-}"
        DISTRO_ID="${ID:-}"
    elif [[ -f /etc/lsb-release ]]; then
        # shellcheck disable=SC1091
        source /etc/lsb-release
        DISTRO_NAME="${DISTRIB_DESCRIPTION:-$DISTRIB_ID $DISTRIB_RELEASE}"
        DISTRO_VERSION="${DISTRIB_RELEASE:-}"
        DISTRO_ID="${DISTRIB_ID:-}"
    elif [[ -f /etc/debian_version ]]; then
        DISTRO_NAME="Debian $(cat /etc/debian_version 2>/dev/null)"
        DISTRO_ID="debian"
    fi

    # Re-read ID from /etc/os-release with grep (most reliable)
    if [[ -r /etc/os-release ]]; then
        local line
        line=$(grep '^ID=' /etc/os-release 2>/dev/null | head -1)
        if [[ -n "$line" ]]; then
            DISTRO_ID="${line#ID=}"
            DISTRO_ID="${DISTRO_ID//\"/}"
        fi
        line=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | head -1)
        if [[ -n "$line" ]]; then
            DISTRO_NAME="${line#PRETTY_NAME=}"
            DISTRO_NAME="${DISTRO_NAME//\"/}"
        fi
    fi

    # Fallback: infer from name
    if [[ -z "$DISTRO_ID" ]]; then
        local ln
        ln=$(echo "$DISTRO_NAME" | tr '[:upper:]' '[:lower:]')
        if echo "$ln" | grep -qi "ubuntu"; then DISTRO_ID="ubuntu"
        elif echo "$ln" | grep -qi "debian"; then DISTRO_ID="debian"
        elif echo "$ln" | grep -qi "proxmox"; then DISTRO_ID="proxmox"
        elif echo "$ln" | grep -qi "kali"; then DISTRO_ID="kali"
        elif echo "$ln" | grep -qi "mint"; then DISTRO_ID="linuxmint"
        elif echo "$ln" | grep -qi "pop"; then DISTRO_ID="pop"
        fi
    fi
}

# ─── DETECTION: VM / HYPERVISOR ─────────────────────────────────────────────
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

    # Method 1: systemd-detect-virt
    if has_cmd systemd-detect-virt; then
        local vt
        vt=$(systemd-detect-virt 2>/dev/null || true)
        if [[ -n "$vt" && "$vt" != "none" ]]; then
            IS_VM="true"
            VM_HYPERVISOR="$vt"
        fi
    fi

    # Method 2: DMI / sysfs
    local dmi_vendor="" dmi_product="" dmi_family=""
    for p in /sys/devices/virtual/dmi/id /sys/class/dmi/id; do
        if [[ -d "$p" ]]; then
            [[ -z "$dmi_vendor" ]] && dmi_vendor=$(cat "${p}/sys_vendor" 2>/dev/null || echo "")
            [[ -z "$dmi_product" ]] && dmi_product=$(cat "${p}/product_name" 2>/dev/null || echo "")
            [[ -z "$dmi_family" ]] && dmi_family=$(cat "${p}/product_family" 2>/dev/null || echo "")
            [[ -z "$VM_UUID" || "$VM_UUID" == "Protected" ]] && VM_UUID=$(cat "${p}/product_uuid" 2>/dev/null || echo "Protected")
        fi
    done
    VM_MANUFACTURER="$dmi_vendor"
    VM_PRODUCT="$dmi_product"
    VM_NAME="$dmi_family"

    # Method 3: dmidecode
    if has_cmd dmidecode && [[ "$IS_VM" == "false" ]]; then
        local dmi_out
        dmi_out=$(dmidecode -t system 2>/dev/null || echo "")
        if [[ -n "$dmi_out" ]]; then
            [[ -z "$VM_MANUFACTURER" ]] && VM_MANUFACTURER=$(echo "$dmi_out" | grep -i "Manufacturer:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
            [[ -z "$VM_PRODUCT" ]] && VM_PRODUCT=$(echo "$dmi_out" | grep -i "Product Name:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
            [[ -z "$VM_NAME" ]] && VM_NAME=$(echo "$dmi_out" | grep -i "Family:" | head -1 | awk -F: '{print $2}' | xargs || echo "")
        fi
    fi

    # Method 4: lscpu
    if has_cmd lscpu && [[ "$IS_VM" == "false" ]]; then
        local lh
        lh=$(lscpu 2>/dev/null | grep -i "Hypervisor:" | awk -F: '{print $2}' | xargs || echo "")
        if [[ -n "$lh" ]]; then IS_VM="true"; VM_HYPERVISOR="$lh"; fi
    fi

    # Method 5: DMI string matching
    local dmi_lower
    dmi_lower=$(echo "${dmi_vendor}${dmi_product}${dmi_family}" | tr '[:upper:]' '[:lower:]')
    if [[ "$IS_VM" == "false" && -n "$dmi_lower" ]]; then
        if echo "$dmi_lower" | grep -qi "vmware"; then IS_VM="true"; VM_HYPERVISOR="VMware"
        elif echo "$dmi_lower" | grep -qi "virtualbox\|vbox"; then IS_VM="true"; VM_HYPERVISOR="VirtualBox"
        elif echo "$dmi_lower" | grep -qi "kvm\|qemu"; then IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$dmi_lower" | grep -qi "xen"; then IS_VM="true"; VM_HYPERVISOR="Xen"
        elif echo "$dmi_lower" | grep -qi "microsoft"; then IS_VM="true"; VM_HYPERVISOR="Hyper-V"
        elif echo "$dmi_lower" | grep -qi "parallels"; then IS_VM="true"; VM_HYPERVISOR="Parallels"
        elif echo "$dmi_lower" | grep -qi "oracle\|virtual machine"; then IS_VM="true"; VM_HYPERVISOR="VirtualBox"
        elif echo "$dmi_lower" | grep -qi "digitalocean"; then IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$dmi_lower" | grep -qi "amazon"; then IS_VM="true"; VM_HYPERVISOR="KVM (Nitro)"
        elif echo "$dmi_lower" | grep -qi "google"; then IS_VM="true"; VM_HYPERVISOR="KVM (Google)"
        elif echo "$dmi_lower" | grep -qi "openstack"; then IS_VM="true"; VM_HYPERVISOR="KVM (OpenStack)"
        elif echo "$dmi_lower" | grep -qi "cloud"; then IS_VM="true"; VM_HYPERVISOR="Cloud VM"
        elif echo "$dmi_lower" | grep -qi "proxmox"; then IS_VM="true"; VM_HYPERVISOR="Proxmox (KVM)"
        fi
    fi

    # Method 5b: Proxmox host detection
    if [[ "$IS_VM" == "false" ]] || [[ "$VM_HYPERVISOR" == "KVM/QEMU" ]]; then
        local is_pve="false"
        has_cmd pveversion && is_pve="true"
        has_cmd pvesh && is_pve="true"
        [[ -d /etc/pve ]] && is_pve="true"
        uname -r 2>/dev/null | grep -qi "pve" && is_pve="true"
        [[ -r /etc/os-release ]] && grep -qi "proxmox" /etc/os-release 2>/dev/null && is_pve="true"
        if [[ "$is_pve" == "true" ]]; then
            IS_VM="false"
            VM_HYPERVISOR="Proxmox VE"
            if has_cmd pveversion; then
                VM_PRODUCT=$(pveversion 2>/dev/null | grep -oP 'pve-manager/\K[^/]+' || echo "")
                [[ -n "$VM_PRODUCT" ]] && VM_PRODUCT="PVE $VM_PRODUCT"
            fi
        fi
    fi

    # Method 6: /proc/cpuinfo hypervisor flag
    if [[ "$IS_VM" == "false" && -r /proc/cpuinfo ]]; then
        if grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
            IS_VM="true"
            local cm
            cm=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | awk -F: '{print tolower($2)}' || echo "")
            if echo "$cm" | grep -qi "qemu"; then VM_HYPERVISOR="KVM/QEMU"
            elif echo "$cm" | grep -qi "vmware"; then VM_HYPERVISOR="VMware"
            elif echo "$cm" | grep -qi "virtualbox"; then VM_HYPERVISOR="VirtualBox"
            else VM_HYPERVISOR="Hypervisor"
            fi
        fi
    fi

    # Method 7: /proc/version
    if [[ "$IS_VM" == "false" && -r /proc/version ]]; then
        local pv
        pv=$(cat /proc/version 2>/dev/null | tr '[:upper:]' '[:lower:]')
        if echo "$pv" | grep -qi "microsoft"; then IS_VM="true"; VM_HYPERVISOR="Hyper-V (WSL)"
        elif echo "$pv" | grep -qi "vmware"; then IS_VM="true"; VM_HYPERVISOR="VMware"
        fi
    fi

    # Method 8: /sys/hypervisor/type
    if [[ "$IS_VM" == "false" && -r /sys/hypervisor/type ]]; then
        local ht
        ht=$(cat /sys/hypervisor/type 2>/dev/null || echo "")
        if [[ -n "$ht" ]]; then IS_VM="true"; VM_HYPERVISOR=$(echo "$ht" | tr '[:upper:]' '[:lower:]'); fi
    fi

    # Method 9: /proc/xen
    [[ "$IS_VM" == "false" && -d /proc/xen ]] && IS_VM="true" && VM_HYPERVISOR="Xen"

    # Method 10: Virtio devices
    if [[ "$IS_VM" == "false" && -d /sys/bus/virtio ]]; then
        local vc
        vc=$(ls /sys/bus/virtio/devices/ 2>/dev/null | wc -l || echo "0")
        ((vc > 0)) && IS_VM="true" && VM_HYPERVISOR="KVM/QEMU (virtio)"
    fi

    # Method 11: Cloud-init
    if [[ "$IS_VM" == "false" ]]; then
        [[ -f /run/cloud-init/instance-data.json ]] || [[ -f /var/lib/cloud/instance/instance-id ]] && IS_VM="true" && VM_HYPERVISOR="Cloud VM"
    fi

    # Method 12: Guest tools
    if [[ "$IS_VM" == "false" ]]; then
        has_cmd vmware-toolbox-cmd && IS_VM="true" && VM_HYPERVISOR="VMware"
        has_cmd VBoxClient && IS_VM="true" && VM_HYPERVISOR="VirtualBox"
    fi

    # Method 13: DMI all files scan
    if [[ "$IS_VM" == "false" && -d /sys/devices/virtual/dmi/id ]]; then
        local da
        da=$(cat /sys/devices/virtual/dmi/id/* 2>/dev/null | tr '[:upper:]' '[:lower:]' || echo "")
        if echo "$da" | grep -qi "kvm\|qemu"; then IS_VM="true"; VM_HYPERVISOR="KVM/QEMU"
        elif echo "$da" | grep -qi "vmware"; then IS_VM="true"; VM_HYPERVISOR="VMware"
        elif echo "$da" | grep -qi "nitro"; then IS_VM="true"; VM_HYPERVISOR="KVM (AWS Nitro)"
        elif echo "$da" | grep -qi "openstack"; then IS_VM="true"; VM_HYPERVISOR="KVM (OpenStack)"
        fi
    fi

    # Method 14: systemd container
    if [[ "$IS_VM" == "false" && -f /run/systemd/container ]]; then
        IS_CONTAINER="true"
        CONTAINER_TYPE=$(cat /run/systemd/container 2>/dev/null || echo "OCI")
    fi

    # Container detection
    [[ -f /.dockerenv ]] && IS_CONTAINER="true" && CONTAINER_TYPE="Docker"
    grep -qE 'container=lxc' /proc/1/environ 2>/dev/null && IS_CONTAINER="true" && CONTAINER_TYPE="LXC/LXD"

    # Cloud detection
    detect_cloud
}

detect_cloud() {
    CLOUD_PROVIDER="N/A"
    CLOUD_INSTANCE="N/A"
    CLOUD_REGION="N/A"
    CLOUD_INSTANCE_TYPE="N/A"

    has_cmd curl || return

    # AWS
    if curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/latest/meta-data/instance-id" &>/dev/null; then
        CLOUD_PROVIDER="AWS"
        CLOUD_INSTANCE=$(curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/latest/meta-data/instance-id" 2>/dev/null || echo "N/A")
        CLOUD_INSTANCE_TYPE=$(curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/latest/meta-data/instance-type" 2>/dev/null || echo "N/A")
        CLOUD_REGION=$(curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/latest/meta-data/placement/availability-zone" 2>/dev/null || echo "N/A")
        return
    fi

    # GCP
    if curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name" &>/dev/null; then
        CLOUD_PROVIDER="GCP"
        CLOUD_INSTANCE=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/name" 2>/dev/null || echo "N/A")
        CLOUD_INSTANCE_TYPE=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/machine-type" 2>/dev/null | sed 's|.*/||' || echo "N/A")
        CLOUD_REGION=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/zone" 2>/dev/null | sed 's|.*/||' || echo "N/A")
        return
    fi

    # Azure
    if curl -sf --connect-timeout 1 --max-time 2 -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" &>/dev/null; then
        CLOUD_PROVIDER="Azure"
        local ad
        ad=$(curl -sf --connect-timeout 1 --max-time 2 -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01" 2>/dev/null || echo "{}")
        CLOUD_INSTANCE=$(echo "$ad" | python3 -c "import sys,json; print(json.load(sys.stdin).get('compute',{}).get('name','N/A'))" 2>/dev/null || echo "N/A")
        CLOUD_REGION=$(echo "$ad" | python3 -c "import sys,json; print(json.load(sys.stdin).get('compute',{}).get('location','N/A'))" 2>/dev/null || echo "N/A")
        CLOUD_INSTANCE_TYPE=$(echo "$ad" | python3 -c "import sys,json; print(json.load(sys.stdin).get('compute',{}).get('vmSize','N/A'))" 2>/dev/null || echo "N/A")
        return
    fi

    [[ -r /etc/digitalocean ]] && CLOUD_PROVIDER="DigitalOcean" && return
    [[ -r /etc/linode ]] && CLOUD_PROVIDER="Linode" && return

    if curl -sf --connect-timeout 1 --max-time 2 "http://169.254.169.254/hetzner/v1/metadata" &>/dev/null; then
        CLOUD_PROVIDER="Hetzner" && return
    fi
}

# ─── SYSTEM INFO GATHERING ──────────────────────────────────────────────────

get_cpu_info() {
    CPU_MODEL="N/A"
    CPU_CORES_LOGICAL=0
    CPU_MHZ="N/A"
    CPU_CACHE="N/A"

    if [[ -r /proc/cpuinfo ]]; then
        CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2 | xargs || echo "N/A")
        CPU_CORES_LOGICAL=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "0")
        CPU_MHZ=$(grep -m1 "cpu MHz" /proc/cpuinfo 2>/dev/null | awk -F: '{printf "%.0f", $2}' | xargs || echo "N/A")
        CPU_CACHE=$(grep -m1 "cache size" /proc/cpuinfo 2>/dev/null | awk -F: '{print $2}' | xargs || echo "N/A")
    fi
}

get_memory_info() {
    MEM_TOTAL=0; MEM_USED=0; MEM_PERCENT="0"
    if [[ -r /proc/meminfo ]]; then
        local mt mf mb mc ma sf
        mt=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
        mf=$(awk '/^MemFree:/ {print $2}' /proc/meminfo)
        mb=$(awk '/^Buffers:/ {print $2}' /proc/meminfo)
        mc=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
        ma=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
        MEM_TOTAL=$mt
        MEM_USED=$((mt - mf - mb - mc))
        [[ "$MEM_USED" -lt 0 ]] && MEM_USED=$((mt - ma))
        (( mt > 0 )) && MEM_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED/$mt)*100}")
    fi
}

get_disk_info() {
    DISK_TOTAL="0"; DISK_USED="0"; DISK_PERCENT="0"
    if has_cmd df; then
        local df_out
        df_out=$(df -h --output=size,used,pcent / 2>/dev/null | tail -1)
        DISK_TOTAL=$(echo "$df_out" | awk '{print $1}')
        DISK_USED=$(echo "$df_out" | awk '{print $2}')
        DISK_PERCENT=$(echo "$df_out" | awk '{print $3}' | tr -d '%')
    fi
}

get_network_info() {
    PRIMARY_IFACE="N/A"
    PRIMARY_IP="N/A"
    PRIMARY_MAC="N/A"

    PRIMARY_IFACE=$(ip route 2>/dev/null | grep default | head -1 | awk '{print $5}' || echo "")
    [[ -z "$PRIMARY_IFACE" ]] && PRIMARY_IFACE="N/A"
    if [[ "$PRIMARY_IFACE" != "N/A" ]]; then
        PRIMARY_IP=$(ip -4 addr show "$PRIMARY_IFACE" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1 || echo "N/A")
        PRIMARY_MAC=$(ip link show "$PRIMARY_IFACE" 2>/dev/null | grep -oP 'link/ether \K[\da-f:]+' | head -1 || echo "N/A")
    fi
}

get_gpu_info() {
    GPU_INFO="N/A"
    if has_cmd lspci; then
        local gl
        gl=$(lspci 2>/dev/null | grep -iE "vga|3d|display" | head -1 || echo "")
        [[ -n "$gl" ]] && GPU_INFO=$(echo "$gl" | sed 's/^[0-9]*:[0-9]*.[0-9]* //' || echo "N/A")
    fi
}

get_uptime_load() {
    UPTIME_HUMAN="N/A"
    LOAD_AVG="N/A"
    PROCS_RUNNING=0; PROCS_TOTAL=0; BOOT_TIME="N/A"

    if [[ -r /proc/uptime ]]; then
        UPTIME_HUMAN=$(human_duration "$(awk '{print int($1)}' /proc/uptime)")
    fi
    LOAD_AVG=$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null || echo "N/A")
    PROCS_RUNNING=$(awk '{print $4}' /proc/loadavg 2>/dev/null | cut -d/ -f1 || echo "0")
    PROCS_TOTAL=$(awk '{print $4}' /proc/loadavg 2>/dev/null | cut -d/ -f2 || echo "0")
    BOOT_TIME=$(uptime -s 2>/dev/null || echo "N/A")
}

get_packages() {
    PKG_COUNT=0
    if has_cmd dpkg-query; then
        PKG_COUNT=$(dpkg-query -f '.' -W 2>/dev/null | wc -c)
    fi
    SNAP_COUNT=0
    if has_cmd snap; then
        SNAP_COUNT=$(snap list 2>/dev/null | tail -n +2 | wc -l || echo "0")
    fi
}

get_security_info() {
    IS_ROOT="false"
    SSH_SESSION="false"
    APPARMOR="N/A"
    [[ $EUID -eq 0 ]] && IS_ROOT="true"
    [[ -n "${SSH_CLIENT:-}" ]] && SSH_SESSION="true"
    if [[ -r /sys/module/apparmor/parameters/enabled ]]; then
        local aa
        aa=$(read_sysfs "/sys/module/apparmor/parameters/enabled" "N/A")
        [[ "$aa" == "Y" ]] && APPARMOR="Active" || APPARMOR="Inactive"
    fi
}

# ─── COLOR BLOCKS ───────────────────────────────────────────────────────────
print_color_blocks() {
    local b1=(16 235 236 237 39 75 111 231)
    local b2=(17 18 19 20 21 27 63 159)
    printf "  "
    for c in "${b1[@]}"; do printf "\033[48;5;%dm   \033[0m" "$c"; done
    echo ""
    printf "  "
    for c in "${b2[@]}"; do printf "\033[48;5;%dm   \033[0m" "$c"; done
    echo ""
}

# ─── MAIN ───────────────────────────────────────────────────────────────────
main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-ascii)    SHOW_ASCII=false; shift ;;
            --style)       ASCII_STYLE="$2"; shift 2 ;;
            --no-blocks)   SHOW_BLOCKS=false; shift ;;
            --logo)        FORCE_LOGO="$2"; shift 2 ;;
            --debug)       DEBUG_MODE=true; shift ;;
            --version|-v)  echo "Technofetch v${VERSION}"; exit 0 ;;
            --help|-h)
                cat << HELP
Technofetch v${VERSION} — VM-Focused System Info

Usage: technofetch [OPTIONS]

Options:
  --no-ascii      Hide ASCII art
  --style STYLE   Style: default, compact, box, minimal
  --no-blocks     Hide color blocks
  --logo NAME     Force logo: ubuntu, debian, proxmox, kali, mint, pop
  --debug         Show detection debug info
  --version, -v   Show version
  --help, -h      Show this help
HELP
                exit 0 ;;
            *) echo "Unknown option: $1 (use --help)"; exit 1 ;;
        esac
    done

    # Gather all info
    detect_distro
    detect_vm
    get_cpu_info
    get_memory_info
    get_disk_info
    get_network_info
    get_gpu_info
    get_uptime_load
    get_packages
    get_security_info

    # Force logo override
    [[ -n "$FORCE_LOGO" ]] && DISTRO_ID="$FORCE_LOGO"

    # Debug
    if [[ "$DEBUG_MODE" == "true" ]]; then
        echo "[DEBUG] DISTRO_ID='$DISTRO_ID'"
        echo "[DEBUG] DISTRO_NAME='$DISTRO_NAME'"
        echo "[DEBUG] VM=$IS_VM ($VM_HYPERVISOR)"
        echo "[DEBUG] CLOUD=$CLOUD_PROVIDER"
        echo ""
    fi

    # Build ASCII lines
    local ascii_lines=()
    if [[ "$SHOW_ASCII" == "true" ]]; then
        while IFS= read -r line; do
            ascii_lines+=("$line")
        done < <(read_ascii_art "$ASCII_STYLE" "$DISTRO_ID")
    fi

    # Build info lines
    local info_lines=()

    # Shell detection
    local shell_name="${SHELL:-N/A}"
    local shell_ver=""
    if [[ -n "$shell_name" && "$shell_name" != "N/A" ]]; then
        shell_ver=$("$shell_name" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1 || echo "")
        shell_name=$(basename "$shell_name")
    fi

    # Terminal detection
    local term_name="${TERM_PROGRAM:-${TERM:-N/A}}"
    if [[ -t 1 ]]; then
        [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_CLIENT:-}" ]] && term_name="ssh"
        [[ -n "${TMUX:-}" ]] && term_name="tmux"
    fi

    # Resolution
    local resolution="N/A"
    if has_cmd xrandr; then
        resolution=$(xrandr 2>/dev/null | grep '*' | head -1 | awk '{print $1}' || echo "")
    fi
    if [[ -z "$resolution" || "$resolution" == "N/A" ]] && [[ -t 1 ]]; then
        local cols rows
        cols=$(tput cols 2>/dev/null || echo "")
        rows=$(tput lines 2>/dev/null || echo "")
        [[ -n "$cols" && -n "$rows" ]] && resolution="${cols}x${rows}"
    fi

    # ── HEADER ──
    local user_color="$WHT"
    [[ "$IS_ROOT" == "true" ]] && user_color="${BLD}"
    info_lines+=("$(printf "${user_color}%s@%s${RST}" "$(whoami 2>/dev/null || echo root)" "$(hostname 2>/dev/null || echo unknown)")")
    info_lines+=("$(printf "${DIM}──────────────────${RST}")")

    # OS
    info_lines+=("$(printf "${BLU}OS${RST}        ${WHT}%s${RST}" "$DISTRO_NAME")")

    # Host / VM
    if [[ "$IS_VM" == "true" ]]; then
        info_lines+=("$(printf "${BLU}Host${RST}      ${WHT}%s${RST}" "${VM_MANUFACTURER:-N/A} ${VM_PRODUCT:-}")")
        info_lines+=("$(printf "${BLU}Hypervisor${RST} ${WHT}%s${RST}" "$VM_HYPERVISOR")")
    elif [[ "$VM_HYPERVISOR" == "Proxmox VE" ]]; then
        info_lines+=("$(printf "${BLU}Host${RST}      ${WHT}%s${RST}" "Proxmox VE")")
        [[ -n "$VM_PRODUCT" ]] && info_lines+=("$(printf "${BLU}Version${RST}    ${WHT}%s${RST}" "$VM_PRODUCT")")
    fi

    [[ "$IS_CONTAINER" == "true" ]] && info_lines+=("$(printf "${BLU}Container${RST} ${WHT}%s${RST}" "$CONTAINER_TYPE")")

    # Kernel
    info_lines+=("$(printf "${BLU}Kernel${RST}    ${WHT}%s${RST}" "$(uname -r)")")

    # Uptime
    info_lines+=("$(printf "${BLU}Uptime${RST}    ${WHT}%s${RST}" "$UPTIME_HUMAN")")

    # Packages
    local pkg_str="${PKG_COUNT} (dpkg)"
    (( SNAP_COUNT > 0 )) && pkg_str="${pkg_str}, ${SNAP_COUNT} (snap)"
    info_lines+=("$(printf "${BLU}Packages${RST}  ${WHT}%s${RST}" "$pkg_str")")

    # Shell
    if [[ -n "$shell_ver" ]]; then
        info_lines+=("$(printf "${BLU}Shell${RST}     ${WHT}%s %s${RST}" "$shell_name" "$shell_ver")")
    else
        info_lines+=("$(printf "${BLU}Shell${RST}     ${WHT}%s${RST}" "$shell_name")")
    fi

    # Resolution
    info_lines+=("$(printf "${BLU}Resolution${RST} ${WHT}%s${RST}" "$resolution")")

    # Terminal
    info_lines+=("$(printf "${BLU}Terminal${RST}  ${WHT}%s${RST}" "$term_name")")

    # CPU
    local cpu_short
    cpu_short=$(echo "$CPU_MODEL" | sed 's/(R)//g; s/(TM)//g; s/CPU //g; s/ @ [0-9.]*GHz//; s/ @ [0-9.]*MHz//; s/  */ /g' | xargs 2>/dev/null || echo "$CPU_MODEL")
    local cpu_freq=""
    if [[ "$CPU_MHZ" != "N/A" ]]; then
        if (( CPU_MHZ > 1000 )); then
            cpu_freq=$(awk "BEGIN {printf \" @ %.2fGHz\", ${CPU_MHZ}/1000}")
        else
            cpu_freq=" @ ${CPU_MHZ}MHz"
        fi
    fi
    info_lines+=("$(printf "${BLU}CPU${RST}        ${WHT}%s${RST} (${WHT}%s${RST})" "$cpu_short" "${CPU_CORES_LOGICAL}${cpu_freq}")")

    # GPU
    if [[ "$GPU_INFO" != "N/A" ]]; then
        local gpu_short
        gpu_short=$(echo "$GPU_INFO" | sed 's/^[0-9]*:[0-9]*.[0-9]* //' | xargs 2>/dev/null || echo "$GPU_INFO")
        info_lines+=("$(printf "${BLU}GPU${RST}        ${WHT}%s${RST}" "$gpu_short")")
    fi

    # Memory
    local mem_used_h mem_total_h
    mem_total_h=$(awk "BEGIN {printf \"%d\", ${MEM_TOTAL}/1024}")
    mem_used_h=$(awk "BEGIN {printf \"%d\", ${MEM_USED}/1024}")
    info_lines+=("$(printf "${BLU}Memory${RST}     ${WHT}%sMiB${RST} / %sMiB" "$mem_used_h" "$mem_total_h")")

    # Memory bar
    local bar_len=20
    local filled
    filled=$(awk "BEGIN {printf \"%d\", (${MEM_PERCENT}/100)*${bar_len}}")
    local bar=""
    local bar_pct=$(( filled * 100 / bar_len ))
    for ((i=0; i<bar_len; i++)); do
        if ((i < filled)); then
            bar="${bar}${BLD}${WHT}█${RST}"
        else
            bar="${bar}${DIM}░${RST}"
        fi
    done
    info_lines+=("$(printf "${BLU}            ${RST}")${bar}")

    # Disk
    info_lines+=("$(printf "${BLU}Disk${RST}      ${WHT}%s / %s (${DISK_PERCENT}%%)${RST}" "$DISK_USED" "$DISK_TOTAL")")

    # Network
    info_lines+=("$(printf "${BLU}Network${RST}   ${WHT}%s${RST} (${WHT}%s${RST})" "$PRIMARY_IFACE" "$PRIMARY_IP")")

    # Security
    local sec_parts=""
    [[ "$SSH_SESSION" == "true" ]] && sec_parts="SSH "
    [[ "$IS_ROOT" == "true" ]] && sec_parts="${sec_parts}ROOT "
    [[ "$APPARMOR" == "Active" ]] && sec_parts="${sec_parts}AppArmor "
    [[ -n "$sec_parts" ]] && info_lines+=("$(printf "${BLU}Security${RST}  ${WHT}%s${RST}" "$sec_parts")")

    # VM extended
    if [[ "$IS_VM" == "true" ]]; then
        [[ -n "${VM_UUID:-}" && "$VM_UUID" != "Protected" ]] && \
            info_lines+=("$(printf "${BLU}VM UUID${RST}   ${WHT}%s${RST}" "$VM_UUID")")
    fi

    # Cloud
    if [[ "$CLOUD_PROVIDER" != "N/A" ]]; then
        info_lines+=("$(printf "${BLU}Cloud${RST}      ${BLD}${WHT}%s${RST}" "$CLOUD_PROVIDER")")
        [[ "$CLOUD_INSTANCE" != "N/A" ]] && info_lines+=("$(printf "${BLU}Instance${RST}  ${WHT}%s${RST}" "$CLOUD_INSTANCE")")
        [[ "$CLOUD_INSTANCE_TYPE" != "N/A" ]] && info_lines+=("$(printf "${BLU}Type${RST}      ${WHT}%s${RST}" "$CLOUD_INSTANCE_TYPE")")
        [[ "$CLOUD_REGION" != "N/A" ]] && info_lines+=("$(printf "${BLU}Region${RST}    ${WHT}%s${RST}" "$CLOUD_REGION")")
    fi

    # Load
    info_lines+=("$(printf "${BLU}Load${RST}      ${WHT}%s${RST}" "$LOAD_AVG")")
    info_lines+=("$(printf "${BLU}Processes${RST} ${WHT}%s${RST}" "${PROCS_RUNNING} running / ${PROCS_TOTAL} total")")
    info_lines+=("$(printf "${DIM}Boot: %s${RST}" "$BOOT_TIME")")

    # ── RENDER SIDE BY SIDE ──
    visible_len() {
        local s="$1"
        if has_cmd python3; then
            python3 -c "
import sys, re
s = sys.argv[1]
s = re.sub(r'\x1b\[[0-9;]*[a-zA-Z]', '', s)
total = 0
for ch in s:
    cp = ord(ch)
    if cp > 0xFFFF: total += 2
    elif 0x1100 <= cp <= 0x115F: total += 2
    elif 0x2E80 <= cp <= 0x303E: total += 2
    elif 0x3040 <= cp <= 0x9FFF: total += 2
    elif 0xAC00 <= cp <= 0xD7AF: total += 2
    elif 0xF900 <= cp <= 0xFAFF: total += 2
    elif 0xFE30 <= cp <= 0xFE4F: total += 2
    elif 0xFF01 <= cp <= 0xFF60: total += 2
    elif 0xFFE0 <= cp <= 0xFFE6: total += 2
    else: total += 1
print(total)" "$s" 2>/dev/null
        else
            echo "$s" | sed $'s/\x1b\[[0-9;]*[a-zA-Z]//g' | wc -m | tr -d ' '
        fi
    }

    local max_ascii=0
    for line in "${ascii_lines[@]}"; do
        local vlen
        vlen=$(visible_len "$line")
        (( vlen > max_ascii )) && max_ascii=$vlen
    done
    local col_width=$(( max_ascii + 3 ))
    (( col_width < 33 )) && col_width=33

    local total_info=${#info_lines[@]}
    local total_ascii=${#ascii_lines[@]}
    local max_lines=$((total_info > total_ascii ? total_info : total_ascii))

    echo ""

    for ((i = 0; i < max_lines; i++)); do
        local ascii_part="" info_part=""
        (( i < total_ascii )) && ascii_part="${ascii_lines[$i]}"
        (( i < total_info )) && info_part="${info_lines[$i]}"

        if [[ -n "$ascii_part" ]]; then
            local vlen
            vlen=$(visible_len "$ascii_part")
            local spaces=$(( col_width - vlen ))
            (( spaces < 1 )) && spaces=1
            printf '%s%*s%s' "$ascii_part" "$spaces" '' "$info_part"
        else
            printf '%*s%s' "$col_width" '' "$info_part"
        fi
        echo ""
    done

    # Color blocks
    if [[ "$SHOW_BLOCKS" == "true" ]]; then
        echo ""
        print_color_blocks
    fi

    echo ""
}

main "$@"
