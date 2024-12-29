# This file handles all my configuration for the OS X system that I'm using like preferences and other stuff.

source './macos/utils.sh'
execution_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

clear
print_in_purple '\nOS X Config Dotfiles - Aaron Staes\n\n'
ask_for_sudo

chmod u+x ./macos/*.sh
chmod u+x ./macos/software/*.sh

./macos/computer-info.sh
./macos/osx-preferences.sh
./macos/software/xcode-install.sh

# Copying the dotfiles to the home folder
# .zshrc, .gitconfig, .gitignore -> $HOME
for file in $execution_dir/.{zshrc,gitconfig,gitignore}; do
	execute "cp -iv "$file" $HOME/"
done;
unset file;

./macos/git-config.sh

directory_exists "$HOME/.dotfiles"

# .files -> $HOME/.dotfiles/
for files in $execution_dir/.{aliases,functions,exports,extra}; do
	execute "cp -iv "$files" $HOME/.dotfiles/";
done;
unset files;
print_success ".files copied to your $HOME/.dotfiles/ directory."

execute "cp -iv $execution_dir/starship.toml $HOME/.config/"
print_success "starship.toml copied to your $HOME/.config/ directory."

./osx/software/brew-install.sh
./osx/software/brew-formulae.sh

./osx/restart.sh