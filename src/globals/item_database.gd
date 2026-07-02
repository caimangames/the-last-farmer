extends Node
## Registro central de ItemData y CropData cargados desde data/.
##
## En _ready() escanea data/items/ y data/crops/ e indexa cada recurso por su
## campo `id`. El resto del juego accede a los datos siempre a través de aquí,
## nunca con load() directo, para facilitar el caché y el hot-reload.

var _items: Dictionary = {}  # StringName → ItemData
var _crops: Dictionary = {}  # StringName → CropData


func _ready() -> void:
	_scan("res://data/items/", _items)
	_scan("res://data/crops/", _crops)


func _scan(path: String, registry: Dictionary) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("ItemDatabase: no se pudo abrir '%s'" % path)
		return
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var res: Resource = load(path + file)
			if res != null and res.get("id"):
				registry[res.id] = res
			elif res != null:
				push_warning("ItemDatabase: recurso sin `id` ignorado: %s" % file)
		file = dir.get_next()


func get_item(id: StringName) -> ItemData:
	return _items.get(id, null)


func get_crop(id: StringName) -> CropData:
	return _crops.get(id, null)


func all_items() -> Array:
	return _items.values()


func all_crops() -> Array:
	return _crops.values()
