# .aliases

alias rm='rm -i' # safety first
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend" # lock mac
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete" # clean recursively all .DS_Store files
alias historyc='rm ~/.zsh_history' # Zsh shell history clean
alias zshedit='$EDITOR ~/.zshrc' # Edit .zshrc config file
alias cp='cp -iv' # Preferred 'cp' implementation
alias mv='mv -iv' # Preferred 'mv' implementation
alias mkdir='mkdir -pv' # Preferred 'mkdir' implementation
alias ..='cd ../' # Go back 1 directory level
alias f='open -a Finder ./' # Opens current directory in MacOS Finder
alias ls='ls --color' # Shows list with colors
alias c='clear' # Clear terminal display
alias editHosts='sudo $EDITOR /etc/hosts' # Edit /etc/hosts file
alias flushDNS='dscacheutil -flushcache' # Flush out the DNS Cache
alias openPorts='sudo lsof -i | grep LISTEN' # All listening connections
