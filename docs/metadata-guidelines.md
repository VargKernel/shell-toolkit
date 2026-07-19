# Metadata Guidelines

Every script must contain a documentation metadata block immediately after the shebang. This block is used to automatically generate project documentation, including README files, HTML pages, and summary tables.

## Rules

* The metadata block **must** begin with `# ---DOC-START---` and end with `# ---DOC-END---`.
* Every metadata entry **must** start with `#`.
* All metadata **must** be written in **English**.
* `summary` must be a single concise sentence describing the script.
* `description` should provide a more detailed explanation of the script's purpose, behavior, or important implementation details. Multi-line descriptions are supported using the YAML-style `|` syntax.
* `sudo` indicates whether the script requires root privileges.
* `interactive` indicates whether the script requires user interaction.
* `idempotent` describes whether the script can be safely executed multiple times.

  * `true` — Safe to run repeatedly without changing the final system state.
  * `mostly` — Generally safe, but some operations may be repeated (for example, updating package indexes or downloading files).
  * `false` — Repeated execution may produce different results or unwanted side effects.
* `dependencies` lists other scripts **in this repository** that the script invokes or requires (for example, an orchestrator in `workflows/` that runs several installers in sequence). This is used to render a dependency tree for each script in the generated documentation.

  * Paths are relative to the repository root and comma-separated on a single line, e.g. `server/deploy-nginx.sh, server/deploy-grafana.sh`.
  * If the script does not call any other script in the repository, use `none`.
  * Only list scripts from this repository — do not list external programs or packages (e.g. `curl`, `docker`, `apt`) here.

## Supported Fields

| Field         | Type                        | Description                                           |
| ------------- | --------------------------- | ----------------------------------------------------- |
| `summary`     | string                      | Short description used in generated tables.           |
| `description` | string                      | Detailed description used in generated documentation. |
| `sudo`        | `true` / `false`            | Whether the script requires root privileges.          |
| `interactive` | `true` / `false`            | Whether the script requires user interaction.         |
| `idempotent`  | `true` / `mostly` / `false` | Whether the script is idempotent.                     |
| `dependencies` | comma-separated paths / `none` | Other repo scripts this script calls; used to build a dependency tree. |

## Example

```bash
#!/bin/bash

# ---DOC-START---
# summary: Install the C and C++ development environment.
# description: |
#   Installs the GNU C and C++ toolchain, CMake, GDB, Make,
#   pkg-config, and other packages required for native
#   development on Debian-based systems.
# sudo: true
# interactive: false
# idempotent: mostly
# dependencies: none
# ---DOC-END---
```

Example for an workflow script that runs other scripts from this repo:

```bash
#!/bin/bash

# ---DOC-START---
# summary: Full-stack workflow: bootstrap → nginx → grafana → portainer from a single .env.
# description: |
#   Orchestrates a full server deployment by running four scripts in sequence from a single `.env` config file.
#
#   - Validates all `.env` variables before starting — fails fast with clear errors
#   - Pipes answers to each subscript via `printf`, safely handling special characters in credentials
#   - Handles sudo user creation between the bootstrap and Nginx steps
#   - Prints a deployment plan before running and confirms before proceeding
#   - Located in `workflows/deploy-server/` alongside its `.env.example` config template
#
#   > Designed for **fresh deployments only** — re-running on an existing system breaks prompt ordering in the subscripts.
# sudo: true
# interactive: true
# idempotent: false
# dependencies: standalone/server/server-bootstrap.sh, standalone/server/deploy-nginx.sh, standalone/server/deploy-grafana.sh, standalone/server/deploy-portainer.sh
# ---DOC-END---
```

> The metadata block is intended to be machine-readable and should always reflect the actual behavior of the script.
