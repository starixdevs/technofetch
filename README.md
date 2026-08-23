# ⚡ Technofetch

A neofetch alternative for VMs and VPS.

## Install

```bash
curl -sL https://raw.githubusercontent.com/starixdevs/technofetch/main/technofetch.sh -o /usr/local/bin/technofetch && chmod +x /usr/local/bin/technofetch && technofetch
```

## Usage

```bash
technofetch
technofetch --style compact
technofetch --style box
technofetch --style minimal --no-blocks
```

## Uninstall

```bash
sudo rm /usr/local/bin/technofetch
```

## Detects

- **Hypervisors** — KVM, VMware, VirtualBox, Hyper-V, Xen, Parallels
- **Cloud** — AWS, GCP, Azure, DigitalOcean, Linode, Hetzner, OCI
- **Containers** — Docker, LXC/LXD, Podman, systemd-nspawn

## Shows

OS, Host, Kernel, Uptime, Packages, Shell, Resolution, Terminal, CPU, GPU, Memory (with bar), Disk, Network, Security, VM info, Cloud details, Load, Processes, Boot time.

## License

MIT
