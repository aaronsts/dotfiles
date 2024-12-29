source './osx/utils.sh'

# osxprefs : Setting up my OS X preferences

osxprefs() {
	# Show the ~/Library folder
	chflags nohidden ~/Library
	print_success "Library shown."

	# Scroll direction natural : False
	defaults write -g com.apple.swipescrolldirection -bool false
	print_success "Scroll direction natural (Lion style) set to false."

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true
	print_success "Automatically hide and show the Dock."

	# Disable delay for dock
	defaults write com.apple.dock autohide-delay -float 0
  print_success "Disable the hide Dock delay"

	# Display full path in Finder title window
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
	print_success "Finder shows full path in title."


	# Save screenshots in ~/Pictures/Screenshots folder
	mkdir $HOME/Pictures/Screenshots
	defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
	print_success "Screenshot now will appear @ $HOME/Pictures/Screenshots"

	# Check for software updates daily, not just once per week
	defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
	print_success "Software updates checking daily"

	# Always show scrollbars
	defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
	print_success "Scroll bars showing"
	# Possible values: `WhenScrolling`, `Automatic` and `Always`

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	print_success "Finder showing filename extensions"

	# Automatically quit printer app once the print jobs complete
	defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
	print_success "Printer app quit once the prints complete."

	# Set the timezone; see `sudo systemsetup -listtimezones` for other values
	sudo systemsetup -settimezone "Europe/Brussels" > /dev/null
	print_success "Time zone set to : Europe/Brussels"

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0
	print_success "Password required immediately after sleep or screen saver begins."

	# Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	print_success "Safari developer tools and web inspector enabled."
}

osxprefs