> **A personal collection of Bash scripts for Debian-based x86_64 systems.**
> Server bootstrapping, monitoring stack deployment, web server setup, shell quality-of-life
> tweaks, media downloads, and day-to-day automation.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)

Scripts are organized into two directories:

- **`standalone/`** — self-contained scripts, each performing a single task.
- **`workflows/`** — higher-level scripts that chain standalones together to accomplish a larger goal.

## Quick Start

Clone the repository:

```bash
git clone https://github.com/rebootless/shell-toolkit.git
cd shell-toolkit
```

All shell scripts are tracked with the executable bit and automatically corrected by GitHub Actions if necessary.

If your local checkout loses executable permissions (for example, after extracting a ZIP archive or copying files to a filesystem that does not preserve Unix permissions), restore them with:

```bash
find . -type f -name "*.sh" -exec chmod +x {} \;
```

Then either run an individual script from `standalone/` or execute a workflow from `workflows/`.

A dry run in a disposable VM or non-production environment is always a good idea before using scripts on production systems.

## Fresh VPS Deployment

For a fresh Debian installation with only **Standard system utilities** and **OpenSSH server** selected:

Run as `root`:

```bash
apt update && apt install -y git && \
git clone https://github.com/rebootless/shell-toolkit && \
cd shell-toolkit/workflows/deploy-server && \
cp .env.example .env && \
nano .env
```

After configuring `.env`, start the deployment:

```bash
./deploy-server
```

## Documentation

Every script includes a metadata block immediately after the shebang describing its purpose,
requirements, privileges, dependencies, and other properties (`summary`, `description`,
`sudo`, `interactive`, `idempotent`, `dependencies`).
- **[`docs/index.html`](docs/index.html)**

To regenerate the documentation locally:

```bash
./generate-docs.py
```

## Requirements

- Debian-based **x86_64** Linux system with Bash 5.0+
- Root/`sudo` access for system-level scripts
- Internet connection for package and image downloads
- `python3` (standard library only) to run `generate-docs.py`
- Some scripts require additional software such as `Docker`, `jq`, `pipx`, `flatpak`, or `npm` (see the documentation for details)

## Contributing

Issues and Pull Requests are welcome.

Please follow the rules:

- English comments and documentation
- Metadata block (`# ---DOC-START--- ... # ---DOC-END---`) for every new script

Before submitting a Pull Request, ensure that documentation generation succeeds:

```bash
./generate-docs.py --strict
```

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">

Built for self-hosted infrastructure, automation, and observability.

</div>
