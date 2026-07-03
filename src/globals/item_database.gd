extends Node
## Central registry of ItemData and CropData loaded from data/.
##
## In _ready() it scans data/items/ and data/crops/ and indexes each resource
## by its `id` field. The rest of the game always accesses data through here,
## never via direct load(), to make caching and hot-reload easier.

var _items: Dictionary = {}  # StringName → ItemData
var _crops: Dictionary = {}  # StringName → CropData


func _ready() -> void:
	_scan("res://data/items/", _items)
	_scan("res://data/crops/", _crops)


func _scan(path: String, registry: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ItemDatabase: could not open '%s'" % path)
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res: Resource = load(path + file)
			if res != null and res.get("id"):
				registry[res.id] = res
			elif res != null:
				push_warning("ItemDatabase: resource with no `id` ignored: %s" % file)
		file = dir.get_next()


func get_item(id: StringName) -> ItemData:
	return _items.get(id, null)


func get_crop(id: StringName) -> CropData:
	return _crops.get(id, null)


func all_items() -> Array:
	return _items.values()


func all_crops() -> Array:
	return _crops.values()
