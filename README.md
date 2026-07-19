> **A personal collection of Bash scripts for Debian-based x86_64 systems.**
> Designed for server bootstrapping, monitoring stack deployment, web server setup, shell quality-of-life tweaks, media downloads, and day-to-day automation.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)

## Table of Contents

- [Features](#features)
- [Compatibility](#compatibility)
- [Documentation](#documentation)
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
> the exception is `download-java.sh`, which hardcodes `x64` in the Adoptium API URL and will fail on ARM.
- **Shell:** Bash 5.0+

## Documentation

Every script carries its own documentation as a metadata block right after the shebang
(`summary`, `description`, `sudo`, `interactive`, `idempotent`, `dependencies` — see
[`docs/documentation-metadata-guidelines.md`](docs/documentation-metadata-guidelines.md)).

That metadata is the single source of truth for what each script does. It's rendered into a
static page at **[`docs/index.html`](docs/index.html)** — a summary table of every script, a
per-script dependency tree built from the `dependencies` field, and a detailed, per-directory
breakdown — by [`generate-docs.py`](generate-docs.py), a dependency-free Python 3 script:

```bash
./generate-docs.py
```

Documentation is regenerated automatically by GitHub Actions whenever a script changes, so
`docs/index.html` always reflects what's in the scripts themselves. Don't hand-edit it.

The full tree (every script, every subdirectory) and per-directory script counts are generated
into [`docs/index.html`](docs/index.html) — see there for the current, complete listing.

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

> [!TIP]
> Scripts are idempotent where possible, but a dry-run review (`bash -n script.sh`) before first
> execution is always a good idea.

Script-specific caveats, bindings, and requirements (e.g. Grafana/Portainer default ports,
`deploy-server.sh` being fresh-deployments-only, `install-nvidia-driver.sh` stopping the display
manager) live in each script's own metadata block — see [`docs/index.html`](docs/index.html) for
the full, current list.

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
- `python3` *(to run `generate-docs.py`; standard library only, no pip packages required)*

## Contributing

Issues and Pull Requests are welcome. If a script fits the collection's scope (server ops,
monitoring, deployment, shell tooling, or useful automation), feel free to open a PR.

Please follow the existing code style: colored output, safety prompts, and inline English
comments. Every new script needs a `# ---DOC-START--- ... # ---DOC-END---` metadata block — see
[`docs/documentation-metadata-guidelines.md`](docs/documentation-metadata-guidelines.md) — and
should regenerate cleanly with `./generate-docs.py --strict`.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Built for self-hosted infrastructure, automation, and observability.
</div>
