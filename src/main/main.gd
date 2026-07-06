extends Node
## Entry point of the game (main_scene in project.godot).
##
## Just hands off to the title screen (M7), which offers New Game / Continue /
## Quit — see src/ui/menus/start_menu.gd for that logic.

func _ready() -> void:
	SceneManager.change_scene("res://src/ui/menus/start_menu.tscn")
