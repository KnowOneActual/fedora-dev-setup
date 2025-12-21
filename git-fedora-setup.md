
# Updated Git Authentication Setup on Fedora: SSH and GPG Options (with HTTPS Fix)

**Updated December 21, 2025** - Added prominent HTTPS-to-SSH conversion section for existing repos.

You have two solid paths forward for passwordless Git authentication on Fedora: **SSH keys** (recommended for simplicity) or **transferring your existing GPG key** from your Mac.

## 🚨 FIRST: Fix Existing HTTPS Repos (Most Common Issue)

**GitHub disabled password auth in 2021.** If you see `remote: Invalid username or token. Password authentication is not supported`, your repo is still using HTTPS.

### Check your remote:
```
git remote -v
```

**HTTPS (BROKEN):** `https://github.com/username/repo.git`  
**SSH (GOOD):** `git@github.com:username/repo.git`

### Convert SINGLE repo:
```
git remote set-url origin git@github.com:YOUR_USERNAME/YOUR_REPO.git
git remote -v  # Verify
```

### Bulk convert ALL repos in directory:
```
cd ~/github_projects  # or your projects dir
for repo in */; do
  cd "$repo"
  CURRENT_URL=$(git remote get-url origin)
  if [[ $CURRENT_URL == https://github.com/* ]]; then
    NEW_URL=$(echo $CURRENT_URL | sed 's|https://github.com/|git@github.com:|')
    git remote set-url origin "$NEW_URL"
    echo "✅ Converted $repo"
  else
    echo "⏭️  $repo already uses SSH"
  fi
  cd ..
done
```

**Test:** `git push` should now work without passwords!

---

## Option 1: SSH Key Authentication (Recommended)

### Generate your SSH key
```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Add key to ssh-agent
```
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Register with GitHub
```
cat ~/.ssh/id_ed25519.pub
```
1. GitHub → Settings → SSH and GPG keys → New SSH key
2. Paste entire key 
3. Name: "Fedora dev machine"

### Test connection
```
ssh -T git@github.com
```

### Configure Git identity
```
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

---

## Troubleshooting

**SSH fails:** `ssh -Tvvv git@github.com`  
**No keys loaded:** `ssh-add -l`  
**Multiple keys:** Create `~/.ssh/config`:
```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
```

**Persist ssh-agent** (add to `~/.bashrc`):
```
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
fi
```

---

## Pro Tips
- Always clone SSH: `git clone git@github.com:username/repo.git`
- Check config: `git config --list --glob
