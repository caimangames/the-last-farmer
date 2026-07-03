extends Node
## Global event bus (pub/sub pattern).
##
## Lets unrelated systems communicate without knowing about each other.
## Instead of the inventory holding a direct reference to the HUD,
## both talk through this bus:
##   EventBus.item_collected.emit(item, 1)   # emitted by the world
##   EventBus.item_collected.connect(...)     # listened to by the HUD
##
## Keep signals grouped by domain and documented.

# --- Time / Calendar ---
signal day_started(day: int, season: int, year: int)
signal day_ended(day: int, season: int, year: int)
signal hour_changed(hour: int, minute: int)
signal season_changed(season: int)

# --- Player / Inventory ---
signal item_collected(item: ItemData, amount: int)
signal item_removed(item: ItemData, amount: int)
signal inventory_changed
signal active_slot_changed(slot: int)
signal gold_changed(new_total: int, delta: int)
signal energy_changed(new_total: int, delta: int)
signal tool_used(tool: ItemData, world_position: Vector2)

# --- Farm / Crops ---
signal crop_planted(crop: CropData, tile: Vector2i)
signal crop_watered(tile: Vector2i)
signal crop_harvested(crop: CropData, tile: Vector2i)

# --- Interaction / Dialogue ---
signal interaction_started(interactable: Node)
signal interact_tile(world_position: Vector2)
signal dialogue_requested(dialogue_id: String)
signal dialogue_finished(dialogue_id: String)

# --- Game flow / UI ---
signal game_paused(is_paused: bool)
signal scene_transition_started(target_scene: String)
signal scene_transition_finished(target_scene: String)
signal notification_requested(text: String)
