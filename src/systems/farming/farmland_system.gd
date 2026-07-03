extends Node
class_name FarmlandSystem
## Manages the state of each farmland tile: tilled, watered, planted, and ready.
##
## farm.gd calls setup() in its _ready() to hand over the necessary references.
## The system listens to EventBus.tool_used and EventBus.interact_tile to
## receive player actions without coupling directly to the Player.

enum State { UNTILLED, TILLED, PLANTED, READY, WITHERED }

const SRC_GRASS    := 0
const SRC_FARMLAND := 1

var _ground: TileMapLayer
var _watered_layer: TileMapLayer
var _crop_layer: Node2D
var _player: Player
var _plot_origin: Vector2i
var _plot_size: Vector2i
## Vector2i -> { state: int, crop_id: StringName, days_grown: int, watered: bool }
var _tiles: Dictionary = {}


func setup(
	ground: TileMapLayer,
	watered_layer: TileMapLayer,
	crop_layer: Node2D,
	player: Player,
	plot_origin: Vector2i,
	plot_size: Vector2i
) -> void:
	add_to_group(&"farmland")
	_ground = ground
	_watered_layer = watered_layer
	_crop_layer = crop_layer
	_player = player
	_plot_origin = plot_origin
	_plot_size = plot_size
	_init_tiles()
	EventBus.tool_used.connect(_on_tool_used)
	EventBus.interact_tile.connect(_on_interact_tile)
	EventBus.day_ended.connect(_on_day_ended)


func _init_tiles() -> void:
	for ny in _plot_size.y:
		for nx in _plot_size.x:
			_tiles[_plot_origin + Vector2i(nx, ny)] = {
				"state": State.UNTILLED,
				"crop_id": &"",
				"days_grown": 0,
				"watered": false,
			}


# ---------------------------------------------------------------------------
# Public actions
# ---------------------------------------------------------------------------

func try_till(pos: Vector2i) -> bool:
	var tile: Dictionary = _tiles.get(pos, {})
	if tile.is_empty() or (tile.state != State.UNTILLED and tile.state != State.WITHERED):
		return false
	tile.state = State.TILLED
	tile.crop_id = &""
	tile.days_grown = 0
	_clear_crop(pos)
	_update_ground(pos)
	return true


func try_water(pos: Vector2i) -> bool:
	var tile: Dictionary = _tiles.get(pos, {})
	if tile.is_empty() or tile.state in [State.UNTILLED, State.WITHERED] or tile.watered:
		return false
	tile.watered = true
	_update_watered(pos, true)
	EventBus.crop_watered.emit(pos)
	return true


func try_plant(pos: Vector2i, seed_item: ItemData) -> bool:
	var tile: Dictionary = _tiles.get(pos, {})
	if tile.is_empty() or tile.state != State.TILLED:
		return false
	if seed_item.crop == null:
		return false
	if not seed_item.crop.can_grow_in_season(TimeManager.season):
		EventBus.notification_requested.emit(
			"%s doesn't grow in this season." % seed_item.crop.display_name
		)
		return false
	if not _player.inventory.remove_item(seed_item, 1):
		return false
	tile.state = State.PLANTED
	tile.crop_id = seed_item.crop.id
	tile.days_grown = 0
	_update_crop(pos)
	EventBus.crop_planted.emit(seed_item.crop, pos)
	return true


func try_harvest(pos: Vector2i) -> bool:
	var tile: Dictionary = _tiles.get(pos, {})
	if tile.is_empty() or tile.state != State.READY:
		return false
	var crop: CropData = ItemDatabase.get_crop(tile.crop_id)
	if crop == null or crop.harvest_item == null:
		return false
	var amount := randi_range(crop.harvest_min, crop.harvest_max)
	_player.inventory.add_item(crop.harvest_item, amount)
	EventBus.crop_harvested.emit(crop, pos)
	EventBus.notification_requested.emit("+%d %s" % [amount, crop.harvest_item.display_name])
	if crop.regrowth_days > 0:
		## Multiple harvest: returns to an earlier stage instead of dying.
		tile.state = State.PLANTED
		tile.days_grown = max(0, crop.total_growth_days() - crop.regrowth_days)
		tile.watered = false
		_update_watered(pos, false)
		_update_crop(pos)
	else:
		tile.state = State.TILLED
		tile.crop_id = &""
		tile.days_grown = 0
		tile.watered = false
		_update_ground(pos)
		_update_watered(pos, false)
		_clear_crop(pos)
	return true


# ---------------------------------------------------------------------------
# EventBus signals
# ---------------------------------------------------------------------------

