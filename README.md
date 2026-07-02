# The Last Farmer 🌾

Juego de gestión de granjas en 2D top-down, estilo *Stardew Valley*, hecho con **Godot 4.6** (GDScript).

## Arquitectura

El proyecto sigue una organización **por features** y se apoya en tres pilares para mantenerse escalable:

1. **Autoloads (singletons)** — sistemas globales que viven durante toda la partida.
2. **EventBus (pub/sub)** — los sistemas se comunican por señales, sin referencias directas entre ellos. Esto evita el acoplamiento y deja añadir features sin tocar lo existente.
3. **Data-driven con `Resource`** — items, cultivos y recetas se definen como archivos `.tres` en `data/`, no en código. Un diseñador puede añadir un cultivo nuevo sin programar.

## Estructura de carpetas

```
the-last-farmer/
├── project.godot          # Config: autoloads, input map, layers de física, render 2D
├── assets/                # Arte y audio crudos (sin lógica)
│   ├── sprites/           #   characters / crops / tiles / ui
│   ├── tilesets/
│   ├── audio/             #   music / sfx
│   ├── fonts/  shaders/
├── data/                  # Recursos .tres (instancias de datos)
│   ├── items/  crops/  recipes/  npcs/
├── src/
│   ├── globals/           # Autoloads (singletons)
│   │   ├── event_bus.gd       # Hub central de señales
│   │   ├── game_state.gd      # Oro, flags, inventario activo
│   │   ├── time_manager.gd    # Reloj, día, estación, año
│   │   ├── save_manager.gd    # Guardado/carga JSON en user://
│   │   ├── scene_manager.gd   # Transiciones entre escenas
│   │   └── audio_manager.gd   # Música y pool de SFX
│   ├── resources/         # Clases de datos (class_name): ItemData, CropData
│   ├── entities/          # Cosas vivas del mundo
│   │   ├── player/            # Player (movimiento + inventario)
│   │   ├── npc/  animals/
│   │   └── interactable.gd    # Clase base de interacción
│   ├── systems/           # Lógica de juego desacoplada
│   │   ├── inventory/         # Inventory + InventorySlot
│   │   ├── farming/  dialogue/  economy/
│   ├── ui/                # hud / menus / components
│   ├── world/             # Escenas de localizaciones
│   │   ├── farm/  town/  interiors/
│   ├── core/              # Utilidades y clases base compartidas
│   └── main/              # main.tscn — punto de entrada
└── tests/                 # Pruebas (GUT u otro framework)
```

## Convenciones

- **Archivos y carpetas**: `snake_case`. **Clases (`class_name`)**: `PascalCase`.
- Un script `.gd` por nodo/escena, junto a su `.tscn`.
- La comunicación entre sistemas distintos pasa **siempre por el EventBus**; las referencias directas se reservan para relaciones padre→hijo.
- Cada manager con estado persistente expone `to_dict()` / `from_dict()` para el guardado.

## Cómo arrancar

Abre la carpeta del proyecto en Godot 4.6 y pulsa **Play** (F5). El flujo de arranque es:

`main.tscn` → inicia partida nueva → `TimeManager.start_day()` → carga `world/farm/farm.tscn`.

Controles: **WASD** mover · **E** interactar · **click izq.** usar herramienta · **I** inventario · **Esc** pausa.

## Assets

Arte: **Cute Fantasy** (versión gratuita) de Kenmi, en `assets/`.

| Carpeta | Contenido | Formato |
|---|---|---|
| `assets/sprites/characters/` | `player.png` (6×10 frames de 32×32), `player_actions.png` (3×18) | Spritesheet |
| `assets/sprites/animals/` | chicken, cow, pig, sheep (64×64) | Spritesheet |
| `assets/sprites/enemies/` | skeleton, slime_green | Spritesheet |
| `assets/sprites/props/` | árboles, vallas, cofre, casa, puente, decoración | Sprites sueltos |
| `assets/tilesets/` | tiles base de 16×16 (grass/path/water/farmland/cliff/beach) | Tiles / autotiles |
| `assets/tilesets/ground_tileset.tres` | TileSet generado (grass + farmland 3×3 + path + water) | Recurso Godot |

Import configurado para pixel-art: filtro **Nearest**, sin mipmaps (definido como default del proyecto).
El `ground_tileset.tres` se regenera con `tools/build_ground_tileset.gd` si cambian los tiles base.

> ⚠️ **Licencia (versión gratuita)**: solo proyectos **no comerciales**, se permite modificar, **NO se permite redistribuir** (ni modificado). Ver `assets/CUTE_FANTASY_LICENSE.txt`. Esto implica: **no subas la carpeta `assets/` a un repositorio público**. Considera añadir `assets/sprites/` y `assets/tilesets/*.png` al `.gitignore` si el repo va a ser público, o adquirir la versión de pago para uso comercial.

## Próximos pasos sugeridos

- [ ] `Farmland` (TileMapLayer) con arar / regar / plantar usando `CropData`.
- [ ] `ItemDatabase` que cargue los `.tres` de `data/items/` por `id`.
- [ ] HUD: reloj, oro y barra de herramientas (escuchando el EventBus).
- [ ] Sistema de diálogo y primer NPC.
- [ ] Pantalla de fin de día → guardado automático.
