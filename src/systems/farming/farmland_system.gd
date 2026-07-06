extends Node
class_name FarmlandSystem
## Owns the state and rules of each farmland tile: tilled, watered, planted, ready, withered.
##
## Pure state + game rules, no drawing — FarmRenderer listens to
## EventBus.tile_updated and repaints ground/watered/crop layers by querying
## get_tile(). farm.gd calls setup() in its _ready() to hand over the
## references this needs. The system listens to EventBus.tool_used and
## EventBus.interact_tile to receive player actions without coupling
## directly to the Player.

enum State { UNTILLED, TILLED, PLANTED, READY, WITHERED }

var _ground: TileMapLayer  # kept only for world_to_tile's coordinate math
var _player: Player
var _plot_origin: Vector2i
var _plot_size: Vector2i
## Vector2i -> { state: int, crop_id: StringName, days_grown: int, watered: bool }
var _tiles: Dictionary = {}


func setup(
	ground: TileMapLayer,
	player: Player,
	plot_origin: Vector2i,
	plot_size: Vector2i
) -> void:
	add_to_group(&"farmland")
	_ground = ground
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


## Read-only lookup for FarmRenderer (and anything else that needs to know
## a tile's current state without duplicating it).
func get_tile(pos: Vector2i) -> Dictionary:
	return _tiles.get(pos, {})


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
	EventBus.tile_updated.emit(pos)
	return true


func try_water(pos: Vector2i) -> bool:
	var tile: Dictionary = _tiles.get(pos, {})
	if tile.is_empty() or tile.state in [State.UNTILLED, State.WITHERED] or tile.watered:
		return false
	tile.watered = true
	EventBus.crop_watered.emit(pos)
	EventBus.tile_updated.emit(pos)
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
	EventBus.crop_planted.emit(seed_item.crop, pos)
	EventBus.tile_updated.emit(pos)
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
	else:
		tile.state = State.TILLED
		tile.crop_id = &""
		tile.days_grown = 0
		tile.watered = false
	EventBus.tile_updated.emit(pos)
	return true


# ---------------------------------------------------------------------------
# EventBus signals
# ---------------------------------------------------------------------------

func _on_tool_used(item: ItemData, world_pos: Vector2) -> void:
	var pos := world_to_tile(world_pos)
	var success := false
	if _tiles.has(pos):
		match item.tool_action:
			ItemData.ToolAction.TILL:
				success = try_till(pos)
			ItemData.ToolAction.WATER:
				success = try_water(pos)
			ItemData.ToolAction.PLANT:
				success = try_plant(pos, item)
	EventBus.tool_action_resolved.emit(item, success)


func _on_interact_tile(world_pos: Vector2) -> void:
	try_harvest(world_to_tile(world_pos))


func _on_day_ended(day: int, season: int, _year: int) -> void:
	for pos: Vector2i in _tiles:
		var tile: Dictionary = _tiles[pos]
		var changed := false
		if tile.state == State.PLANTED:
			if tile.watered:
				tile.days_grown += 1
				var crop: CropData = ItemDatabase.get_crop(tile.crop_id)
				if crop != null and tile.days_grown >= crop.total_growth_days():
					if crop.can_grow_in_season(season):
						tile.state = State.READY
				changed = true
			else:
				## No watering for a full day: the crop withers.
				tile.state = State.WITHERED
				changed = true
		if tile.watered:
			tile.watered = false
			changed = true
		if changed:
			EventBus.tile_updated.emit(pos)
	print("[FarmlandSystem] Day %d processed." % day)


# ---------------------------------------------------------------------------
# Coordinates
# ---------------------------------------------------------------------------

func world_to_tile(world_pos: Vector2) -> Vector2i:
	return _ground.local_to_map(_ground.to_local(world_pos))


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
		## JSON always round-trips numbers as float; State.PLANTED etc. are int,
		## and `in`/Array.has() compare by exact type, so an un-cast float state
		## silently fails every "is this tile planted?" check below.
		d.state = int(d.get("state", State.UNTILLED))
		d.days_grown = int(d.get("days_grown", 0))
		d.crop_id = StringName(d.get("crop_id", ""))
		_tiles[pos] = d
		EventBus.tile_updated.emit(pos)
