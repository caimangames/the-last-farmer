extends Node
## Global state of the current playthrough.
##
## Holds the "live" player data that must persist between scenes and be
## saved to disk: gold, inventory, progress flags, etc.
## Deliberately simple: logic lives in the systems, only data lives here.

const STARTING_GOLD: int = 500
const STARTING_ENERGY: int = 100

var player_name: String = "Farmer"
var farm_name: String = "Unnamed"
var gold: int = STARTING_GOLD

var energy: int = STARTING_ENERGY
var max_energy: int = STARTING_ENERGY

## Story progress flags / unlocks. E.g.: {"barn_built": true}
var flags: Dictionary = {}

## Reference to the player's inventory (assigned when the game starts).
var inventory: Object = null

## True while farm.gd should load a saved game instead of handing out
## the starting items. Set by main.gd, not persisted.
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


## Deducts energy without going below 0 (does not block the action that spends it).
func spend_energy(amount: int) -> void:
	var new_energy: int = max(0, energy - amount)
	var delta: int = new_energy - energy
	energy = new_energy
	EventBus.energy_changed.emit(energy, delta)


## Restores energy to max, typically at the start of the day.
func restore_energy() -> void:
	var delta: int = max_energy - energy
	energy = max_energy
	EventBus.energy_changed.emit(energy, delta)


func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value


func has_flag(key: String) -> bool:
	return flags.get(key, false)


## Resets the state for a new playthrough.
func reset() -> void:
	gold = STARTING_GOLD
	energy = STARTING_ENERGY
	max_energy = STARTING_ENERGY
	flags.clear()
	inventory = null


## Serializes the state for saving.
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
