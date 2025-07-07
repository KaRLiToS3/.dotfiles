########## TERMINAL COLORS ############

# Configurar colores básicos de la terminal para que coincidan con el esquema rojo/negro
export TERM="xterm-256color"

# Colores para ls (usando LS_COLORS)
export LS_COLORS="di=1;31:fi=0;37:ln=1;91:pi=40;33:so=1;35:bd=40;33;1:cd=40;33;1:or=1;05;37;41:mi=1;05;37;41:ex=1;91:*.tar=1;31:*.tgz=1;31:*.arc=1;31:*.arj=1;31:*.taz=1;31:*.lha=1;31:*.lz4=1;31:*.lzh=1;31:*.lzma=1;31:*.tlz=1;31:*.txz=1;31:*.tzo=1;31:*.t7z=1;31:*.zip=1;31:*.z=1;31:*.Z=1;31:*.dz=1;31:*.gz=1;31:*.lrz=1;31:*.lz=1;31:*.lzo=1;31:*.xz=1;31:*.bz2=1;31:*.bz=1;31:*.tbz=1;31:*.tbz2=1;31:*.tz=1;31:*.deb=1;31:*.rpm=1;31:*.jar=1;31:*.war=1;31:*.ear=1;31:*.sar=1;31:*.rar=1;31:*.alz=1;31:*.ace=1;31:*.zoo=1;31:*.cpio=1;31:*.7z=1;31:*.rz=1;31:*.cab=1;31"

# Colores para grep (coincidiendo con el esquema)
export GREP_COLOR="1;31"  # Rojo brillante para coincidencias
export GREP_COLORS="mt=1;31:fn=1;33:ln=1;32:bn=1;32:se=1;36"

# Configurar colores para man pages
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold - rojo
export LESS_TERMCAP_md=$'\e[1;31m'     # begin blink - rojo
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\e[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\e[1;33m'     # begin underline - naranja
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

# Configurar lsd con colores personalizados (ya tienes alias ls='lsd')
export LSD_COLORS="di=1;31:fi=0;37:ln=1;91:pi=40;33:so=1;35:bd=40;33;1:cd=40;33;1:or=1;05;37;41:mi=1;05;37;41:ex=1;91"

# Configurar bat con tema oscuro (ya tienes alias cat='bat')
export BAT_THEME="base16"

# Configurar colores para git diff
git config --global color.diff.meta "red bold"
git config --global color.diff.frag "red bold"
git config --global color.diff.old "red"
git config --global color.diff.new "green"
git config --global color.status.added "red"
git config --global color.status.changed "red"
git config --global color.status.untracked "red"