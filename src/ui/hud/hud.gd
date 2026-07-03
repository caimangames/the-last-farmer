extends CanvasLayer
## HUD básico: reloj/día, oro y hotbar del inventario activo.
##
## farm.gd llama a setup(player) en su _ready() para conectar la hotbar
## al inventario del jugador. El reloj y el oro se actualizan solo mirando
## el EventBus, sin depender del Player.

const SLOT_COUNT: int = 9
const SLOT_SIZE: int = 34
const ACTIVE_BORDER: Color = Color(1.0, 0.85, 0.3, 1.0)
const IDLE_BORDER: Color = Color(0.0, 0.0, 0.0, 0.8)
const SEASON_NAMES: Array[String] = ["Primavera", "Verano", "Otoño", "Invierno"]

var _player: Player
var _active_slot: int = 0

var _slot_styles: Array[StyleBoxFlat] = []
var _slot_icons: Array[TextureRect] = []
var _slot_fallbacks: Array[Label] = []
var _slot_counts: Array[Label] = []

@onready var _time_label: Label = $TopLeft/TimeLabel
@onready var _gold_label: Label = $TopRight/GoldLabel
@onready var _energy_bar: ProgressBar = $EnergyPanel/EnergyBar
@onready var _hotbar: HBoxContainer = $Hotbar
@onready var _toast: PanelContainer = $Toast
@onready var _toast_label: Label = $Toast/ToastLabel
@onready var _toast_timer: Timer = $ToastTimer


func _ready() -> void:
	_build_hotbar()
	_update_time()
	_update_gold(GameState.gold, 0)
	_update_energy(GameState.energy, 0)

	EventBus.day_started.connect(func(_d, _s, _y): _update_time())
	EventBus.hour_changed.connect(func(_h, _m): _update_time())
	EventBus.gold_changed.connect(_update_gold)
	EventBus.energy_changed.connect(_update_energy)
	EventBus.inventory_changed.connect(_refresh_hotbar)
	EventBus.active_slot_changed.connect(_on_active_slot_changed)
	EventBus.notification_requested.connect(_show_toast)
	_toast_timer.timeout.connect(func(): _toast.visible = false)


## Llamado por farm.gd para enlazar la hotbar al inventario del jugador.
func setup(player: Player) -> void:
	_player = player
	_active_slot = player.active_slot
	_refresh_hotbar()
	_update_active_visual()


func _build_hotbar() -> void:
	for i in SLOT_COUNT:
		var panel := Panel.new()
		panel.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = IDLE_BORDER
		panel.add_theme_stylebox_override("panel", style)
		_hotbar.add_child(panel)

		var icon := TextureRect.new()
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 3
		icon.offset_top = 3
		icon.offset_right = -3
		icon.offset_bottom = -3
		panel.add_child(icon)

		var fallback := Label.new()
		fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		fallback.add_theme_font_size_override("font_size", 10)
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.add_child(fallback)

		var count := Label.new()
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.add_theme_font_size_override("font_size", 10)
		count.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		count.offset_left = -20
		count.offset_top = -14
		panel.add_child(count)

		var number := Label.new()
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		number.text = str(i + 1)
		number.modulate = Color(1, 1, 1, 0.6)
		number.add_theme_font_size_override("font_size", 8)
		number.set_anchors_preset(Control.PRESET_TOP_LEFT)
		number.offset_left = 2
		panel.add_child(number)

		_slot_styles.append(style)
		_slot_icons.append(icon)
		_slot_fallbacks.append(fallback)
		_slot_counts.append(count)


func _refresh_hotbar() -> void:
	if _player == null or _player.inventory == null:
		return
	for i in SLOT_COUNT:
		var slot: InventorySlot = _player.inventory.slots[i]
		if slot.is_empty():
			_slot_icons[i].texture = null
			_slot_fallbacks[i].text = ""
			_slot_counts[i].text = ""
			continue
		_slot_icons[i].texture = slot.item.icon
		_slot_fallbacks[i].text = "" if slot.item.icon != null else slot.item.display_name.left(2).to_upper()
		_slot_counts[i].text = "" if slot.amount <= 1 else str(slot.amount)


func _on_active_slot_changed(slot: int) -> void:
	_active_slot = slot
	_update_active_visual()


func _update_active_visual() -> void:
	for i in SLOT_COUNT:
		_slot_styles[i].border_color = ACTIVE_BORDER if i == _active_slot else IDLE_BORDER


func _update_time() -> void:
	_time_label.text = "Día %d — %s — %s" % [
		TimeManager.day,
		SEASON_NAMES[TimeManager.season],
		TimeManager.get_time_string(),
	]


func _update_gold(new_total: int, _delta: int) -> void:
	_gold_label.text = "Oro: %d" % new_total


func _update_energy(new_total: int, _delta: int) -> void:
	_energy_bar.max_value = GameState.max_energy
	_energy_bar.value = new_total


func _show_toast(text: String) -> void:
	_toast_label.text = text
	_toast.visible = true
	_toast_timer.start()
