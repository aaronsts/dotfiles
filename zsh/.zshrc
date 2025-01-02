# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# Completion Styling
zstyle ':plugin:ez-compinit' 'compstyle' 'zshzoo'

# OhMyPosh theming
if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
    eval "$(oh-my-posh init zsh --config $HOME/dotfiles/ohmyposh/zen.toml)"
fi
