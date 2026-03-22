# lal — List Aliases

A tiny shell utility to **list**, **add**, **modify**, and **remove** your shell aliases — right from the terminal.

Works with **bash** and **zsh**.

```
  Aliases in /Users/you/.zshrc
  ──────────────────────────────────────────
   1.  ll='ls -la'
   2.  gs='git status'
   3.  dc='docker compose'

  [a] Add   [m] Modify   [r] Remove   [q] Quit
  >
```

---

## Installation

### Quick setup (recommended)

```bash
git clone git@github.com:KevinJoseP/listAlias.git
cd listAlias
bash install.sh
```

Then **open a new terminal** (or run `source ~/.zshrc`) and type:

```bash
lal
```

### Manual setup

Source `lal.sh` directly in your shell config:

```bash
# Add this line to your ~/.zshrc or ~/.bashrc
source /path/to/listAlias/lal.sh
```

Restart your shell, then run `lal`.

---

## Usage

Run `lal` to see all aliases defined in your shell rc file. Then pick an action:

### `a` — Add a new alias

```
  > a

  Alias name : gp
  Command    : git push

  + Added: alias gp='git push'
  Saved to /Users/you/.zshrc and active in this session.
```

The alias is written to your rc file **and** activated immediately — no need to restart.

### `m` — Modify an existing alias

```
  > m

  Alias # to modify (1-3): 2
  Current: gs='git status'
  New command for 'gs': git status --short

  ~ Modified: gs -> 'git status --short'
  Saved to /Users/you/.zshrc and active in this session.
```

### `r` — Remove an alias

```
  > r

  Alias # to remove (1-3): 3
  Remove  dc='docker compose'  ? [y/N] y

  - Removed: dc='docker compose'
  Deleted from /Users/you/.zshrc and current session.
```

### `q` — Quit

Press `q` (or any other key) to exit without changes.

---

## Uninstall

```bash
cd listAlias
bash uninstall.sh
```

This removes the `source` line from your rc file(s). You can then delete the `listAlias` directory.

---

## How it works

- `lal` is a shell **function** (not a binary) so it can modify aliases in your current session
- It parses your `~/.zshrc` or `~/.bashrc` for lines starting with `alias`
- Changes are written directly to the rc file so they persist across sessions
- All edits happen in-place — no temp databases, no config files, just your rc file

## License

MIT
