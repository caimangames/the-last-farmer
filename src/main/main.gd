extends Node
## Entry point of the game (main_scene in project.godot).
##
## If a saved game exists, continues it; otherwise starts a new one.
## Later this will become a main menu with New Game / Continue / Settings
## options (M7).

func _ready() -> void:
	if SaveManager.has_save():
		_continue_game()
	else:
		_start_new_game()


func _start_new_game() -> void:
	GameState.reset()
	TimeManager.start_day()
	SceneManager.change_scene("res://src/world/farm/farm.tscn")


func _continue_game() -> void:
	GameState.loading_save = true
	SceneManager.change_scene("res://src/world/farm/farm.tscn")
