extends Node
## Manages scene transitions with an optional fade.
##
## Usage:
##   SceneManager.change_scene("res://src/world/farm/farm.tscn")
##
## Centralizing this avoids calling get_tree().change_scene_to_file() all over
## the place and allows adding transition effects, loading screens, etc.

var _transitioning: bool = false


func change_scene(target_scene: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	EventBus.scene_transition_started.emit(target_scene)

	# Extension point: this is where a global CanvasLayer's fade-out would play.
	await get_tree().process_frame

	var err: int = get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("SceneManager: could not load scene '%s' (error %d)" % [target_scene, err])

	_transitioning = false
	EventBus.scene_transition_finished.emit(target_scene)
