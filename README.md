# Shell-Toolkit

> **A personal collection of Bash scripts for Debian-based x86_64 systems.**
> Designed for server bootstrapping, monitoring stack deployment, web server setup, shell quality-of-life tweaks, media downloads, and day-to-day automation.

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
- **Automatic backups** of configuration files before modification
- **Comprehensive logging** with final run summaries
- **Security-focused defaults** where the script scope allows it

## Compatibility

- **Platform:** Debian-based GNU/Linux distributions
- **Architecture:** x86_64 / amd64
- **Shell:** Bash 5.0+

## Scripts Overview

| Script | Purpose | Requires Root |
|---------|---------|:------------:|
| [`server-bootstrap.sh`](#server-bootstrapsh) | Initial server setup, users, firewall, Fail2Ban | ✅ |
| [`server-report.sh`](#server-reportsh) | Full system inventory report + archive | ✅ |
| [`deploy-nginx.sh`](#deploy-nginxsh) | Production Nginx + optional PHP-FPM, Grafana & Portainer proxy | ✅ |
| [`deploy-grafana.sh`](#deploy-grafanash) | Grafana + Prometheus + Node Exporter via Docker | ✅ |
| [`deploy-portainer.sh`](#deploy-portainersh) | Portainer CE container management UI via Docker | ✅ |
| [`update-stacks.sh`](#update-stackssh) | Pull and redeploy all Docker Compose stacks under `/opt/*` | ✅ |
| [`system-cleanup.sh`](#system-cleanupsh) | Clean up APT cache, old kernels, logs, temp files & Docker leftovers | ✅ |
| [`bashrc-default.sh`](#bashrc-defaultsh) | Reset `~/.bashrc` to the distribution default | ✅ |
| [`download-java.sh`](#download-javash) | Eclipse Temurin JDK/JRE installer (v8, 17, 21, 25) | ✅ |
| [`discord-attachments-dl.sh`](#discord-attachments-dlsh) | Download attachments from Discord data export | ❌ |
| [`git-clone-all.sh`](#git-clone-allsh) | Clone all public repositories from a GitHub user/profile | ❌ |
| [`prompt-cli.sh`](#prompt-clish) | Gemini-based CLI assistant with markdown rendering; exposed as `ask` | ❌ |
| [`yt-dlp-best-format.sh`](#yt-dlp-best-formatsh) | Download best quality video as MP4 via yt-dlp | ❌ |
| [`yt-dlp-audio-only.sh`](#yt-dlp-audio-onlysh) | Download audio only as MP3 via yt-dlp | ❌ |
| [`yt-dlp-all-formats.sh`](#yt-dlp-all-formatssh) | Download every resolution tier (480p–8K) via yt-dlp | ❌ |
| [`bash-qol.sh`](#bash-qolsh) | Install shell quality-of-life tools and Bash config | ✅ |
| [`oh-my-bash.sh`](#oh-my-bashsh) | Install oh-my-bash with theme selection | ✅ |
| [`bash-qol-demo.sh`](#bash-qol-demosh) | Demo for the Bash QOL terminal styling | ❌ |

## Repository Structure

| Path | Description |
|------|-------------|
| `server/` | Server deployment, monitoring, and maintenance scripts |
| `maintenance/` | System cleanup and shell reset utilities |
| `utilities/` | General-purpose standalone tools |
| `yt-dlp/` | Video and audio download helpers |
| `qol/` | Bash quality-of-life and terminal customization scripts |
| `README.md` | Project overview and usage documentation |
| `LICENSE` | GNU GPL v3.0 license text |

## Detailed Descriptions

### `server-bootstrap.sh`

Initial hardening and configuration for a fresh server.

- Installs essential admin tools such as `htop`, `ranger`, `git`, `curl`, `wget`, and more
- Offers optional hardware diagnostic utilities
- Creates and configures a sudo-enabled user account
- Sets up **Firewalld** with sensible default rules
- Configures **Fail2Ban** for SSH brute-force protection
- Prints a full system summary at the end

### `server-report.sh`

Generates a comprehensive server inventory report, saved locally and archived.

- Collects hardware specs, OS info, network interfaces, active users, running services, Docker containers, Nginx vhosts, and firewall rules
- Saves all data to `~/server-report/`
- Packages everything into `server-report.tar.gz` for easy transfer
- Displays a color-coded console summary with key metrics

### `deploy-nginx.sh`

Deploys a hardened, production-ready Nginx web server.

- Installs Nginx with optional **PHP-FPM** integration
- Generates a clean virtual host with security headers and other baseline best practices
- Optionally installs **avahi-daemon** for mDNS / `.local` hostname resolution on the LAN
- Can add reverse proxies for **Grafana** at `/grafana` and **Portainer** at `/portainer`
- Configures **Firewalld** for HTTP, HTTPS, and mDNS
- Creates a clean default `index.html`

### `deploy-grafana.sh`

Deploys a full observability stack: **Grafana + Prometheus + Node Exporter**.

- Managed via **Docker Compose**
- Uses a dedicated secret for the Grafana admin password
- Pre-configures Prometheus to scrape Node Exporter metrics
- Attempts to auto-import the **Node Exporter Full** dashboard (ID 19937)
- Persists data under `/opt/grafana-stack/`

> **Default binding:** `127.0.0.1:3000` — use `deploy-nginx.sh` to expose it externally.

### `deploy-portainer.sh`

Deploys **Portainer CE** — a lightweight web UI for managing Docker containers.

- Managed via **Docker Compose**
- Uses a dedicated secret for the Portainer admin password
- Stores data under `/opt/portainer-stack/`

> **Default binding:** `127.0.0.1:9000` — use `deploy-nginx.sh` to expose it externally.

### `update-stacks.sh`

Updates and redeploys every Docker Compose stack found under `/opt/*`.

- Lists currently running containers before starting
- Detects `docker-compose.yml`, `compose.yml`, `compose.yaml`, and `docker-compose.yaml`
- Runs `docker compose pull` followed by `docker compose up -d` for each stack
- Detects whether new images were actually pulled
- Skips directories with no compose file or where the pull fails
- Prints a final summary of updated, unchanged, and skipped stacks

### `system-cleanup.sh`

Frees up disk space by clearing caches, logs, and other safe-to-remove files.

- Runs `apt-get autoremove`, `autoclean`, and `clean`
- Detects and optionally removes **old kernel packages** while keeping the running kernel
- Vacuums `journald` logs and removes rotated/compressed logs in `/var/log` older than 7 days
- Clears stale files from `/tmp` and `/var/tmp`
- Optionally prunes Docker images, containers, networks, and volumes with separate confirmations
- Clears thumbnail caches for all home directories
- Prints a summary of freed disk space at the end

### `bashrc-default.sh`

Restores `~/.bashrc` to the distro default.

- Backs up the current `~/.bashrc` with a timestamp before overwriting
- Restores the file from `/etc/skel/.bashrc`
- Requires explicit confirmation before making changes

### `download-java.sh`

Downloads and installs multiple **Eclipse Temurin (Adoptium)** JDK/JRE builds.

- Supported versions: **8, 17, 21, 25**
- Downloads both **JDK** and **JRE** for each version
- Installs to `/opt/java/temurin/`
- Updates shell configuration so the installed Java versions can be used easily

### `discord-attachments-dl.sh`

Downloads media attachments from a local **Discord data export**.

- Scans all `c*/` channel folders inside the export directory
- Parses `messages.json` using `jq` to extract attachment URLs
- Downloads files to an `attachments/` subdirectory per channel
- Skips already-downloaded files
- Logs failed downloads for review

### `git-clone-all.sh`

Clones every public repository belonging to a GitHub user or organization.

- Usage: `./git-clone-all.sh <github-username-or-url> [target-dir]`
- Accepts either a bare username or a full `github.com/<user>` URL
- Paginates through the GitHub API to fetch all repositories
- Clones each repo into the target directory (default `./repos`)
- Skips repositories that are already cloned locally
- No root required

### `prompt-cli.sh`

A terminal-based assistant client for the **Google Gemini API** with markdown rendering.

- Usage: `ask [--model NAME] <prompt text>`
- Self-installs into `~/.local/bin/` on first run
- Stores the API key in `~/.config/prompt-cli/keys.env`
- Renders markdown directly in the terminal
- Includes `--setup`, `--reset`, `--uninstall`, and `--help`
- Uses the `ask` command name because `prompt` is already used by **oh-my-bash**

### `yt-dlp-best-format.sh`

Downloads a video at the best available quality, merged into a single MP4.

- Usage: `./yt-dlp-best-format.sh <URL> [extra yt-dlp options]`
- Prefers `bestvideo[ext=mp4]+bestaudio[ext=m4a]`, falling back to the best overall format
- Installs `jq` and `wget` dependencies automatically
- Uses Firefox cookies and Node.js JS runtime for restricted videos
- Retries up to 100 times with randomized sleep intervals between requests
- Output filename includes uploader, upload date, title, and video ID
- No root required

### `yt-dlp-audio-only.sh`

Downloads only the audio track and converts it to MP3.

- Usage: `./yt-dlp-audio-only.sh <URL> [extra yt-dlp options]`
- Extracts audio at the best available quality (`--audio-quality 0`)
- Installs `jq` and `wget` dependencies automatically
- Uses Firefox cookies and Node.js JS runtime for restricted videos
- Retries up to 100 times with randomized sleep intervals between requests
- Output filename includes uploader, upload date, title, and video ID
- No root required

### `yt-dlp-all-formats.sh`

Downloads a video at each resolution tier up to 8K, falling back to the best overall format.

- Usage: `./yt-dlp-all-formats.sh <URL> [extra yt-dlp options]`
- Targets 480p, 720p, 1080p, 1440p, 2160p (4K), and 4320p (8K) tiers with `bestaudio[ext=m4a]`
- Falls back to `best[ext=mp4]` / `best` if no matching tier is available
- Merges output into MP4
- Installs `jq` and `wget` dependencies automatically
- Uses Firefox cookies and Node.js JS runtime for restricted videos
- Output filename includes uploader, upload date, title, video ID, and resolution
- No root required

### `bash-qol.sh`

Installs shell quality-of-life tools and configures the current user’s Bash environment.

- Installs packages such as `bash-completion`, `fzf`, `zoxide`, `ripgrep`, and `bat`
- Optionally adds the `eza` apt repository when needed
- Updates `~/.bashrc` and `~/.inputrc` with a managed block
- Adds aliases, completion tweaks, and history improvements
- Designed to be re-run safely

### `oh-my-bash.sh`

Installs **oh-my-bash** and lets the user pick a theme via an interactive preview.

- Uses theme screenshots rendered in the terminal with `chafa`
- Supports both upstream installation and a manual integration mode
- Preserves existing Bash customizations in manual mode
- Updates only the managed block when re-run
- Requires `git` and `chafa`

### `bash-qol-demo.sh`

A standalone demonstration of the Bash QOL terminal styling.

- Creates a temporary sandbox with sample files
- Shows off formatted output and terminal UI behavior
- Useful as a preview for the QOL theme and rendering style
- No root required

## Quick Start

```bash
git clone https://github.com/VargKernel/shell-toolkit.git
cd shell-toolkit
find . -type f -name "*.sh" -exec chmod +x {} \;
```

Run the scripts in logical order for a fresh server setup:

```bash
# 1. Harden and configure the new server
sudo ./server/server-bootstrap.sh

# 2. Generate a full system inventory
sudo ./server/server-report.sh

# 3. Deploy Nginx (optionally with PHP-FPM, Grafana & Portainer proxy)
sudo ./server/deploy-nginx.sh

# 4. Deploy the monitoring stack (requires Docker)
sudo ./server/deploy-grafana.sh

# 5. Deploy Portainer CE for container management (requires Docker)
sudo ./server/deploy-portainer.sh

# 6. Periodically free up disk space
sudo ./maintenance/system-cleanup.sh

# 7. Periodically pull and redeploy updated Docker stacks
sudo ./server/update-stacks.sh
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

> [!NOTE]
> `prompt-cli.sh` stores the Gemini API key locally in `~/.config/prompt-cli/keys.env`.
> `bash-qol.sh` and `oh-my-bash.sh` modify shell startup files such as `~/.bashrc`.

> [!TIP]
> Scripts are idempotent where possible, but a dry-run review (`bash -n script.sh`) before first execution is always a good idea.

## Requirements

- Debian-based **x86_64** Linux system
- `bash` 5.0+
- Root or `sudo` access for the system-level scripts
- Internet connection for package and Docker image downloads
- `docker` + `docker compose` *(only for `deploy-grafana.sh`, `deploy-portainer.sh`, and `update-stacks.sh`)*
- `jq` *(only for `discord-attachments-dl.sh`, `prompt-cli.sh`, and the `yt-dlp-*` scripts)*
- `yt-dlp` and a Firefox profile with cookies *(only for the `yt-dlp-*` scripts)*
- A Google Gemini API key *(only for `prompt-cli.sh`)*

## Contributing

Issues and Pull Requests are welcome. If a script fits the collection’s scope (server ops, monitoring, deployment, shell tooling, or useful automation), feel free to open a PR.

Please follow the existing code style: colored output, safety prompts, and inline English comments.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Made for clean, efficient server management.
</div>
