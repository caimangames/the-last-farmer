extends Node
class_name FarmRenderer
## Paints the tilemap layers and crop sprites for FarmlandSystem's tile state.
##
## Owns everything Node2D/TileMapLayer-shaped: FarmlandSystem stays pure data
## and rules so its logic can change without touching a Sprite2D. farm.gd
## calls setup() in its _ready() to hand over the layers and FarmlandSystem
## reference; from then on this repaints reactively via EventBus.tile_updated
## instead of being called directly.

const SRC_GRASS    := 0
const SRC_FARMLAND := 1

var _farmland: FarmlandSystem
var _ground: TileMapLayer
var _watered_layer: TileMapLayer
var _crop_layer: Node2D
var _plot_origin: Vector2i
var _plot_size: Vector2i


func setup(
	farmland: FarmlandSystem,
	ground: TileMapLayer,
	watered_layer: TileMapLayer,
	crop_layer: Node2D,
	plot_origin: Vector2i,
	plot_size: Vector2i
) -> void:
	_farmland = farmland
	_ground = ground
	_watered_layer = watered_layer
	_crop_layer = crop_layer
	_plot_origin = plot_origin
	_plot_size = plot_size
	EventBus.tile_updated.connect(_on_tile_updated)


func _on_tile_updated(pos: Vector2i) -> void:
	var tile: Dictionary = _farmland.get_tile(pos)
	if tile.is_empty():
		return
	_update_ground(pos, tile)
	_update_watered(pos, tile)
	_update_crop(pos, tile)


func _update_ground(pos: Vector2i, tile: Dictionary) -> void:
	if tile.state == FarmlandSystem.State.UNTILLED:
		_ground.set_cell(pos, SRC_GRASS, Vector2i.ZERO)
	else:
		var nx := pos.x - _plot_origin.x
		var ny := pos.y - _plot_origin.y
		_ground.set_cell(pos, SRC_FARMLAND, _farmland_coord(nx, ny))


func _farmland_coord(nx: int, ny: int) -> Vector2i:
	var col := 0 if nx == 0 else (2 if nx == _plot_size.x - 1 else 1)
	var row := 0 if ny == 0 else (2 if ny == _plot_size.y - 1 else 1)
	return Vector2i(col, row)


func _update_watered(pos: Vector2i, tile: Dictionary) -> void:
	if tile.watered:
		_watered_layer.set_cell(pos, SRC_FARMLAND, Vector2i(1, 1))
	else:
		_watered_layer.erase_cell(pos)


func _update_crop(pos: Vector2i, tile: Dictionary) -> void:
	_clear_crop(pos)
	if tile.state not in [FarmlandSystem.State.PLANTED, FarmlandSystem.State.READY, FarmlandSystem.State.WITHERED]:
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
	if tile.state == FarmlandSystem.State.WITHERED:
		spr.modulate = Color(0.45, 0.4, 0.35)
	_crop_layer.add_child(spr)
	if tile.state == FarmlandSystem.State.PLANTED and tile.days_grown == 0:
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
	if tile.state == FarmlandSystem.State.READY:
		return crop.stage_textures.size() - 1
	var elapsed := 0
	for i in crop.growth_stages.size():
		elapsed += crop.growth_stages[i]
		if tile.days_grown < elapsed:
			return i
	return crop.stage_textures.size() - 1
