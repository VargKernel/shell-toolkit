> **A personal collection of Bash scripts for Debian-based x86_64 systems.**
> Server bootstrapping, monitoring stack deployment, web server setup, shell quality-of-life
> tweaks, media downloads, and day-to-day automation.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Bash](https://img.shields.io/badge/Bash-5.0%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Debian](https://img.shields.io/badge/Debian-Supported-A81D33?logo=debian&logoColor=white)](https://www.debian.org)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-Supported-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)

## Structure

Scripts are organized into three tiers:

- **`standalone/`** — self-contained scripts, each doing one thing.
- **`workflows/`** — scripts that chain standalones together toward a goal.

The full, current tree — every script, every subdirectory — is in
[`docs/index.html`](docs/index.html), not here, so it never goes stale.

## Documentation

Every script carries its own documentation as a metadata block right after the shebang
(`summary`, `description`, `sudo`, `interactive`, `idempotent`, `dependencies` — see
[`docs/metadata-guidelines.md`](docs/metadata-guidelines.md)). That metadata is the single
source of truth for what each script does, what it needs, and what it depends on.

It's rendered into **[`docs/index.html`](docs/index.html)** by [`generate-docs.py`](generate-docs.py)
(dependency-free, standard library only):

```bash
./generate-docs.py
```

`docs/index.html` is regenerated automatically by GitHub Actions on every push, so it always
reflects what's in the scripts themselves — including a searchable/sortable summary table,
per-script dependency trees, and any dependency issues. Don't hand-edit it.

## Features

- Colored, consistent output with clear progress and status messages
- Interactive prompts with safety confirmations before destructive actions
- Idempotent where the script's scope allows it
- Automatic backups of configuration files before modification

## Quick Start

```bash
git clone https://github.com/rebootless/shell-toolkit.git
cd shell-toolkit
find . -type f -name "*.sh" -exec chmod +x {} \;
```

From there:

- **Run a standalone script directly** for a single, focused task.
- **Run a workflow** to chain several standalones toward a larger goal.

Always review a script's source and its metadata block before running it with `sudo` on a
production machine. Browse [`docs/index.html`](docs/index.html) for the current list of
scripts, what each one does, what it requires, and how they depend on each other.

## Requirements

- Debian-based **x86_64** Linux system, Bash 5.0+
- Root/`sudo` access for system-level scripts, and an internet connection for package/image
  downloads
- `python3` to run `generate-docs.py` (standard library only, no pip packages)
- A handful of scripts need extra tools (Docker, `jq`, `pipx`, `flatpak`, `npm`, etc.) — these
  are called out per-script in [`docs/index.html`](docs/index.html), not duplicated here

## Contributing

Issues and Pull Requests are welcome. If a script fits the collection's scope (server ops,
monitoring, deployment, shell tooling, or useful automation), feel free to open a PR.

Follow the existing code style: colored output, safety prompts, inline English comments. Every
new script needs a `# ---DOC-START--- ... # ---DOC-END---` metadata block — see
[`docs/metadata-guidelines.md`](docs/metadata-guidelines.md) — and should regenerate cleanly
with `./generate-docs.py --strict`.

## License

Distributed under the [GNU General Public License v3.0](LICENSE).

<div align="center">
Built for self-hosted infrastructure, automation, and observability.
</div>
