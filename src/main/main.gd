extends Node
## Punto de entrada del juego (main_scene en project.godot).
##
## Si existe una partida guardada, la continúa; si no, arranca una nueva.
## Más adelante esto será un menú principal con opciones de Nueva partida /
## Continuar / Ajustes (M7).

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
