extends Node
## Reloj del juego: gestiona la hora, el día, la estación y el año.
##
## El tiempo solo avanza cuando el juego está activo (no en pausa ni en menús).
## Emite señales a través del EventBus para que cultivos, NPCs e iluminación
## reaccionen al paso del tiempo sin depender directamente de este nodo.

enum Season { SPRING, SUMMER, FALL, WINTER }

const DAYS_PER_SEASON: int = 28
const START_HOUR: int = 6
const END_HOUR: int = 26  # 2:00 AM del día siguiente -> el jugador se desmaya
## Segundos reales por minuto del juego. Más bajo = el día pasa más rápido.
const REAL_SECONDS_PER_GAME_MINUTE: float = 0.7

var hour: int = START_HOUR
var minute: int = 0
var day: int = 1
var season: Season = Season.SPRING
var year: int = 1

var _paused: bool = true
var _accumulator: float = 0.0


func _ready() -> void:
	EventBus.game_paused.connect(func(p): _paused = p)


func _process(delta: float) -> void:
	if _paused:
		return
	_accumulator += delta
	while _accumulator >= REAL_SECONDS_PER_GAME_MINUTE:
		_accumulator -= REAL_SECONDS_PER_GAME_MINUTE
		_advance_minute()


func start_day() -> void:
	_paused = false
	hour = START_HOUR
	minute = 0
	EventBus.day_started.emit(day, season, year)


func _advance_minute() -> void:
	minute += 10
	if minute >= 60:
		minute = 0
		hour += 1
		EventBus.hour_changed.emit(hour, minute)
		if hour >= END_HOUR:
			end_day()
	else:
		EventBus.hour_changed.emit(hour, minute)


func end_day() -> void:
	_paused = true
	EventBus.day_ended.emit(day, season, year)
	_advance_calendar()


func _advance_calendar() -> void:
	day += 1
	if day > DAYS_PER_SEASON:
		day = 1
		var next: int = (int(season) + 1) % Season.size()
		season = next as Season
		EventBus.season_changed.emit(season)
		if season == Season.SPRING:
			year += 1


func get_time_string() -> String:
	var period: String = "AM"
	var display_hour: int = hour
	if display_hour >= 24:
		display_hour -= 24
	if display_hour >= 12:
		period = "PM"
	if display_hour > 12:
		display_hour -= 12
	if display_hour == 0:
		display_hour = 12
	return "%d:%02d %s" % [display_hour, minute, period]


func to_dict() -> Dictionary:
	return {"hour": hour, "minute": minute, "day": day, "season": int(season), "year": year}


func from_dict(data: Dictionary) -> void:
	hour = data.get("hour", START_HOUR)
	minute = data.get("minute", 0)
	day = data.get("day", 1)
	season = data.get("season", Season.SPRING) as Season
	year = data.get("year", 1)
