extends Area2D
class_name Interactable
## Base class for anything the player can interact with:
## NPCs, chests, doors, signs...
##
## Extend this class and override `interact()` with the concrete behavior.

## Text the UI can show as a hint ("Press E to talk").
@export var prompt: String = "Interact"


## Called by the Player when they press the interact button while nearby.
func interact(_player: Player) -> void:
	push_warning("Interactable '%s' does not implement interact()." % name)
