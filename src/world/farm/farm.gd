extends Node2D

const SRC_GRASS := 0

const FIELD_SIZE  := Vector2i(40, 24)
const PLOT_ORIGIN := Vector2i(6, 6)
const PLOT_SIZE   := Vector2i(8, 6)

@onready var _ground: TileMapLayer       = $Ground
@onready var _watered_layer: TileMapLayer = $WateredLayer
@onready var _crop_layer: Node2D          = $CropLayer
@onready var _farmland: FarmlandSystem    = $FarmlandSystem
@onready var _props: Node2D              = $Props
@onready var _player: Player             = $Entities/Player
@onready var _hud: CanvasLayer           = $HUD


func _ready() -> void:
	_paint_grass()
	_farmland.setup(_ground, _watered_layer, _crop_layer, _player, PLOT_ORIGIN, PLOT_SIZE)
	if GameState.loading_save:
		GameState.loading_save = false
		SaveManager.load_game()
		EventBus.game_paused.emit(false)
	else:
		_give_starting_items()
	_setup_decorations()
	_hud.setup(_player)
	print("[Farm] Farm loaded. Day %d, %s." % [TimeManager.day, TimeManager.get_time_string()])


func _paint_grass() -> void:
	for y in FIELD_SIZE.y:
		for x in FIELD_SIZE.x:
			_ground.set_cell(Vector2i(x, y), SRC_GRASS, Vector2i.ZERO)


func _give_starting_items() -> void:
	var inv := _player.inventory
	for id: StringName in [&"hoe", &"watering_can"]:
		var item: ItemData = ItemDatabase.get_item(id)
		if item:
			inv.add_item(item, 1)
	var seed_item: ItemData = ItemDatabase.get_item(&"turnip_seed")
	if seed_item:
		inv.add_item(seed_item, 10)


func _setup_decorations() -> void:
	# --- House (96x128) — top-right corner ---
	_prop("res://assets/sprites/props/house_wood_blue.png", Vector2(424, 12))

	# --- Chest (16x16) — next to the house door ---
	_prop("res://assets/sprites/props/chest.png", Vector2(424, 140))

	# --- Large tree (64x80) — corners of the field ---
	_prop("res://assets/sprites/props/oak_tree.png", Vector2(8,   8))
	_prop("res://assets/sprites/props/oak_tree.png", Vector2(8,  288))
	_prop("res://assets/sprites/props/oak_tree.png", Vector2(552,  8))
	_prop("res://assets/sprites/props/oak_tree.png", Vector2(552, 288))

	# --- Small tree, left (48x48, left half of the sheet) ---
	_prop_atlas("res://assets/sprites/props/oak_tree_small.png",
			Vector2(8, 160), Rect2(0, 0, 48, 48))

	# --- Small tree, right (48x48, right half of the sheet) ---
	_prop_atlas("res://assets/sprites/props/oak_tree_small.png",
			Vector2(552, 160), Rect2(48, 0, 48, 48))


func _prop(path: String, pos: Vector2) -> void:
	var spr := Sprite2D.new()
	spr.texture = load(path)
	spr.centered = false
	spr.position = pos
	_props.add_child(spr)


func _prop_atlas(path: String, pos: Vector2, region: Rect2) -> void:
	var spr := Sprite2D.new()
	var atlas := AtlasTexture.new()
	atlas.atlas = load(path)
	atlas.region = region
	spr.texture = atlas
	spr.centered = false
	spr.position = pos
	_props.add_child(spr)
