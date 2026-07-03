# MVP Roadmap

> Engineering breakdown to reach the playable MVP. See `docs/GDD.md` section 1.4 for the
> high-level scope; this document details milestones, files, and "done" criteria.

Target loop: till → plant → water → grow → harvest → sell → sleep → next day,
with an initial narrative hook and at least one NPC.

Recommended order: M0 and M1 in parallel → M2/M3 → M4 → M5/M6 in parallel → M7 → M8 (optional).

## M0 — Minimal design decisions

**No code.** Define in `docs/GDD.md`: elevator pitch (1.1), 3-4 design pillars (1.2),
premise in 1-2 sentences (2.1), 1 NPC with name/role (2.4), 3-5 lines of opening dialogue.

Blocks M4 and M6 — the dialogue system can't be tested with real content without this.

## M1 — Fix saving (inventory + farmland)

**Goal:** reloading a game doesn't lose progress.

- `Inventory` (`src/systems/inventory/inventory.gd`): add `to_dict()`/`from_dict()`.
- `GameState.to_dict()`/`from_dict()` (`src/globals/game_state.gd`): include the inventory.
- `SaveManager.save_game()`/`load_game()` (`src/globals/save_manager.gd`): also call
  `FarmlandSystem.to_dict()`/`from_dict()` (already exist, lines 223-243 of
  `farmland_system.gd`, nobody calls them today). Requires locating the active instance, e.g.
  via the `"farmland"` group.
- `farm.gd`: don't hand out starting items if an existing save is being loaded.

**Done when:** till/plant/water, save, close the game, reload → everything intact.

## M2 — Energy/stamina and manual sleep

**Goal:** end the day by player choice, not just by waiting for the clock.

- New `energy_changed` signal in `EventBus`.
- `GameState`: `energy`, `max_energy`, `spend_energy()`, `restore_energy()`.
- `Player._try_use_tool()` (`player.gd`): spend energy when using tools.
- `TimeManager.start_day()`: restore energy.
- `HUD`: energy bar.
- "Sleep" action (interacting with the bed/house, or a dedicated UI) that calls
  `TimeManager.end_day()`.

**Depends on:** M1. **Done when:** the player can sleep voluntarily and energy is reflected
in the HUD.

## M3 — Polish the farming loop

**Goal:** crops wither if not watered; regrowth works; there's feedback for the wrong
season.

- `farmland_system.gd`: use `CropData.regrowth_days` (field already exists, ignored today in
  `try_harvest()`); add withering after days without watering.
- Finally connect `crop_planted`, `crop_watered`, `crop_harvested` (declared in `EventBus`,
  never connected) to visual/audio feedback.
- Clear message when `try_plant()` fails due to the wrong season.

**Done when:** an unwatered crop visibly dies; one with `regrowth_days > 0` can be
harvested more than once.

## M4 — First NPC and dialogue system

**Goal:** interacting (E) with the M0 NPC opens a dialogue box with their text.

- `src/entities/npc/npc.gd` (new): extends `Interactable`
  (`src/entities/interactable.gd`, currently nothing uses it).
- `src/resources/dialogue_data.gd` (new `Resource`, following the `ItemData`/`CropData` pattern).
- `src/ui/components/dialogue_box.gd`/`.tscn` (new, folder currently empty).
- Reuse `dialogue_requested`, `dialogue_finished`, `interaction_started`, `game_paused`
  (all 4 declared in `EventBus`, none connected today).
- Requires a placeholder sprite for the NPC (none exist in `assets/sprites/`).

**Depends on:** M0. **Done when:** approaching the NPC and pressing E shows their dialogue and
pauses the game for its duration.

## M5 — Basic economy: selling crops

**Goal:** selling turnips to the M4 NPC increases gold.

- `src/systems/economy/shop_system.gd` (new).
- `src/ui/menus/sell_menu.gd`/`.tscn` (new, folder currently empty).
- Reuses `gold_changed` and `inventory_changed` (already connected to the HUD).

**Depends on:** M4. **Done when:** selling a turnip deducts it from the inventory and adds
gold visible in the HUD.

## M6 — Initial narrative hook

**Goal:** an automatic opening dialogue when starting a new game (GDD 2.5, marked as an
MVP priority).

- Almost entirely content: reuses M4's infrastructure.
- `main.gd`/`farm.gd`: fire `dialogue_requested` with the intro dialogue on first load.

**Depends on:** M0 + M4.

## M7 — Menus: pause, save/load, start

**Goal:** stop always starting on a new game.

- `main.gd` today unconditionally calls `_start_new_game()` — needs a start screen
  offering "New Game" / "Load" (uses `SaveManager.has_save()`).
- Pause menu: the `pause` action (already in `project.godot`'s input map) has no handler in
  any script today. Emit `EventBus.game_paused` (already connected in `TimeManager`, with no
  emitter).
- `src/ui/menus/` (currently empty except for `.gitkeep`).

**Depends on:** M1 + M2.

## M8 — Sensory polish (optional / stretch)

Not blocking for the MVP to be considered playable.

- Music and SFX (`assets/audio/` folders empty, `AudioManager` already implemented and unused).
- Tool-use animation (`player_actions.png` exists, not configured).
- Toasts for `notification_requested` (declared, no consumer).
