# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting encode64)
source $ZSH/oh-my-zsh.sh

########## POWERLEVEL10K ############

# source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

#Neofetch
#neofetch

########## PLUGINS ############
# autoload -Uz compinit
# compinit
# fpath+=/usr/share/zsh/site-functions
# source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
# source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

########## LOAD FROM .ZSH ############

for config in ~/.zsh/*.zsh; do
    if [[ -f "$config" ]]; then
        source "$config"
    fi
done