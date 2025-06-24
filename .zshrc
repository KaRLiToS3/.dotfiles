# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

########## POWERLEVEL10K ############

source ~/.zsh/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

########## POWERLEVEL10K ############

#Neofetch
#neofetch

########## AUTOCOMPLETION ############
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
########## AUTOCOMPLETION ############


########## SSH ############
# Git SSH load Key
# Cargar SSH Agent de forma persistente
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#     eval "$(ssh-agent -a "$SSH_AUTH_SOCK" -s)" > /dev/null
# fi

#Añadir clave SSH solo si no está cargada
if ! ssh-add -l &>/dev/null; then
    ssh-add ~/.ssh/github < /dev/tty
fi
########## SSH ############


########## ALIAS ############

alias ls='lsd'
alias cat='bat'
alias ll='ls -al'
alias easyeda2kicad='source ~/Projects/venv/easyeda-env/bin/activate && easyeda2kicad'

kicadcomponent() {
    for arg in "$@"; do
        if [[ $arg == "-h" ]]; then
            echo "Use: kicadcomponent <lcsc_id> <output_location>"
            echo "Example: kicadcomponent C12345 ~/Documents/easyeda2kicad"
            echo "The output location must be the location of the lib and the name of the files"
            echo "Supose the lib name is easyeda2kicad, then the output will be:"
            echo "easyeda2kicad.pretty in ~/Documents"
            echo "easyeda2kicad.kicad_sym in ~/Documents"
            echo "easyeda2kicad.3dshape in ~/Documents"
            echo "If the lib name is . then all files will be hidden"
            return 0
        fi
    done
    
    # MODIFY THE LOCATION OF THE VENV
    source ~/Projects/venv/easyeda-env/bin/activate
    easyeda2kicad --full --overwrite --lcsc_id="$1" --output="$2"
}

locate() {
    find / -type f -name "*$1*" 2>/dev/null
}

# Comando especial de pacman para registrar programas nuevos en ~/.dotfiles/pkgs/pkglist.txt
pactrack() {
    # Guardar los argumentos originales para pasarlos a pacman
    local original_args=("$@")
    # Ejecutar pacman primero
    if sudo pacman "${original_args[@]}"; then
        # Detectar si es una operación de eliminación
        if [[ "$1" == -R* ]]; then
            # Procesar los paquetes para eliminar (saltando el primer argumento que es -R, -Rs, etc.)
            for pkg in "${@:2}"; do
                # Ignorar argumentos que son flags
                if [[ "$pkg" != -* ]]; then
                    # Eliminar el paquete del archivo
                    sed -i "/^$pkg$/d" ~/.dotfiles/pkgs/pkglist.txt
                fi
            done
        # Detectar si es una operación de instalación
        elif [[ "$1" == -S* || "$1" == -U* ]]; then
            # Procesar los paquetes para instalar (saltando el primer argumento)
            for pkg in "${@:2}"; do
                # Ignorar argumentos que son flags
                if [[ "$pkg" != -* ]]; then
                    # Extraer solo el nombre base del paquete (sin versión)
                    local pkgname=$(echo "$pkg" | sed 's/[<>=].*$//')
                    # Añadir el paquete si no existe ya en la lista
                    if ! grep -qx "$pkgname" ~/.dotfiles/pkgs/pkglist.txt; then
                        echo "$pkgname" >> ~/.dotfiles/pkgs/pkglist.txt
                    fi
                fi
            done
        fi
    fi
}

yaytrack() {
    # Guardar los argumentos originales para pasarlos a yay
    local original_args=("$@")
    # Ejecutar yay primero
    if yay "${original_args[@]}"; then
        # Detectar si es una operación de eliminación
        if [[ "$1" == -R* ]]; then
            # Procesar los paquetes para eliminar (saltando el primer argumento que es -R, -Rs, etc.)
            for pkg in "${@:2}"; do
                # Ignorar argumentos que son flags
                if [[ "$pkg" != -* ]]; then
                    # Eliminar el paquete del archivo
                    sed -i "/^$pkg$/d" ~/.dotfiles/pkgs/pkglist.txt
                fi
            done
        # Detectar si es una operación de instalación
        elif [[ "$1" == -S* || "$1" == -U* ]]; then
            # Procesar los paquetes para instalar (saltando el primer argumento que es el segundo elemento)
            for pkg in "${@:2}"; do
                # Ignorar argumentos que son flags
                if [[ "$pkg" != -* ]]; then
                    # Extraer solo el nombre base del paquete (sin versión)
                    local pkgname=$(echo "$pkg" | sed 's/[<>=].*$//')
                    # Añadir el paquete si no existe ya en la lista
                    if ! grep -qx "$pkgname" ~/.dotfiles/pkgs/pkglist.txt; then
                        echo "$pkgname" >> ~/.dotfiles/pkgs/pkglist.txt
                    fi
                fi
            done
        fi
    fi
}
