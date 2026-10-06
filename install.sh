#!/usr/bin/env bash
#
# dotfiles installer.
# Installs Homebrew + packages (Brewfile), symlinks config into place,
# applies macOS preferences, and sets brew's zsh as the login shell.
# Re-runnable. Real config files live in this repo and are symlinked, so
# editing them here updates your machine without re-running everything.
#
# Usage:  ./install.sh

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "▶ dotfiles setup"
sudo -v   # cache credentials for macOS defaults + changing the login shell

# ─────────────────────────────────────────────────────────────────────────────
# Homebrew
# ─────────────────────────────────────────────────────────────────────────────
if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Installing Homebrew (also installs Xcode Command Line Tools)…"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew update

# ─────────────────────────────────────────────────────────────────────────────
# Packages
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Installing packages from Brewfile…"
brew bundle --file="$DOTFILES/Brewfile" \
  || echo "⚠ Some Brewfile packages failed — continuing (re-run brew bundle later)"

# ─────────────────────────────────────────────────────────────────────────────
# Symlink config
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Linking config…"
mkdir -p "$HOME/.config/git" "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/monsterbrew" "$HOME/.config/mise" "$HOME/.pi/agent"

link() {
  local src="$1" dest="$2"
  # Back up a real (non-symlink) file once, then link.
  if [ -e "$dest" ] && [ ! -L "$dest" ] && [ ! -e "$dest.pre-dotfiles" ]; then
    mv "$dest" "$dest.pre-dotfiles"
  fi
  ln -sfn "$src" "$dest"
  echo "  linked $dest"
}

link "$DOTFILES/zsh/zshrc"            "$HOME/.zshrc"
link "$DOTFILES/zsh/zsh_plugins.txt"  "$HOME/.zsh_plugins.txt"
link "$DOTFILES/zsh/aliases.zsh"      "$HOME/.aliases.zsh"
link "$DOTFILES/git/gitconfig"        "$HOME/.gitconfig"
link "$DOTFILES/git/ignore"           "$HOME/.config/git/ignore"
link "$DOTFILES/ghostty/config"       "$HOME/.config/ghostty/config"
link "$DOTFILES/ohmyposh/prompt.omp.yaml" "$HOME/.config/ohmyposh/prompt.omp.yaml"
link "$DOTFILES/pi/settings.json"       "$HOME/.pi/agent/settings.json"
link "$DOTFILES/pi/extensions"          "$HOME/.pi/agent/extensions"
link "$DOTFILES/monsterbrew/dev.sh"     "$HOME/.config/monsterbrew/dev.sh"
link "$DOTFILES/monsterbrew/prod.sh"    "$HOME/.config/monsterbrew/prod.sh"
link "$DOTFILES/mise/config.toml"       "$HOME/.config/mise/config.toml"

# ─────────────────────────────────────────────────────────────────────────────
# Runtimes (node + global npm tools from mise/config.toml)
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Installing mise tools…"
mise install || echo "⚠ mise install had errors — continuing (re-run mise install later)"

# ─────────────────────────────────────────────────────────────────────────────
# macOS preferences
# ─────────────────────────────────────────────────────────────────────────────
"$DOTFILES/macos.sh" || echo "⚠ macos.sh had errors — continuing with the rest of the setup"

# ─────────────────────────────────────────────────────────────────────────────
# Dock
# ─────────────────────────────────────────────────────────────────────────────
"$DOTFILES/dock.sh" || echo "⚠ dock.sh had errors — continuing with the rest of the setup"

# ─────────────────────────────────────────────────────────────────────────────
# File-mover automation (Shortcuts folder automation on ~/Downloads)
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Installing file-mover…"
"$DOTFILES/file-mover/install.sh" || echo "⚠ file-mover install had errors — continuing (re-run file-mover/install.sh later)"

# ─────────────────────────────────────────────────────────────────────────────
# Make brew's zsh the login shell
# ─────────────────────────────────────────────────────────────────────────────
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -qxF "$BREW_ZSH" /etc/shells; then
  echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
fi
[ "$SHELL" != "$BREW_ZSH" ] && chsh -s "$BREW_ZSH" || true

echo "✅ Done. Quit your terminal and open Ghostty (or run: exec zsh)."
