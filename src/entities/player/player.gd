extends CharacterBody2D
class_name Player

const ENERGY_COST_PER_TOOL_USE: int = 2

@export var move_speed: float = 90.0
@export var inventory_size: int = 24

var inventory: Inventory
var active_slot: int = 0

var _facing: String = "down"
var _current_anim: String = ""

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group(&"player")
	inventory = Inventory.new(inventory_size)
	GameState.inventory = inventory
	_play_anim("idle_down", false)
	EventBus.active_slot_changed.emit(active_slot)
	EventBus.tool_action_resolved.connect(_on_tool_action_resolved)


# ---------------------------------------------------------------------------
# Saving
# ---------------------------------------------------------------------------

func to_dict() -> Dictionary:
	return {"position_x": global_position.x, "position_y": global_position.y}


func from_dict(data: Dictionary) -> void:
	global_position = Vector2(
		data.get("position_x", global_position.x),
		data.get("position_y", global_position.y)
	)


func get_active_item() -> ItemData:
	if inventory == null or active_slot >= inventory.slots.size():
		return null
	var slot := inventory.slots[active_slot]
	return null if slot.is_empty() else slot.item


func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * move_speed
	_update_animation(dir)
	move_and_slide()


func _update_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		if _facing in ["left", "right"]:
			_sprite.flip_h = (_facing == "left")
			if _current_anim != "idle_side":
				_current_anim = "idle_side"
				_sprite.play("walk_side")
				_sprite.stop()
		else:
			_play_anim("idle_" + _facing, false)
	elif absf(dir.x) >= absf(dir.y):
		_facing = "right" if dir.x > 0.0 else "left"
		_play_anim("walk_side", _facing == "left")
	elif dir.y > 0.0:
		_facing = "down"
		_play_anim("walk_down", false)
	else:
		_facing = "up"
		_play_anim("walk_up", false)


func _play_anim(anim: String, flip: bool) -> void:
	_sprite.flip_h = flip
	if _current_anim != anim:
		_current_anim = anim
		_sprite.play(anim)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_try_interact()
	elif event.is_action_pressed("use_tool"):
		_try_use_tool()
	elif event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo:
			var k := key_event.physical_keycode
			if k >= KEY_1 and k <= KEY_9:
				var slot := k - KEY_1
				if slot < inventory.size:
					active_slot = slot
					EventBus.active_slot_changed.emit(active_slot)


func _try_interact() -> void:
	for body in _interaction_area.get_overlapping_bodies():
		if body.has_method("interact"):
			body.interact(self)
			EventBus.interaction_started.emit(body)
			return
	for area in _interaction_area.get_overlapping_areas():
		if area.has_method("interact"):
			area.interact(self)
			EventBus.interaction_started.emit(area)
			return
	# No nearby interactable: try to harvest the tile under the player.
	EventBus.interact_tile.emit(global_position)


func _try_use_tool() -> void:
	var item := get_active_item()
	if item == null:
		return
	EventBus.tool_used.emit(item, get_global_mouse_position())


## A no-op tool use (e.g. hoeing an already-tilled tile) must not drain energy.
func _on_tool_action_resolved(_item: ItemData, success: bool) -> void:
	if success:
		GameState.spend_energy(ENERGY_COST_PER_TOOL_USE)
