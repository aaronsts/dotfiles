#!/usr/bin/env bash
#
# macOS preferences. Safe to re-run.

set -e

echo "▶ Applying macOS preferences…"

# Computer name (friendly name allows spaces; host/Bonjour names use hyphens)
COMPUTER_NAME="A Wizards Laptop"
HOST_NAME="A-Wizards-Laptop"
sudo scutil --set ComputerName  "$COMPUTER_NAME"
sudo scutil --set HostName      "$HOST_NAME"
sudo scutil --set LocalHostName "$HOST_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server \
  NetBIOSName -string "$HOST_NAME"

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

# Trackpad/mouse: disable "natural" scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Keyboard: fast key repeat
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 12

# Security: require password immediately after sleep / screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Software updates: check daily
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Timezone
sudo systemsetup -settimezone "Europe/Brussels" >/dev/null

# Screenshots -> ~/Pictures/Screenshots
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

killall Finder Dock >/dev/null 2>&1 || true
