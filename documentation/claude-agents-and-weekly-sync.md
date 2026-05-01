# Claude Code agents + weekly git sync

Two custom subagents and a systemd user timer that auto-syncs the repo to GitHub every Sunday.

## Agents

- **`dotfiles-maintainer`** — project-level, model `sonnet`, at `~/.dotfiles/.claude/agents/dotfiles-maintainer.md`. Routine repo work + the documented weekly git sync procedure.
- **`arch-system-fixer`** — user-level, model `opus`, at `~/.claude/agents/arch-system-fixer.md`. System-wide breakage (Hyprland, audio, packages, post-update recovery). Has `WebSearch`/`WebFetch`.

## `.gitignore`

Previously contained only `.git` (no-op). Now excludes editor backups, runtime histories, logs, secrets, and Claude local artifacts. No `git rm --cached` needed — nothing tracked matched.

## Weekly sync — systemd user units

Files live in `~/.dotfiles/.config/systemd/user/` (the whole `~/.config/systemd` is symlinked from the repo).

- `dotfiles-sync.service` — `Type=oneshot`, runs `claude -p "..."` to invoke the dotfiles-maintainer for the sync.
- `dotfiles-sync.timer` — `OnCalendar=Sun *-*-* 20:00:00`, `Persistent=true` so missed runs (laptop off) catch up at next login.

Enable:
```bash
systemctl --user daemon-reload
systemctl --user enable --now dotfiles-sync.timer
```

Inspect:
```bash
systemctl --user list-timers --all | grep dotfiles   # next fire
systemctl --user status dotfiles-sync.service        # last exit code
journalctl --user -u dotfiles-sync.service -f        # follow live log
```

## Why systemd, not `/schedule`

`/schedule` creates remote cloud routines that clone the GitHub repo fresh each run — they cannot see the local working tree where uncommitted dotfiles edits live. A local timer is the only option that can commit local changes.

## Known issue (TODO)

First scheduled run passed pre-flight and categorisation correctly but `git add`/commit/push were blocked by the harness permission sandbox, so nothing was committed. Resolution: allowlist git write commands for the systemd-launched session in `~/.claude/settings.json`. Not yet done.
