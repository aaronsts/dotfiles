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
brew bundle --file="$DOTFILES/Brewfile"

# ─────────────────────────────────────────────────────────────────────────────
# Symlink config
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Linking config…"
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/ohmyposh" "$HOME/.config/monsterbrew" "$HOME/.pi/agent"

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
link "$DOTFILES/ghostty/config"       "$HOME/.config/ghostty/config"
link "$DOTFILES/ohmyposh/prompt.omp.yaml" "$HOME/.config/ohmyposh/prompt.omp.yaml"
link "$DOTFILES/pi/settings.json"       "$HOME/.pi/agent/settings.json"
link "$DOTFILES/pi/extensions"          "$HOME/.pi/agent/extensions"
link "$DOTFILES/monsterbrew/dev.sh"     "$HOME/.config/monsterbrew/dev.sh"
link "$DOTFILES/monsterbrew/prod.sh"    "$HOME/.config/monsterbrew/prod.sh"

# ─────────────────────────────────────────────────────────────────────────────
# macOS preferences
# ─────────────────────────────────────────────────────────────────────────────
"$DOTFILES/macos.sh"

# ─────────────────────────────────────────────────────────────────────────────
# Dock
# ─────────────────────────────────────────────────────────────────────────────
"$DOTFILES/dock.sh"

# ─────────────────────────────────────────────────────────────────────────────
# File-mover automation (launchd agent watching ~/Downloads)
# ─────────────────────────────────────────────────────────────────────────────
echo "▶ Installing file-mover agent…"
FM_DIR="$DOTFILES/file-mover"
FM_PLIST="com.rnsts.filemover"
FM_LOG_DIR="$HOME/.config/file-mover"
LAUNCH_AGENTS="$HOME/Library/LaunchAgents"

chmod +x "$FM_DIR/file-mover.sh" "$FM_DIR/process_statement.py"
mkdir -p "$FM_LOG_DIR" "$LAUNCH_AGENTS"

# Render the plist from the template with this machine's paths.
sed -e "s|__SCRIPT__|$FM_DIR/file-mover.sh|g" \
    -e "s|__LOG_DIR__|$FM_LOG_DIR|g" \
    "$FM_DIR/$FM_PLIST.plist.template" > "$LAUNCH_AGENTS/$FM_PLIST.plist"

# Reload the agent (ignore errors if it wasn't running yet).
launchctl bootout "gui/$(id -u)" "$LAUNCH_AGENTS/$FM_PLIST.plist" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$LAUNCH_AGENTS/$FM_PLIST.plist"
echo "  file-mover watching ~/Downloads → ~/Documents/finance/statements"

# ─────────────────────────────────────────────────────────────────────────────
# Make brew's zsh the login shell
# ─────────────────────────────────────────────────────────────────────────────
BREW_ZSH="$(brew --prefix)/bin/zsh"
if ! grep -qxF "$BREW_ZSH" /etc/shells; then
  echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
fi
[ "$SHELL" != "$BREW_ZSH" ] && chsh -s "$BREW_ZSH" || true

echo "✅ Done. Quit your terminal and open Ghostty (or run: exec zsh)."
