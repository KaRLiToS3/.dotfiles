#!/bin/bash
set -euo pipefail

# gpg-agent doubles as the SSH agent; its socket path is stable for the
# current user session but is NOT automatically exported into systemd units.
# Set it explicitly so 'git push' can authenticate over SSH.
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-/run/user/$(id -u)/gnupg/S.gpg-agent.ssh}"

cd /home/Carlos/.dotfiles/ || exit

# 'git status --porcelain' covers untracked files, staged changes, and
# working-tree modifications — no need for three separate git diff calls.
if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit."
    exit 0
fi

git add -A
git commit -m "Auto-sync: $(date +'%Y-%m-%d %H:%M:%S')"
git push origin main