# Shell-Toolkit

> **A personal collection of production-grade Bash scripts for Debian-based x64 systems.**
> Designed for rapid server bootstrapping, monitoring stack deployment, web server setup, and everyday automation.

[![License](https://img.shields.io/github/license/VargKernel/shell-toolkit)](LICENSE)
[![Shell](https://img.shields.io/badge/language-Bash-4EAA25?logo=gnubash\&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-Debian%20%2F%20Ubuntu-informational?logo=linux)](https://debian.org)

## Table of Contents

* [Features](#-features)
* [Compatibility](#-compatibility)
* [Scripts Overview](#-scripts-overview)
* [Detailed Descriptions](#-detailed-descriptions)
* [Quick Start](#-quick-start)
* [Important Notes](#-important-notes)
* [Requirements](#-requirements)
* [License](#-license)

## Features

* **Colored output** with clear progress indicators and status messages
* **Interactive prompts** with safety confirmations before destructive actions
* **Idempotent design** — safe to re-run without breaking existing configs
* **Automatic backups** of any configuration files before modification
* **Comprehensive logging** with final run summaries
* **Security-focused defaults** out of the box

## Compatibility

| Distribution       | Version       | Status          |
| ------------------ | ------------- | --------------- |
| Debian             | 12 (Bookworm) | ✅ Tested        |
| Debian             | 13 (Trixie)   | ✅ Tested        |
| Ubuntu LTS         | 22.04 (Jammy) | ✅ Tested        |
| Ubuntu LTS         | 24.04 (Noble) | ✅ Tested        |
| Other Debian-based | —             | ⚠️ Likely works |

> Architecture: **x86_64 (amd64)** only.

## Scripts Overview

| Script                                                   | Purpose                                         | Requires Root |
| -------------------------------------------------------- | ----------------------------------------------- | :-----------: |
| [`server-bootstrap.sh`](#server-bootstrapsh)             | Initial server setup, users, firewall, Fail2Ban |       ✅       |
| [`server-report.sh`](#server-reportsh)                   | Full system inventory report + archive          |       ✅       |
| [`deploy-nginx.sh`](#deploy-nginxsh)                     | Production Nginx + optional PHP-FPM             |       ✅       |
| [`deploy-grafana.sh`](#deploy-grafanash)                 | Grafana + Prometheus + Node Exporter via Docker |       ✅       |
| [`download-java.sh`](#download-javash)                   | Eclipse Temurin JDK/JRE (v8, 17, 21, 25)        |       ❌       |
| [`discord-attachments-dl.sh`](#discord-attachments-dlsh) | Download attachments from Discord data export   |       ❌       |

## Detailed Descriptions

### `server-bootstrap.sh`

Initial hardening and configuration for a fresh server.

* Installs essential admin tools: `htop`, `ranger`, `git`, `curl`, `wget`, and more
* Optional hardware diagnostic utilities
* Creates and configures a sudo-enabled user account
* Sets up **Firewalld** with sensible default rules
* Configures **Fail2Ban** for SSH brute-force protection
* Prints a full system summary at the end

### `server-report.sh`

Generates a comprehensive server inventory report, saved locally and archived.

* Collects: hardware specs, OS info, network interfaces, active users, running services, Docker containers, Nginx vhosts, and firewall rules
* Saves all data to `~/server-report/`
* Packages everything into `server-report.tar.gz` for easy transfer
* Displays a color-coded console summary with key metrics

### `deploy-nginx.sh`

Deploys a hardened, production-ready Nginx web server.

* Installs Nginx with an optional **PHP-FPM** integration (correct socket config)
* Generates a clean virtual host with security headers and best practices
* Optional **Grafana reverse proxy** endpoint at `/grafana`
* Configures **Firewalld** for HTTP, HTTPS, and mDNS
* Creates a clean default `index.html`

### `deploy-grafana.sh`

Deploys a full observability stack: **Grafana + Prometheus + Node Exporter**.

* Orchestrated via **Docker Compose** for easy lifecycle management
* Secure credential setup with a prominent warning for default passwords
* Pre-configured Prometheus scraping Node Exporter metrics
* Auto-imports the popular **[Node Exporter Full](https://grafana.com/grafana/dashboards/1860)** dashboard (ID 1860)
* Supports `root_url` configuration for proxying through Nginx

> **Default binding:** `127.0.0.1:3000` — use `deploy-nginx.sh` to expose it externally.

### `download-java.sh`

Downloads and installs multiple **Eclipse Temurin (Adoptium)** JDK/JRE builds.

* Supported versions: **8, 17, 21, 25**
* Downloads both **JDK** and **JRE** for each version
* Installs to `~/Java/Temurin/` — no root required

### `discord-attachments-dl.sh`

Downloads media attachments from a local **Discord data export**.

* Scans all `c*/` channel folders inside the export directory
* Parses `messages.json` using `jq` to extract attachment URLs
* Downloads files to `attachments/` subdirectory per channel
* Skips already-downloaded files
* Logs all failed downloads for review

## Quick Start

```bash
git clone https://github.com/VargKernel/shell-toolkit.git
cd shell-toolkit
chmod +x *.sh
```

Run the scripts in logical order for a fresh server setup:

```bash
# 1. Harden and configure the new server
sudo ./server-bootstrap.sh

# 2. Generate a full system inventory
sudo ./server-report.sh

# 3. Deploy Nginx (optionally with PHP-FPM)
sudo ./deploy-nginx.sh

# 4. Deploy the monitoring stack (requires Docker)
sudo ./deploy-grafana.sh
```

Or use standalone scripts independently — each one is self-contained.

---

## Important Notes

> [!WARNING]
> Most scripts require **root** or **sudo** privileges and make real system changes.
> Always review the script source before running on a production machine.

> [!IMPORTANT]
> Grafana is bound to `127.0.0.1:3000` by default.
> Use `deploy-nginx.sh` to create a reverse proxy for external access.
> **Change the default Grafana admin password immediately after first login.**

> [!TIP]
> Scripts are idempotent where possible, but a dry-run review (`bash -n script.sh`) before first execution is always a good idea.

## Requirements

* Debian-based **x86_64** Linux system
* `bash` 5.0+
* Root or `sudo` access
* Internet connection (for package and Docker image downloads)
* `docker` + `docker compose` *(only for `deploy-grafana.sh`)*
* `jq` *(only for `discord-attachments-dl.sh`)*

## Contributing

Issues and Pull Requests are welcome! If you have a script that fits the collection's scope (server ops, monitoring, deployment), feel free to open a PR.

Please follow the existing code style: colored output, safety prompts, and inline English comments.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Made for clean, efficient server management.
</div>
