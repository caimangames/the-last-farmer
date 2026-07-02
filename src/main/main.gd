extends Node
## Punto de entrada del juego (main_scene en project.godot).
##
## Por ahora arranca una partida nueva directamente. Más adelante esto será
## un menú principal con opciones de Nueva partida / Continuar / Ajustes.

func _ready() -> void:
	_start_new_game()


func _start_new_game() -> void:
	GameState.reset()
	TimeManager.start_day()
	SceneManager.change_scene("res://src/world/farm/farm.tscn")
