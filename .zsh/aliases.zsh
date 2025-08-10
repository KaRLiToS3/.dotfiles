########## ALIAS ############

alias ls='lsd'
alias cat='bat'
alias ll='ls -al'
# alias easyeda2kicad='source ~/Projects/venv/easyeda-env/bin/activate && easyeda2kicad'
alias sync-zsh-root='sudo cp ~/.zshrc /root/ && sudo cp -r ~/.zsh /root/ && sudo cp -r ~/.oh-my-zsh /root/ && sudo chown -R root:root /root/.zsh /root/.zshrc /root/.oh-my-zsh'
alias wmount='udisksctl mount -b /dev/nvme0n1p3'
alias wumount='udisksctl unmount -b /dev/nvme0n1p3'

kicadcomponent() {
    # Change the location anytime when switching projects
    # local default_output_location="$HOME/Proyectos/UDMT/esp32-schematic/lib/easyeda2kicad/easyeda2kicad"
    local default_output_location="$HOME/Proyectos/Robotica/COCHE/car-pcb-schematics/lib/easyeda2kicad/easyeda2kicad"
    # Location of the VENV, modify it aswell for other projects
    # source $HOME/Proyectos/UDMT/esp32-schematic/.venv/bin/activate
    source $HOME/Proyectos/Robotica/COCHE/car-pcb-schematics/.venv/bin/activate

    show_help() {
        echo "Usage: kicadcomponent <lcsc_id> <name_for_index>
Example: kicadcomponent C12345 10K-resistor

This command downloads a component from EasyEDA and converts it to KiCad format.
The component will be saved to a fixed default location:
  $default_output_location

The output files will be:
  - easyeda2kicad.pretty (footprint library)
  - easyeda2kicad.kicad_sym (symbol library)  
  - easyeda2kicad.3dshape (3D model library)

Parameters:
  <lcsc_id>        - Required: LCSC component ID (e.g., C12345)
  <name_for_index> - Optional: Human-readable name for the component
                     Used to create an entry in index.txt for easy reference
                     
Example usage:
  kicadcomponent C12345 10K-resistor
  
This will create an entry in index.txt like:
  'Symbol name : RC0603FR-0710KL is a 10K-resistor'
"
    }

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                deactivate
                return 0
                ;;
            -*)
                echo "Unknown option: $1" >&2
                deactivate
                return 1
                ;;
            *)
                # Found first non-option argument, break to process positional args
                break
                ;;
        esac
        shift
    done

    local output=$(easyeda2kicad --full --overwrite --lcsc_id="$1" --output="$default_output_location" 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "Error: easyeda2kicad command failed with exit code $exit_code"
        deactivate
        return 1
    fi
    
    echo "$output"

    if [[ -z "$2" ]]; then
        echo "No name provided for index.txt, skipping index entry."
        deactivate
        return 0
    fi

    local index_file="${default_output_location%/*}/index.txt"

    if [[ ! -f "$index_file" ]]; then
        printf "# Here are the Footprint names of the components, which may be repeated, since they use the same footprint\n\n" > "$index_file"
    fi

    local symbol_line=$(echo "$output" | grep -i 'Footprint name:' | head -1 | sed 's/^[[:space:]]*//')
    
    # Create index file if it doesn't exist and append entry
    echo "$symbol_line is a $2" >> "$index_file"
    deactivate
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