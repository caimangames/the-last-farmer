extends Node
## Saving and loading of games in JSON format.
##
## Collects the state of the various managers (GameState, TimeManager, ...) into
## a single dictionary and writes it to user:// (the user data folder).
## Each system exposes to_dict()/from_dict() to keep saving decoupled.

const SAVE_DIR: String = "user://saves/"
const SAVE_EXTENSION: String = ".save"
const SAVE_VERSION: int = 1
const FARMLAND_GROUP: StringName = &"farmland"


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


## Manual test save while there's no pause menu yet (M7).
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quicksave"):
		save_game()


func save_game(slot: int = 0) -> bool:
	var data: Dictionary = {
		"version": SAVE_VERSION,
		"saved_at": Time.get_datetime_string_from_system(),
		"game_state": GameState.to_dict(),
		"time": TimeManager.to_dict(),
		"farmland": _farmland_to_dict(),
	}

	var path: String = _slot_path(slot)
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: could not write to '%s'" % path)
		return false

	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func load_game(slot: int = 0) -> bool:
	var path: String = _slot_path(slot)
	if not FileAccess.file_exists(path):
		return false

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: could not read '%s'" % path)
		return false

	var content: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(content)
	if parsed == null or not parsed is Dictionary:
		push_error("SaveManager: corrupt save file at '%s'" % path)
		return false

	var data: Dictionary = parsed
	GameState.from_dict(data.get("game_state", {}))
	TimeManager.from_dict(data.get("time", {}))
	var farmland := get_tree().get_first_node_in_group(FARMLAND_GROUP) as FarmlandSystem
	if farmland != null:
		farmland.from_dict(data.get("farmland", {}))
	return true


func has_save(slot: int = 0) -> bool:
	return FileAccess.file_exists(_slot_path(slot))


func delete_save(slot: int = 0) -> void:
	var path: String = _slot_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func _farmland_to_dict() -> Dictionary:
	var farmland := get_tree().get_first_node_in_group(FARMLAND_GROUP) as FarmlandSystem
	return farmland.to_dict() if farmland != null else {}


func _slot_path(slot: int) -> String:
	return "%sslot_%d%s" % [SAVE_DIR, slot, SAVE_EXTENSION]
