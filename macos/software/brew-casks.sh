source './osx/utils.sh'

# brew_packages : Asks to install these package through brew.

brew_casks() {

	print_in_blue "Installing brew cask."

	brew_install "caskroom/cask/brew-cask"
	brew_install "caskroom/versions"

	brew_cask_install "visual-studio-code"
	brew_cask_install "wezterm"
	brew_cask_install "rectangle"
	brew_cask_install "bitwarden"
	brew_cask_install "firefox"
	brew_cask_install "spotify"
	brew_cask_install "obsidian"
}

brew_casks