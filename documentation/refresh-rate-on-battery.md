# Pantalla a 60 Hz en batería, 240 Hz con cargador

## Problema

El panel (`eDP-1`, 2560x1600) estaba fijado a 240 Hz en `hyprland.lua` siempre,
también en batería, donde no aporta nada y gasta más. ROG Control Center no
gestiona la frecuencia del panel.

## Solución

Dos piezas, con la lógica en un único sitio:

| Fichero | Qué hace |
|---|---|
| [`.config/hypr/hyprland.lua`](../.config/hypr/hyprland.lua) | Define la función global `set_refresh_for_power()`: lee `/sys/class/power_supply/BAT0/status` y aplica 60 Hz si es `Discharging`, 240 Hz en cualquier otro caso. Se llama al cargar la config, así que también acierta al arrancar y en cada `hyprctl reload`. |
| [`.config/hypr/scripts/refresh-on-power.sh`](../.config/hypr/scripts/refresh-on-power.sh) | Lanzado desde el autostart. Escucha `udevadm monitor --udev --subsystem-match=power_supply` y, en cada evento, ejecuta `hyprctl eval 'set_refresh_for_power()'`. |

Detalles:

- **Se usa `BAT0/status` y no `ADP0/online`** para que funcione igual con el
  cargador de barril que cargando por USB-C (que aparece como
  `ucsi-source-psy-*`, no como `ADP0`). Con el límite de carga al 80 % el estado
  enchufado es `Not charging`, que también cuenta como "con cargador".
- **La batería emite eventos cada poco**, por eso la función guarda el modo
  actual y no hace nada si no cambia (si no, habría un modeset con parpadeo en
  cada evento).
- **El script sale solo** si el socket de la sesión de Hyprland que lo lanzó ya
  no existe, para no quedarse huérfano tras cerrar sesión.
- Bajo el gestor Lua, `hyprctl eval` ejecuta Lua en el mismo estado que la
  config, así que las funciones globales definidas en `hyprland.lua` son
  accesibles desde fuera.

## Consumo medido (15/09/2026)

En batería, escritorio en reposo, brillo 20 %, dGPU suspendida. Medida
alternando 60/240/60/240 Hz, 15 s cada una, leyendo `BAT0/power_now`:

| Modo | Medias | Media |
|---|---|---|
| 60 Hz | 20,50 W · 20,79 W | **20,65 W** |
| 240 Hz | 21,55 W · 20,84 W | **21,20 W** |

En reposo el ahorro es pequeño (~0,5 W, y dentro del ruido en una de las dos
parejas): Hyprland ya no redibuja si nada cambia, así que a 240 Hz sólo cuesta
el refresco del propio panel. La diferencia debería crecer con contenido en
movimiento (scroll, vídeo, animaciones), donde a 240 Hz se renderizan hasta 4×
más frames, pero eso no está medido.

## Comandos útiles

```bash
hyprctl monitors | grep @                          # frecuencia actual
hyprctl eval 'set_refresh_for_power()'             # forzar comprobación
pgrep -af refresh-on-power                         # ¿está corriendo el script?
```

Para cambiar las frecuencias, editar `panel_modes` en `hyprland.lua`.
