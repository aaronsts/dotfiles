1. Missing from the Brewfile

- Command-line tools you use:
  - libpq — your zshrc already adds it to the PATH for psql.
  - doctl, the DigitalOcean CLI.
  - uv, which graphify needs.
  - opencode and herdr.
- Apps installed through Homebrew but not listed: claude, claude-code, discord, obsidian.
- Apps you installed by hand that Homebrew can install (I checked each one exists): docker-desktop, google-chrome, spotify, chatgpt, proton-mail, microsoft-teams, stremio, affinity, citrix-workspace, recordly.
- To stop this drifting again: brew bundle cleanup --file=~/code/dotfiles/Brewfile lists everything installed but not in the Brewfile, without removing anything. It would make a good alias.

2. Claude Code config

- You already track your Pi config the same way.
- Worth linking: ~/.claude/CLAUDE.md, statusline.sh, hooks/ (including your block-env-reads.sh), output-styles/tldr.md and your own graphify skill.
- settings.json: test it first. Claude Code rewrites that file, which might replace the link with a plain copy.

3. Global git ignore file

- ~/.config/git/ignore exists and makes git ignore .claude/settings.local.json in every repo, but it isn't in the repo, so it would be lost.
- It's a one-file add, and a good place for .DS_Store too.

4. SSH config

- ~/.ssh/config holds your GitHub and Bitbucket entries and is safe to track.
- Never put the keys themselves in the repo; see the checklist below.

5. VS Code

- Extensions: the Brewfile can install them with vscode "publisher.extension" lines. brew bundle dump --vscode --file=- prints yours (18 extensions).
- Settings: link settings.json the way your other configs are linked.

6. Small upgrades

- fzf: a fuzzy search for shell history on Ctrl-R. It's probably the single biggest everyday improvement.
- Rectangle: export its settings to the repo from its preferences and import them on the new Mac.

7. Cleanup in the repo

- The root .gitconfig does nothing. install.sh never links it, and it has a different name and email from git/gitconfig. I'd delete it.
- The repo is public, so both files expose a personal email address. Your own README suggests GitHub's noreply address instead.
- Remove leftovers from this Mac: fnm, Homebrew's pnpm (corepack covers it now) and Amphetamine.

Doesn't belong in dotfiles, but don't forget it when you move:

- your SSH keys
- the monsterbrew .env file and do-ca.crt
- cloning ~/code/personal/pi-subagents
- signing in to gh and Claude Code again
