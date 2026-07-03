extends Resource
class_name CropData
## Definition of a crop: how long it takes to grow, in which season, and what it produces.
##
## Each concrete crop lives as a .tres in res://data/crops/.

@export var id: StringName
@export var display_name: String = ""

## Days each growth stage takes. Total days = sum of the array.
## The array's size determines the number of sprite stages.
@export var growth_stages: Array[int] = [1, 2, 2, 2]

## Textures for each stage (must match growth_stages in size + 1
## if the "dead/withered" stage is included).
@export var stage_textures: Array[Texture2D] = []

## Seasons in which the crop can grow (uses TimeManager.Season).
@export var valid_seasons: Array[int] = []

## Item obtained when harvesting.
@export var harvest_item: ItemData
@export var harvest_min: int = 1
@export var harvest_max: int = 1

## If > 0, after harvesting the crop returns to this stage instead of dying
## (regrowable crops like strawberries). 0 = single-harvest crop.
@export var regrowth_days: int = 0


func total_growth_days() -> int:
	var total: int = 0
	for days in growth_stages:
		total += days
	return total


func can_grow_in_season(season: int) -> bool:
	return valid_seasons.is_empty() or season in valid_seasons
