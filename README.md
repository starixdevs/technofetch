<div align="center">

# ⚡ Technofetch

### VM-Focused System Info Display for Ubuntu & Debian

A powerful **neofetch** alternative built for virtual machine environments.
Detects hypervisors, cloud providers, containers, and provides deep system insights.

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Ubuntu%20%7C%20Debian-orange)

</div>

---

## 🖼️ Preview

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

---

## 🚀 Features

| Feature | Description |
|---------|-------------|
| 🔍 **VM Detection** | Auto-detects KVM, VMware, VirtualBox, Hyper-V, Xen, Parallels, QEMU |
| ☁ **Cloud Detection** | Identifies AWS, GCP, Azure, DigitalOcean, Linode, Hetzner, OCI |
| 🐳 **Container Detection** | Detects Docker, LXC/LXD, Podman, systemd-nspawn, OCI |
| 🖥️ **CPU Deep Dive** | Model, cores, threads, sockets, MHz, cache, virtualization flags |
| 💾 **Memory Details** | Used/total with visual bar, swap, buffers, cache breakdown |
| 🌐 **Network Info** | Interface, IP, MAC, link speed, traffic stats, DNS servers |
| 💿 **Disk Intelligence** | Size, usage, filesystem type, virtual disk driver detection |
| 🔒 **Security Status** | Root check, SSH session, AppArmor, firewall, pending updates |
| 📦 **Package Count** | Total packages + upgradable count |
| 🎨 **Color Blocks** | Neofetch-style color block display |
| ⚡ **Zero Dependencies** | Pure bash — no Python, no compiled tools needed |
| 🎯 **Debian Focus** | Optimized for Ubuntu/Debian and all derivatives |

---

## 📦 Installation

### One-Line Install

```bash
git clone https://github.com/YOUR_USERNAME/technofetch.git && cd technofetch && sudo bash install.sh
```

### Manual Install

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/technofetch.git
cd technofetch

# Make executable
chmod +x technofetch.sh install.sh uninstall.sh

# Install system-wide (requires sudo)
sudo bash install.sh

# OR install locally (no sudo)
bash install.sh --local
```

### Quick Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
alias tf='technofetch'
alias tfcompact='technofetch --style compact'
alias tfminimal='technofetch --style minimal --no-blocks'
alias tfbox='technofetch --style box'
```

---

## 🎨 ASCII Styles

```bash
# Default (full block art)
technofetch

# Compact (smaller, for narrow terminals)
technofetch --style compact

# Box (boxed border art)
technofetch --style box

# Minimal (ultra compact)
technofetch --style minimal --no-blocks
```

---

## ⚙️ Options

| Option | Description |
|--------|-------------|
| `--style STYLE` | ASCII art style: `default`, `compact`, `box`, `minimal` |
| `--no-ascii` | Hide ASCII art entirely |
| `--no-blocks` | Hide color blocks at bottom |
| `--no-color` | Disable colors (useful for piping) |
| `--version, -v` | Show version |
| `--help, -h` | Show help |

---

## 🔍 What It Detects

### Hypervisors

| Hypervisor | Detection Method |
|------------|-----------------|
| KVM/QEMU | systemd-detect-virt, DMI vendor/product, cpuinfo flags |
| VMware | DMI strings, cpuinfo hypervisor flag |
| VirtualBox | DMI strings, product family |
| Hyper-V | Microsoft DMI vendor, Hyper-V specific strings |
| Xen | Xen DMI product strings, cpuinfo |
| Parallels | Parallels DMI detection |

### Cloud Providers

| Provider | Detection Method |
|----------|-----------------|
| AWS | Metadata endpoint (169.254.169.254) |
| GCP | Google metadata endpoint |
| Azure | Azure Instance Metadata Service |
| DigitalOcean | /etc/digitalocean marker |
| Linode/Akamai | /etc/linode marker |
| Hetzner | Hetzner metadata endpoint |
| Oracle Cloud | OCI metadata endpoint |

### Containers

| Container | Detection Method |
|-----------|-----------------|
| Docker | /.dockerenv, cgroup patterns |
| LXC/LXD | container=LXC environment variable |
| Podman | rootless detection, cgroup patterns |
| systemd-nspawn | /proc/1/cmdline inspection |
| OCI Generic | containerd socket, cgroup patterns |

---

## 📊 Information Displayed

```
System          Distro name, version, codename, family
Kernel          Release, arch, version, loaded modules count
VM Status       Hypervisor type, host brand, VM name, virt features
CPU             Model, physical cores, logical threads, sockets, MHz, cache
Memory          Used/total MiB with visual bar, swap usage
Disk            Root filesystem size/usage, FS type, virtual disk driver
Network         Primary interface, IP, MAC, link speed, traffic, DNS
GPU             Model, driver (VM-aware: virtio, vmwgfx, etc.)
Packages        Total installed, package manager, upgradable count
Uptime          Human-readable duration
Load Average    1/5/15 min load averages
Processes       Active / total counts
Security        Root status, SSH session, AppArmor, firewall, updates
Cloud           Provider, instance ID, type, region
Boot Time       System boot timestamp
```

---

## 🛠️ Requirements

- **OS**: Ubuntu (any version), Debian (any version), or derivatives
- **Shell**: Bash 4.0+
- **Dependencies**: None — uses only built-in commands and `/proc`/`/sys`

Optional (for enhanced features):
- `systemd-detect-virt` — more accurate VM detection
- `lspci` — GPU information
- `lsblk` — storage device listing
- `iwgetid` — WiFi SSID detection
- `curl` — cloud provider detection

---

## 📁 Project Structure

```
technofetch/
├── technofetch.sh    # Main script (single-file, no dependencies)
├── install.sh        # Installer (system-wide or local)
├── uninstall.sh      # Clean uninstaller
└── README.md         # This file
```

---

## 🐛 Troubleshooting

### "Permission denied" on install
```bash
# Use sudo for system-wide install
sudo bash install.sh

# Or install locally
bash install.sh --local
```

### Command not found after install
```bash
# Check your PATH
echo $PATH

# If ~/.local/bin is not in PATH, add it
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### VM not detected
Make sure `systemd-detect-virt` is installed:
```bash
sudo apt install systemd
```

Or check DMI data directly:
```bash
cat /sys/devices/virtual/dmi/id/sys_vendor
```

---

## 📜 License

MIT License — use it, modify it, share it.

---

## 🤝 Contributing

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## ⭐ Star History

If you find Technofetch useful, give it a ⭐ on GitHub!
