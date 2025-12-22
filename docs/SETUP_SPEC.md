# Fedora Dev Setup - Technical Specification

**Version:** 1.0.0  
**Status:** Active  
**Last Updated:** December 21, 2025

---

## 1. System Overview

The **Fedora Dev Setup** is a modular, idempotent bootstrapping system designed to configure a fresh Fedora Workstation for professional Python development.

### Core Philosophy

1.  **Idempotency:** All scripts can be run multiple times without causing errors or duplication.
2.  **Modularity:** Concerns (System, Python, Editor) are separated into distinct scripts.
3.  **Observability:** All actions are logged to both console (colored) and disk (timestamped).
4.  **Safety:** `DRY_RUN` mode allows testing logic without modifying the system.

---

## 2. Architecture

### Directory Structure

```text
.
├── bootstrap-fedora.sh      # Entry point orchestrator
├── logs/                    # Runtime logs (git-ignored)
├── scripts/
│   ├── 00-system-base.sh    # DNF, Repos, Core Tools
│   ├── 10-python-dev.sh     # Python, uv, pipx
│   ├── 20-vscodium.sh       # Editor, Extensions, Settings
│   ├── 99-validate.sh       # Post-install verification
│   └── lib/
│       ├── logging.sh       # Logging primitives
│       └── utils.sh         # Helper functions

```

### Shared Libraries (`scripts/lib/`)

#### `logging.sh`

Provides standardized output formats:

- **`log_info`** (Blue): General progress.
- **`log_success`** (Green): Successful operations.
- **`log_warn`** (Yellow): Non-fatal issues.
- **`log_error`** (Red): Fatal errors (exits script).
- **Log Rotation:** Creates a new log file `logs/install-YYYYMMDD-HHMMSS.log` for every run.

#### `utils.sh`

Provides functional primitives:

- **`install_dnf_packages`**: Checks if a package exists before attempting install.
- **`ensure_in_path`**: Appends to `.bashrc` only if the entry is missing.
- **`backup_file`**: Creates timestamped backups before overwriting configs.
- **`validate_command`**: Verifies binary existence for validation steps.
- **`DRY_RUN` Support**: Mocks destructive operations when `DRY_RUN=true`.

---

## 3. Installation Phases

### Phase 1: System Base (`00-system-base.sh`)

**Goal:** Prepare the OS for development.

1. **Optimization:** Configures `/etc/dnf/dnf.conf` for parallel downloads.
2. **Updates:** Runs full system upgrade (`dnf upgrade`).
3. **Repositories:** Enables RPM Fusion Free.
4. **Packages:** Installs GCC, Git, Make, Tmux, Zsh, Neovim, Ripgrep, FD, etc.

### Phase 2: Python Environment (`10-python-dev.sh`)

**Goal:** Setup a modern, fast Python workflow.

1. **`uv`**: Installed to `~/.cargo/bin` for high-speed package resolution.
2. **`pipx`**: Installed for isolated global tool management.
3. **Global Tools:**

- `ruff` (Linting)
- `black` (Formatting)
- `mypy` (Typing)
- `pytest` (Testing)
- `ipython` (REPL)

### Phase 3: VSCodium (`20-vscodium.sh`)

**Goal:** Configure a telemetry-free IDE.

1. **Repo:** Adds `gitlab.com/paulcarroty/vscodium-deb-rpm-repo`.
2. **Install:** Installs `codium` package.
3. **Config:** Writes `settings.json` (Format on Save, Ruler at 88 chars).
4. **Extensions:** Installs Python, Ruff, GitLens, Material Icons.

### Phase 4: Validation (`99-validate.sh`)

**Goal:** Ensure the system is ready for use.

- Checks existence of all binaries (`git`, `uv`, `codium`).
- Verifies pipx tool registration.
- Verifies VSCodium extensions are active.
- Reports a summary of Pass/Fail metrics.

---
## 4. Backup & Restore Architecture

### Export (`scripts/export-config.sh`)
Creates a portable snapshot of the development environment.
- **Packages:** Queries RPM DB, Pipx, and VSCodium CLI to generate manifest text files.
- **Configs:** Copies dotfiles from `$HOME`.
- **Artifact:** Generates a `tar.gz` archive in `~/fedora-backups/`.

### Restore (`scripts/restore-config.sh`)
Rehydrates a system from a snapshot.
- **Smart Install:** Reads manifest files and installs *only* missing packages/extensions.
- **Safety:** Before restoring a config file (e.g., `.bashrc`), it creates a timestamped backup of the version on disk (e.g., `.bashrc.backup.20251222`).
- **Idempotency:** Can be run multiple times safely.

---

## 5. Usage Modes

### Standard Installation
```bash
sudo ./bootstrap-fedora.sh --install

```

### Backup

```bash
./scripts/export-config.sh

```

### Restore

```bash
./scripts/restore-config.sh path/to/backup.tar.gz

```

### Dry Run (Safe Test)

```bash
./bootstrap-fedora.sh --dry-run
# OR
DRY_RUN=true ./scripts/export-config.sh

```

---

## 6. Requirements

- **OS:** Fedora Workstation 40 or newer.
- **Privileges:** Sudo access required.
- **Network:** Active internet connection required.
- **Disk:** ~5GB free space recommended.
