extends Resource
class_name ItemData
## Definición de un objeto del juego (semilla, cosecha, herramienta, mineral...).
##
## Es un Resource: cada objeto concreto se crea como un archivo .tres en
## res://data/items/. Esto permite a diseñadores añadir objetos sin tocar código
## y los carga el ItemDatabase por su `id`.

enum Category { SEED, CROP, TOOL, RESOURCE, FOOD, FISH, FORAGE, MISC }

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: Category = Category.MISC

## Cuántas unidades caben en un solo slot del inventario.
@export var max_stack: int = 99
## Precio de venta base (antes de modificadores de calidad/perks).
@export var sell_price: int = 0
## Si es false, el objeto no puede venderse en la tienda.
@export var sellable: bool = true

## Para semillas: el cultivo que producen al plantarse.
@export var crop: CropData


func is_stackable() -> bool:
	return max_stack > 1
