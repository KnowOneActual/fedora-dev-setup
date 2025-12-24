# Fedora Dev Setup Bootstrap - Development Roadmap

**Version:** 1.3.0  
**Last Updated:** December 24, 2025  
**Repository:** https://github.com/KnowOneActual/fedora-dev-setup

## 🚀 Current Focus: Dotfile Mastery (v1.4.0)

**Target Release:** v1.4.0  
**Status:** 🚧 Planning  
**Goal:** Decouple configuration from the repository using GNU Stow for cleaner updates and version control.

### Planned Features
- [ ] **Dotfile Engine:** Replace `cp` based restore with `stow` symlinking.
- [ ] **Repo Restructure:** Organize `dotfiles/` directory to mirror `$HOME` structure (e.g., `dotfiles/zsh/.zshrc`).
- [ ] **Theme Integration:** Add optional Starship or Powerlevel10k theme configuration files.
- [ ] **Nix Support:** Optional Nix package manager installation for hermetic tooling.

---

## ✅ Completed Milestones

### v1.3.0 - Security & UX Polish (Released: Dec 24, 2025)
- **Security Audit:** Added `scripts/60-security.sh` using Lynis to scan and score system hardening.
- **Interactive CLI:** `bootstrap-fedora.sh` now features an interactive menu if no arguments are passed.
- **Visuals:** Automated installation of Nerd Fonts (JetBrains Mono) for correct icon rendering.

### v1.2.0 - Hardware Intelligence
- **GPU Auto-Detect:** NVIDIA (CUDA) and AMD (ROCm) setup.
- **Chassis Optimization:** Laptop (TLP) vs. Desktop (Performance) profiles.
- **Language Stacks:** Node.js, Go, Rust (rustup).

### v1.1.0 - Backup & Restore
- **Snapshot System:** Export/Import packages, extensions, and config files to portable `.tar.gz` archives.

### v1.0.0 - Core Foundation
- **Base System:** DNF optimization, Zsh setup, VSCodium, and Python (uv/pipx) environment.

---

## 🔮 Future Backlog (v1.5+)

- **Ansible Migration:** Investigate migrating shell scripts to Ansible playbooks for enterprise-grade idempotency.
- **Immutable Support:** Add specific support for Fedora Silverblue/Atomic (rpm-ostree).
- **Dashboard:** Create a simple TUI (Text User Interface) dashboard for post-install system status.

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Architecture** | Modular Bash (7 Phases) |
| **Security** | Lynis Integration |
| **Last Verified** | Fedora 43 (Rawhide/Testing) |