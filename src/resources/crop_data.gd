extends Resource
class_name CropData
## Definición de un cultivo: cuánto tarda en crecer, en qué estación y qué produce.
##
## Cada cultivo concreto vive como un .tres en res://data/crops/.

@export var id: StringName
@export var display_name: String = ""

## Días que tarda cada fase de crecimiento. El total de días = suma del array.
## El tamaño del array determina el número de fases de sprite.
@export var growth_stages: Array[int] = [1, 2, 2, 2]

## Texturas para cada fase (debe coincidir en tamaño con growth_stages + 1
## si se incluye la fase "muerta/seca").
@export var stage_textures: Array[Texture2D] = []

## Estaciones en las que el cultivo puede crecer (usa TimeManager.Season).
@export var valid_seasons: Array[int] = []

## Objeto que se obtiene al cosechar.
@export var harvest_item: ItemData
@export var harvest_min: int = 1
@export var harvest_max: int = 1

## Si es > 0, tras cosechar el cultivo vuelve a esta fase en lugar de morir
## (cultivos regrowables como las fresas). 0 = cultivo de una sola cosecha.
@export var regrowth_days: int = 0


func total_growth_days() -> int:
	var total: int = 0
	for days in growth_stages:
		total += days
	return total


func can_grow_in_season(season: int) -> bool:
	return valid_seasons.is_empty() or season in valid_seasons
