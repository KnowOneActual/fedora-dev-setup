# Contributing to Fedora Dev Setup

First off, thanks for taking the time to contribute! 🚀

We welcome contributions from the community to help improve this project. Whether it's adding a new tool, fixing a bug, or improving the documentation, your help is appreciated.

## 🛠 Project Architecture

This project is modular by design. Before contributing, please understand the structure:

* **`bootstrap-fedora.sh`**: The main orchestrator. It handles the CLI menu and calls other scripts.
* **`scripts/`**: Contains the actual installation logic, split by phase (e.g., `00-system-base.sh`, `50-desktop-apps.sh`).
* **`scripts/lib/`**: Shared libraries (`logging.sh`, `utils.sh`) for consistent output and helper functions.

## 💻 Development Workflow

### 1. Fork & Clone
Fork the repository and clone it locally:
```bash
git clone [https://github.com/YOUR-USERNAME/fedora-dev-setup.git](https://github.com/YOUR-USERNAME/fedora-dev-setup.git)
cd fedora-dev-setup

```

### 2. Create a Branch

Create a descriptive branch for your work:

```bash
git checkout -b feat/add-my-tool
# or
git checkout -b fix/font-installation-bug

```

### 3. Making Changes

* **Idempotency is King**: Scripts must be safe to run multiple times. Use `command_exists` or `package_installed` checks before trying to install something.
* **Use the Libraries**: Source `lib/logging.sh` and use `log_info`, `log_success`, etc., instead of raw `echo`.
* **Dry Run Support**: Wrap destructive commands in `if [[ "${DRY_RUN:-}" == "true" ]];` blocks so users can preview changes safely.

### 4. Local Testing

We provide built-in tools to validate your changes.

**Step 1: Syntax Checking (Mandatory)**
We strictly enforce [ShellCheck](https://www.shellcheck.net/). Run this on any script you touch:

```bash
shellcheck -x scripts/your-modified-script.sh

```

**Step 2: Simulation**
Run the bootstrapper in Dry Run mode to ensure the logic flows correctly without modifying your system:

```bash
./bootstrap-fedora.sh --dry-run

```

**Step 3: Validation**
If you installed the changes on your own machine, verify the state:

```bash
./bootstrap-fedora.sh --validate

```

## 📝 Pull Request Guidelines

1. **Template**: Please fill out the PR template completely.
2. **Scope**: Keep PRs focused on a single feature or fix.
3. **Linting**: Ensure the CI ShellCheck workflow passes.
4. **Documentation**: If you added a new tool, update `README.md` or the relevant documentation.

## 🎨 Style Guide

* **Indentation**: 4 spaces.
* **Shebang**: Always use `#!/bin/bash`.
* **Safety**: Use `set -e` (or `set -euo pipefail` where appropriate) to fail fast on errors.
* **Variables**: Quote all variable expansions (`"$VAR"`) to prevent word splitting.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.