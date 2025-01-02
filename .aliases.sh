# .aliases

# safety first
alias rm='rm -i'
# lock mac
alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
# clean recursively all .DS_Store files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"
# Zsh shell history clean
alias historyc='rm ~/.zsh_history'
# Edit .zshrc config file
alias zshedit='$EDITOR ~/.zshrc'
# Preferred 'cp' implementation
alias cp='cp -iv'
# Preferred 'mv' implementation
alias mv='mv -iv'
# Preferred 'mkdir' implementation
alias mkdir='mkdir -pv'
# Go back 1 directory level
alias ..='cd ../'
# Opens current directory in MacOS Finder
alias f='open -a Finder ./'
# Shows list with colors
alias ls='ls --color'
# Clear terminal display
alias c='clear'
# Edit /etc/hosts file
alias editHosts='sudo $EDITOR /etc/hosts'
# Flush out the DNS Cache
alias flushDNS='dscacheutil -flushcache'
# All listening connections
alias openPorts='sudo lsof -i | grep LISTEN'

## Git
# Pretty git logs
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"

alias gp='git push origin HEAD'
alias gc='git commit'
alias gca='git commit -a'
alias gco='git checkout'
alias gcb='git copy-branch-name'
alias gb='git branch'
alias gst='git status -sb'
alias gac='git add -A && git commit -m'
