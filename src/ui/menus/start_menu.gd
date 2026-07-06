extends Control
## Title screen (M7): New Game / Continue / Quit.
##
## Replaces main.gd's old auto-decision (has_save() ? continue : new game).
## Continue is disabled when there's no save to load from.

@onready var _new_game_button: Button = $VBoxContainer/NewGameButton
@onready var _continue_button: Button = $VBoxContainer/ContinueButton
@onready var _quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	_continue_button.disabled = not SaveManager.has_save()
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	GameState.loading_save = false
	GameState.reset()
	TimeManager.start_day()
	SceneManager.change_scene("res://src/world/farm/farm.tscn")


func _on_continue_pressed() -> void:
	if not SaveManager.has_save():
		return
	GameState.loading_save = true
	SceneManager.change_scene("res://src/world/farm/farm.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
