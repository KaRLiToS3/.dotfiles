# Node.js via fnm — Claude Code auto-update fix

**Problem:** Node installed via pacman is root-owned, so Claude Code couldn't auto-update.

**Fix:** Install Node through `fnm`, which stores versions in `~/.local/share/fnm/` (user-owned).

```bash
sudo pacman -S fnm
fnm install --lts
fnm use lts-latest
npm install -g @anthropic-ai/claude-code
```

Shell init added to `~/.zsh/fnm.zsh` (auto-sourced by `.zshrc`):
```zsh
eval "$(fnm env --use-on-cd --shell zsh)"
```
