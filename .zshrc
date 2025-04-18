# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##########POWERLEVEL10K############

source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

##########POWERLEVEL10K############

#Neofetch
#neofetch

#Autocompletion
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

alias ls='lsd'
alias cat='bat'

locate() {
    find / -type f -name "*$1*" 2>/dev/null
}


source /home/Carlos/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Git SSH load Key
# Cargar SSH Agent de forma persistente
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" > /dev/null
fi

# Añadir clave SSH solo si no está cargada
if ! ssh-add -l &>/dev/null; then
    ssh-add ~/.ssh/github </dev/tty
fi

# Comando especial de pacman para registrar programas nuevos en ~/.dotfiles/pkgs/pkglist.txt
pctrack() {
    if sudo pacman -Syu "$@"; then
        for pkg in "$@"; do
            if ! grep -qx "$pkg" ~/.dotfiles/pkgs/pkglist.txt; then
                echo -e "$pkg\n" >> ~/.dotfiles/pkgs/pkglist.txt
            fi
        done
    fi
}
