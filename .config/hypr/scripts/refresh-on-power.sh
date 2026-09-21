#!/bin/sh
# Cambia la frecuencia del panel al enchufar/desenchufar el cargador.
# Qué modo toca lo decide hyprland.lua (set_refresh_for_power); aquí sólo se
# escuchan los eventos de udev de power_supply y se le avisa.

sock="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock"

udevadm monitor --udev --subsystem-match=power_supply | while read -r line; do
    case $line in UDEV*) ;; *) continue ;; esac
    # Si la sesión de Hyprland que nos lanzó ya no existe, salir en vez de quedar huérfano
    [ -S "$sock" ] || exit 0
    hyprctl eval 'set_refresh_for_power()' >/dev/null
done
