#!/usr/bin/env bash
#
# macOS preferences. Safe to re-run.
# No `set -e`: settings are independent, so one failure shouldn't skip the rest.

echo "▶ Applying macOS preferences…"

# Computer name (friendly name allows spaces; host/Bonjour names use hyphens)
COMPUTER_NAME="A Wizards Laptop"
HOST_NAME="A-Wizards-Laptop"
sudo scutil --set ComputerName  "$COMPUTER_NAME"
sudo scutil --set HostName      "$HOST_NAME"
sudo scutil --set LocalHostName "$HOST_NAME"

# Appearance: dark mode, and prefer tabs when opening documents
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleWindowTabbingMode -string "always"

# Finder: show all extensions, list view, full path in title, and ~/Library
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
chflags nohidden ~/Library

# Dock: auto-hide with no delay
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool "false"

# Trackpad/mouse: swipe down scrolls down ("natural" scrolling off)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Keyboard: fast key repeat (15 is the shortest delay System Settings allows)
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Security: require password immediately after sleep / screensaver.
# The old com.apple.screensaver keys are ignored since High Sierra.
echo "  Setting screen lock to immediate (asks for your login password)…"
sysadminctl -screenLock immediate -password - \
  || echo "  ⚠ Screen lock not set — do it in System Settings › Lock Screen"

# Timezone
sudo systemsetup -settimezone "Europe/Brussels" >/dev/null

# Screenshots -> ~/Pictures/Screenshots
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

killall Finder Dock >/dev/null 2>&1 || true
