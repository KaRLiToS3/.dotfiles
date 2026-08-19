# Manually Installed Packages

Programs installed outside of pacman/yay. Each entry needs source, install method, and why it couldn't be packaged normally.

| Name | Source | Method | Reason |
|------|--------|--------|--------|
| kicadcomponent | ~/Proyectos/kicadcomponent (propio) | `uv tool install --editable ~/Proyectos/kicadcomponent` | Herramienta propia en Python; se instala con uv tool para que quede aislada y en el PATH. Arrastra easyeda2kicad (PyPI), que tampoco esta en repos. |
