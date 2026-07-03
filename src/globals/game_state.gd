extends Node
## Estado global de la partida en curso.
##
## Contiene los datos "vivos" del jugador que deben persistir entre escenas
## y guardarse en disco: oro, inventario, banderas de progreso, etc.
## Es deliberadamente simple: la lógica vive en los sistemas, aquí solo el dato.

const STARTING_GOLD: int = 500
const STARTING_ENERGY: int = 100

var player_name: String = "Granjero"
var farm_name: String = "Sin Nombre"
var gold: int = STARTING_GOLD

var energy: int = STARTING_ENERGY
var max_energy: int = STARTING_ENERGY

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


## Descuenta energía sin bajar de 0 (no bloquea la acción que la gasta).
func spend_energy(amount: int) -> void:
	var new_energy: int = max(0, energy - amount)
	var delta: int = new_energy - energy
	energy = new_energy
	EventBus.energy_changed.emit(energy, delta)


## Repone la energía al máximo, típicamente al empezar el día.
func restore_energy() -> void:
	var delta: int = max_energy - energy
	energy = max_energy
	EventBus.energy_changed.emit(energy, delta)


func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value


func has_flag(key: String) -> bool:
	return flags.get(key, false)


## Reinicia el estado para una partida nueva.
func reset() -> void:
	gold = STARTING_GOLD
	energy = STARTING_ENERGY
	max_energy = STARTING_ENERGY
	flags.clear()
	inventory = null


## Serializa el estado para guardarlo.
func to_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"farm_name": farm_name,
		"gold": gold,
		"energy": energy,
		"max_energy": max_energy,
		"flags": flags,
		"inventory": inventory.to_dict() if inventory != null else {},
	}


func from_dict(data: Dictionary) -> void:
	player_name = data.get("player_name", player_name)
	farm_name = data.get("farm_name", farm_name)
	gold = data.get("gold", STARTING_GOLD)
	max_energy = data.get("max_energy", STARTING_ENERGY)
	energy = data.get("energy", max_energy)
	flags = data.get("flags", {})
	if inventory != null:
		inventory.from_dict(data.get("inventory", {}))
	EventBus.gold_changed.emit(gold, 0)
	EventBus.energy_changed.emit(energy, 0)
