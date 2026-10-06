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
4. `mise install` Node and global npm tools ([`mise/config.toml`](./mise/config.toml))
5. Apply macOS preferences ([`macos.sh`](./macos.sh)) and reset the Dock ([`dock.sh`](./dock.sh))
6. Install the file-mover shortcut ([`file-mover/`](./file-mover)) — plus one manual step, see below
7. Make Homebrew's zsh the login shell

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
│   ├── gitconfig         -> ~/.gitconfig
│   └── ignore            -> ~/.config/git/ignore   (global gitignore)
├── ghostty/
│   └── config            -> ~/.config/ghostty/config
├── ohmyposh/
│   └── prompt.omp.yaml   -> ~/.config/ohmyposh/prompt.omp.yaml
├── pi/
│   ├── settings.json     -> ~/.pi/agent/settings.json
│   └── extensions/       -> ~/.pi/agent/extensions/
├── mise/
│   └── config.toml       -> ~/.config/mise/config.toml
├── ssh/                  # host config only; keys stay in ~/.ssh
│   └── config            -> ~/.ssh/config
├── monsterbrew/          # database scripts; .env and do-ca.crt stay local
│   ├── dev.sh            -> ~/.config/monsterbrew/dev.sh
│   └── prod.sh           -> ~/.config/monsterbrew/prod.sh
├── file-mover/           # Shortcuts automation, files statements from ~/Downloads
│   ├── file-mover.sh     -> ~/.config/file-mover/file-mover.sh
│   ├── process_statement.py
│   ├── file-mover.shortcut.xml
│   └── install.sh
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
- **[mise](https://mise.jdx.dev/)** for Node and global npm tools like Pi
  (`mise/config.toml`; auto-switches on `cd` and reads `.nvmrc`/`.node-version`).
  `mise use -g <tool>` adds a tool to that file, so it's tracked here
- **[zoxide](https://github.com/ajeetdsouza/zoxide)** — `z <partial>` to jump
- Aliases in `zsh/aliases.zsh`; run `alias` to list them

## Terminal

[Ghostty](https://ghostty.org/), JetBrains Mono Nerd Font. Uses the default
theme — browse others with `ghostty +list-themes`.

## File-mover automation

A Shortcuts folder automation runs `file-mover.sh` whenever a file lands in
`~/Downloads`. The script picks up bank-statement exports (filenames containing
`Afschriften` or `Statements`), strips a few columns, renames them, and files
them under `~/Documents/finance/statements`. Every run scans the whole folder,
so a missed trigger is caught by the next one.

It runs through Shortcuts so macOS grants access to just Downloads and
Documents to that one shortcut. A launchd agent would need Full Disk Access
for `/bin/bash`, which every bash-based background job would then get.

`file-mover/install.sh` links the script to `~/.config/file-mover/`, signs
`file-mover.shortcut.xml`, and opens it for import. **The automation itself
can't be scripted** — create it once per Mac:

1. Shortcuts → Settings → Advanced → turn on **Allow Running Scripts**
2. Automations → **+** → **Folder** → Downloads, tick only **Added** →
   **Run Immediately** → Next → pick **File Mover**
3. If macOS asks whether Shortcuts may access Downloads, click **Allow**

- Check state and recent log: `file-mover/install.sh --status`
- View logs: `tail -f ~/.config/file-mover/file-mover.log`
- Pause: toggle the automation off in Shortcuts → Automations
- Tests: `node --test tests/file-mover.test.cjs`

## Notes

- Set your git identity in `git/gitconfig`. For a public repo, use your GitHub
  `@users.noreply.github.com` address to avoid exposing a personal email.
- Machine-specific git settings, like a work email for one directory, go in
  `~/.config/git/local` (included last, not tracked). Recreate it on a new Mac:
  ```
  [includeIf "gitdir:~/code/<client>/"]
  	path = work          # ~/.config/git/work holds [user] email = …
  ```
- Casks with their own updaters (Firefox, VS Code, Ghostty…) are skipped by a
  plain `brew upgrade`; use `brew upgrade --greedy` (aliased to `brewupg`) to
  include them.
