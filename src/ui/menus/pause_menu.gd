extends CanvasLayer
## Pause menu (M7): hard-pauses the game (get_tree().paused) and offers
## Resume / Save / Load / Quit to Title.
##
## process_mode is set to Always (in the .tscn) so this node keeps receiving
## input while the SceneTree is paused — otherwise Escape could never close it.
## Instanced as a child of Farm (farm.tscn), same as HUD: pausing only applies
## to gameplay scenes, not the title screen.

@onready var _overlay: Control = $Overlay
@onready var _resume_button: Button = $Overlay/VBoxContainer/ResumeButton
@onready var _save_button: Button = $Overlay/VBoxContainer/SaveButton
@onready var _load_button: Button = $Overlay/VBoxContainer/LoadButton
@onready var _quit_button: Button = $Overlay/VBoxContainer/QuitButton

var _open: bool = false


func _ready() -> void:
	_overlay.visible = false
	_resume_button.pressed.connect(_close)
	_save_button.pressed.connect(_on_save_pressed)
	_load_button.pressed.connect(_on_load_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		if _open:
			_close()
		else:
			_open_menu()


func _open_menu() -> void:
	_open = true
	_overlay.visible = true
	_load_button.disabled = not SaveManager.has_save()
	get_tree().paused = true
	EventBus.game_paused.emit(true)
	_resume_button.grab_focus()


func _close() -> void:
	_open = false
	_overlay.visible = false
	get_tree().paused = false
	EventBus.game_paused.emit(false)


func _on_save_pressed() -> void:
	SaveManager.save_game()
	EventBus.notification_requested.emit("Game saved")
	_load_button.disabled = false


func _on_load_pressed() -> void:
	if not SaveManager.has_save():
		return
	SaveManager.load_game()
	_close()


func _on_quit_pressed() -> void:
	_open = false
	_overlay.visible = false
	get_tree().paused = false
	EventBus.game_paused.emit(false)
	SceneManager.change_scene("res://src/ui/menus/start_menu.tscn")
