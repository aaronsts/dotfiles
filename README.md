# dotfiles

Personal macOS setup. One script installs Homebrew and all packages, symlinks
the config files into place, applies macOS preferences, and sets zsh as the
login shell.

## Fresh Mac

You need `git` before you can clone, which comes with the Xcode Command Line
Tools. On a brand-new machine:

```sh
xcode-select --install          # wait for it to finish
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

(`install.sh` also installs the Command Line Tools via Homebrew if they're
missing, but you need them first just to run `git clone`.)

Re-running `./install.sh` any time is safe.

## What it does

1. Install Homebrew (if missing)
2. `brew bundle` everything in the [`Brewfile`](./Brewfile)
3. Symlink the config files below into `~`
4. Apply macOS preferences ([`macos.sh`](./macos.sh))
5. Install the file-mover launchd agent ([`file-mover/`](./file-mover))
6. Make Homebrew's zsh the login shell

## Layout

```
dotfiles/
├── install.sh            # orchestrator
├── Brewfile              # packages (formulae + casks)
├── macos.sh              # system defaults
├── .gitignore
├── zsh/
│   ├── zshrc             -> ~/.zshrc
│   ├── zsh_plugins.txt   -> ~/.zsh_plugins.txt   (antidote plugin list)
│   └── aliases.zsh       -> ~/.aliases.zsh
├── git/
│   └── gitconfig         -> ~/.gitconfig
├── ghostty/
│   └── config            -> ~/.config/ghostty/config
├── ohmyposh/
│   └── prompt.omp.yaml   -> ~/.config/ohmyposh/prompt.omp.yaml
├── pi/
│   ├── settings.json     -> ~/.pi/agent/settings.json
│   └── extensions/       -> ~/.pi/agent/extensions/
├── file-mover/           # launchd agent, watches ~/Downloads
│   ├── file-mover.sh
│   ├── process_statement.py
│   └── com.rnsts.filemover.plist.template
└── archive/              # retired configs kept for reference (e.g. wezterm)
```

The config files live in this repo and are symlinked into place, so editing
them here updates your machine immediately — no need to re-run the installer.
If a real (non-symlink) file or directory already exists at a target, the installer backs it
up once to `<file>.pre-dotfiles` before linking. Only Pi settings and hand-written
extensions are linked; Pi credentials, sessions, caches, and trust state stay local.
The settings include a local pi-subagents package at
`~/code/personal/pi-subagents`; clone it there before using Pi on a new machine.
Each project still needs `.pi/local-subagents.json` to enable subagents and
select its child model.

## Shell

- **zsh** with [antidote](https://github.com/mattmc3/antidote) for plugins
- **[oh-my-posh](https://ohmyposh.dev/)** prompt — two-line, terminal-palette
  colors, clock, git, and a transient prompt (`prompt.omp.yaml`)
- **[fnm](https://github.com/Schniz/fnm)** for Node (auto-switches on `cd`; run
  `fnm install --lts` once to get a runtime)
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — `z <partial>` to jump
- Aliases in `zsh/aliases.zsh`; run `alias` to list them

## Terminal

[Ghostty](https://ghostty.org/), JetBrains Mono Nerd Font. Uses the default
theme — browse others with `ghostty +list-themes`.

## File-mover automation

A launchd agent watches `~/Downloads` for bank-statement exports (filenames
containing `Afschriften` or `Statements`), strips a few columns, renames them,
and files them under `~/Documents/finance/statements`. It runs continuously and
restarts on login. `install.sh` renders the plist from
`file-mover/com.rnsts.filemover.plist.template` with this machine's paths and
loads it via `launchctl`.

- View logs: `tail -f ~/.config/file-mover/file-mover.log`
- Stop: `launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.rnsts.filemover.plist`
- Start: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.rnsts.filemover.plist`

## Notes

- Set your git identity in `git/gitconfig`. For a public repo, use your GitHub
  `@users.noreply.github.com` address to avoid exposing a personal email.
- Casks with their own updaters (Firefox, VS Code, Ghostty…) are skipped by a
  plain `brew upgrade`; use `brew upgrade --greedy` (aliased to `brewupg`) to
  include them.
