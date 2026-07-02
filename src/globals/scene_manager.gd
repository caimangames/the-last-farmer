extends Node
## Gestiona la transición entre escenas con un fundido (fade) opcional.
##
## Uso:
##   SceneManager.change_scene("res://src/world/farm/farm.tscn")
##
## Centralizar esto evita llamar a get_tree().change_scene_to_file() por todos
## lados y permite añadir efectos de transición, pantallas de carga, etc.

var _transitioning: bool = false


func change_scene(target_scene: String) -> void:
	if _transitioning:
		return
	_transitioning = true
	EventBus.scene_transition_started.emit(target_scene)

	# Punto de extensión: aquí se reproduce el fade-out de un CanvasLayer global.
	await get_tree().process_frame

	var err: int = get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("SceneManager: no se pudo cargar la escena '%s' (error %d)" % [target_scene, err])

	_transitioning = false
	EventBus.scene_transition_finished.emit(target_scene)