func _on_tool_used(item: ItemData, world_pos: Vector2) -> void:
	var pos := world_to_tile(world_pos)
	if not _tiles.has(pos):
		return
	match item.category:
		ItemData.Category.TOOL:
			if item.id == &"hoe":
				try_till(pos)
			elif item.id == &"watering_can":
				try_water(pos)
		ItemData.Category.SEED:
			try_plant(pos, item)


func _on_interact_tile(world_pos: Vector2) -> void:
	try_harvest(world_to_tile(world_pos))


func _on_day_ended(day: int, season: int, _year: int) -> void:
	for pos: Vector2i in _tiles:
		var tile: Dictionary = _tiles[pos]
		if tile.state == State.PLANTED:
			if tile.watered:
				tile.days_grown += 1
				var crop: CropData = ItemDatabase.get_crop(tile.crop_id)
				if crop != null and tile.days_grown >= crop.total_growth_days():
					if crop.can_grow_in_season(season):
						tile.state = State.READY
				_update_crop(pos)
			else:
				## No watering for a full day: the crop withers.
				tile.state = State.WITHERED
				_update_crop(pos)
		if tile.watered:
			tile.watered = false
			_update_watered(pos, false)
	print("[FarmlandSystem] Day %d processed." % day)


# ---------------------------------------------------------------------------
# Visuals
# ---------------------------------------------------------------------------

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return _ground.local_to_map(_ground.to_local(world_pos))


func _update_ground(pos: Vector2i) -> void:
	var tile: Dictionary = _tiles[pos]
	if tile.state == State.UNTILLED:
		_ground.set_cell(pos, SRC_GRASS, Vector2i.ZERO)
	else:
		var nx := pos.x - _plot_origin.x
		var ny := pos.y - _plot_origin.y
		_ground.set_cell(pos, SRC_FARMLAND, _farmland_coord(nx, ny))


func _farmland_coord(nx: int, ny: int) -> Vector2i:
	var col := 0 if nx == 0 else (2 if nx == _plot_size.x - 1 else 1)
	var row := 0 if ny == 0 else (2 if ny == _plot_size.y - 1 else 1)
	return Vector2i(col, row)


func _update_watered(pos: Vector2i, watered: bool) -> void:
	if watered:
		_watered_layer.set_cell(pos, SRC_FARMLAND, Vector2i(1, 1))
	else:
		_watered_layer.erase_cell(pos)


func _update_crop(pos: Vector2i) -> void:
	_clear_crop(pos)
	var tile: Dictionary = _tiles[pos]
	if tile.state not in [State.PLANTED, State.READY, State.WITHERED]:
		return
	var crop: CropData = ItemDatabase.get_crop(tile.crop_id)
	if crop == null or crop.stage_textures.is_empty():
		return
	var stage := _get_stage(tile, crop)
	if stage >= crop.stage_textures.size():
		return
	var spr := Sprite2D.new()
	spr.name = "c%d_%d" % [pos.x, pos.y]
	spr.texture = crop.stage_textures[stage]
	spr.global_position = _ground.to_global(_ground.map_to_local(pos))
	if tile.state == State.WITHERED:
		spr.modulate = Color(0.45, 0.4, 0.35)
	_crop_layer.add_child(spr)
	if tile.state == State.PLANTED and tile.days_grown == 0:
		_play_pop(spr)


func _play_pop(spr: Sprite2D) -> void:
	spr.scale = Vector2(0.2, 0.2)
	var tween := create_tween()
	tween.tween_property(spr, "scale", Vector2.ONE, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _clear_crop(pos: Vector2i) -> void:
	var node := _crop_layer.get_node_or_null("c%d_%d" % [pos.x, pos.y])
	if node:
		node.queue_free()


func _get_stage(tile: Dictionary, crop: CropData) -> int:
	if tile.state == State.READY:
		return crop.stage_textures.size() - 1
	var elapsed := 0
	for i in crop.growth_stages.size():
		elapsed += crop.growth_stages[i]
		if tile.days_grown < elapsed:
			return i
	return crop.stage_textures.size() - 1


# ---------------------------------------------------------------------------
# Saving
# ---------------------------------------------------------------------------

func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for pos: Vector2i in _tiles:
		var t: Dictionary = _tiles[pos].duplicate()
		t.crop_id = str(t.crop_id)
		out["%d,%d" % [pos.x, pos.y]] = t
	return out


func from_dict(data: Dictionary) -> void:
	for key: String in data:
		var parts := key.split(",")
		var pos := Vector2i(int(parts[0]), int(parts[1]))
		if not _tiles.has(pos):
			continue
		var d: Dictionary = data[key]
		d.crop_id = StringName(d.get("crop_id", ""))
		_tiles[pos] = d
		_update_ground(pos)
		_update_watered(pos, d.get("watered", false))
		_update_crop(pos)
