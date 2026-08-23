<div align="center">

```
████████╗██████╗  ██████╗ ███████╗██████╗ ██╗  ██╗ █████╗ ████████╗
██╔════╝██╔══██╗██╔════╝ ██╔════╝██╔══██╗██║  ██║██╔══██╗╚══██╔══╝
█████╗  ██████╔╝██║  ███╗█████╗  ██████╔╝███████║███████║   ██║
██╔══╝  ██╔══██╗██║   ██║██╔══╝  ██╔══██╗██╔══██║██╔══██║   ██║
███████╗██║  ██║╚██████╔╝███████╗██║  ██║██║  ██║██║  ██║   ██║
╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝
```

# ⚡ Technofetch

### The Ultimate VM-Focused System Info Display for Linux

**Version 2.0** • **14 Detection Methods** • **Zero Dependencies** • **Pure Bash**

<br>

![Version](https://img.shields.io/badge/version-2.0.0-blue?style=for-the-badge)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-orange?style=for-the-badge)
![Shell](https://img.shields.io/badge/shell-bash-lightgrey?style=for-the-badge)
![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen?style=for-the-badge)
![Size](https://img.shields.io/badge/size-40KB-blue?style=for-the-badge)

<br>

**Technofetch** is a hyper-detailed neofetch replacement built specifically for **virtual machine environments**.
It goes far beyond basic system info — it detects your **hypervisor**, **cloud provider**, **container runtime**,
**VM disk driver**, **security posture**, and much more using **14 independent detection methods**.

No Python. No compiled binaries. Just pure Bash that works everywhere.

<br>

```
  ╔══════════════════════════════════════════════════════════════╗
  ║  Run on:    Ubuntu • Debian • Mint • Pop!_OS • Kali • ...  ║
  ║  Detects:   KVM • VMware • VirtualBox • Hyper-V • Xen      ║
  ║  Clouds:    AWS • GCP • Azure • DigitalOcean • Linode      ║
  ║  Containers: Docker • LXC • Podman • containerd • OCI      ║
  ╚══════════════════════════════════════════════════════════════╝
```

</div>

---

## 🖼️ Live Preview

### Default Style
```
                 ╭───────────────────────────╮
                 │  ████████╗██████╗  ██████╗│  Ubuntu 22.04.4 LTS
                 │  ██╔════╝██╔══██╗██╔════╝│  ⚡ VM: KVM/QEMU
                 │  █████╗  ██████╔╝██║      │
                 │  ██╔══╝  ██╔══██╗██║      │  Kernel:        5.15.0-91-generic (x86_64)
                 │  ██║     ██║  ██║╚██████╗│  OS:            Ubuntu 22.04.4 LTS
                 │  ╚═╝     ╚═╝  ╚═╝ ╚═════╝│  Codename:      jammy
                 │          FETCH             │  Hypervisor:    KVM/QEMU
                 │        ── v2.0 ──          │  Host/Brand:    QEMU Standard PC
                 ╰───────────────────────────╯
                                             │
                                             │  CPU:           Intel Xeon Platinum 8375C
                                             │  CPU Config:    2C / 4T @ 2900 MHz
                                             │  Virt Capable:  vmx
                                             │  Cache:         36608 KB
                                             │
                                             │  Memory:        45.2% │ 3617.4 / 7984.0 MiB
                                             │                 ████████████░░░░░░░░
                                             │
                                             │  Disk (/):      12.4G / 49.1G (25% used)
                                             │  Filesystem:    ext2/ext3
                                             │  Disk Driver:   virtio
                                             │
                                             │  Network:       eth0 (10.0.2.15)
                                             │  MAC:           52:54:00:12:34:56
                                             │  Traffic:       ↑ 12.3 MB  ↓ 456.7 MB
                                             │  DNS:           8.8.8.8, 8.8.4.4
                                             │
                                             │  GPU:           Virtio GPU
                                             │  Packages:      847 packages (apt/dpkg)
                                             │  Uptime:        3d 12h 45m
                                             │  Load Avg:      0.52 0.38 0.29
                                             │  Processes:     3 active / 187 total
                                             │
                                             │  User:          root
                                             │  AppArmor:      Active
                                             │  Firewall:      ufw active
                                             │  Updates:       12 updates available
                                             │
                                             │  ☁ Cloud:       AWS (Amazon Web Services)
                                             │  Instance:      i-0abc123def456789
                                             │  Instance Type: t3.medium
                                             │  Region:        us-east-1
                                             │
                                             │  Boot Time:     2024-01-15 08:30:00
```

### Compact Style
```
    ┌──────────────┐   Ubuntu 22.04.4 LTS
    │  TECH        │   ⚡ VM: KVM/QEMU
    │  ████████    │
    │  █      █    │   Kernel         5.15.0-91-generic (x86_64)
    │  ████████    │   Hypervisor     KVM/QEMU
    │       █      │   CPU            Intel Xeon Platinum 8375C
    │  ████████    │   Memory         45.2% │ 3617.4 / 7984.0 MiB
    │  FETCH  v2   │   Disk (/)      12.4G / 49.1G (25% used)
    └──────────────┘   Network        eth0 (10.0.2.15)
                       Packages       847 (apt/dpkg)
                       Uptime         3d 12h 45m
```

---

## 🚀 Why Technofetch?

<table>
<tr>
<td width="50%" valign="top">

### vs. neofetch
- ✅ **VM-aware** — detects hypervisors neofetch can't
- ✅ **Cloud metadata** — shows instance ID, type, region
- ✅ **Security status** — AppArmor, firewall, SSH, updates
- ✅ **No dependencies** — pure bash, runs everywhere
- ❌ neofetch is archived and unmaintained

</td>
<td width="50%" valign="top">

### vs. fastfetch
- ✅ **Zero compile** — no Rust/C required
- ✅ **VM-focused** — purpose-built for servers
- ✅ **Cloud detection** — 7 providers supported
- ✅ **Single file** — easy to copy anywhere
- ❌ fastfetch needs compilation on most systems

</td>
</tr>
</table>

---

## 🎯 Features

<table>
<tr><td>

### 🔍 VM Detection (14 Methods)
- `systemd-detect-virt` — systemd native detection
- DMI/SMBIOS sysfs parsing — reads `/sys/devices/virtual/dmi/id/*`
- `dmidecode` command — hardware table parsing
- `lscpu` hypervisor field — CPU-level detection
- `/proc/cpuinfo` hypervisor flag — kernel-level detection
- `/proc/version` string — kernel build info
- `/sys/hypervisor/type` — Xen/KVM type file
- `/proc/xen` directory — Xen presence
- Virtio device scan — `/sys/bus/virtio/devices/`
- Cloud-init data — `/run/cloud-init/` and `/var/lib/cloud/`
- Guest tools — VMware Tools / VBox Guest Additions
- DMI raw dump — scans ALL sysfs DMI fields
- systemd container info — `/run/systemd/container`
- DMI pattern matching — 15+ known VM brand patterns

</td><td>

### ☁️ Cloud Provider Detection
- **AWS** — Instance metadata (169.254.169.254)
- **GCP** — Google metadata endpoint
- **Azure** — Azure Instance Metadata Service
- **DigitalOcean** — `/etc/digitalocean` marker
- **Linode/Akamai** — `/etc/linode` marker
- **Hetzner** — Hetzner metadata endpoint
- **Oracle Cloud** — OCI metadata endpoint
- **Alibaba Cloud** — DMI vendor detection

</td></tr>
<tr><td>

### 🐳 Container Detection
- **Docker** — `/.dockerenv`, cgroup patterns
- **LXC/LXD** — `container=LXC` env variable
- **Podman** — rootless detection, cgroup patterns
- **containerd** — socket detection
- **systemd-nspawn** — `/proc/1/cmdline`
- **OCI Generic** — containerd socket + cgroup v2

</td><td>

### 🖥️ System Information
- **CPU**: Model, cores, threads, sockets, MHz, cache
- **Memory**: Used/total with visual bar, swap
- **Disk**: Size, usage, FS type, virt disk driver
- **Network**: Interface, IP, MAC, speed, traffic, DNS
- **GPU**: Model, driver (VM-aware)
- **Packages**: Total count, upgradable
- **Uptime**: Human-readable duration
- **Load**: 1/5/15 min averages
- **Processes**: Active / total counts

</td></tr>
<tr><td>

### 🔒 Security Status
- **Root check** — warns when running as root
- **SSH session** — detects active SSH connections
- **AppArmor** — active/inactive status
- **Firewall** — ufw/iptables status
- **Updates** — available & security updates
- **User context** — whoami@hostname display

</td><td>

### 🎨 Display Options
- **4 ASCII styles**: default, compact, box, minimal
- **Color blocks**: Neofetch-style palette display
- **Memory bar**: Visual usage indicator (green/yellow/red)
- **Side-by-side**: ASCII art + info in columns
- **ANSI colors**: Full terminal color support
- **No-color mode**: For piping and logging

</td></tr>
</table>

---

## 📦 Installation

### ⚡ One-Line Install

```bash
git clone https://github.com/starixdevs/technofetch.git && cd technofetch && sudo bash install.sh
```

That's it. Run `technofetch`.

### 🗑️ Uninstall

```bash
sudo bash uninstall.sh
```

---

## 🎨 ASCII Styles

```bash
# Default — full block art (best for wide terminals)
technofetch

# Compact — smaller art (fits in 80-col terminals)
technofetch --style compact

# Box — bordered art
technofetch --style box

# Minimal — ultra compact, no extras
technofetch --style minimal --no-blocks

# No ASCII — info only, no art
technofetch --no-ascii

# No color blocks at bottom
technofetch --no-blocks

# Combine options
technofetch --style box --no-blocks --no-ascii
```

---

## ⚙️ Command Line Options

| Option | Description | Example |
|--------|-------------|---------|
| `--style STYLE` | ASCII art style | `--style compact` |
| `--no-ascii` | Hide ASCII art entirely | `--no-ascii` |
| `--no-blocks` | Hide color blocks at bottom | `--no-blocks` |
| `--no-color` | Disable all colors (for piping) | `--no-color` |
| `--version, -v` | Show version number | `--version` |
| `--help, -h` | Show help message | `--help` |

---

## 🔍 How Detection Works

### Hypervisor Detection Flow

```
┌─────────────────────────────────────────────────────────┐
│                    DETECTION PIPELINE                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐    ┌──────────────────────┐       │
│  │ Method 1:       │───▶│ systemd-detect-virt   │       │
│  │ systemd native  │    │ (most reliable)       │       │
│  └─────────────────┘    └──────────────────────┘       │
│           │                                             │
│           ▼ (if no result)                              │
│  ┌─────────────────┐    ┌──────────────────────┐       │
│  │ Method 2:       │───▶│ /sys/devices/virtual/ │       │
│  │ DMI sysfs       │    │ dmi/id/* parsing      │       │
│  └─────────────────┘    └──────────────────────┘       │
│           │                                             │
│           ▼ (if no result)                              │
│  ┌─────────────────┐    ┌──────────────────────┐       │
│  │ Method 3:       │───▶│ dmidecode -t system   │       │
│  │ dmidecode cmd   │    │ (if installed)        │       │
│  └─────────────────┘    └──────────────────────┘       │
│           │                                             │
│           ▼ (if no result)                              │
│  ┌─────────────────┐    ┌──────────────────────┐       │
│  │ Method 4:       │───▶│ lscpu Hypervisor:     │       │
│  │ lscpu field     │    │ field extraction      │       │
│  └─────────────────┘    └──────────────────────┘       │
│           │                                             │
│           ▼ (if no result)                              │
│  ┌─────────────────┐    ┌──────────────────────┐       │
│  │ Method 5-14:    │───▶│ DMI patterns,         │       │
│  │ Fallback chain  │    │ /proc/cpuinfo,        │       │
│  │                 │    │ /proc/version,         │       │
│  │                 │    │ /sys/hypervisor,       │       │
│  │                 │    │ virtio devices,        │       │
│  │                 │    │ cloud-init,            │       │
│  │                 │    │ guest tools,           │       │
│  │                 │    │ DMI raw dump           │       │
│  └─────────────────┘    └──────────────────────┘       │
│                                                         │
│  ┌─────────────────────────────────────────────┐       │
│  │ RESULT: VM_HYPERVISOR = "KVM/QEMU"          │       │
│  │         VM_MANUFACTURER = "QEMU"            │       │
│  │         VM_PRODUCT = "Standard PC"          │       │
│  └─────────────────────────────────────────────┘       │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### What Gets Detected

| Category | What | How |
|----------|------|-----|
| **Hypervisor** | KVM, VMware, VirtualBox, Hyper-V, Xen, Parallels | 14 detection methods |
| **Cloud Provider** | AWS, GCP, Azure, DO, Linode, Hetzner, OCI | Metadata endpoints + markers |
| **Container** | Docker, LXC, Podman, containerd, nspawn | cgroups, env vars, sockets |
| **OS** | Ubuntu, Debian, and all derivatives | /etc/os-release + lsb-release |
| **CPU** | Model, cores, threads, MHz, cache, virt flags | /proc/cpuinfo + lscpu |
| **Memory** | Used/total, swap, buffers, cache | /proc/meminfo |
| **Disk** | Root FS size, type, virt driver | df + sysfs + lsblk |
| **Network** | Interface, IP, MAC, speed, traffic, DNS | ip + /sys/class/net |
| **GPU** | Model, VM-aware driver detection | lspci + sysfs |
| **Security** | Root, SSH, AppArmor, firewall, updates | Multiple system checks |

---

## 📊 Information Displayed

```
╔═══════════════════════════════════════════════════════════════╗
║                    INFORMATION CATEGORIES                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  SYSTEM            Kernel, OS, codename, family               ║
║  HOST / VM         Hypervisor, manufacturer, product, name    ║
║  CPU               Model, cores/threads, sockets, MHz, cache  ║
║  MEMORY            Used/total with visual bar, swap           ║
║  DISK              Root FS size/usage, type, virt driver      ║
║  NETWORK           Interface, IP, MAC, speed, traffic, DNS    ║
║  GPU               Model, driver (VM-aware: virtio, etc.)     ║
║  PACKAGES          Total installed, package manager           ║
║  UPTIME            Human-readable duration                    ║
║  LOAD              1/5/15 min load averages                   ║
║  PROCESSES         Active / total counts                      ║
║  SECURITY          Root, SSH, AppArmor, firewall, updates     ║
║  CLOUD             Provider, instance ID, type, region        ║
║  BOOT TIME         System boot timestamp                      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 🏗️ Architecture

```
technofetch.sh
│
├── UTILITIES
│   ├── print_info()         — Formatted label:value output
│   ├── print_section()      — Section headers
│   ├── safe_cmd()           — Command execution with fallback
│   ├── read_sysfs()         — Safe sysfs file reading
│   ├── human_size()         — Bytes → human readable
│   └── human_duration()     — Seconds → "3d 12h 45m"
│
├── DETECTION MODULES
│   ├── detect_distro()      — OS identification (6 fallback methods)
│   ├── detect_vm()          — Hypervisor detection (14 methods)
│   ├── detect_cloud()       — Cloud provider identification
│   ├── get_kernel_info()    — Kernel version, arch, modules
│   ├── get_cpu_info()       — CPU model, cores, cache, virt flags
│   ├── get_memory_info()    — RAM + swap usage
│   ├── get_disk_info()      — Root filesystem + virt disk driver
│   ├── get_network_info()   — Interface, IP, MAC, traffic, DNS
│   ├── get_gpu_info()       — GPU model + VM-aware driver
│   ├── get_uptime_load()    — Uptime + load averages
│   ├── get_packages()       — Package count + manager
│   ├── get_process_info()   — Process counts + services
│   ├── get_security_info()  — Root, SSH, AppArmor, firewall
│   └── get_storage_info()   — Block devices + virt disk info
│
├── DISPLAY ENGINE
│   ├── read_ascii_art()     — 4 ASCII art variants
│   ├── print_color_blocks() — Neofetch-style palette
│   ├── Memory bar           — Visual usage indicator
│   └── Side-by-side renderer — ASCII + info columns
│
└── CLI INTERFACE
    ├── Argument parser      — --style, --no-ascii, etc.
    └── Help system          --help, --version
```

---

## 🛠️ Requirements

### Required
- **OS**: Ubuntu, Debian, or any derivative (Linux Mint, Pop!_OS, Kali, etc.)
- **Shell**: Bash 4.0+
- **Dependencies**: **None** — pure bash

### Optional (Enhanced Features)

| Tool | What it adds | Install |
|------|-------------|---------|
| `systemd-detect-virt` | Most accurate VM detection | `sudo apt install systemd` |
| `dmidecode` | Hardware manufacturer/product info | `sudo apt install dmidecode` |
| `lspci` | GPU model information | `sudo apt install pciutils` |
| `lsblk` | Block device listing | `sudo apt install util-linux` |
| `iwgetid` | WiFi SSID detection | `sudo apt install wireless-tools` |
| `curl` | Cloud provider metadata queries | `sudo apt install curl` |
| `findmnt` | Mount options display | `sudo apt install util-linux` |

---

## 📁 Project Structure

```
technofetch/
├── technofetch.sh     # Main script (zero dependencies)
├── install.sh         # Installer (sudo bash install.sh)
├── uninstall.sh       # Uninstaller (sudo bash uninstall.sh)
└── README.md          # This file
```

---

## 🐛 Troubleshooting

### "Permission denied" on install
```bash
# Use sudo for system-wide install
sudo bash install.sh

# Or install locally (no sudo needed)
bash install.sh --local
```

### "command not found: technofetch"
```bash
# Check if it's in your PATH
which technofetch

# If not, add the install directory to PATH
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Or run directly
bash /usr/local/bin/technofetch.sh
```

### No output when running `technofetch`
```bash
# Debug mode — run with bash -x to see what fails
bash -x technofetch.sh 2>&1 | head -50

# Check if the script is executable
ls -la /usr/local/bin/technofetch

# Make it executable if needed
chmod +x /usr/local/bin/technofetch
```

### VM shows as "Bare Metal"
```bash
# Check which detection methods are available on your system
systemd-detect-virt          # Best method
cat /sys/devices/virtual/dmi/id/sys_vendor  # DMI data
grep -i hypervisor /proc/cpuinfo            # CPU flag
cat /proc/version                          # Kernel string

# Install systemd for better detection
sudo apt install systemd

# Install dmidecode for hardware info
sudo apt install dmidecode
```

### Cloud not detected
```bash
# Check cloud-init
ls /run/cloud-init/
cat /var/lib/cloud/instance/instance-id

# Check metadata endpoint (example for AWS)
curl -sf http://169.254.169.254/latest/meta-data/instance-id
```

### Colors look wrong
```bash
# Ensure your terminal supports 256 colors
echo $TERM

# Try with explicit color setting
TERM=xterm-256color technofetch

# Or disable colors entirely
technofetch --no-color
```

---

## 🤝 Contributing

We love contributions! Here's how to get started:

### 1. Fork & Clone
```bash
git clone https://github.com/starixdevs/technofetch.git
cd technofetch
```

### 2. Create a Branch
```bash
git checkout -b feature/amazing-feature
```

### 3. Make Changes
- Follow the existing code style
- Test on Ubuntu 22.04+ and Debian 12+
- Add comments for complex detection logic
- Update the README if adding features

### 4. Test
```bash
# Syntax check
bash -n technofetch.sh

# Run locally
bash technofetch.sh

# Test with different options
bash technofetch.sh --style compact --no-blocks
bash technofetch.sh --no-ascii
bash technofetch.sh --help
```

### 5. Submit PR
```bash
git add .
git commit -m "feat: add amazing feature"
git push origin feature/amazing-feature
# Then open a Pull Request on GitHub
```

### Ideas for Contributions
- 🎨 New ASCII art styles
- 🔍 Detection for more cloud providers (Hetzner, Vultr, etc.)
- 📊 JSON output mode for scripting
- 🌐 Network speed test integration
- 💾 Disk I/O statistics
- 🔋 Battery info for laptops
- 📈 Historical data tracking
- 🎯 Configuration file support

---

## 📜 License

```
MIT License

Copyright (c) 2024 Technofetch Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🌟 Show Your Support

If **Technofetch** helped you, please consider:

- ⭐ **Star** this repository
- 🍴 **Fork** it for your own customizations
- 📢 **Share** it with your sysadmin friends
- 🐛 **Report** any bugs you find
- 💡 **Suggest** new features

---

<div align="center">

**Made with ❤️ for the Linux server community**

*No compilers were harmed in the making of this tool*

```
  ╔═══════════════════════════════════════════════╗
  ║  "The best system info tool is the one that   ║
  ║   actually works on your VM."                  ║
  ║                              — Technofetch     ║
  ╚═══════════════════════════════════════════════╝
```

</div>
