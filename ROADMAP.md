# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.6.0  
**Last Updated:** June 6, 2026  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

## 🚀 Current Focus: Dotfile Mastery (v1.7.0)

**Target Release:** v1.7.0  
**Status:** 🚧 Planning  
**Goal:** Decouple configuration from the repository using GNU Stow for cleaner updates and version control.

### Planned Features
- [ ] **Dotfile Engine:** Replace `cp` based restore with `stow` symlinking.
- [ ] **Repo Restructure:** Organize `dotfiles/` directory to mirror `$HOME` structure (e.g., `dotfiles/zsh/.zshrc`).
- [ ] **Theme Integration:** Add optional Starship or Powerlevel10k theme configuration files.
- [ ] **Nix Support:** Optional Nix package manager installation for hermetic tooling.

---

## ✅ Completed Milestones

### v1.6.0 - Resilient & Interactive Disaster Recovery (Released: June 6, 2026)
- **Interactive Menu & CLI Flags:** Spliced backup and restore workflows directly into `bootstrap-fedora.sh` flags (`--backup`/`--restore`) and menu options.
- **Interactive Backup Selection:** Added auto-discovery in `~/fedora-backups/` with a selection menu.
- **Resilient DNF Recovery:** Implemented best-effort package installation that retries packages individually on failure.
- **Expanded Scope:** Added backing up and restoring of tmux (`.tmux.conf`), custom zsh directories, and GNOME/dconf desktop environment configurations.
- **Correct Path & Permission Restoration:** Resolved dynamic user home directories and user-level file ownership under sudo.

### v1.5.0 - Core Shell & Repositories (Released: April 25, 2026)
- **RPM Fusion:** Added automatic setup of Free and Nonfree repositories.
- **Zsh Default shell:** Automated `chsh` to set Zsh as the user shell.
- **Core Dependencies:** Sourced and installed base requirements (`tmux`, `zsh`, `jq`, etc.) directly.

### v1.4.0 - Identity & Git Automation (Released: Dec 25, 2025)
- **Git & SSH Setup:** Added `scripts/15-git-ssh-setup.sh` to automate global identity and Ed25519 key generation.
- **Agent Persistence:** Automated `ssh-agent` start-up in `.bashrc` and `.zshrc`.
- **Legacy Migration:** Added utility to bulk-convert existing HTTPS repositories to SSH.
- **Verification:** Integrated automated `known_hosts` fingerprinting and GitHub connection testing.

### v1.3.0 - Security & UX Polish (Released: Dec 24, 2025)
- [cite_start]**Security Audit:** Added `scripts/60-security.sh` using Lynis to scan and score system hardening.
- [cite_start]**Interactive CLI:** `bootstrap-fedora.sh` now features an interactive menu if no arguments are passed.
- [cite_start]**Visuals:** Automated installation of Nerd Fonts (JetBrains Mono) for correct icon rendering.

### v1.2.0 - Hardware Intelligence
- [cite_start]**GPU Auto-Detect:** NVIDIA (CUDA) and AMD (ROCm) setup.
- [cite_start]**Chassis Optimization:** Laptop (TLP) vs. Desktop (Performance) profiles.
- [cite_start]**Language Stacks:** Node.js, Go, Rust (rustup).

### v1.1.0 - Backup & Restore
- [cite_start]**Snapshot System:** Export/Import packages, extensions, and config files to portable `.tar.gz` archives.

### v1.0.0 - Core Foundation
- [cite_start]**Base System:** DNF optimization, Zsh setup, VSCodium, and Python (uv/pipx) environment.

---

## 🔮 Future Backlog (v1.6+)

- [cite_start]**Ansible Migration:** Investigate migrating shell scripts to Ansible playbooks for enterprise-grade idempotency.
- [cite_start]**Immutable Support:** Add specific support for Fedora Silverblue/Atomic (rpm-ostree).
- [cite_start]**Dashboard:** Create a simple TUI (Text User Interface) dashboard for post-install system status.

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Architecture** | Modular Bash (8 Phases) |
| **Security** | Lynis Integration |
| **Last Verified** | Fedora 43 (Rawhide/Testing) |