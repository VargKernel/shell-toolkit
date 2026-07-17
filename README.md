> **A personal collection of Bash scripts for Debian-based x86_64 systems.**
> Designed for server bootstrapping, monitoring stack deployment, web server setup, shell quality-of-life tweaks, media downloads, and day-to-day automation.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)

## Table of Contents

- [Features](#features)
- [Compatibility](#compatibility)
- [Scripts Overview](#scripts-overview)
- [Repository Structure](#repository-structure)
- [Detailed Descriptions](#detailed-descriptions)
- [Quick Start](#quick-start)
- [Important Notes](#important-notes)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

## Features

- **Colored output** with clear progress indicators and status messages
- **Interactive prompts** with safety confirmations before destructive actions
- **Idempotent design** — safe to re-run without breaking existing configs
- **Automatic backups** of configuration files before modification
- **Comprehensive logging** with final run summaries
- **Security-focused defaults** where the script scope allows it

## Compatibility

- **Platform:** Debian-based GNU/Linux distributions
- **Architecture:** x86_64 / amd64
> Most scripts are architecture-neutral (apt, Docker, Python);
> The exception is `download-java.sh`, which hardcodes `x64` in the Adoptium API URL and will fail on ARM.
- **Shell:** Bash 5.0+

## Scripts Overview

| Script | Purpose | Root | Idempotent |
|--------|---------|:----:|:----------:|
| [`server-bootstrap.sh`](#server-bootstrapsh) | Initial server setup, users, firewall, Fail2Ban | ✅ | ✅ |
| [`deploy-ssh.sh`](#deploy-sshsh) | Install & harden OpenSSH Server, optional Firewalld rule | ✅ | ✅ |
| [`server-report.sh`](#server-reportsh) | Full system inventory report + archive | ✅ | ✅ |
| [`deploy-nginx.sh`](#deploy-nginxsh) | Production Nginx + optional PHP-FPM, Grafana & Portainer proxy | ✅ | ✅ |
| [`deploy-grafana.sh`](#deploy-grafanash) | Grafana + Prometheus + Node Exporter via Docker | ✅ | ✅ |
| [`deploy-portainer.sh`](#deploy-portainersh) | Portainer CE container management UI via Docker | ✅ | ✅ |
| [`update-stacks.sh`](#update-stackssh) | Pull and redeploy all Docker Compose stacks under `/opt/*` | ✅ | ✅ |
| [`deploy-server.sh`](#deploy-serversh) | Full-stack orchestrator: bootstrap → nginx → grafana → portainer from a single `.env` | ✅ | ❌ |
| [`setup-dev.sh`](#setup-devsh) | Install a full C++/Python/PHP/Node dev environment + LSP servers in one step | ✅ | ✅ |
| [`setup-flatpak.sh`](#setup-flatpaksh) | Install Flatpak + Flathub + Discord, Steam, Telegram in one step | ❌ | ✅ |
| [`setup-pipx.sh`](#setup-pipxsh) | Install yt-dlp, gallery-dl, spotdl via pipx in one step | ❌ | ✅ |
| [`system-cleanup.sh`](#system-cleanupsh) | Clean up APT cache, old kernels, logs, temp files & Docker leftovers | ✅ | ✅ |
| [`browser-cleanup.sh`](#browser-cleanupsh) | Clear cache, cookies, and history for Firefox, Chrome, Chromium, and others | ❌ | ✅ |
| [`set-bashrc-default.sh`](#set-bashrc-defaultsh) | Reset `~/.bashrc` to the distribution default | ❌ | ✅ |
| [`create-swap-file.sh`](#create-swap-filesh) | Create and activate a swap file of any size | ✅ | ✅ |
| [`grant-sudo.sh`](#grant-sudosh) | Add a user to the `sudo` group | ✅ | ✅ |
| [`ufw-firewalld-migration.sh`](#ufw-firewalld-migrationsh) | Remove UFW and replace it with Firewalld | ✅ | ⚠️ |
| [`install-virtualbox-guest-additions.sh`](#install-virtualbox-guest-additionssh) | Install VirtualBox Guest Additions from apt | ✅ | ✅ |
| [`chmod-add-x.sh`](#chmod-add-xsh--chmod-remove-xsh) | Recursively add execute permission to `.sh` files in a path | ❌ | ✅ |
| [`chmod-remove-x.sh`](#chmod-add-xsh--chmod-remove-xsh) | Recursively remove execute permission from `.sh` files in a path | ❌ | ✅ |
| [`prompt-cli.sh`](#prompt-clish) | Gemini-based CLI assistant with markdown rendering; exposed as `ask` | ❌ | ✅ |
| [`git-clone-all.sh`](#git-clone-allsh) | Clone all public repositories from a GitHub user/profile | ❌ | ✅ |
| [`download-java.sh`](#download-javash) | Eclipse Temurin JDK/JRE installer (v8, 17, 21, 25) | ✅ | ⚠️ |
| [`discord-attachments-dl.sh`](#discord-attachments-dlsh) | Download attachments from a Discord data export | ❌ | ✅ |
| [`yt-dlp-best-format.sh`](#yt-dlp-best-formatsh) | Download best quality video as MP4 via yt-dlp | ❌ | ✅ |
| [`yt-dlp-audio-only.sh`](#yt-dlp-audio-onlysh) | Download audio only as MP3 via yt-dlp | ❌ | ✅ |
| [`yt-dlp-all-formats.sh`](#yt-dlp-all-formatssh) | Download every resolution tier (480p–8K) via yt-dlp | ❌ | ✅ |
| [`bash-qol.sh`](#bash-qolsh) | Install shell quality-of-life tools and configure Bash | ✅ | ✅ |
| [`oh-my-bash.sh`](#oh-my-bashsh) | Install oh-my-bash with interactive theme selection | ✅ | ✅ |
| [`bash-qol-demo.sh`](#bash-qol-demosh) | Demo for the Bash QOL terminal styling | ❌ | ✅ |
| [`git-fetch.sh`](#git-fetchsh) | Fastfetch-style terminal portfolio card with live GitHub stats | ❌ | ✅ |
| [`install-nvidia-driver.sh`](#install-nvidia-driversh) | NVIDIA GPU driver install (auto-detect, apt package, or `.run`), with nouveau blacklist | ✅ | ⚠️ |

> ⚠️ — mostly safe to re-run, but with caveats described in the script's section below.
>
> The read-only diagnostic scripts under `network/` (17 scripts), plus the individual package installers under `apt/`, `flatpak/`, `pipx/`, and `lsp/`, are not listed row-by-row above — see their dedicated tables in [Detailed Descriptions](#detailed-descriptions).

## Repository Structure

```
shell-toolkit/
├── server/                          # Server deployment, monitoring, and maintenance
│   ├── server-bootstrap.sh
│   ├── deploy-ssh.sh
│   ├── server-report.sh
│   ├── deploy-nginx.sh
│   ├── deploy-grafana.sh
│   ├── deploy-portainer.sh
│   └── update-stacks.sh
├── network/                         # Read-only network diagnostics and status checks
│   ├── network-summary.sh
│   ├── connectivity.sh
│   ├── network-interfaces.sh
│   ├── interface-statistics.sh
│   ├── bandwidth-summary.sh
│   ├── routing.sh
│   ├── neighbors.sh
│   ├── dns-info.sh
│   ├── public-ip.sh
│   ├── listening-ports.sh
│   ├── established-connections.sh
│   ├── firewall-status.sh
│   ├── network-services.sh
│   ├── network-statistics.sh
│   ├── wifi-status.sh
│   ├── vpn-status.sh
│   └── system-info.sh
├── workflows/                       # Multi-step orchestrators and their config
│   ├── deploy-server/
│   │   ├── deploy-server.sh
│   │   └── .env.example
│   ├── setup-dev/
│   │   └── setup-dev.sh
│   ├── setup-flatpak/
│   │   └── setup-flatpak.sh
│   └── setup-pipx/
│       └── setup-pipx.sh
├── maintenance/                     # System utilities and one-off admin tasks
│   ├── system-cleanup.sh
│   ├── browser-cleanup.sh
│   ├── set-bashrc-default.sh
│   ├── create-swap-file.sh
│   ├── grant-sudo.sh
│   ├── ufw-firewalld-migration.sh
│   ├── install-virtualbox-guest-additions.sh
│   ├── chmod-add-x.sh
│   └── chmod-remove-x.sh
├── apt/                             # Individual apt package installers
│   ├── install-cpp.sh
│   ├── install-python.sh
│   ├── install-php.sh
│   ├── install-npm.sh
│   ├── install-docker.sh
│   ├── install-kdevelop.sh
│   ├── install-ghostwriter.sh
│   ├── install-okular.sh
│   ├── install-pipx.sh
│   ├── install-kio-admin.sh
│   ├── install-protonvpn.sh
│   ├── install-tor-browser.sh
│   ├── install-veracrypt.sh
│   └── install-virtualbox.sh
├── flatpak/                         # Flatpak app installers
│   ├── install-flatpak.sh
│   ├── install-discord.sh
│   ├── install-steam.sh
│   └── install-telegram.sh
├── pipx/                            # pipx-based tool installers
│   ├── install-yt-dlp.sh
│   ├── install-gallery-dl.sh
│   └── install-spotdl.sh
├── lsp/                             # Language server installations
│   ├── install-bash-language-server.sh
│   └── install-markdown-language-server.sh
├── utilities/                       # General-purpose standalone tools
│   ├── prompt-cli.sh
│   ├── git-clone-all.sh
│   ├── download-java.sh
│   └── discord-attachments-dl.sh
├── yt-dlp/                          # Video and audio download helpers
│   ├── yt-dlp-best-format.sh
│   ├── yt-dlp-audio-only.sh
│   └── yt-dlp-all-formats.sh
├── qol/                             # Bash quality-of-life and terminal customization
│   ├── bash-qol.sh
│   ├── oh-my-bash.sh
│   └── bash-qol-demo.sh
├── showcase/                        # Terminal portfolio and visual scripts
│   └── git-fetch.sh
├── nvidia/                          # NVIDIA GPU driver installation
│   └── install-nvidia-driver.sh
├── README.md
└── LICENSE
```

## Detailed Descriptions

---

<details>
<summary><strong>server/</strong> — deployment, monitoring, bootstrapping</summary>

<br>

<details>
<summary><code>server-bootstrap.sh</code> — initial server hardening and configuration</summary>

<br>

Initial hardening and configuration for a fresh server.

- Installs essential admin tools such as `htop`, `ranger`, `git`, `curl`, `wget`, and more
- Offers optional hardware diagnostic utilities
- Creates and configures a sudo-enabled user account
- Sets up **[Firewalld](https://firewalld.org)** with sensible default rules
- Configures **[Fail2Ban](https://github.com/fail2ban/fail2ban)** for SSH brute-force protection
- Prints a full system summary at the end

</details>

<details>
<summary><code>deploy-ssh.sh</code> — install &amp; harden OpenSSH Server</summary>

<br>

Installs and enables **[OpenSSH Server](https://www.openssh.com)**, with optional firewall configuration.

- Installs `openssh-server` and enables the `ssh` service
- Optionally installs **Firewalld** and opens the SSH service in the `public` zone
- Validates `sshd` configuration with `sshd -t` before restarting the service — aborts on a bad config instead of dropping the session
- Prints a summary of service status, startup state, and firewall configuration

> Recommended for Debian 12/13 and Ubuntu 22.04/24.04 LTS.

</details>

<details>
<summary><code>server-report.sh</code> — full system inventory report + archive</summary>

<br>

Generates a comprehensive server inventory report, saved locally and archived.

- Collects hardware specs, OS info, network interfaces, active users, running services, Docker containers, Nginx config, and firewall rules
- Saves all data to `~/server-report/`
- Packages everything into `server-report.tar.gz` for easy transfer
- Displays a color-coded console summary with key metrics

</details>

<details>
<summary><code>deploy-nginx.sh</code> — production Nginx + optional PHP-FPM, Grafana &amp; Portainer proxy</summary>

<br>

Deploys a hardened, production-ready **[Nginx](https://nginx.org)** web server.

- Installs Nginx with optional **[PHP-FPM](https://www.php.net/manual/en/install.fpm.php)** integration
- Generates a clean virtual host with security headers and other baseline best practices
- Optionally installs **[avahi-daemon](https://avahi.org)** for mDNS / `.local` hostname resolution on the LAN
- Can add reverse proxies for **Grafana** at `/grafana` and **Portainer** at `/portainer`
- Configures **Firewalld** for HTTP, HTTPS, and mDNS
- Creates a clean default `index.html`

</details>

<details>
<summary><code>deploy-grafana.sh</code> — Grafana + Prometheus + Node Exporter via Docker</summary>

<br>

Deploys a full observability stack: **[Grafana](https://grafana.com)** + **[Prometheus](https://prometheus.io)** + **[Node Exporter](https://github.com/prometheus/node_exporter)**.

- Managed via **[Docker Compose](https://docs.docker.com/compose/)**
- Uses a dedicated secret for the Grafana admin password
- Pre-configures Prometheus to scrape Node Exporter metrics
- Attempts to auto-import the **[Node Exporter Full](https://grafana.com/grafana/dashboards/19937)** dashboard (ID 19937)
- Persists data under `/opt/grafana-stack/`

> **Default binding:** `127.0.0.1:3000` — use `deploy-nginx.sh` to expose it externally.

</details>

<details>
<summary><code>deploy-portainer.sh</code> — Portainer CE container management UI via Docker</summary>

<br>

Deploys **[Portainer CE](https://github.com/portainer/portainer)** — a lightweight web UI for managing Docker containers.

- Managed via **[Docker Compose](https://docs.docker.com/compose/)**
- Uses a dedicated secret for the Portainer admin password
- Stores data under `/opt/portainer-stack/`

> **Default binding:** `127.0.0.1:9000` — use `deploy-nginx.sh` to expose it externally.

</details>

<details>
<summary><code>update-stacks.sh</code> — pull and redeploy all Docker Compose stacks under <code>/opt/*</code></summary>

<br>

Updates and redeploys every Docker Compose stack found under `/opt/*`.

- Lists currently running containers before starting
- Detects `docker-compose.yml`, `compose.yml`, `compose.yaml`, and `docker-compose.yaml`
- Runs `docker compose pull` followed by `docker compose up -d` for each stack
- Detects whether new images were actually pulled
- Skips directories with no compose file or where the pull fails
- Prints a final summary of updated, unchanged, and skipped stacks

</details>

</details>

---

<details>
<summary><strong>network/</strong> — read-only network diagnostics (17 scripts)</summary>

<br>

Read-only status and diagnostic scripts — none of them modify system configuration. Most work without root, though a few (`established-connections.sh`, `listening-ports.sh`, `firewall-status.sh`) print a warning and show reduced process detail when not run as `sudo`. Colored output degrades gracefully to plain text when not attached to a terminal.

| Script | What it shows |
|--------|-----------------|
| `network-summary.sh` | One-shot pass/fail overview: gateway, DNS, internet, public IPv4/IPv6 |
| `connectivity.sh` | Same checks as above plus DNS query time and IPv6 internet reachability |
| `network-interfaces.sh` | Per-interface state, MAC, MTU, driver, speed, and IPv4/IPv6 addresses |
| `interface-statistics.sh` | Per-interface RX/TX bytes, packets, errors, drops, and collisions from `/sys/class/net` |
| `bandwidth-summary.sh` | Per-interface link speed, duplex, carrier state, and MTU |
| `routing.sh` | IPv4/IPv6 routing tables and the default gateway/interface |
| `neighbors.sh` | ARP table (IPv4) and neighbor cache (IPv6) |
| `dns-info.sh` | `resolvectl` status or `/etc/resolv.conf`, active nameservers, and search domains |
| `public-ip.sh` | Public IPv4/IPv6 via ipify, falling back to ifconfig.me/ifconfig.co |
| `listening-ports.sh` | Listening TCP/UDP ports with the owning process, via `ss` |
| `established-connections.sh` | Established TCP connections with local/remote endpoints and owning process |
| `firewall-status.sh` | Status across UFW, Firewalld, nftables, and iptables — whichever are installed |
| `network-services.sh` | Active state of NetworkManager, systemd-networkd/-resolved, dhcpcd, wpa_supplicant, iwd |
| `network-statistics.sh` | TCP congestion control algorithm, IPv4/IPv6 forwarding, and BBR status via `sysctl` |
| `wifi-status.sh` | SSID, signal, bitrate, and frequency for wireless interfaces via `iw` or `nmcli` |
| `vpn-status.sh` | WireGuard/TUN/TAP interfaces, Tailscale status, and ZeroTier status |
| `system-info.sh` | Hostname, OS, kernel, architecture, and uptime |

> None require root, but running as `sudo` gives fuller process detail on the connection- and port-related scripts.

</details>

---

<details>
<summary><strong>workflows/</strong> — multi-step orchestrators</summary>

<br>

<details>
<summary><code>deploy-server.sh</code> — full-stack orchestrator from a single <code>.env</code></summary>

<br>

Orchestrates a full server deployment by running four scripts in sequence from a single `.env` config file.

- Validates all `.env` variables before starting — fails fast with clear errors
- Pipes answers to each subscript via `printf`, safely handling special characters in credentials
- Handles sudo user creation between the bootstrap and Nginx steps
- Prints a deployment plan before running and confirms before proceeding
- Located in `workflows/deploy-server/` alongside its `.env.example` config template

> Designed for **fresh deployments only** — re-running on an existing system breaks prompt ordering in the subscripts.

</details>

<details>
<summary><code>setup-dev.sh</code> — full dev environment in one step</summary>

<br>

Installs a complete development environment by chaining scripts from `apt/` and `lsp/`.

- Runs in order: `install-cpp.sh`, `install-python.sh`, `install-php.sh`, `install-kdevelop.sh`, `install-npm.sh`, `install-ghostwriter.sh`, `install-docker.sh`
- Then installs `install-bash-language-server.sh` and `install-markdown-language-server.sh`
- Each subscript is executed individually so a failure is isolated and traceable
- Located in `workflows/setup-dev/`

</details>

<details>
<summary><code>setup-flatpak.sh</code> — Flatpak + standard GUI apps in one step</summary>

<br>

Installs [Flatpak](https://flatpak.org) and a standard set of GUI applications in one step.

- Runs in order: `install-flatpak.sh` (Flatpak + Flathub), `install-telegram.sh`, `install-discord.sh`, `install-steam.sh`
- Located in `workflows/setup-flatpak/`

</details>

<details>
<summary><code>setup-pipx.sh</code> — Python CLI tools via pipx in one step</summary>

<br>

Installs a curated set of Python CLI tools via [pipx](https://github.com/pypa/pipx) in one step.

- Runs in order: `install-gallery-dl.sh`, `install-yt-dlp.sh`, `install-spotdl.sh`
- Located in `workflows/setup-pipx/`

</details>

</details>

---

<details>
<summary><strong>maintenance/</strong> — system utilities and one-off admin tasks</summary>

<br>

<details>
<summary><code>system-cleanup.sh</code> — free up disk space</summary>

<br>

Frees up disk space by clearing caches, logs, and other safe-to-remove files.

- Runs `apt-get autoremove`, `autoclean`, and `clean`
- Detects and optionally removes **old kernel packages** while keeping the running kernel
- Vacuums `journald` logs and removes rotated/compressed logs in `/var/log` older than 7 days
- Clears stale files from `/tmp` and `/var/tmp`
- Optionally prunes Docker images, containers, networks, and volumes with separate confirmations
- Clears thumbnail caches for all home directories
- Prints a summary of freed disk space at the end

</details>

<details>
<summary><code>browser-cleanup.sh</code> — clear cache, cookies, and history for major browsers</summary>

<br>

Clears browser data for Firefox, Chrome, Chromium, Brave, Edge, Opera, and Vivaldi.

- Stops all detected browser processes before cleaning
- Removes cookies, history, cache, session data, and local storage per browser
- Only cleans browsers that are actually installed on the system
- No root required — operates entirely within the current user's home directory

</details>

<details>
<summary><code>set-bashrc-default.sh</code> — reset <code>~/.bashrc</code> to the distro default</summary>

<br>

Restores `~/.bashrc` to the distro default.

- Backs up the current `~/.bashrc` with a timestamp before overwriting
- Restores the file from `/etc/skel/.bashrc`
- Requires explicit confirmation before making changes

</details>

<details>
<summary><code>create-swap-file.sh</code> — create and activate a swap file</summary>

<br>

Creates and activates a swap file at `/swapfile`.

- Usage: `./create-swap-file.sh <size>` (e.g. `4G`, `8192M`, `2GiB`)
- Accepts G, GB, GiB, M, MB, MiB, T, TB, TiB units
- Detects and safely handles an existing swap file with a confirmation prompt
- Enables the new swap immediately and persists it via `/etc/fstab`

</details>

<details>
<summary><code>grant-sudo.sh</code> — add a user to the <code>sudo</code> group</summary>

<br>

Adds an existing user to the `sudo` group.

- Usage: `./grant-sudo.sh <username>` or run as `sudo` (inherits `SUDO_USER` automatically)
- Validates that the target user exists and is not `root`

</details>

<details>
<summary><code>ufw-firewalld-migration.sh</code> — replace UFW with Firewalld</summary>

<br>

Replaces UFW with **[Firewalld](https://firewalld.org)** on Debian/Ubuntu systems.

- Disables and removes UFW
- Installs Firewalld and enables it on boot
- Opens SSH in the default zone before finishing so the session is not dropped

> ⚠️ **Idempotency caveat:** safe to run on a system that still has UFW, but a no-op if UFW is already gone and Firewalld is already running — it will not reconfigure an existing Firewalld setup.

</details>

<details>
<summary><code>install-virtualbox-guest-additions.sh</code> — install VirtualBox Guest Additions from apt</summary>

<br>

Installs [VirtualBox Guest Additions](https://www.virtualbox.org/manual/ch04.html) from the distribution's apt repository.

- Supports Debian, Ubuntu, Linux Mint, Pop!_OS, and Kali
- Installs `virtualbox-guest-x11` and `virtualbox-guest-utils`
- Reminds the user to reboot to activate the additions

</details>

<details>
<summary><code>chmod-add-x.sh</code> / <code>chmod-remove-x.sh</code> — bulk permission toggle for <code>.sh</code> files</summary>

<br>

Recursively add or remove the execute bit on all `.sh` files under a given path.

- Usage: `./chmod-add-x.sh <path>` / `./chmod-remove-x.sh <path>`
- No root required unless the target path requires elevated access

</details>

</details>

---

<details>
<summary><strong>apt/</strong> — individual package installers (14 scripts)</summary>

<br>

Individual apt-based package installers. Each script is self-contained, idempotent, and requires root.

| Script | What it installs |
|--------|-----------------|
| `install-cpp.sh` | `build-essential`, `gcc`, `g++`, `clang`, `cmake`, `ninja-build`, `gdb`, `lldb` |
| `install-python.sh` | `python3`, `python3-pip`, `python3-venv` |
| `install-php.sh` | `php`, `php-cli`, `php-fpm`, common PHP extensions |
| `install-npm.sh` | `nodejs`, `npm` |
| `install-docker.sh` | [Docker](https://www.docker.com) Engine (`docker.io`), Docker Compose plugin; enables and starts the service |
| `install-kdevelop.sh` | [KDevelop](https://kdevelop.org) IDE |
| `install-ghostwriter.sh` | [Ghostwriter](https://ghostwriter.kde.org) Markdown editor |
| `install-okular.sh` | [Okular](https://okular.kde.org) document viewer |
| `install-pipx.sh` | [pipx](https://github.com/pypa/pipx) and ensures `~/.local/bin` is on PATH |
| `install-kio-admin.sh` | `kio-admin` for Dolphin root access |
| `install-protonvpn.sh` | [ProtonVPN](https://protonvpn.com) CLI from the official Proton apt repository |
| `install-tor-browser.sh` | [Tor Browser](https://www.torproject.org) via the official Tor Project apt repository |
| `install-veracrypt.sh` | [VeraCrypt](https://www.veracrypt.fr) from the official PPA |
| `install-virtualbox.sh` | [VirtualBox](https://www.virtualbox.org) from the official Oracle apt repository |

</details>

---

<details>
<summary><strong>flatpak/</strong> — Flatpak app installers (4 scripts)</summary>

<br>

[Flatpak](https://flatpak.org)-based app installers. Each script is idempotent and does not require root (except `install-flatpak.sh`).

| Script | What it installs |
|--------|-----------------|
| `install-flatpak.sh` | `flatpak`, adds the [Flathub](https://flathub.org) remote, optionally enables KDE Discover integration |
| `install-discord.sh` | [Discord](https://discord.com) from Flathub |
| `install-steam.sh` | [Steam](https://store.steampowered.com) from Flathub |
| `install-telegram.sh` | [Telegram Desktop](https://desktop.telegram.org) from Flathub |

</details>

---

<details>
<summary><strong>pipx/</strong> — Python CLI tool installers (3 scripts)</summary>

<br>

[pipx](https://github.com/pypa/pipx)-based CLI tool installers. Each script is idempotent and does not require root.

| Script | What it installs |
|--------|-----------------|
| `install-yt-dlp.sh` | [yt-dlp](https://github.com/yt-dlp/yt-dlp) |
| `install-gallery-dl.sh` | [gallery-dl](https://github.com/mikf/gallery-dl) |
| `install-spotdl.sh` | [spotdl](https://github.com/spotDL/spotify-downloader) |

</details>

---

<details>
<summary><strong>lsp/</strong> — language server installations (2 scripts)</summary>

<br>

Language server installations for editor/IDE LSP integration via npm. Both scripts are idempotent — they use marker blocks in `~/.bashrc` and skip installation if the server is already present.

| Script | What it installs |
|--------|-----------------|
| `install-bash-language-server.sh` | [bash-language-server](https://github.com/bash-lsp/bash-language-server) via npm into `~/.local/npm`; adds to `~/.bashrc` |
| `install-markdown-language-server.sh` | `markdown-language-server` via npm into `~/.local/npm`; adds to `~/.bashrc` |

</details>

---

<details>
<summary><strong>utilities/</strong> — general-purpose standalone tools</summary>

<br>

<details>
<summary><code>prompt-cli.sh</code> — Gemini-based CLI assistant exposed as <code>ask</code></summary>

<br>

A terminal-based assistant client for the **[Google Gemini API](https://ai.google.dev)** with markdown rendering.

- Usage: `ask [--model NAME] <prompt text>`
- Self-installs into `~/.local/bin/` on first run
- Stores the API key in `~/.config/prompt-cli/keys.env`
- Renders markdown directly in the terminal
- Includes `--setup`, `--reset`, `--uninstall`, and `--help`
- Uses the `ask` command name because `prompt` is already taken by oh-my-bash

</details>

<details>
<summary><code>git-clone-all.sh</code> — clone all public repos from a GitHub user</summary>

<br>

Clones every public repository belonging to a GitHub user or organization.

- Usage: `./git-clone-all.sh <github-username-or-url> [target-dir]`
- Accepts either a bare username or a full `github.com/<user>` URL
- Paginates through the GitHub API to fetch all repositories
- Clones each repo into the target directory (default `./repos`)
- Skips repositories that are already cloned locally
- No root required

</details>

<details>
<summary><code>download-java.sh</code> — Eclipse Temurin JDK/JRE installer</summary>

<br>

Downloads and installs multiple **[Eclipse Temurin (Adoptium)](https://adoptium.net)** JDK/JRE builds.

- Supported versions: **8, 17, 21, 25**
- Downloads both **JDK** and **JRE** for each version
- Installs to `/opt/java/temurin/`
- Updates shell configuration so the installed Java versions can be used easily

> ⚠️ **Idempotency caveat:** hardcodes `x64` in the Adoptium API URL — will fail on ARM. Re-running will re-download and overwrite existing installations without prompting.

</details>

<details>
<summary><code>discord-attachments-dl.sh</code> — download attachments from a Discord data export</summary>

<br>

Downloads media attachments from a local **Discord data export**.

- Scans all `c*/` channel folders inside the export directory
- Parses `messages.json` using [jq](https://jqlang.github.io/jq/) to extract attachment URLs
- Downloads files to an `attachments/` subdirectory per channel
- Skips already-downloaded files
- Logs failed downloads for review

</details>

</details>

---

<details>
<summary><strong>yt-dlp/</strong> — video and audio download helpers (3 scripts)</summary>

<br>

All three scripts share the same conventions: they install [jq](https://jqlang.github.io/jq/) and `wget` if missing, use Firefox cookies and a Node.js JS runtime for restricted videos, and retry up to 100 times with randomized sleep intervals. Output filenames always include uploader, upload date, title, and video ID. No root required.

<details>
<summary><code>yt-dlp-best-format.sh</code> — best quality video as MP4</summary>

<br>

- Usage: `./yt-dlp-best-format.sh <URL> [extra yt-dlp options]`
- Prefers `bestvideo[ext=mp4]+bestaudio[ext=m4a]`, falling back to the best overall format

</details>

<details>
<summary><code>yt-dlp-audio-only.sh</code> — audio only as MP3</summary>

<br>

- Usage: `./yt-dlp-audio-only.sh <URL> [extra yt-dlp options]`
- Extracts audio at the best available quality (`--audio-quality 0`) and converts to MP3

</details>

<details>
<summary><code>yt-dlp-all-formats.sh</code> — every resolution tier up to 8K</summary>

<br>

- Usage: `./yt-dlp-all-formats.sh <URL> [extra yt-dlp options]`
- Targets 480p, 720p, 1080p, 1440p, 2160p (4K), and 4320p (8K) with `bestaudio[ext=m4a]`
- Falls back to `best[ext=mp4]` / `best` if no matching tier is available
- Output filename also includes the resolution

</details>

</details>

---

<details>
<summary><strong>qol/</strong> — Bash quality-of-life and terminal customization</summary>

<br>

<details>
<summary><code>bash-qol.sh</code> — install shell tools and configure Bash</summary>

<br>

Installs shell quality-of-life tools and configures the current user's Bash environment.

- Installs [fzf](https://github.com/junegunn/fzf), [zoxide](https://github.com/ajeetdsouza/zoxide), [ripgrep](https://github.com/BurntSushi/ripgrep), [bat](https://github.com/sharkdp/bat), [eza](https://github.com/eza-community/eza), and `bash-completion`
- Adds the official `eza` apt repository when the package is not available in distro repos
- Updates `~/.bashrc` and `~/.inputrc` with a managed block
- Adds aliases, completion tweaks, and history improvements
- Designed to be re-run safely

</details>

<details>
<summary><code>oh-my-bash.sh</code> — install oh-my-bash with interactive theme selection</summary>

<br>

Installs **[oh-my-bash](https://github.com/ohmybash/oh-my-bash)** and lets the user pick a theme via an interactive preview.

- Uses theme screenshots rendered in the terminal with [chafa](https://github.com/hpjansson/chafa)
- Supports both upstream installation and a manual integration mode
- Preserves existing Bash customizations in manual mode
- Updates only the managed block when re-run
- Requires `git` and `chafa`

</details>

<details>
<summary><code>bash-qol-demo.sh</code> — standalone demo of the Bash QOL terminal styling</summary>

<br>

A standalone demonstration of the Bash QOL terminal styling.

- Creates a temporary sandbox with sample files
- Shows off formatted output and terminal UI behavior
- Useful as a preview before committing to `bash-qol.sh`
- No root required

</details>

</details>

---

<details>
<summary><strong>showcase/</strong> — terminal portfolio and visual scripts</summary>

<br>

<details>
<summary><code>git-fetch.sh</code> — fastfetch-style terminal portfolio card with live GitHub stats</summary>

<br>

A fastfetch-style terminal portfolio card with live GitHub stats, rendered in 24-bit ANSI color.

- Displays identity, role, focus, and tech stack as [Nerd Fonts](https://www.nerdfonts.com) pill badges
- Fetches live data from the GitHub API: repo count, total stars, forks, followers, last push date
- Computes top languages by byte count across all public repos and shows them with percentage and icon
- Uses a dot spinner while API requests are in flight
- Displays a 16-color palette at the bottom using the project's brand colors
- Requires **[Nerd Fonts](https://www.nerdfonts.com)** to render the pill badge glyphs correctly

</details>

</details>

---

<details>
<summary><strong>nvidia/</strong> — NVIDIA GPU driver installation</summary>

<br>

<details>
<summary><code>install-nvidia-driver.sh</code> — install an NVIDIA GPU driver safely</summary>

<br>

Installs an NVIDIA GPU driver, either from the distro's apt repository or from a legacy/manual `.run` installer.

- Usage: `sudo ./install-nvidia-driver.sh --detect` (auto-detects the recommended package via `ubuntu-drivers` or `nvidia-detect`), `--package <nvidia-driver-XXX>`, or `--run <path-to-.run>`
- Blacklists the `nouveau` driver and refreshes `initramfs` before installing
- Stops the display manager and switches to `multi-user.target` so X/Wayland is fully down before the driver installs or builds — asks for confirmation first
- Warns if a process is still holding `/dev/nvidia*` before proceeding
- Installs via `apt-get install` (package mode) or runs the `.run` file with `--silent --dkms --no-x-check` (manual mode)
- Offers to reboot at the end, or prints how to return to `graphical.target` manually

> ⚠️ **Idempotency caveat:** re-running always stops the graphical session and prompts for a reboot again, even if the driver is already installed — run it from an SSH session or TTY, not from inside the graphical session it's about to stop.

</details>

</details>

---

## Quick Start

**1. Clone the repository and enter the project directory:**

```bash
git clone https://github.com/VargKernel/shell-toolkit.git
cd shell-toolkit
```

**2. Make all scripts executable:**

```bash
find . -type f -name "*.sh" -exec chmod +x {} \;
```

**3. Choose how to proceed:**

**Option A — run scripts individually** in logical order for a fresh server setup:

```bash
# 1. Harden and configure the new server
sudo ./server/server-bootstrap.sh

# 2. Install & harden OpenSSH Server (skip if already configured)
sudo ./server/deploy-ssh.sh

# 3. Generate a full system inventory
sudo ./server/server-report.sh

# 4. Deploy Nginx (optionally with PHP-FPM, Grafana & Portainer proxy)
sudo ./server/deploy-nginx.sh

# 5. Deploy the monitoring stack (requires Docker)
sudo ./server/deploy-grafana.sh

# 6. Deploy Portainer CE for container management (requires Docker)
sudo ./server/deploy-portainer.sh

# 7. Check connectivity, open ports, and firewall status at any time
./network/network-summary.sh
./network/firewall-status.sh

# 8. Periodically free up disk space
sudo ./maintenance/system-cleanup.sh

# 9. Periodically pull and redeploy updated Docker stacks
sudo ./server/update-stacks.sh
```

**Option B — deploy the full server stack in one step** using the orchestrator:

```bash
cd workflows/deploy-server
cp .env.example .env
nano .env
sudo ./deploy-server.sh
```

**Option C — set up a development workstation:**

```bash
# Full dev environment (C++, Python, PHP, Node, Docker, KDevelop, LSP servers)
sudo ./workflows/setup-dev/setup-dev.sh

# Flatpak apps (Telegram, Discord, Steam)
./workflows/setup-flatpak/setup-flatpak.sh

# Python CLI tools via pipx (yt-dlp, gallery-dl, spotdl)
./workflows/setup-pipx/setup-pipx.sh

# Shell quality-of-life tools (fzf, zoxide, eza, bat, ripgrep)
sudo ./qol/bash-qol.sh
```

Each script is self-contained and can be run independently at any time.

## Important Notes

> [!WARNING]
> Most scripts require **root** or **sudo** privileges and make real system changes.
> Always review the script source before running on a production machine.

> [!IMPORTANT]
> Grafana is bound to `127.0.0.1:3000` by default.
> Portainer is bound to `127.0.0.1:9000` by default.
> Use `deploy-nginx.sh` to create reverse proxies for external access.
> **Change default admin passwords immediately after first login.**

> [!NOTE]
> `deploy-server.sh` is designed for **fresh deployments only** — re-running it on an existing setup will break prompt ordering in the subscripts.
> `prompt-cli.sh` stores the Gemini API key locally in `~/.config/prompt-cli/keys.env`.
> `bash-qol.sh` and `oh-my-bash.sh` modify shell startup files such as `~/.bashrc`.
> `git-fetch.sh` requires **Nerd Fonts** to render correctly.
> `install-nvidia-driver.sh` stops the display manager and switches to `multi-user.target` — run it from an SSH session or a TTY, never from inside the graphical session it's about to close.
> Scripts under `network/` are read-only diagnostics; none of them change system configuration.

> [!TIP]
> Scripts are idempotent where possible, but a dry-run review (`bash -n script.sh`) before first execution is always a good idea.

## Requirements

- Debian-based **x86_64** Linux system
- `bash` 5.0+
- Root or `sudo` access for system-level scripts
- Internet connection for package and Docker image downloads
- `docker` + `docker compose` *(only for `deploy-grafana.sh`, `deploy-portainer.sh`, `update-stacks.sh`, and `deploy-server.sh`)*
- `jq` *(only for `discord-attachments-dl.sh`, `prompt-cli.sh`, and the `yt-dlp-*` scripts)*
- `yt-dlp` and a Firefox profile with cookies *(only for the `yt-dlp-*` scripts)*
- `pipx` *(only for scripts in `pipx/` and the `setup-pipx` workflow)*
- `flatpak` *(only for scripts in `flatpak/` and the `setup-flatpak` workflow)*
- `npm` *(only for scripts in `lsp/`)*
- A Google Gemini API key *(only for `prompt-cli.sh`)*
- **Nerd Fonts** *(only for `git-fetch.sh`)*
- `ubuntu-drivers` or `nvidia-detect`, and `dkms` for the `.run` mode *(only for `install-nvidia-driver.sh`, `--detect` mode is optional)*
- Standard networking tools (`ip`, `ss`, `curl`) — present by default on most Debian/Ubuntu systems; `dig`, `ethtool`, `iw`/`nmcli`, `tailscale`, and `zerotier-cli` unlock extra detail where installed *(only for scripts in `network/`)*

## Contributing

Issues and Pull Requests are welcome. If a script fits the collection's scope (server ops, monitoring, deployment, shell tooling, or useful automation), feel free to open a PR.

Please follow the existing code style: colored output, safety prompts, and inline English comments.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Built for self-hosted infrastructure, automation, and observability.
</div>
