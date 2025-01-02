source './osx/utils.sh'

# brew_packages : Asks to install packages and software

brew_packages() {

	if cmd_exists "brew"; then

		print_in_blue "Updating brew packages ..."
		execute "brew update"
		brew upgrade --all

		# Shell Specific

		print_in_blue "Shell packages"
		brew_install "zsh"
		brew_install "git"
		brew_install "tree"
		brew_install "gh"
		brew_install "oh-my-posh"
		brew_install "antidote"

		# Developer
		print_in_blue "Developer packages"
		brew_install "nvm"

		# OSX Software

		print_in_blue "OS X Apps."
		./brew-casks.sh

		brew cleanup
	else
		print_error 'brew not installed, the packages cannot be installed without brew.'
		./osx/software/brew-install.sh
	fi
}

brew_packages
