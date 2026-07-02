extends SceneTree
## Herramienta de un solo uso: genera el TileSet del suelo de la granja.
##
## Se ejecuta en modo headless:
##   godot --headless --path . --script res://tools/build_ground_tileset.gd
##
## Construir un TileSet a mano en .tres es propenso a errores; dejar que Godot
## lo serialice garantiza un recurso válido. Vuelve a ejecutarlo si cambian los
## tiles base.

const TILE_SIZE := Vector2i(16, 16)
const OUTPUT := "res://assets/tilesets/ground_tileset.tres"

# Cada entrada: textura base y rejilla de tiles (columnas x filas) a registrar.
const SOURCES := [
	{"id": 0, "path": "res://assets/tilesets/grass_middle.png", "cols": 1, "rows": 1},
	{"id": 1, "path": "res://assets/tilesets/farmland_tile.png", "cols": 3, "rows": 3},
	{"id": 2, "path": "res://assets/tilesets/path_middle.png", "cols": 1, "rows": 1},
	{"id": 3, "path": "res://assets/tilesets/water_middle.png", "cols": 1, "rows": 1},
]


func _initialize() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE

	for entry in SOURCES:
		var tex: Texture2D = load(entry["path"])
		if tex == null:
			push_error("No se pudo cargar %s" % entry["path"])
			continue
		var source := TileSetAtlasSource.new()
		source.texture = tex
		source.texture_region_size = TILE_SIZE
		for y in entry["rows"]:
			for x in entry["cols"]:
				source.create_tile(Vector2i(x, y))
		tile_set.add_source(source, entry["id"])
		print("Fuente %d: %s (%dx%d tiles)" % [entry["id"], entry["path"], entry["cols"], entry["rows"]])

	var err := ResourceSaver.save(tile_set, OUTPUT)
	if err == OK:
		print("TileSet guardado en %s" % OUTPUT)
	else:
		push_error("Error al guardar el TileSet: %d" % err)

	quit()
