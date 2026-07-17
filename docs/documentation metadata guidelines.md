# Documentation Metadata Guidelines

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

## Supported Fields

| Field         | Type                        | Description                                           |
| ------------- | --------------------------- | ----------------------------------------------------- |
| `summary`     | string                      | Short description used in generated tables.           |
| `description` | string                      | Detailed description used in generated documentation. |
| `sudo`        | `true` / `false`            | Whether the script requires root privileges.          |
| `interactive` | `true` / `false`            | Whether the script requires user interaction.         |
| `idempotent`  | `true` / `mostly` / `false` | Whether the script is idempotent.                     |

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
# ---DOC-END---
```

> The metadata block is intended to be machine-readable and should always reflect the actual behavior of the script.
