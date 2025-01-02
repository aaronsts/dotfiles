# This file handles all my configuration for the OS X system that I'm using like preferences and other stuff.

source './macos/utils.sh'
execution_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

clear
print_in_purple '\nOS X Config Dotfiles - Aaron Staes\n\n'
ask_for_sudo

chmod u+x ./macos/*.sh
chmod u+x ./macos/software/*.sh

./macos/computer-info.sh
./macos/osx-preferences.sh
./macos/software/xcode-install.sh
./homebrew/install.sh
./homebrew/path.sh

./osx/restart.sh
