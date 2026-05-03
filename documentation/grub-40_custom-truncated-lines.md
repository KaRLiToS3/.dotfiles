# GRUB custom entry — truncated lines fix

**Date:** 2026-05-01

`/etc/grub.d/40_custom` had two lines truncated (likely from copy-pasting through a narrow terminal), causing a syntax error at line 202 when running `grub-mkconfig`.

**Line 1 fix** — broken opening brace:
```
# before
menuentry 'Arch Linux ROG' --class arch -->
# after
menuentry 'Arch Linux ROG' --class arch --class gnu-linux --class gnu --class os {
```

**Line 2 fix** — truncated UUID and missing kernel params:
```
# before
linux   /vmlinuz-linux-g14 root=UUID=b3b06a37-26fe-4>
# after
linux   /vmlinuz-linux-g14 root=UUID=b3b06a37-26fe-4a1e-8958-0eb302623d2a rw  loglevel=3 quiet nvidia_drm.modeset=1 i8042.dumbkbd
```

After fixing, regenerate:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
