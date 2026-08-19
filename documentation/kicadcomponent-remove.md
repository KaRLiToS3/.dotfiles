# `kicadcomponent --remove` — borrar componentes de una librería easyeda2kicad

> **Nota (18/08/2026):** esta función zsh sigue siendo la que se ejecuta al
> escribir `kicadcomponent`, pero ya existe un reemplazo en Python instalado con
> `uv tool`: [`~/Proyectos/kicadcomponent`](file:///home/Carlos/Proyectos/kicadcomponent).
> Mientras la función exista, tiene prioridad sobre el binario; para probar el
> nuevo hay que escribir `command kicadcomponent ...`.

## Problema

`kicadcomponent` (en [`.zsh/aliases.zsh`](../.zsh/aliases.zsh)) sólo sabía importar
componentes de LCSC. Para quitar uno había que hacerlo a mano, y el lío está en
que **cada pieza tiene un nombre distinto** y ninguno coincide con el LCSC ID:

```
C71459  ->  símbolo   MPU-9250
        ->  footprint QFN-24_L3.0-W3.0-P0.40-BL-EP
        ->  modelo 3D QFN-24_L3.0-W3.0-H0.9-P0.40-BL-EP   (.wrl + .step)
```

## Por qué no hace falta una base de datos aparte

La cadena completa ya está guardada dentro de los propios ficheros de la
librería, así que un índice paralelo sólo podría desincronizarse (y además
nacería vacío para todo lo ya importado):

| Dato | Dónde está |
|---|---|
| LCSC ID → símbolo | `easyeda2kicad.kicad_sym`, `(property "LCSC Part" "C71459")` |
| símbolo → footprint | mismo bloque, `(property "Footprint" "easyeda2kicad:QFN-24_...")` |
| footprint → modelo 3D | `easyeda2kicad.pretty/<fp>.kicad_mod`, línea `(model "...")` |

Dos detalles que obligan a parsear de verdad en vez de usar `grep`:

- **Dos estilos de sangría conviven** en el mismo `.kicad_sym`: easyeda2kicad
  escribe con 2 espacios y `(property\n "Nombre"\n "Valor"`, mientras que KiCad,
  al guardar desde el editor, lo reescribe con tabuladores y `(property "Nombre" "Valor"`.
- **La ruta del `(model ...)` puede venir de otra máquina** (p. ej.
  `/home/udmt/Documentos/...`), así que sólo sirve el nombre del fichero.

Por eso la resolución la hace [`.zsh/scripts/kicadlib.py`](../.zsh/scripts/kicadlib.py),
un lector de s-expressions (sólo stdlib) que recorta el bloque del símbolo por
posición exacta en el fichero, dejando el resto byte a byte igual.

## Uso

```bash
kicadcomponent --list              # inventario: LCSC | símbolo | footprint | modelo 3D
kicadcomponent --remove C71459     # por LCSC ID
kicadcomponent --remove MPU-9250   # o por nombre de símbolo
kicadcomponent --remove -y C71459  # sin preguntar
```

Antes de borrar enseña el plan y pide confirmación:

```
Se va a borrar de /home/Carlos/Proyectos/UDMT/esp32-schematic/lib/easyeda2kicad:
  simbolo    MPU-9250  (C71459)
  footprint  .../easyeda2kicad.pretty/QFN-24_L3.0-W3.0-P0.40-BL-EP.kicad_mod
  modelo 3D  .../easyeda2kicad.3dshapes/QFN-24_L3.0-W3.0-H0.9-P0.40-BL-EP.wrl
  modelo 3D  .../easyeda2kicad.3dshapes/QFN-24_L3.0-W3.0-H0.9-P0.40-BL-EP.step
Confirmas el borrado? [y/N]
```

## Salvaguardas

- **Footprints compartidos no se borran.** `R0603` lo usan `0603WAF1200T5E` y
  `RC0603FR-0710KL`: al quitar uno se borra sólo su símbolo y se avisa.
- **Modelos 3D compartidos tampoco**, ni los de un footprint que se conserva.
- **Footprints de otra librería** (`Device:R` y similares) se dejan en paz.
- **Backup automático** del `.kicad_sym` en `easyeda2kicad.kicad_sym.bak` antes
  de cada borrado (se sobrescribe en cada operación: guarda el estado anterior
  al último borrado, no un historial).
- Si la búsqueda encaja con varios componentes, los lista y no toca nada.
- Si sólo existe el footprint (importado con `--footprint` o `--3d`, sin
  símbolo), lo detecta igualmente por el nombre del `.kicad_mod`.

Tras borrar hay que **refrescar las librerías en KiCad** para que deje de verlo.

## Cambiar de proyecto

Sigue habiendo que editar a mano las dos rutas al principio de la función
(`default_output_location` y `venv`), que están comentadas para cada proyecto.
La carpeta de la librería (`lib_dir`) se deduce sola de `default_output_location`.

## Verificado con

```bash
zsh -n ~/.dotfiles/.zsh/aliases.zsh                       # sintaxis
kicad-cli sym upgrade --force easyeda2kicad.kicad_sym     # el .kicad_sym sigue siendo válido
```

Probado sobre una copia de la librería del proyecto UDMT (33 componentes),
cubriendo: componente exclusivo, footprint compartido, footprint sin símbolo,
búsqueda ambigua y búsqueda sin resultados.
