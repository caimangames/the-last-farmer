# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"The Last Farmer" — a Stardew Valley-style 2D top-down farm sim built with **Godot 4.6** (GDScript, GL Compatibility renderer). Solo dev project; all docs, code comments, and player-facing text are written in English.

- `docs/GDD.md` — game design doc (mostly `_Pendiente_`/TBD placeholders; check before assuming a mechanic is decided).
- `docs/ROADMAP_MVP.md` — the actual engineering plan: milestones M0–M8 toward a playable MVP loop (till → plant → water → grow → harvest → sell → sleep → next day). **Read this before starting any feature work** — it names exact files, functions, and EventBus signals to wire up, and which ones already exist but are unused/unconnected.

## Commands

No build step — this is a Godot project, opened and run through the editor (Play/F5) or headless via CLI.

```bash
# Headless syntax/scene check (parses scripts, reports errors) — closest thing to a lint/build check
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --check-only --quit

# Re-import assets (needed after adding/changing files under assets/)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import --quit

# Run the game headless for N seconds (smoke test — watch stdout for pushed errors/warnings)
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --quit-after 15
```

There is no test framework wired up yet (`tests/` is empty apart from `.gitkeep`). No linter is configured beyond Godot's own script parser.

## Architecture

Organized **by feature**, held together by three conventions — understand these before writing any new system:

1. **Autoloads (singletons)**, declared in `project.godot` under `[autoload]`, in this load order: `EventBus`, `GameState`, `TimeManager`, `SaveManager`, `SceneManager`, `AudioManager`, `ItemDatabase`. Each lives in `src/globals/`.
2. **EventBus pub/sub** (`src/globals/event_bus.gd`) — the *only* channel between unrelated systems. Direct node references are reserved for parent→child relationships (e.g. `farm.gd` holding `@onready` refs to its children). When adding a feature, check `event_bus.gd` first: many signals are already declared for future milestones but have zero emitters or zero listeners today (e.g. `crop_planted`/`crop_watered`/`crop_harvested`, `dialogue_requested`/`dialogue_finished`, `game_paused`, `notification_requested`) — wire into these rather than inventing parallel ones.
3. **Data-driven `Resource`s** — game data (items, crops) lives as `.tres` files under `data/`, not in code. `ItemDatabase` (`src/globals/item_database.gd`) scans `data/items/` and `data/crops/` at startup and indexes each resource by its `id` field; everything else looks data up through `ItemDatabase.get_item(id)`/`get_crop(id)`, never via direct `load()`. Adding a new item/crop means adding a `.tres` (via the Godot editor's Resource inspector) with `class_name` `ItemData` (`src/resources/item_data.gd`) or `CropData` (`src/resources/crop_data.gd`), not writing code.

### Save/load

Each stateful manager exposes `to_dict()`/`from_dict()`; `SaveManager` (`src/globals/save_manager.gd`) collects them into one JSON blob under `user://saves/slot_N.save`. Currently only `GameState` and `TimeManager` are wired into `save_game()`/`load_game()` — `FarmlandSystem.to_dict()`/`from_dict()` already exist (`src/systems/farming/farmland_system.gd`) but nothing calls them yet, and `Inventory` has no serialization at all. When touching save/load, extend the same pattern rather than introducing a different persistence mechanism.

### Scene/gameplay flow

`main.tscn` (`src/main/main.gd`) always calls `_start_new_game()` unconditionally today (no continue/menu flow yet) → `GameState.reset()` → `TimeManager.start_day()` → `SceneManager.change_scene()` to `src/world/farm/farm.tscn`.

`farm.gd` wires its children together imperatively in `_ready()`: grabs `@onready` refs to `Ground`/`WateredLayer`/`CropLayer`/`FarmlandSystem`/`Player`/`HUD`, calls `FarmlandSystem.setup(...)` to hand it the tilemap layers and player ref, gives starting items directly into `player.inventory`, and places decorative props by hand-coded pixel coordinates.

`FarmlandSystem` (`src/systems/farming/farmland_system.gd`) owns all per-tile farming state (`Dictionary` keyed by `Vector2i`, values `{state, crop_id, days_grown, watered}`) and listens to `EventBus.tool_used` / `EventBus.interact_tile` / `EventBus.day_ended` rather than being called directly by `Player`. `Player` (`src/entities/player/player.gd`) never touches farmland directly — it just emits `tool_used`/`interact_tile` on the bus with the active item and world position.

`Interactable` (`src/entities/interactable.gd`, extends `Area2D`) is the base class for anything the player can interact with via the `interact` action — nothing extends it yet (planned for the first NPC, see ROADMAP M4).

### Physics layers

Defined in `project.godot`: `1=world, 2=player, 3=npc, 4=interactable, 5=enemy`.

### Assets

Art is **Cute Fantasy** (free tier) by Kenmi — **non-commercial only, no redistribution** (see `assets/CUTE_FANTASY_LICENSE.txt`). Don't push `assets/` to a public repo without checking this. Import settings default to pixel-art (Nearest filter, no mipmaps) project-wide. `assets/tilesets/ground_tileset.tres` is a generated `TileSet` resource — regenerate it with `tools/build_ground_tileset.gd` (run as an in-editor script) if the source tile PNGs change, rather than hand-editing the `.tres`.

## Conventions

- Files/folders: `snake_case`. Classes (`class_name`): `PascalCase`.
- One `.gd` script per node/scene, alongside its `.tscn`.
- Signal names in `event_bus.gd` are grouped by domain with comment headers (`--- Tiempo / Calendario ---`, etc.) — keep new signals grouped the same way.
