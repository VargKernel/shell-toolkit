# Shell-Toolkit

> **A personal collection of production-grade Bash scripts for Debian-based x64 systems.**
> Designed for rapid server bootstrapping, monitoring stack deployment, web server setup, and everyday automation.

[![License](https://img.shields.io/github/license/VargKernel/shell-toolkit)](LICENSE)
[![Shell](https://img.shields.io/badge/language-Bash-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Debian%20%2F%20Ubuntu-informational?logo=linux)](https://debian.org)

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
- **Automatic backups** of any configuration files before modification
- **Comprehensive logging** with final run summaries
- **Security-focused defaults** out of the box

## Compatibility

| Distribution | Version | Status |
|--------------|---------|--------|
| Debian | 12 (Bookworm) | ✅ Tested |
| Debian | 13 (Trixie) | ✅ Tested |
| Ubuntu LTS | 22.04 (Jammy) | ✅ Tested |
| Ubuntu LTS | 24.04 (Noble) | ✅ Tested |
| Other Debian-based | — | ⚠️ Likely works |

> Architecture: **x86_64 (amd64)** only.

## Scripts Overview

| Script | Purpose | Requires Root |
|---------|---------|:------------:|
| [`server-bootstrap.sh`](#server-bootstrapsh) | Initial server setup, users, firewall, Fail2Ban | ✅ |
| [`server-report.sh`](#server-reportsh) | Full system inventory report + archive | ✅ |
| [`system-cleanup.sh`](#system-cleanupsh) | Clean up APT cache, old kernels, logs, temp files & Docker leftovers | ✅ |
| [`deploy-nginx.sh`](#deploy-nginxsh) | Production Nginx + optional PHP-FPM, Grafana & Portainer proxy | ✅ |
| [`deploy-grafana.sh`](#deploy-grafanash) | Grafana + Prometheus + Node Exporter via Docker | ✅ |
| [`deploy-portainer.sh`](#deploy-portainersh) | Portainer CE container management UI via Docker | ✅ |
| [`download-java.sh`](#download-javash) | Eclipse Temurin JDK/JRE (v8, 17, 21, 25) | ❌ |
| [`discord-attachments-dl.sh`](#discord-attachments-dlsh) | Download attachments from Discord data export | ❌ |

## Repository Structure

| Path | Description |
|------|-------------|
| `server-bootstrap.sh` | Initial hardening and system setup script |
| `server-report.sh` | Generates a full system inventory and archive |
| `system-cleanup.sh` | Cleans up disk space and stale system files |
| `deploy-nginx.sh` | Deploys Nginx with secure defaults |
| `deploy-grafana.sh` | Deploys Grafana, Prometheus, and Node Exporter via Docker |
| `deploy-portainer.sh` | Deploys Portainer CE via Docker |
| `download-java.sh` | Downloads and installs Eclipse Temurin builds |
| `discord-attachments-dl.sh` | Downloads Discord attachments from an export |
| `README.md` | Project overview and usage documentation |
| `LICENSE` | GNU GPL v3.0 license text |

## Detailed Descriptions

### `server-bootstrap.sh`

Initial hardening and configuration for a fresh server.

- Installs essential admin tools: `htop`, `ranger`, `git`, `curl`, `wget`, and more
- Optional hardware diagnostic utilities
- Creates and configures a sudo-enabled user account
- Sets up **Firewalld** with sensible default rules
- Configures **Fail2Ban** for SSH brute-force protection
- Prints a full system summary at the end

### `server-report.sh`

Generates a comprehensive server inventory report, saved locally and archived.

- Collects: hardware specs, OS info, network interfaces, active users, running services, Docker containers, Nginx vhosts, and firewall rules
- Saves all data to `~/server-report/`
- Packages everything into `server-report.tar.gz` for easy transfer
- Displays a color-coded console summary with key metrics

### `system-cleanup.sh`

Frees up disk space by clearing caches, logs, and other safe-to-remove files.

- Runs `apt-get autoremove`, `autoclean`, and `clean` to clear package leftovers
- Detects and optionally removes **old kernel packages** (keeps the running kernel)
- Vacuums `journald` logs and removes rotated/compressed logs in `/var/log` older than 7 days
- Clears stale files from `/tmp` and `/var/tmp`
- Optional **Docker cleanup**: prunes dangling images/containers/networks, with a separate confirmation for unused images and volumes
- Clears thumbnail caches for all home directories
- Prints a summary of freed disk space at the end

### `deploy-nginx.sh`

Deploys a hardened, production-ready Nginx web server.

- Installs Nginx with an optional **PHP-FPM** integration (correct socket config)
- Generates a clean virtual host with security headers and best practices
- Optional **avahi-daemon** for mDNS / `.local` hostname resolution on the LAN
- Optional **Grafana reverse proxy** endpoint at `/grafana`
- Optional **Portainer reverse proxy** endpoint at `/portainer`
- Configures **Firewalld** for HTTP, HTTPS, and mDNS
- Creates a clean default `index.html`

### `deploy-grafana.sh`

Deploys a full observability stack: **[Grafana](https://grafana.com/) + [Prometheus](https://prometheus.io/) + [Node Exporter](https://github.com/prometheus/node_exporter)**.

- Managed via **Docker Compose**
- Secure credential setup with a prominent warning for default passwords
- Password stored as a **Docker secret** and passed via `--admin-password-file`
- Pre-configured Prometheus scraping Node Exporter metrics
- Auto-imports the popular **[Node Exporter Full](https://grafana.com/grafana/dashboards/19937)** dashboard (ID 19937)
> [!NOTE]
> On low-spec servers, Grafana may take longer to initialize on the first boot. If the healthcheck times out before it fully starts, the Node Exporter Full dashboard (ID 19937) won't auto-import, requiring > you to set it up manually.
- Data persisted to `/opt/grafana-stack/data`

> **Default binding:** `127.0.0.1:3000` — use `deploy-nginx.sh` to expose it externally.

### `deploy-portainer.sh`

Deploys **[Portainer CE](https://www.portainer.io/)** — a lightweight web UI for managing Docker containers.

- Managed via **Docker Compose**
- Secure credential setup with a prominent warning for default passwords
- Password stored as a **Docker secret** and passed via `--admin-password-file`
- Data persisted to `/opt/portainer-stack/data`

> **Default binding:** `127.0.0.1:9000` — use `deploy-nginx.sh` to expose it externally.

### `download-java.sh`

Downloads and installs multiple **Eclipse Temurin (Adoptium)** JDK/JRE builds.

- Supported versions: **8, 17, 21, 25**
- Downloads both **JDK** and **JRE** for each version
- Installs to `~/Java/Temurin/` — no root required

### `discord-attachments-dl.sh`

Downloads media attachments from a local **Discord data export**.

- Scans all `c*/` channel folders inside the export directory
- Parses `messages.json` using `jq` to extract attachment URLs
- Downloads files to `attachments/` subdirectory per channel
- Skips already-downloaded files
- Logs all failed downloads for review

## Quick Start

```bash
git clone https://github.com/VargKernel/shell-toolkit.git
cd shell-toolkit
chmod +x *.sh
````

Run the scripts in logical order for a fresh server setup:

```bash
# 1. Harden and configure the new server
sudo ./server-bootstrap.sh

# 2. Generate a full system inventory
sudo ./server-report.sh

# 3. Deploy Nginx (optionally with PHP-FPM, Grafana & Portainer proxy)
sudo ./deploy-nginx.sh

# 4. Deploy the monitoring stack (requires Docker)
sudo ./deploy-grafana.sh

# 5. Deploy Portainer CE for container management (requires Docker)
sudo ./deploy-portainer.sh

# 6. Periodically free up disk space
sudo ./system-cleanup.sh
```

Or use standalone scripts independently — each one is self-contained.

## Important Notes

> [!WARNING]
> Most scripts require **root** or **sudo** privileges and make real system changes.
> Always review the script source before running on a production machine.

> [!IMPORTANT]
> Grafana is bound to `127.0.0.1:3000` by default.
> Portainer is bound to `127.0.0.1:9000` by default.
> Use `deploy-nginx.sh` to create reverse proxies for external access.
> **Change default admin passwords immediately after first login.**

> [!TIP]
> Scripts are idempotent where possible, but a dry-run review (`bash -n script.sh`) before first execution is always a good idea.

## Requirements

* Debian-based **x86_64** Linux system
* `bash` 5.0+
* Root or `sudo` access
* Internet connection (for package and Docker image downloads)
* `docker` + `docker compose` *(only for `deploy-grafana.sh` and `deploy-portainer.sh`)*
* `jq` *(only for `discord-attachments-dl.sh`)*

## Contributing

Issues and Pull Requests are welcome! If you have a script that fits the collection's scope (server ops, monitoring, deployment), feel free to open a PR.

Please follow the existing code style: colored output, safety prompts, and inline English comments.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Made for clean, efficient server management.
</div>
