extends Area2D
class_name Interactable
## Clase base para cualquier cosa con la que el jugador pueda interactuar:
## NPCs, cofres, puertas, carteles...
##
## Extiende esta clase y sobrescribe `interact()` con el comportamiento concreto.

## Texto que la UI puede mostrar como pista ("Pulsa E para hablar").
@export var prompt: String = "Interactuar"


## Llamado por el Player cuando pulsa el botón de interacción estando cerca.
func interact(_player: Player) -> void:
	push_warning("Interactable '%s' no implementa interact()." % name)
