extends Resource
class_name ItemData
## Definition of a game item (seed, crop, tool, mineral...).
##
## It's a Resource: each concrete item is created as a .tres file in
## res://data/items/. This lets designers add items without touching code,
## and ItemDatabase loads them by their `id`.

enum Category { SEED, CROP, TOOL, RESOURCE, FOOD, FISH, FORAGE, MISC }

@export var id: StringName
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var category: Category = Category.MISC

## How many units fit in a single inventory slot.
@export var max_stack: int = 99
## Base sell price (before quality/perk modifiers).
@export var sell_price: int = 0
## If false, the item cannot be sold in the shop.
@export var sellable: bool = true

## For seeds: the crop they produce when planted.
@export var crop: CropData


func is_stackable() -> bool:
	return max_stack > 1
