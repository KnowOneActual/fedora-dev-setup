# Comprehensive Fedora Development Setup Guide

**Version:** 1.3.0  
**Last Updated:** December 2025  
**Target Audience:** Developers setting up a fresh Fedora workstation.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start (The "One Command" Setup)](#quick-start-the-one-command-setup)
3. [What Gets Installed?](#what-gets-installed)
4. [Post-Installation Steps](#post-installation-steps)
5. [Backup & Restore](#backup--restore)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements
- **OS:** Fedora Workstation 40 or newer (Tested on Fedora 41/42/43).
- **Internet:** Required for package downloads.
- **Privileges:** Sudo access is required.

---

## Quick Start (The "One Command" Setup)

We have replaced the manual script-by-script process with a single intelligent bootstrapper.

### 1. Clone the Repository
```bash
git clone https://github.com/KnowOneActual/fedora-dev-setup.git
cd fedora-dev-setup

```

### 2. Run the Interactive Installer

Run the script with `sudo` to ensure it has permission to install packages:

```bash
sudo ./bootstrap-fedora.sh

```

You will see:

```text
Welcome! Please select an operation:
  1) [INSTALL]  Run full setup (System -> Apps -> Security)
  2) [DRY RUN]  Simulate installation (No changes)
  3) [VALIDATE] Verify existing setup
  4) [EXIT]     Quit

```

Select **Option 1** to begin. The script will:

1. Detect your hardware (Laptop vs. Desktop, Nvidia vs. AMD).
2. Install and configure everything automatically.

### 3. Verification

Once finished, you can re-run the script (no sudo needed for validation) and choose **Option 3 [VALIDATE]** to ensure all checks pass.

---

## What Gets Installed?

### 🛠️ Core Development

* **Shell:** Zsh + Oh My Zsh + Powerlevel10k-ready fonts (JetBrains Mono Nerd Font).
* **Editors:** VSCodium (Telemetry-free VS Code) with Python/Git extensions.
* **Languages:**
* **Python:** 3.x + `uv` (fast installer) + `pipx`.
* **Node.js:** Latest stable + `npm`/`yarn`/`pnpm`.
* **Rust:** Installed via `rustup`.
* **Go:** Latest stable.



### 🛡️ Security & Optimization

* **Security:** **Lynis** is installed and runs a system audit automatically.
* **Hardware:**
* **Laptops:** TLP is installed for better battery life.
* **Desktops:** CPU governor is set to "Performance".
* **GPU:** Drivers for NVIDIA (CUDA) or AMD (ROCm) are auto-installed.



### 📦 Applications

* **Containers:** Docker CE, Podman, and Distrobox.
* **Flatpaks:** LibreOffice, Obsidian, Postman, DBeaver, Slack.

---

## Post-Installation Steps

### 1. Restart Your Shell

To see the new Zsh theme and have `uv`/`cargo` in your PATH, log out and log back in, or restart your computer.

### 2. Configure Git (Optional)

If you haven't set up Git yet, the script installs it, but you should set your identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

```

### 3. Check Security Report

A full security audit log is saved during installation. You can review warnings here:

```bash
grep "warning" /var/log/lynis-report.log

```

---

## Backup & Restore

Moving to a new machine?

**Backup:**

```bash
./scripts/export-config.sh
# Creates: ~/fedora-backups/fedora_dev_backup_DATE.tar.gz

```

**Restore:**

```bash
./scripts/restore-config.sh <path_to_backup.tar.gz>

```

---

## Troubleshooting

**"This script must be run as root or with sudo"**
You selected **Option 1 (Install)** but launched the script as a regular user. The installation phase requires root privileges.
**Solution:** Exit and run `sudo ./bootstrap-fedora.sh`.

**"Curl error (56)" during font install?**
This is usually a temporary network glitch. The script uses DNF which automatically retries mirrors. If validation passes, you can ignore this.

**"Command not found" for `uv` or `cargo`?**
Restart your terminal session. These tools update your `.zshrc` PATH, which needs to be reloaded.

```

### 2. Commit the Fix

```bash
git add docs/SETUP_GUIDE.md
git commit -m "docs: clarify sudo requirement for installation mode"

```