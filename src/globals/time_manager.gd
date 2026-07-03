extends Node
## Game clock: manages the hour, day, season, and year.
##
## Time only advances while the game is active (not paused or in menus).
## Emits signals through the EventBus so crops, NPCs, and lighting can
## react to the passage of time without depending directly on this node.

enum Season { SPRING, SUMMER, FALL, WINTER }

const DAYS_PER_SEASON: int = 28
const START_HOUR: int = 6
const END_HOUR: int = 26  # 2:00 AM the next day -> the player passes out
## Real seconds per game minute. Lower = the day passes faster.
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


## Sleep voluntarily: closes out the current day and starts the next one.
## Provisional until an interactable bed/house exists (M7): triggered
## by the "sleep" action while the clock is running.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("sleep") and not _paused:
		sleep()


func sleep() -> void:
	end_day()
	start_day()


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
	GameState.restore_energy()
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
	EventBus.hour_changed.emit(hour, minute)
