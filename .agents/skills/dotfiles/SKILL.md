---
description: Commands for managing dotfiles using a bare git repository (dot command wrapper)
---

# Dotfiles Management

## Comando dot

El alias `dot` es un wrapper para git que gestiona el repo bare de dotfiles:

```bash
dot status        # Ver estado
dot add <archivo> # Agregar archivo
dot commit -m ""  # Guardar cambios
dot push          # Subir cambios
dot log           # Ver historial
```

## Registrar cambios

1. **Ver qué cambió:**
   ```bash
   dot status
   ```

2. **Agregar archivos modificados:**
   ```bash
   dot add ~/.config/rofi/powermenu.rasi
   ```

⚠️ **NUNCA uses `git add .` ni `dot add -A`** - Eso añadiría TODOS los archivos de `$HOME` al repo, incluyendo archivos personales, descargas, etc. Siempre agrega archivos específicos.

3. **Hacer commit:**
   ```bash
   dot commit -m "Actualización del powermenu"
   ```

4. **Subir al remoto:**
   ```bash
   dot push
   ```

## Notas
- El repo está en `~/.dotfiles` (bare)
- Los archivos reales están en `~`
- El archivo `.pi/` está ignorado (no se sube al repo)
