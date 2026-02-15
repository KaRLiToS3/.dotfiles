########## ALIAS ############

alias ls='lsd'
alias cat='bat'
alias ll='ls -al'
# alias easyeda2kicad='source ~/Projects/venv/easyeda-env/bin/activate && easyeda2kicad'
alias sync-zsh-root='sudo cp ~/.zshrc /root/ && sudo cp -r ~/.zsh /root/ && sudo cp -r ~/.oh-my-zsh /root/ && sudo chown -R root:root /root/.zsh /root/.zshrc /root/.oh-my-zsh'
alias wmount='udisksctl mount -b /dev/nvme0n1p3'
alias wumount='udisksctl unmount -b /dev/nvme0n1p3'
alias arduino-ide='arduino-ide --ozone-platform=x11'

kicadcomponent() {
    # Change the location anytime when switching projects
    local default_output_location="$HOME/Proyectos/UDMT/esp32-schematic/lib/easyeda2kicad/easyeda2kicad"
    # local default_output_location="$HOME/Proyectos/Robotica/COCHE/car-pcb-schematics/lib/easyeda2kicad/easyeda2kicad"
    # Location of the VENV, modify it aswell for other projects
    source $HOME/Proyectos/UDMT/esp32-schematic/.venv/bin/activate
    # source $HOME/Proyectos/Robotica/COCHE/car-pcb-schematics/.venv/bin/activate

    show_help() {
        echo "Usage: kicadcomponent [OPTIONS] <lcsc_id>
Example: kicadcomponent C12345
         kicadcomponent --3d C12345
         kicadcomponent --footprint C12345

This command downloads a component from EasyEDA and converts it to KiCad format.
The component will be saved to a fixed default location:
$default_output_location

The output files will be:
  - easyeda2kicad.pretty (footprint library)
  - easyeda2kicad.kicad_sym (symbol library)  
  - easyeda2kicad.3dshape (3D model library)

Parameters:
  <lcsc_id>        - Required: LCSC component ID (e.g., C12345)

Options:
  --3d             - Download only the 3D model
  --footprint      - Download only the footprint
  --symbol         - Download only the symbol
  -h, --help       - Show this help message
                     
Example usage:
  kicadcomponent C12345           # Download full component
  kicadcomponent --3d C12345      # Download only 3D model
  kicadcomponent --footprint C12345  # Download only footprint
  kicadcomponent --symbol C12345     # Download only symbol
"
    }

    local output=""
    local exit_code=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            --3d)
                output=$(easyeda2kicad --3d --overwrite --lcsc_id="$2" --output="$default_output_location" 2>&1)
                exit_code=$?
                break
                ;;
            --footprint)
                output=$(easyeda2kicad --footprint --overwrite --lcsc_id="$2" --output="$default_output_location" 2>&1)
                exit_code=$?
                break
                ;;
            --symbol)
                output=$(easyeda2kicad --symbol --overwrite --lcsc_id="$2" --output="$default_output_location" 2>&1)
                exit_code=$?
                break
                ;;
            -*)
                echo -e "\033[31mUnknown option: $1\033[0m" >&2
                show_help
                return 1
                ;;
            *)
                # Default case: full download
                output=$(easyeda2kicad --full --overwrite --lcsc_id="$1" --output="$default_output_location" 2>&1)
                exit_code=$?
                break
                ;;
        esac
    done

    if [[ -z "$output" ]]; then
        echo -e "\033[31mError: No LCSC ID provided\033[0m \n" >&2
        show_help
        deactivate
        return 1
    fi
    
    if [[ $exit_code -ne 0 ]]; then
        echo -e "\033[31mError: easyeda2kicad command failed with exit code $exit_code"
        echo -e "$output\033[0m\n"
        show_help
        deactivate
        return 1
    fi
    
    echo "$output"
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