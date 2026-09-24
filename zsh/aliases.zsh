# ~/.aliases.zsh  (symlinked from dotfiles/zsh/aliases.zsh)

# ── Navigation ───────────────────────────────────────────────────
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
mkcd() { mkdir -p "$1" && cd "$1"; }        # make a dir and step into it

# ── Listing (macOS ls; -G adds color) ────────────────────────────
alias ls='ls -G'
alias ll='ls -lahG'                         # long, human sizes, hidden
alias la='ls -AG'

# ── Shell ────────────────────────────────────────────────────────
alias reload='exec zsh'                     # restart the shell
alias zshrc='$EDITOR ~/.zshrc'              # edit shell config
alias c='clear'
alias path='echo -e ${PATH//:/\\n}'         # print $PATH one entry per line

# ── Homebrew ─────────────────────────────────────────────────────
alias brewup='brew update && brew upgrade && brew cleanup'

# ── Git ──────────────────────────────────────────────────────────
alias gst='git status -sb'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate -20'

# ── Misc ─────────────────────────────────────────────────────────
alias ip='curl -s ifconfig.me'              # public IP
alias localip='ipconfig getifaddr en0'      # LAN IP
alias cleanup='find . -type f -name .DS_Store -delete'
