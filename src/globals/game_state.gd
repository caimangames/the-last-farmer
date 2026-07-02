extends Node
## Estado global de la partida en curso.
##
## Contiene los datos "vivos" del jugador que deben persistir entre escenas
## y guardarse en disco: oro, inventario, banderas de progreso, etc.
## Es deliberadamente simple: la lógica vive en los sistemas, aquí solo el dato.

const STARTING_GOLD: int = 500

var player_name: String = "Granjero"
var farm_name: String = "Sin Nombre"
var gold: int = STARTING_GOLD

## Banderas de progreso de la historia / desbloqueos. Ej: {"barn_built": true}
var flags: Dictionary = {}

## Referencia al inventario del jugador (se asigna al iniciar la partida).
var inventory: Object = null

## True mientras farm.gd debe cargar una partida guardada en vez de repartir
## los ítems iniciales. Lo fija main.gd, no se persiste.
var loading_save: bool = false


func add_gold(amount: int) -> void:
	gold += amount
	EventBus.gold_changed.emit(gold, amount)


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	EventBus.gold_changed.emit(gold, -amount)
	return true


func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value


func has_flag(key: String) -> bool:
	return flags.get(key, false)


## Reinicia el estado para una partida nueva.
func reset() -> void:
	gold = STARTING_GOLD
	flags.clear()
	inventory = null


## Serializa el estado para guardarlo.
func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"farm_name": farm_name,
		"gold": gold,
		"flags": flags,
		"inventory": inventory.to_dict() if inventory != null else {},
	}


func from_dict(data: Dictionary) -> void:
	player_name = data.get("player_name", player_name)
	farm_name = data.get("farm_name", farm_name)
	gold = data.get("gold", STARTING_GOLD)
	flags = data.get("flags", {})
	if inventory != null:
		inventory.from_dict(data.get("inventory", {}))
	EventBus.gold_changed.emit(gold, 0)
