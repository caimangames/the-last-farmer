extends Node
## Bus de eventos global (patrón pub/sub).
##
## Permite que sistemas distintos se comuniquen sin conocerse entre sí.
## En lugar de que el inventario tenga una referencia directa a la HUD,
## ambos hablan a través de este bus:
##   EventBus.item_collected.emit(item, 1)   # lo emite el mundo
##   EventBus.item_collected.connect(...)     # lo escucha la HUD
##
## Mantén las señales agrupadas por dominio y documentadas.

# --- Tiempo / Calendario ---
signal day_started(day: int, season: int, year: int)
signal day_ended(day: int, season: int, year: int)
signal hour_changed(hour: int, minute: int)
signal season_changed(season: int)

# --- Jugador / Inventario ---
signal item_collected(item: ItemData, amount: int)
signal item_removed(item: ItemData, amount: int)
signal inventory_changed
signal active_slot_changed(slot: int)
signal gold_changed(new_total: int, delta: int)
signal tool_used(tool: ItemData, world_position: Vector2)

# --- Granja / Cultivos ---
signal crop_planted(crop: CropData, tile: Vector2i)
signal crop_watered(tile: Vector2i)
signal crop_harvested(crop: CropData, tile: Vector2i)

# --- Interacción / Diálogo ---
signal interaction_started(interactable: Node)
signal interact_tile(world_position: Vector2)
signal dialogue_requested(dialogue_id: String)
signal dialogue_finished(dialogue_id: String)

# --- Flujo de juego / UI ---
signal game_paused(is_paused: bool)
signal scene_transition_started(target_scene: String)
signal scene_transition_finished(target_scene: String)
signal notification_requested(text: String)
