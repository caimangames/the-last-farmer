# The Last Farmer 🌾

2D top-down farm management game, *Stardew Valley*-style, made with **Godot 4.6** (GDScript).

## Architecture

The project follows a **by-feature** organization and rests on three pillars to stay scalable:

1. **Autoloads (singletons)** — global systems that live for the whole playthrough.
2. **EventBus (pub/sub)** — systems communicate via signals, with no direct references between them. This avoids coupling and lets features be added without touching existing code.
3. **Data-driven with `Resource`** — items, crops, and recipes are defined as `.tres` files in `data/`, not in code. A designer can add a new crop without programming.

## Folder structure

```
the-last-farmer/
├── project.godot          # Config: autoloads, input map, physics layers, 2D render
├── assets/                # Raw art and audio (no logic)
│   ├── sprites/           #   characters / crops / tiles / ui
│   ├── tilesets/
│   ├── audio/             #   music / sfx
│   ├── fonts/  shaders/
├── data/                  # .tres resources (data instances)
│   ├── items/  crops/  recipes/  npcs/
├── src/
│   ├── globals/           # Autoloads (singletons)
│   │   ├── event_bus.gd       # Central signal hub
│   │   ├── game_state.gd      # Gold, flags, active inventory
│   │   ├── time_manager.gd    # Clock, day, season, year
│   │   ├── save_manager.gd    # JSON save/load in user://
│   │   ├── scene_manager.gd   # Scene transitions
│   │   └── audio_manager.gd   # Music and SFX pool
│   ├── resources/         # Data classes (class_name): ItemData, CropData
│   ├── entities/          # Living things in the world
│   │   ├── player/            # Player (movement + inventory)
│   │   ├── npc/  animals/
│   │   └── interactable.gd    # Base interaction class
│   ├── systems/           # Decoupled game logic
│   │   ├── inventory/         # Inventory + InventorySlot
│   │   ├── farming/  dialogue/  economy/
│   ├── ui/                # hud / menus / components
│   ├── world/             # Location scenes
│   │   ├── farm/  town/  interiors/
│   ├── core/              # Shared utilities and base classes
│   └── main/              # main.tscn — entry point
└── tests/                 # Tests (GUT or another framework)
```

## Conventions

- **Files and folders**: `snake_case`. **Classes (`class_name`)**: `PascalCase`.
- One `.gd` script per node/scene, alongside its `.tscn`.
- Communication between unrelated systems **always goes through the EventBus**; direct references are reserved for parent→child relationships.
- Every manager with persistent state exposes `to_dict()` / `from_dict()` for saving.

## Getting started

Open the project folder in Godot 4.6 and press **Play** (F5). The startup flow is:

`main.tscn` → starts a new game → `TimeManager.start_day()` → loads `world/farm/farm.tscn`.

Controls: **WASD** move · **E** interact · **left click** use tool · **I** inventory · **Esc** pause.

## Assets

Art: **Cute Fantasy** (free tier) by Kenmi, in `assets/`.

| Folder | Contents | Format |
|---|---|---|
| `assets/sprites/characters/` | `player.png` (6x10 frames of 32x32), `player_actions.png` (3x18) | Spritesheet |
| `assets/sprites/animals/` | chicken, cow, pig, sheep (64x64) | Spritesheet |
| `assets/sprites/enemies/` | skeleton, slime_green | Spritesheet |
| `assets/sprites/props/` | trees, fences, chest, house, bridge, decoration | Loose sprites |
| `assets/tilesets/` | 16x16 base tiles (grass/path/water/farmland/cliff/beach) | Tiles / autotiles |
| `assets/tilesets/ground_tileset.tres` | Generated TileSet (grass + farmland 3x3 + path + water) | Godot resource |

Import configured for pixel art: **Nearest** filter, no mipmaps (set as the project default).
`ground_tileset.tres` is regenerated with `tools/build_ground_tileset.gd` if the base tiles change.

> ⚠️ **License (free tier)**: **non-commercial** projects only, modification allowed, **redistribution NOT allowed** (even modified). See `assets/CUTE_FANTASY_LICENSE.txt`. This means: **don't push the `assets/` folder to a public repository**. Consider adding `assets/sprites/` and `assets/tilesets/*.png` to `.gitignore` if the repo will be public, or buying the paid version for commercial use.

## Suggested next steps

- [ ] `Farmland` (TileMapLayer) with till / water / plant using `CropData`.
- [ ] `ItemDatabase` that loads the `.tres` files in `data/items/` by `id`.
- [ ] HUD: clock, gold, and toolbar (listening to the EventBus).
- [ ] Dialogue system and first NPC.
- [ ] End-of-day screen → auto-save.
