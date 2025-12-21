# Git Authentication Setup on Fedora: SSH and GPG Options

You have two solid paths forward for passwordless Git authentication on Fedora: **SSH keys** (recommended for simplicity) or **transferring your existing GPG key** from your Mac. This guide walks you through both approaches so you can choose what fits your workflow.

## Option 1: SSH Key Authentication (Recommended for Most Users)

SSH is the simplest and most common approach. You'll generate a unique key pair on your Fedora machine and register the public key with GitHub.

### Generate your SSH key

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Replace `your_email@example.com` with your actual GitHub email. The `-t ed25519` flag generates a modern, secure key type that GitHub strongly prefers (it's faster and smaller than RSA while maintaining better security).

When prompted for a file location, press Enter to accept the default (`~/.ssh/id_ed25519`). When prompted for a passphrase, you have two choices:
- **With passphrase**: Adds extra security—you'll need to enter it once per session (handled by ssh-agent, not GitHub)
- **Without passphrase**: Quickest path, especially if you already have disk-level encryption

### Add the key to your ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

The first command starts the SSH agent. The second adds your key to it, so you'll only need to enter the passphrase once per session (if you set one).

### Register with GitHub

Copy your public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Then:
1. Go to GitHub → Settings → SSH and GPG keys
2. Click "New SSH key"
3. Paste your entire public key (starts with `ssh-ed25519`)
4. Give it a descriptive name like "Fedora dev machine"

### Test the connection

```bash
ssh -T git@github.com
```

You should see: `Hi [username]! You've successfully authenticated...`

### Configure Git to use SSH by default

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

From now on, use SSH URLs when cloning: `git clone git@github.com:username/repo.git` (not `https://`)

---

## Option 2: Transfer Your Existing GPG Key from Mac to Fedora

If you want to maintain signing consistency with your Mac setup, you can transfer your GPG key. This is more complex but useful if you're already using GPG for commit signing or encryption elsewhere.

### On your Mac (source machine)

First, list your keys to find the one you want:

```bash
gpg --list-keys
```

You'll see output like:
```
pub   rsa4096/ABCDFE01 2023-01-15
uid   [ultimate] Your Name <your_email@example.com>
```

Export both public and secret keys (replace `ABCDFE01` with your actual key ID):

```bash
gpg --output mygpgkey_pub.gpg --armor --export ABCDFE01
gpg --output mygpgkey_sec.gpg --armor --export-secret-key ABCDFE01
```

This creates two ASCII-armored files. Transfer them securely to your Fedora machine via `scp`:

```bash
scp mygpgkey_pub.gpg mygpgkey_sec.gpg user@fedora_machine:~/
```

### On Fedora (destination machine)

Import the keys:

```bash
gpg --import ~/mygpgkey_pub.gpg
gpg --allow-secret-key-import --import ~/mygpgkey_sec.gpg
```

Edit the key to trust it:

```bash
gpg --edit-key your_email@example.com
```

At the `gpg>` prompt:
- Type `trust`
- Select option `5` for ultimate trust
- Type `quit`

Clean up the temporary files:

```bash
rm ~/mygpgkey_pub.gpg ~/mygpgkey_sec.gpg
```

### Configure Git to use your GPG key

Find your key ID:

```bash
gpg --list-keys --keyid-format=short
```

Configure Git globally:

```bash
git config --global user.signingkey ABCDFE01
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

Now all your commits and tags will be automatically signed.

---

## Option 3: Hybrid Approach—Use SSH for Authentication, GPG for Signing

Modern Git supports signing commits with SSH keys, giving you the best of both worlds: simple SSH authentication plus signed commits without managing a separate GPG key. This is growing more common.

### If you've already set up SSH (Option 1)

Configure Git to use your SSH key for signing:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

Then add your SSH key to GitHub as a **signing key** (separate from auth key) in Settings → SSH and GPG keys.

---

## Comparison: Which Path?

| Aspect | SSH Only | GPG (Transferred) | SSH + GPG Signing |
|--------|----------|------------------|-------------------|
| Setup complexity | Simple | Moderate (key transfer needed) | Moderate |
| Authentication | Yes | No (separate concern) | Yes |
| Commit signing | Optional command flag | Automatic | Automatic |
| Cross-machine consistency | Key per machine | Same key everywhere | SSH key per machine |
| Best for | Quick setup, single machine | Multi-machine signing | Power users wanting everything |

---

## Pro Tips for Fedora

### Persist ssh-agent across sessions

Add this to your `~/.bashrc`:

```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
fi
```

### Git Credential Manager (for HTTPS users)

Fedora also supports Git Credential Manager if you're using HTTPS (though SSH is preferred):

```bash
sudo dnf install git-credential-manager
git-credential-manager-core configure
```

### Check what's configured globally

```bash
git config --list --global
```

---

## Recommended Path

For quick setup and avoiding repeated authentication, **Option 1 (SSH)** is recommended. It's the fastest to implement, removes the authentication friction entirely, and works seamlessly across all your repositories. If you later decide you want commit signing, you can layer on SSH-based signing (Option 3) without redoing authentication.

The GPG transfer (Option 2) makes sense if you're signing commits across multiple machines and want cryptographic continuity with your Mac setup.
