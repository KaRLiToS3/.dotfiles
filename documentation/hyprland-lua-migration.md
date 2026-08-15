# Hyprland — migración de hyprlang (.conf) a Lua (.lua)

**Date:** 2026-08-15
**Versión:** Hyprland 0.56.2

## Problema

Desde Hyprland 0.55 el formato `.conf` (hyprlang) está **deprecado** en favor de Lua.
0.56.1 añadió un aviso explícito. El log lo confirmaba:

```
[cfg] Lua config not found, using legacy config at ~/.config/hypr/hyprland.conf
```

Plazo declarado por upstream: hyprlang aguanta "1-2 releases a partir de 0.55" y **ya no
recibe features nuevas**. Estando en 0.56.2, la ventana se cerraba en 0.57/0.58.

## Estructura resultante

```
.config/hypr/
├── hyprland.lua              # entrada: monitor, env, requires, autostart
├── hyprpaper.conf            # SIN tocar (ver más abajo)
└── sources/
    ├── programs.lua          # apps por defecto, compartido entre módulos
    ├── look_and_feel.lua
    ├── input.lua
    ├── binds.lua
    └── window_rules.lua
```

`require()` resuelve con el `package.path` que monta Hyprland
(`src/config/lua/ConfigManager.cpp`):

```
<configdir>/?.lua;<configdir>/?/init.lua
```

Por eso la forma correcta es `require("sources.binds")`, **no** `require("_.sources.binds")`.

## hyprpaper NO está afectado

Los demás daemons del ecosistema (hyprpaper, hyprlock, hypridle) tienen su propio config
y **siguen usando hyprlang**; migrarán a su propio ritmo. `hyprpaper.conf` se deja igual.

## Sobre la herramienta hyprconf2lua

Se usó `hyprconf2lua` v1.4.0 como andamio, pero **su salida no es fiable**. Reportó
"100% coverage, 0 flagged" mientras que:

- **Perdió las 5 curvas bezier y las 17 animaciones** por completo (las sustituyó por un comentario).
- Generó `animations.enabled = { true, "please:)" }` a partir del valor broma `yes, please :)`.
- **No resolvió las variables** `$terminal` / `$browser` / `$fileManager` / `$menu`: quedaron
  como literales, dejando muertos los binds principales.
- Corrompió comandos de shell comiéndose espacios:
  - `grim -g "$(slurp)" - | wl-copy` → `grim -g "$(slurp)"-| wl-copy`
  - `$(date +"%Y-...")` → `$(date+ "%Y-...")`
  - regex `^(Sin título - Brave)$` → `^(Sin título- Brave)$`
- **Perdió el flag `repeating`** al traducir `bindel` (solo puso `locked`), dejando sin
  auto-repetición las teclas de volumen y brillo.
- Usó rutas de `require` inválidas (`_.sources.x`).
- Tipos incorrectos: `opacity = 0.9` y `workspace = 2` (la API espera strings), `xwayland = 1`
  (espera bool).

Conclusión: sirve para arrancar, pero hay que revisar la salida línea a línea.

## Cambios de comportamiento que exige el gestor Lua

`hyprctl dispatch` ahora recibe **expresiones Lua** (`src/debug/HyprCtl.cpp`):

```cpp
std::string evalStr = std::format("return hl.dispatch({})", in);
```

Por tanto `hyprctl dispatch dpms off` se convierte en `hl.dispatch(dpms off)` → error de
sintaxis. Había que reescribir el comando de swayidle:

```
# antes
hyprctl dispatch dpms off
# después
hyprctl dispatch "hl.dsp.dpms({ action = \"off\" })"
```

Igualmente, `hyprctl setprop active alpha 1.0` se sustituyó por el dispatcher nativo
`hl.dsp.window.set_prop({ prop = "opacity", value = "1.0" })`.

`hl.exec_cmd()` sí pasa por `/bin/sh -c` (`Executor.cpp` usa
`execl("/bin/sh", "/bin/sh", "-c", args)`), así que pipes, `&&` y `$(...)` funcionan. No
hace falta `&` final: ya lanza el proceso de forma asíncrona.

## Bugs preexistentes corregidos de paso

1. **Dos `env` en una línea** en `hyprland.conf`:
   ```
   env = GDK_BACKEND,wayland,x11,* env = QT_QPA_PLATFORM,wayland;xcb
   ```
   Resultado real en la sesión: `GDK_BACKEND` con basura y `QT_QPA_PLATFORM` sin definir.
   Ahora son dos `hl.env()` separados.

2. **Regla de opacidad de terminales que nunca casaba**: buscaba `^(alacritty|kitty)$` pero
   la clase real es `Alacritty`. El regex (RE2) es case-sensitive.

3. **VS Code nunca iba al workspace 3**: buscaba `^(Code|...)$`, la clase real es `code`.

Clases reales verificadas con `hyprctl clients -j`.

## Verificación

`hyprctl eval` solo funciona ya en modo Lua, así que la validación previa al reinicio se
hizo con:

```bash
# sintaxis
luac -p .config/hypr/hyprland.lua .config/hypr/sources/*.lua

# runtime: ejecutar la config con un stub de `hl` replicando el package.path de Hyprland
lua harness.lua
```

Los recuentos cuadran con el `.conf` original: 72 binds, 33 window rules, 2 layer rules,
16 animaciones, 5 curvas, 11 autostart, 14 env (13 líneas, una contenía dos variables).

## Nota: stub regenerado

Al borrar `hyprland.conf` con la sesión legacy aún en marcha, Hyprland regeneró un stub
por defecto. Es inerte: el resolutor prueba `.lua` primero y solo cae a `.conf` si falta.
Se borró y no volvió a aparecer.

## Archivos eliminados

`hyprland.conf`, `sources/{look_and_feel,input,binds,window_rules}.conf` y
`sources/old_window_rules.conf` (este último ya estaba muerto: no lo sourceaba nadie).
Recuperables con `git checkout` si hiciera falta.
