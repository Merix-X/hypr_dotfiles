# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Nastavení tématu - robbyrussell
ZSH_THEME="robbyrussell"

# Výběr pluginů
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Načtení Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ====== EXPORTY A SYSTÉMOVÉ CESTY ======
export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools
export PATH="$HOME/.local/bin:$PATH"

# ====== POKROČILÉ DOPLŇOVÁNÍ (ZSTYLE) ======
zstyle ':completion:*' menu select

# ====== ALIASY (OSOBNÍ KONFIGURACE) ======

# Práce se soubory a barvy
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'

# Bezpečnější manipulace s daty
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Správa balíčků Arch Linux (Pacman)
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias remove='sudo pacman -R'
alias pkg='pacman -Ss'
alias cleanup='sudo pacman -Rns $(pacman -Qdtq)'
alias scan='./nscan.sh'

# Multimédia a utility
alias yta='yt-dlp -x -f bestaudio'
alias yt='yt-dlp'
alias zshrc='sudo nano ~/.zshrc'
alias home='cd ~'
alias sys='btop'
alias git-push='./push-to-git.sh'

# Zábava a vizualizace
alias matrix='cmatrix -C green -u 5 -s'
alias quote='fortune -s quotes | cowsay | lolcat'

# Komplexní reload systému a služeb
alias reload='echo "Restarting system services..."; \
    sudo pacman -Sy && \
    sudo systemctl daemon-reload && \
    systemctl --user daemon-reload && \
    [ -f /usr/bin/needrestart ] && sudo needrestart -r l; \
    hyprctl reload && \
    exec zsh'

# ====== AUTOMATICKÉ SPUŠTĚNÍ PŘI PŘIHLÁŠENÍ ======

fastfetch                  # Ukáže logo Archu a info o PC při startu
eval "$(zoxide init zsh)"  # Inicializace chytrého skákání (pro bash dej bash)
alias cd="z"               # Teď stačí psát 'cd slozka' a zoxide se učí cesty
